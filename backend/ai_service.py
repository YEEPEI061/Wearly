import os
import json
import math
from typing import Dict, List, Optional, Tuple

import numpy as np
from PIL import Image

import torch

# -------------------------------------------------------------------
# Torch / torchvision compatibility patch
# -------------------------------------------------------------------

try:
    lib = torch.library.Library("torchvision", "DEF")
    lib.define(
        "nms(Tensor boxes, Tensor scores, float iou_threshold) -> Tensor"
    )
except Exception:
    pass

from transformers import (
    CLIPModel,
    CLIPProcessor,
)

try:
    from fashn_human_parser import FashnHumanParser
except Exception:
    FashnHumanParser = None


# -------------------------------------------------------------------
# Configuration
# -------------------------------------------------------------------

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

USE_MPS = False

DEVICE = "cpu"

STYLE_LABELS = [
    "casual",
    "smart casual",
    "formal",
    "sporty",
    "streetwear",
    "minimalist",
    "elegant",
    "vintage",
    "preppy",
    "relaxed",
]

COLOR_LABELS = [
    "black",
    "white",
    "light gray",
    "dark gray",
    "beige",
    "brown",
    "navy blue",
    "blue",
    "green",
    "red",
    "orange",
    "yellow",
    "pink",
    "purple",
    "multicolor",
]

CATEGORY_MAP = {
    "top": "upper",
    "shirt": "upper",
    "t-shirt": "upper",
    "blouse": "upper",
    "sweater": "upper",
    "jacket": "upper",
    "coat": "upper",

    "pants": "lower",
    "trousers": "lower",
    "jeans": "lower",
    "shorts": "lower",
    "skirt": "lower",

    "dress": "full",
    "jumpsuit": "full",
}


# -------------------------------------------------------------------
# Global models
# -------------------------------------------------------------------

_parser = None
_clip_processor = None
_clip_model = None
_fashion_processor = None
_fashion_model = None


# -------------------------------------------------------------------
# Model loading
# -------------------------------------------------------------------

def load_models():
    global _parser
    global _clip_processor
    global _clip_model
    global _fashion_processor
    global _fashion_model

    if _parser is None and FashnHumanParser is not None:
        try:
            print("Loading FASHN Human Parser...")
            _parser = FashnHumanParser()
            print("✓ FASHN Human Parser loaded")
        except Exception as e:
            print(f"⚠ FASHN parser unavailable: {e}")
            _parser = None

    if _clip_model is None:
        try:
            print("Loading CLIP...")

            model_name = "openai/clip-vit-base-patch32"

            _clip_processor = CLIPProcessor.from_pretrained(
                model_name
            )

            _clip_model = CLIPModel.from_pretrained(
                model_name,
                use_safetensors=True,
            )

            _clip_model.to(DEVICE)
            _clip_model.eval()

            print("✓ CLIP loaded")

        except Exception as e:
            print(f"⚠ CLIP unavailable: {e}")

    # FashionCLIP
    if _fashion_model is None:
        try:
            print("Loading FashionCLIP...")

            from transformers import CLIPVisionModelWithProjection

            fashion_name = "patrickjohncyh/fashion-clip"

            _fashion_processor = CLIPProcessor.from_pretrained(
                fashion_name
            )

            _fashion_model = CLIPVisionModelWithProjection.from_pretrained(
                fashion_name,
                use_safetensors=True,
            )

            _fashion_model.to(DEVICE)
            _fashion_model.eval()

            print("✓ FashionCLIP loaded")

        except Exception as e:
            print(f"⚠ FashionCLIP unavailable: {e}")
            _fashion_model = None


# -------------------------------------------------------------------
# Image utilities
# -------------------------------------------------------------------

def load_image(image_path: str) -> Image.Image:
    return Image.open(image_path).convert("RGB")


def cosine_similarity(a, b) -> float:
    a = np.asarray(a, dtype=np.float32)
    b = np.asarray(b, dtype=np.float32)

    denominator = (
        np.linalg.norm(a) * np.linalg.norm(b)
    )

    if denominator == 0:
        return 0.0

    return float(np.dot(a, b) / denominator)


# -------------------------------------------------------------------
# FASHN clothing segmentation
# -------------------------------------------------------------------

def detect_clothing(image_path: str) -> Dict:
    """
    Uses FASHN Human Parser semantic segmentation.

    Returns:
        category: top / pants / skirt / dress
        confidence: segmentation confidence estimate
        bbox: bounding box of the detected clothing region
        mask: segmentation mask
    """

    image = load_image(image_path)

    if _parser is None:
        return {
            "category": "top",
            "confidence": 0.0,
            "bbox": None,
            "mask": None,
        }

    try:
        # FASHN Human Parser uses .predict()
        segmentation = _parser.predict(image)

        if segmentation is None:
            raise ValueError("FASHN returned no segmentation result.")

        # -----------------------------------------------------------
        # Get FASHN label mapping
        # -----------------------------------------------------------

        labels = _parser.get_labels()

        # -----------------------------------------------------------
        # Count pixels for each clothing label
        # -----------------------------------------------------------

        clothing_labels = {
            "top",
            "pants",
            "skirt",
            "dress",
        }

        label_pixel_counts = {}

        for label_id, label_name in labels.items():
            label_name = str(label_name).lower()

            if label_name in clothing_labels:
                count = int(
                    np.sum(segmentation == label_id)
                )

                if count > 0:
                    label_pixel_counts[label_name] = count

        # -----------------------------------------------------------
        # No clothing detected
        # -----------------------------------------------------------

        if not label_pixel_counts:
            print(
                "⚠ FASHN did not detect supported clothing labels."
            )

            return {
                "category": "top",
                "confidence": 0.0,
                "bbox": None,
                "mask": None,
            }

        # -----------------------------------------------------------
        # Select clothing category with most pixels
        # -----------------------------------------------------------

        category = max(
            label_pixel_counts,
            key=label_pixel_counts.get,
        )

        mask = segmentation == next(
            label_id
            for label_id, label_name in labels.items()
            if str(label_name).lower() == category
        )

        # -----------------------------------------------------------
        # Calculate bounding box from mask
        # -----------------------------------------------------------

        ys, xs = np.where(mask)

        if len(xs) == 0 or len(ys) == 0:
            bbox = None
        else:
            x1 = int(xs.min())
            y1 = int(ys.min())
            x2 = int(xs.max()) + 1
            y2 = int(ys.max()) + 1

            bbox = [x1, y1, x2, y2]

        # -----------------------------------------------------------
        # Calculate approximate confidence
        #
        # This is NOT model probability.
        # It represents how dominant the selected clothing
        # segmentation is among the supported clothing labels.
        # -----------------------------------------------------------

        total_clothing_pixels = sum(
            label_pixel_counts.values()
        )

        if total_clothing_pixels > 0:
            confidence = (
                label_pixel_counts[category]
                / total_clothing_pixels
            )
        else:
            confidence = 0.0

        confidence = float(
            np.clip(
                confidence,
                0.0,
                1.0,
            )
        )

        print(
            f"✓ FASHN detected: "
            f"{category} "
            f"(confidence={confidence:.3f})"
        )

        return {
            "category": category,
            "confidence": confidence,
            "bbox": bbox,
            "mask": mask,
        }

    except Exception as e:
        print(
            f"⚠ Clothing detection failed: {e}"
        )

        return {
            "category": "top",
            "confidence": 0.0,
            "bbox": None,
            "mask": None,
        }
    
# -------------------------------------------------------------------
# Clothing image processing
# -------------------------------------------------------------------
def _crop_from_bbox(
    image: Image.Image,
    bbox,
) -> Image.Image:

    if bbox:
        try:
            x1, y1, x2, y2 = map(
                int,
                bbox,
            )

            x1 = max(0, x1)
            y1 = max(0, y1)
            x2 = min(image.width, x2)
            y2 = min(image.height, y2)

            return image.crop(
                (x1, y1, x2, y2)
            )

        except Exception:
            pass

    return image

def create_processed_image(
    image_path: str,
    output_path: str,
) -> Dict:

    image = load_image(image_path)

    detection = detect_clothing(image_path)

    bbox = detection.get("bbox")
    mask = detection.get("mask")

    # ---------------------------------------------------------------
    # Extract clothing using segmentation mask
    # ---------------------------------------------------------------

    if mask is not None:
        try:
            # Convert FASHN mask to PIL grayscale mask.
            mask_image = Image.fromarray(
                (mask.astype("uint8") * 255)
            ).convert("L")

            # Make sure mask matches original image size.
            if mask_image.size != image.size:
                mask_image = mask_image.resize(
                    image.size,
                    Image.Resampling.NEAREST,
                )

            # Convert original image to RGBA.
            image_rgba = image.convert("RGBA")

            # Create transparent image.
            clothing = Image.new(
                "RGBA",
                image_rgba.size,
                (0, 0, 0, 0),
            )

            # Keep only the detected clothing.
            clothing.paste(
                image_rgba,
                (0, 0),
                mask_image,
            )

            # Find actual visible clothing area.
            clothing_bbox = clothing.getbbox()

            if clothing_bbox:
                clothing = clothing.crop(
                    clothing_bbox
                )
            else:
                clothing = image_rgba

        except Exception as e:
            print(
                f"⚠️ Mask processing failed: {e}"
            )

            # Fallback to bounding-box crop.
            clothing = _crop_from_bbox(
                image,
                bbox,
            )

    else:
        # -----------------------------------------------------------
        # Fallback if segmentation mask is unavailable
        # -----------------------------------------------------------

        clothing = _crop_from_bbox(
            image,
            bbox,
        )

    # ---------------------------------------------------------------
    # Consistent Wearly canvas
    # ---------------------------------------------------------------

    canvas_size = 1000

    background = Image.new(
        "RGBA",
        (canvas_size, canvas_size),
        (248, 247, 244, 255),
    )

    # Resize clothing while keeping aspect ratio.
    clothing.thumbnail(
        (850, 850),
        Image.Resampling.LANCZOS,
    )

    # Centre clothing.
    x = (
        canvas_size - clothing.width
    ) // 2

    y = (
        canvas_size - clothing.height
    ) // 2

    background.alpha_composite(
        clothing,
        (x, y),
    )

    # Save as JPEG.
    background.convert("RGB").save(
        output_path,
        "JPEG",
        quality=95,
    )

    return {
        "category": detection["category"],
        "confidence": detection["confidence"],
        "bbox": bbox,
    }

# -------------------------------------------------------------------
# CLIP style classification
# -------------------------------------------------------------------

def classify_with_clip(
    image_path: str,
    labels: List[str],
) -> Tuple[str, float]:

    if _clip_model is None or _clip_processor is None:
        return labels[0], 0.0

    image = load_image(image_path)

    prompts = [
        f"a photo of a {label} fashion clothing item"
        for label in labels
    ]

    try:
        inputs = _clip_processor(
            text=prompts,
            images=image,
            return_tensors="pt",
            padding=True,
        )

        inputs = {
            key: value.to(DEVICE)
            for key, value in inputs.items()
        }

        with torch.no_grad():
            outputs = _clip_model(**inputs)

        logits = outputs.logits_per_image[0]

        probabilities = torch.softmax(
            logits,
            dim=0,
        )

        index = int(
            torch.argmax(probabilities).item()
        )

        confidence = _safe_float(
            probabilities[index].item(),
            default=0.0,
        )

        return labels[index], confidence

    except Exception as e:
        print(
            f"⚠ CLIP classification failed: {e}"
        )

        return labels[0], 0.0
# -------------------------------------------------------------------
# FashionCLIP embedding
# -------------------------------------------------------------------

def create_fashion_embedding(
    image_path: str,
) -> Optional[List[float]]:

    if _fashion_model is None or _fashion_processor is None:
        return None

    image = load_image(image_path)

    try:
        inputs = _fashion_processor(
            images=image,
            return_tensors="pt",
        )

        inputs = {
            key: value.to(DEVICE)
            for key, value in inputs.items()
        }

        with torch.no_grad():
            # Important:
            # Do not use get_image_features().
            #
            # Your Mac previously had a bus error around
            # FashionCLIP visual_projection().
            outputs = _fashion_model.vision_model(
                pixel_values=inputs["pixel_values"]
            )

            embedding = outputs.pooler_output

            embedding = torch.nn.functional.normalize(
                embedding,
                dim=-1,
            )

        return embedding[0].cpu().numpy().tolist()

    except Exception as e:
        print(
            f"⚠ FashionCLIP embedding failed: {e}"
        )

        return None


# -------------------------------------------------------------------
# Deterministic color fallback
# -------------------------------------------------------------------

def detect_basic_color(
    image_path: str,
) -> Tuple[str, float]:

    image = load_image(image_path)

    image = image.resize((100, 100))

    pixels = np.asarray(image).reshape(
        -1,
        3,
    )

    r = pixels[:, 0]
    g = pixels[:, 1]
    b = pixels[:, 2]

    brightness = (
        0.299 * r +
        0.587 * g +
        0.114 * b
    )

    mean_r = float(np.mean(r))
    mean_g = float(np.mean(g))
    mean_b = float(np.mean(b))

    mean_brightness = float(
        np.mean(brightness)
    )

    if mean_brightness < 45:
        return "black", 0.85

    if mean_brightness > 225:
        return "white", 0.85

    if (
        abs(mean_r - mean_g) < 15
        and abs(mean_g - mean_b) < 15
    ):
        if mean_brightness < 130:
            return "dark gray", 0.75

        return "light gray", 0.75

    if mean_r > mean_b * 1.35:
        if mean_g > mean_b * 1.2:
            return "orange", 0.65

        return "red", 0.65

    if mean_b > mean_r * 1.25:
        if mean_b > mean_g * 1.15:
            return "blue", 0.65

        return "purple", 0.60

    if mean_g > mean_r * 1.2:
        return "green", 0.65

    if (
        mean_r > 120
        and mean_g > 100
        and mean_b < 100
    ):
        return "brown", 0.60

    return "multicolor", 0.40

# -------------------------------------------------------------------
# Helper
# -------------------------------------------------------------------


def _safe_float(value, default=0.0) -> float:
    """
    Convert a value into JSON-safe finite float.
    """

    try:
        value = float(value)

        if not math.isfinite(value):
            return default

        return value

    except (TypeError, ValueError):
        return default

def _safe_embedding(embedding) -> List[float]:
    """
    Convert an embedding into a JSON-safe list of finite floats.
    """

    if embedding is None:
        return []

    try:
        array = np.asarray(
            embedding,
            dtype=np.float32,
        )

        array = np.nan_to_num(
            array,
            nan=0.0,
            posinf=0.0,
            neginf=0.0,
        )

        return array.astype(
            np.float32
        ).tolist()

    except Exception as e:
        print(
            f"⚠ Embedding sanitisation failed: {e}"
        )
        return []
    
# -------------------------------------------------------------------
# Full clothing analysis
# -------------------------------------------------------------------

def analyse_clothing(
    image_path: str,
) -> Dict:

    load_models()

    detection = detect_clothing(
        image_path
    )

    detected_category = detection["category"]

    style, style_confidence = classify_with_clip(
        image_path,
        STYLE_LABELS,
    )

    color, color_confidence = classify_with_clip(
        image_path,
        COLOR_LABELS,
    )

    # Fallback color detector
    if color_confidence < 0.20:
        color, color_confidence = detect_basic_color(
            image_path
        )

    embedding = create_fashion_embedding(
        image_path
    )

    return {
        "category": detected_category,
        "category_confidence": detection[
            "confidence"
        ],
        "color": color,
        "color_confidence": color_confidence,
        "style": style,
        "style_confidence": style_confidence,
        "embedding": _safe_embedding(embedding),
        "model_name": (
            "FASHN Human Parser + "
            "OpenAI CLIP + FashionCLIP"
        ),
    }


# -------------------------------------------------------------------
# Compatibility helpers
# -------------------------------------------------------------------

def category_group(category: str) -> str:

    category = category.lower().strip()

    return CATEGORY_MAP.get(
        category,
        category,
    )


def compare_embeddings(
    embedding_a,
    embedding_b,
) -> float:

    if not embedding_a or not embedding_b:
        return 0.0

    try:
        return cosine_similarity(
            embedding_a,
            embedding_b,
        )

    except Exception:
        return 0.0