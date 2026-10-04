from fastapi import (
    FastAPI,
    UploadFile,
    File,
    HTTPException,
    Form,
)

from fastapi.responses import FileResponse

from PIL import (
    Image,
    ImageOps,
    ImageFilter,
)

from pathlib import Path
from itertools import product

import uuid
import io
import json
import threading
import random

from datetime import datetime, timezone

import numpy as np

import torch
from pydantic import BaseModel


# ============================================================
# TORCHVISION MACOS COMPATIBILITY PATCH
# ============================================================

try:
    lib = torch.library.Library("torchvision", "DEF")

    lib.define(
        "nms(Tensor boxes, Tensor scores, float iou_threshold) -> Tensor"
    )

    print("Torchvision NMS compatibility patch applied.")

except Exception as e:
    print("Torchvision NMS patch:", e)


# ============================================================
# FASHN HUMAN PARSER
# ============================================================

from fashn_human_parser import FashnHumanParser


# ============================================================
# TRANSFORMERS
# ============================================================

from transformers import (
    CLIPProcessor,
    CLIPModel,
)


# ============================================================
# APP
# ============================================================

app = FastAPI(
    title="AI Wardrobe MVP"
)


# ============================================================
# DIRECTORIES
# ============================================================

BASE = Path(__file__).parent

UPLOAD_DIR = BASE / "uploads"
PROCESSED_DIR = BASE / "processed"
DEBUG_DIR = BASE / "debug"

WARDROBE_FILE = BASE / "wardrobe.json"

# NEW — OUTFIT FEEDBACK
PREFERENCES_FILE = BASE / "preferences.json"


UPLOAD_DIR.mkdir(exist_ok=True)
PROCESSED_DIR.mkdir(exist_ok=True)
DEBUG_DIR.mkdir(exist_ok=True)


USE_MPS = False


try:
    torch.set_num_threads(1)
except Exception:
    pass


try:
    torch.set_num_interop_threads(1)
except Exception:
    pass


if USE_MPS and torch.backends.mps.is_available():
    DEVICE = torch.device("mps")
else:
    DEVICE = torch.device("cpu")


print("========================================")
print("AI WARDROBE BACKEND")
print("========================================")
print("PyTorch:", torch.__version__)
print("Device:", DEVICE)
print("MPS available:", torch.backends.mps.is_available())
print("========================================")


# ============================================================
# LOCKS
# ============================================================

# Prevent multiple FashionCLIP inference operations
# from running simultaneously.

FASHION_LOCK = threading.Lock()


# Prevent multiple CLIP style/color operations
# from running simultaneously.

STYLE_COLOR_LOCK = threading.Lock()


# Prevent simultaneous reads/writes to wardrobe.json.

WARDROBE_LOCK = threading.Lock()


# NEW — OUTFIT FEEDBACK
# Prevent simultaneous reads/writes to preferences.json.

PREFERENCES_LOCK = threading.Lock()


# ============================================================
# GENERATED OUTFIT MEMORY
# ============================================================

GENERATED_OUTFITS = []


def reset_generated_outfits():
    """
    Clear generated outfit history.

    This is called whenever the wardrobe changes.
    """

    global GENERATED_OUTFITS

    GENERATED_OUTFITS = []

    print(
        "Generated outfit history cleared."
    )


# ============================================================
# NEW — OUTFIT FEEDBACK STORAGE
# ============================================================

# ============================================================
# OUTFIT FEEDBACK STORAGE
# ============================================================

def load_preferences():
    """
    Load saved Like / Dislike feedback.

    If preferences.json does not exist yet,
    return an empty preference structure.
    """

    if not PREFERENCES_FILE.exists():
        return {
            "liked_outfits": [],
            "disliked_outfits": [],
        }

    try:
        with open(
            PREFERENCES_FILE,
            "r",
            encoding="utf-8"
        ) as f:

            data = json.load(f)

        if not isinstance(data, dict):
            return {
                "liked_outfits": [],
                "disliked_outfits": [],
            }

        data.setdefault(
            "liked_outfits",
            []
        )

        data.setdefault(
            "disliked_outfits",
            []
        )

        return data

    except json.JSONDecodeError as e:

        print(
            "PREFERENCES LOAD ERROR:",
            repr(e)
        )

        return {
            "liked_outfits": [],
            "disliked_outfits": [],
        }

    except Exception as e:

        print(
            "PREFERENCES LOAD ERROR:",
            repr(e)
        )

        return {
            "liked_outfits": [],
            "disliked_outfits": [],
        }


def save_preferences(data):
    """
    Save Like / Dislike feedback safely.

    The data is first written to a temporary file.
    Once writing is complete, it replaces preferences.json.
    """

    try:

        temp_file = PREFERENCES_FILE.with_suffix(".tmp")

        with open(
            temp_file,
            "w",
            encoding="utf-8"
        ) as f:

            json.dump(
                data,
                f,
                indent=2,
                ensure_ascii=False
            )

        # Replace the old file only after
        # the new JSON has been completely written.
        temp_file.replace(PREFERENCES_FILE)

        return True

    except Exception as e:

        print(
            "PREFERENCES SAVE ERROR:",
            repr(e)
        )

        return False
    
# ============================================================
# NEW — OUTFIT FEEDBACK REQUEST MODEL
# ============================================================

class OutfitFeedback(BaseModel):

    outfit_key: list[str]

    feedback: str


# ============================================================
# HUMAN PARSER
# ============================================================

print(
    "Loading FASHN Human Parser..."
)

parser = FashnHumanParser()

print(
    "FASHN Human Parser loaded."
)


# ============================================================
# FASHIONCLIP
# ============================================================

FASHION_CLIP_MODEL = (
    "patrickjohncyh/fashion-clip"
)


print(
    "Loading FashionCLIP..."
)


fashion_processor = CLIPProcessor.from_pretrained(
    FASHION_CLIP_MODEL
)


fashion_model = CLIPModel.from_pretrained(
    FASHION_CLIP_MODEL
)


fashion_model = fashion_model.to(
    DEVICE
)


fashion_model.eval()


print(
    "FashionCLIP loaded."
)


print(
    "FashionCLIP vision encoder will be used "
    "WITHOUT visual_projection()."
)


# ============================================================
# STANDARD CLIP
# ============================================================

STYLE_COLOR_CLIP_MODEL = (
    "openai/clip-vit-base-patch32"
)


print(
    "Loading standard CLIP for AI style/color analysis..."
)


style_color_processor = CLIPProcessor.from_pretrained(
    STYLE_COLOR_CLIP_MODEL
)


style_color_model = CLIPModel.from_pretrained(
    STYLE_COLOR_CLIP_MODEL,
    use_safetensors=True
)


style_color_model = style_color_model.to(
    DEVICE
)


style_color_model.eval()


print(
    "Standard CLIP loaded."
)


print(
    "Standard CLIP will handle AI style/color classification."
)


# ============================================================
# FASHIONCLIP IMAGE EMBEDDING
# ============================================================

@torch.no_grad()
def get_fashion_image_features(
    image: Image.Image
):
    """
    Extract FashionCLIP visual features.

    IMPORTANT:
    We intentionally DO NOT use:

        fashion_model.get_image_features()

    because your Mac crashes with a bus error during
    FashionCLIP's visual_projection().

    Instead we use:

        fashion_model.vision_model()

    and take:

        vision_outputs.pooler_output

    as the visual embedding.
    """

    print(
        "FashionCLIP: preparing image..."
    )

    image = image.convert("RGB")

    inputs = fashion_processor(
        images=image,
        return_tensors="pt"
    )

    pixel_values = (
        inputs["pixel_values"]
        .to(DEVICE)
    )

    print(
        "FashionCLIP: running vision encoder..."
    )

    vision_outputs = (
        fashion_model.vision_model(
            pixel_values=pixel_values
        )
    )

    print(
        "FashionCLIP: vision encoder finished."
    )

    image_features = (
        vision_outputs.pooler_output
    )

    print(
        "FashionCLIP: using pooled vision features."
    )

    image_features = (
        image_features
        /
        (
            image_features.norm(
                dim=-1,
                keepdim=True
            )
            + 1e-8
        )
    )

    print(
        "FashionCLIP: image embedding complete."
    )

    return image_features


# ============================================================
# AI STYLE LABELS
# ============================================================

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


# ============================================================
# AI COLOR LABELS
# ============================================================

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


# ============================================================
# AI STYLE PROMPTS
# ============================================================

STYLE_PROMPTS = [

    f"a photo of {style} clothing"

    for style in STYLE_LABELS

]


# ============================================================
# AI COLOR PROMPTS
# ============================================================

COLOR_PROMPTS = [

    f"a photo of {color} clothing"

    for color in COLOR_LABELS

]


# ============================================================
# CLIP CLASSIFICATION
# ============================================================

@torch.no_grad()
def classify_image_with_clip(
    image: Image.Image,
    labels,
    prompts,
    classification_name
):
    """
    Use standard CLIP zero-shot classification.
    """

    print(
        f"AI {classification_name}: starting..."
    )

    image = image.convert(
        "RGB"
    )

    inputs = style_color_processor(
        text=prompts,
        images=image,
        return_tensors="pt",
        padding=True
    )

    inputs = {
        key: value.to(DEVICE)
        for key, value in inputs.items()
    }

    outputs = style_color_model(
        **inputs
    )

    logits_per_image = (
        outputs.logits_per_image
    )

    probabilities = torch.softmax(
        logits_per_image,
        dim=1
    )[0]

    best_index = int(
        torch.argmax(
            probabilities
        ).item()
    )

    best_label = labels[
        best_index
    ]

    best_confidence = float(
        probabilities[
            best_index
        ].item()
    )

    scores = {}

    for index, label in enumerate(
        labels
    ):

        scores[label] = round(
            float(
                probabilities[index].item()
            ),
            4
        )

    print(
        f"AI {classification_name}:",
        best_label
    )

    print(
        f"AI {classification_name} confidence:",
        round(
            best_confidence,
            4
        )
    )

    return {

        "label":
            best_label,

        "confidence":
            best_confidence,

        "scores":
            scores,

    }


# ============================================================
# AI COLOR CLASSIFICATION
# ============================================================

def classify_color_with_ai(
    image: Image.Image
):
    """
    AI-assisted color classification.
    """

    return classify_image_with_clip(
        image=image,
        labels=COLOR_LABELS,
        prompts=COLOR_PROMPTS,
        classification_name="COLOR"
    )


# ============================================================
# AI STYLE CLASSIFICATION
# ============================================================

def classify_style_with_ai(
    image: Image.Image
):
    """
    AI-assisted clothing style classification.
    """

    return classify_image_with_clip(
        image=image,
        labels=STYLE_LABELS,
        prompts=STYLE_PROMPTS,
        classification_name="STYLE"
    )


# ============================================================
# FASHIONCLIP ZERO-SHOT CLASSIFICATION
# ============================================================

def classify_with_fashionclip(
    image,
    labels
):
    """
    FashionCLIP zero-shot classification remains disabled.

    We use standard CLIP for style/color classification
    instead.
    """

    raise RuntimeError(
        "FashionCLIP zero-shot classification is disabled. "
        "Standard CLIP is used for style/color classification."
    )


# ============================================================
# FASHN LABELS
# ============================================================

LABELS = {

    0: "background",

    1: "face",

    2: "hair",

    3: "top",

    4: "dress",

    5: "skirt",

    6: "pants",

    7: "belt",

    8: "bag",

    9: "hat",

    10: "scarf",

    11: "glasses",

    12: "arms",

    13: "hands",

    14: "legs",

    15: "feet",

    16: "torso",

    17: "jewelry",

}


# ============================================================
# CATEGORY LABELS
# ============================================================

CATEGORY_LABELS = {

    "upper": {
        3,
    },

    "lower": {
        5,
        6,
    },

    "full": {
        4,
    },

}


CATEGORY_NAMES = {

    "upper":
        "Upper",

    "lower":
        "Lower",

    "full":
        "Full Body",

}


# ============================================================
# WARDROBE
# ============================================================

def load_wardrobe():

    with WARDROBE_LOCK:

        if not WARDROBE_FILE.exists():

            return []

        try:

            with open(
                WARDROBE_FILE,
                "r",
                encoding="utf-8"
            ) as f:

                data = json.load(f)

                if not isinstance(
                    data,
                    list
                ):

                    return []

                return data

        except Exception as e:

            print(
                "WARDROBE LOAD ERROR:",
                repr(e)
            )

            return []


def save_wardrobe(
    items
):

    with WARDROBE_LOCK:

        with open(
            WARDROBE_FILE,
            "w",
            encoding="utf-8"
        ) as f:

            json.dump(
                items,
                f,
                indent=2,
                ensure_ascii=False
            )


# ============================================================
# COLOR DETECTION FALLBACK
# ============================================================

def detect_color(
    image: Image.Image
) -> str:

    image = image.convert(
        "RGBA"
    )

    pixels = []

    for r, g, b, a in image.getdata():

        if a < 180:
            continue

        pixels.append(
            (
                r,
                g,
                b
            )
        )

    if not pixels:
        return "unknown"

    if len(pixels) > 20000:

        step = max(
            1,
            len(pixels) // 20000
        )

        pixels = pixels[
            ::step
        ]

    arr = np.array(
        pixels,
        dtype=np.float32
    )

    avg_r = float(
        np.mean(arr[:, 0])
    )

    avg_g = float(
        np.mean(arr[:, 1])
    )

    avg_b = float(
        np.mean(arr[:, 2])
    )

    brightness = (
        avg_r +
        avg_g +
        avg_b
    ) / 3

    maximum = max(
        avg_r,
        avg_g,
        avg_b
    )

    minimum = min(
        avg_r,
        avg_g,
        avg_b
    )

    saturation = (
        maximum -
        minimum
    )

    if brightness < 45:
        return "black"

    if (
        saturation < 28
        and brightness < 100
    ):
        return "dark gray"

    if saturation < 30:

        if brightness < 160:
            return "gray"

        return "light gray"

    if (
        brightness > 210
        and saturation < 35
    ):
        return "white"

    if (
        avg_r > 150
        and avg_g > 125
        and avg_b > 90
        and avg_r > avg_b * 1.15
    ):
        return "beige"

    if (
        avg_r > avg_g * 1.25
        and avg_r > avg_b * 1.25
    ):
        return "red"

    if (
        avg_g > avg_r * 1.20
        and avg_g > avg_b * 1.10
    ):
        return "green"

    if (
        avg_b > avg_r * 1.20
        and avg_b > avg_g * 1.05
    ):
        return "blue"

    if (
        avg_r > 150
        and avg_g > 130
        and avg_b < 110
    ):
        return "yellow"

    if (
        avg_r > 160
        and avg_g > 80
        and avg_g < 160
        and avg_b < 110
    ):
        return "orange"

    if (
        avg_r > avg_g * 1.20
        and avg_b > avg_g * 1.20
    ):
        return "purple"

    if (
        avg_r > 170
        and avg_b > 120
        and avg_g < 150
    ):
        return "pink"

    return "multicolor"


# ============================================================
# CATEGORY NAME
# ============================================================

def category_to_display_name(
    category
):

    return CATEGORY_NAMES.get(
        category,
        "Clothing"
    )


# ============================================================
# HUMAN PARSING
# ============================================================

def get_parsing_map(
    image: Image.Image
):

    print(
        "Running human parsing..."
    )

    parsing = parser.predict(
        image
    )

    if parsing is None:

        raise ValueError(
            "Human parser returned no result."
        )

    parsing = np.asarray(
        parsing
    )

    print(
        "PARSING SHAPE:",
        parsing.shape
    )

    print(
        "PARSING CLASSES:",
        np.unique(parsing)
    )

    return parsing


# ============================================================
# CLOTHING MASK
# ============================================================

def create_clothing_mask(
    parsing_map,
    category,
    original_size
):

    allowed_labels = (
        CATEGORY_LABELS.get(
            category
        )
    )

    if not allowed_labels:

        raise ValueError(
            f"Unknown category: {category}"
        )

    print(
        "CATEGORY:",
        category
    )

    print(
        "KEEPING LABELS:",
        [
            LABELS.get(
                label,
                str(label)
            )
            for label in allowed_labels
        ]
    )

    mask = np.zeros(
        parsing_map.shape,
        dtype=np.uint8
    )

    for label in allowed_labels:

        mask[
            parsing_map == label
        ] = 255

    mask_image = Image.fromarray(
        mask,
        mode="L"
    )

    if mask_image.size != original_size:

        mask_image = mask_image.resize(
            original_size,
            Image.Resampling.NEAREST
        )

    mask_image = mask_image.filter(
        ImageFilter.GaussianBlur(
            radius=0.7
        )
    )

    minimum, maximum = (
        mask_image.getextrema()
    )

    print(
        "MASK RANGE:",
        minimum,
        maximum
    )

    if maximum == 0:

        raise ValueError(
            "The human parser could not find "
            f"a {category} clothing item."
        )

    return mask_image


# ============================================================
# CLOTHING EXTRACTION
# ============================================================

def create_aesthetic_clothing_image(
    input_bytes,
    output_path,
    category,
    item_id
):

    original = Image.open(
        io.BytesIO(input_bytes)
    )

    original = ImageOps.exif_transpose(
        original
    ).convert("RGBA")

    print(
        "ORIGINAL SIZE:",
        original.size
    )

    parsing_map = get_parsing_map(
        original.convert("RGB")
    )

    debug_parsing = Image.fromarray(
        parsing_map.astype(np.uint8),
        mode="L"
    )

    debug_parsing.save(
        DEBUG_DIR /
        f"{item_id}_parsing.png"
    )

    mask = create_clothing_mask(
        parsing_map,
        category,
        original.size
    )

    mask.save(
        DEBUG_DIR /
        f"{item_id}_mask.png"
    )

    clothing = original.copy()

    clothing.putalpha(
        mask
    )

    bbox = mask.getbbox()

    if bbox is None:

        raise ValueError(
            "No clothing was detected."
        )

    print(
        "CLOTHING BBOX:",
        bbox
    )

    clothing = clothing.crop(
        bbox
    )

    clothing.thumbnail(
        (800, 800),
        Image.Resampling.LANCZOS
    )

    canvas = Image.new(
        "RGBA",
        (1000, 1000),
        (
            248,
            247,
            244,
            255
        )
    )

    x = (
        1000 -
        clothing.width
    ) // 2

    y = (
        1000 -
        clothing.height
    ) // 2

    alpha = clothing.getchannel(
        "A"
    )

    shadow_alpha = alpha.point(
        lambda p:
        int(p * 0.14)
    )

    shadow = Image.new(
        "RGBA",
        clothing.size,
        (
            0,
            0,
            0,
            0
        )
    )

    shadow.putalpha(
        shadow_alpha
    )

    canvas.alpha_composite(
        shadow,
        (
            x + 8,
            y + 12
        )
    )

    canvas.alpha_composite(
        clothing,
        (
            x,
            y
        )
    )

    canvas.convert(
        "RGB"
    ).save(
        output_path,
        "JPEG",
        quality=95
    )

    print(
        "PROCESSED IMAGE:",
        output_path
    )

    return clothing


# ============================================================
# COMPLETE AI ANALYSIS
# ============================================================

@torch.no_grad()
def analyze_clothing_with_ai(
    image: Image.Image
):

    print(
        "========================================"
    )

    print(
        "AI CLOTHING ANALYSIS"
    )

    print(
        "========================================"
    )

    image = image.convert(
        "RGB"
    )

    print(
        "FashionCLIP: creating image embedding..."
    )

    image_features = (
        get_fashion_image_features(
            image
        )
    )

    embedding = (
        image_features[0]
        .detach()
        .cpu()
        .float()
        .tolist()
    )

    print(
        "FashionCLIP embedding complete."
    )

    print(
        "Running AI style classification..."
    )

    style_result = (
        classify_style_with_ai(
            image
        )
    )

    print(
        "Running AI color classification..."
    )

    color_result = (
        classify_color_with_ai(
            image
        )
    )

    print(
        "========================================"
    )

    print(
        "AI ANALYSIS COMPLETE"
    )

    print(
        "STYLE:",
        style_result["label"]
    )

    print(
        "STYLE CONFIDENCE:",
        style_result["confidence"]
    )

    print(
        "COLOR:",
        color_result["label"]
    )

    print(
        "COLOR CONFIDENCE:",
        color_result["confidence"]
    )

    print(
        "========================================"
    )

    return {

        "embedding":
            embedding,

        "style":
            style_result["label"],

        "style_confidence":
            style_result["confidence"],

        "style_scores":
            style_result["scores"],

        "ai_color":
            color_result["label"],

        "color_confidence":
            color_result["confidence"],

        "color_scores":
            color_result["scores"],

    }


# ============================================================
# COSINE SIMILARITY
# ============================================================

def cosine_similarity(
    a,
    b
):

    a = np.asarray(
        a,
        dtype=np.float32
    )

    b = np.asarray(
        b,
        dtype=np.float32
    )

    denominator = (
        np.linalg.norm(a)
        *
        np.linalg.norm(b)
    )

    if denominator == 0:

        return 0.0

    return float(
        np.dot(a, b)
        /
        denominator
    )


# ============================================================
# LOAD PROCESSED IMAGE
# ============================================================

def load_processed_image(
    item
):

    image_url = item.get(
        "image_url",
        ""
    )

    filename = Path(
        image_url
    ).name

    path = (
        PROCESSED_DIR /
        filename
    )

    if not path.exists():

        return None

    try:

        return Image.open(
            path
        ).convert("RGB")

    except Exception as e:

        print(
            "PROCESSED IMAGE LOAD ERROR:",
            repr(e)
        )

        return None


# ============================================================
# STAGE 2 — USER PREFERENCE LEARNING
# ============================================================

def get_feedback_item_ids(feedback_outfits):
    """
    Extract unique wardrobe item IDs from a list of
    liked/disliked outfit keys.
    """

    item_ids = set()

    for outfit_key in feedback_outfits:

        if not isinstance(outfit_key, list):
            continue

        for item_id in outfit_key:

            if isinstance(item_id, str):
                item_ids.add(item_id)

    return item_ids


def get_feedback_items(
    wardrobe,
    feedback_outfits
):
    """
    Convert saved outfit IDs into actual wardrobe items.
    """

    item_map = {
        item.get("id"): item
        for item in wardrobe
        if item.get("id")
    }

    items = []

    for item_id in get_feedback_item_ids(
        feedback_outfits
    ):

        item = item_map.get(item_id)

        if item is not None:
            items.append(item)

    return items


def calculate_attribute_preference(
    liked_items,
    disliked_items,
    attribute
):
    """
    Calculate preference strength for an attribute.

    Example:

        black:
            liked = 4
            disliked = 1

        preference = +0.60

    Range:

        -1.0 = strongly disliked
         0.0 = neutral
        +1.0 = strongly liked
    """

    liked_counts = {}
    disliked_counts = {}

    for item in liked_items:

        value = item.get(attribute)

        if not value:
            continue

        value = str(value).lower()

        liked_counts[value] = (
            liked_counts.get(value, 0) + 1
        )

    for item in disliked_items:

        value = item.get(attribute)

        if not value:
            continue

        value = str(value).lower()

        disliked_counts[value] = (
            disliked_counts.get(value, 0) + 1
        )

    values = set(
        liked_counts.keys()
    ) | set(
        disliked_counts.keys()
    )

    preferences = {}

    for value in values:

        liked = liked_counts.get(
            value,
            0
        )

        disliked = disliked_counts.get(
            value,
            0
        )

        total = liked + disliked

        if total == 0:
            continue

        # Laplace-like smoothing prevents a single
        # feedback from becoming too extreme.
        preference = (
            liked - disliked
        ) / total

        preferences[value] = {
            "score": round(
                preference,
                4
            ),
            "liked": liked,
            "disliked": disliked,
            "total": total,
        }

    return preferences


def build_preference_profile(
    wardrobe
):
    """
    Build a complete user preference profile
    from saved Like / Dislike feedback.

    This is Stage 2.
    """

    preferences = load_preferences()

    liked_outfits = preferences.get(
        "liked_outfits",
        []
    )

    disliked_outfits = preferences.get(
        "disliked_outfits",
        []
    )

    liked_items = get_feedback_items(
        wardrobe,
        liked_outfits
    )

    disliked_items = get_feedback_items(
        wardrobe,
        disliked_outfits
    )

    total_feedback = (
        len(liked_outfits)
        +
        len(disliked_outfits)
    )

    # --------------------------------------------------------
    # Learning strength
    #
    # The AI becomes more confident as the user provides
    # more feedback.
    # --------------------------------------------------------

    learning_strength = min(
        1.0,
        total_feedback / 10.0
    )

    # --------------------------------------------------------
    # Attribute preferences
    # --------------------------------------------------------

    color_preferences = (
        calculate_attribute_preference(
            liked_items,
            disliked_items,
            "ai_color"
        )
    )

    style_preferences = (
        calculate_attribute_preference(
            liked_items,
            disliked_items,
            "ai_style"
        )
    )

    category_preferences = (
        calculate_attribute_preference(
            liked_items,
            disliked_items,
            "category"
        )
    )

    profile = {

        "total_feedback":
            total_feedback,

        "liked_outfits":
            len(liked_outfits),

        "disliked_outfits":
            len(disliked_outfits),

        "liked_items":
            len(liked_items),

        "disliked_items":
            len(disliked_items),

        "learning_strength":
            round(
                learning_strength,
                4
            ),

        "color_preferences":
            color_preferences,

        "style_preferences":
            style_preferences,

        "category_preferences":
            category_preferences,

    }

    return profile


# ============================================================
# STAGE 4 — FASHIONCLIP USER VISUAL PREFERENCE
# ============================================================

def average_embeddings(items):
    """
    Calculate the average FashionCLIP embedding
    of a group of wardrobe items.
    """

    embeddings = []

    for item in items:

        embedding = item.get(
            "embedding"
        )

        if not embedding:
            continue

        try:

            vector = np.asarray(
                embedding,
                dtype=np.float32
            )

            if vector.size == 0:
                continue

            norm = np.linalg.norm(
                vector
            )

            if norm == 0:
                continue

            vector = vector / norm

            embeddings.append(
                vector
            )

        except Exception as e:

            print(
                "EMBEDDING ERROR:",
                repr(e)
            )

    if not embeddings:
        return None

    average = np.mean(
        np.stack(
            embeddings
        ),
        axis=0
    )

    norm = np.linalg.norm(
        average
    )

    if norm == 0:
        return None

    average = (
        average / norm
    )

    return average


def get_outfit_embedding(
    outfit_items
):
    """
    Create one visual representation of an outfit
    by averaging its clothing FashionCLIP embeddings.
    """

    return average_embeddings(
        outfit_items
    )


def build_visual_preference_profile(
    wardrobe
):
    """
    Build FashionCLIP visual preference information.

    Liked clothing creates a positive visual profile.
    Disliked clothing creates a negative visual profile.
    """

    preferences = load_preferences()

    liked_outfits = preferences.get(
        "liked_outfits",
        []
    )

    disliked_outfits = preferences.get(
        "disliked_outfits",
        []
    )

    liked_items = get_feedback_items(
        wardrobe,
        liked_outfits
    )

    disliked_items = get_feedback_items(
        wardrobe,
        disliked_outfits
    )

    liked_embedding = (
        average_embeddings(
            liked_items
        )
    )

    disliked_embedding = (
        average_embeddings(
            disliked_items
        )
    )

    return {
        "liked_embedding":
            liked_embedding,

        "disliked_embedding":
            disliked_embedding,

        "liked_count":
            len(liked_items),

        "disliked_count":
            len(disliked_items),
    }


def calculate_visual_preference(
    outfit_items,
    visual_profile
):
    """
    Calculate how visually similar an outfit is
    to the user's previous feedback.

    Returns 0.0 - 1.0.

    Higher = more visually aligned with the user's
    previous preferences.
    """

    outfit_embedding = (
        get_outfit_embedding(
            outfit_items
        )
    )

    if outfit_embedding is None:
        return 0.5

    liked_embedding = (
        visual_profile.get(
            "liked_embedding"
        )
    )

    disliked_embedding = (
        visual_profile.get(
            "disliked_embedding"
        )
    )

    has_liked = (
        liked_embedding is not None
    )

    has_disliked = (
        disliked_embedding is not None
    )

    # --------------------------------------------------------
    # No previous visual feedback
    # --------------------------------------------------------

    if not has_liked and not has_disliked:

        return 0.5

    # --------------------------------------------------------
    # Only liked clothing exists
    # --------------------------------------------------------

    if has_liked and not has_disliked:

        similarity = cosine_similarity(
            outfit_embedding,
            liked_embedding
        )

        normalized = (
            similarity + 1.0
        ) / 2.0

        return float(
            max(
                0.0,
                min(
                    1.0,
                    normalized
                )
            )
        )

    # --------------------------------------------------------
    # Only disliked clothing exists
    # --------------------------------------------------------

    if has_disliked and not has_liked:

        similarity = cosine_similarity(
            outfit_embedding,
            disliked_embedding
        )

        normalized = (
            similarity + 1.0
        ) / 2.0

        return float(
            max(
                0.0,
                min(
                    1.0,
                    1.0 - normalized
                )
            )
        )

    # --------------------------------------------------------
    # Both liked and disliked clothing exist
    # --------------------------------------------------------

    liked_similarity = cosine_similarity(
        outfit_embedding,
        liked_embedding
    )

    disliked_similarity = cosine_similarity(
        outfit_embedding,
        disliked_embedding
    )

    liked_normalized = (
        liked_similarity + 1.0
    ) / 2.0

    disliked_normalized = (
        disliked_similarity + 1.0
    ) / 2.0

    # Reward similarity to liked clothing
    # and penalize similarity to disliked clothing.
    score = (
        0.5
        +
        (
            liked_normalized
            -
            disliked_normalized
        )
        * 0.5
    )

    return float(
        max(
            0.0,
            min(
                1.0,
                score
            )
        )
    )


# ============================================================
# ENSURE AI FEATURES
# ============================================================

def ensure_ai_features(
    item
):

    if (
        item.get("embedding")
        and item.get("ai_style")
        and item.get("ai_color")
    ):

        return False

    image = load_processed_image(
        item
    )

    if image is None:

        return False

    print(
        "Generating missing AI features for:",
        item.get("id")
    )

    with FASHION_LOCK:

        with STYLE_COLOR_LOCK:

            result = (
                analyze_clothing_with_ai(
                    image
                )
            )

    item["embedding"] = (
        result["embedding"]
    )

    item["ai_style"] = (
        result["style"]
    )

    item["ai_style_confidence"] = (
        result["style_confidence"]
    )

    item["style_scores"] = (
        result["style_scores"]
    )

    item["ai_color"] = (
        result["ai_color"]
    )

    item["ai_color_confidence"] = (
        result["color_confidence"]
    )

    item["color_scores"] = (
        result["color_scores"]
    )

    return True


# ============================================================
# COLOR COMPATIBILITY
# ============================================================

COLOR_FAMILY = {

    "black":
        "neutral",

    "white":
        "neutral",

    "light gray":
        "neutral",

    "dark gray":
        "neutral",

    "gray":
        "neutral",

    "beige":
        "earth",

    "brown":
        "earth",

    "blue":
        "cool",

    "navy blue":
        "cool",

    "green":
        "cool",

    "purple":
        "cool",

    "red":
        "warm",

    "orange":
        "warm",

    "yellow":
        "warm",

    "pink":
        "warm",

    "multicolor":
        "multi",

}


def color_compatibility(
    color_a,
    color_b
):

    a = COLOR_FAMILY.get(
        color_a,
        "neutral"
    )

    b = COLOR_FAMILY.get(
        color_b,
        "neutral"
    )

    if (
        a == "neutral"
        or b == "neutral"
    ):

        return 1.0

    if "multi" in {
        a,
        b
    }:

        return 0.70

    if {
        a,
        b
    } == {
        "earth",
        "warm"
    }:

        return 0.88

    if a == b:

        return 0.82

    if {
        a,
        b
    } == {
        "cool",
        "earth"
    }:

        return 0.72

    if {
        a,
        b
    } == {
        "warm",
        "cool"
    }:

        return 0.58

    return 0.55


# ============================================================
# STYLE COMPATIBILITY
# ============================================================

STYLE_COMPATIBILITY = {

    "casual": {
        "casual": 1.00,
        "smart casual": 0.92,
        "streetwear": 0.90,
        "relaxed": 0.92,
        "sporty": 0.78,
        "minimalist": 0.82,
        "preppy": 0.72,
        "vintage": 0.75,
        "elegant": 0.58,
        "formal": 0.45,
    },

    "smart casual": {
        "casual": 0.92,
        "smart casual": 1.00,
        "minimalist": 0.92,
        "preppy": 0.90,
        "elegant": 0.82,
        "formal": 0.76,
        "relaxed": 0.82,
        "streetwear": 0.68,
        "vintage": 0.78,
        "sporty": 0.62,
    },

    "formal": {
        "formal": 1.00,
        "elegant": 0.95,
        "smart casual": 0.78,
        "minimalist": 0.82,
        "preppy": 0.75,
        "vintage": 0.68,
        "casual": 0.45,
        "streetwear": 0.35,
        "sporty": 0.25,
        "relaxed": 0.42,
    },

    "sporty": {
        "sporty": 1.00,
        "casual": 0.78,
        "streetwear": 0.82,
        "relaxed": 0.85,
        "smart casual": 0.58,
        "minimalist": 0.70,
        "formal": 0.25,
        "elegant": 0.30,
        "preppy": 0.40,
        "vintage": 0.55,
    },

    "streetwear": {
        "streetwear": 1.00,
        "casual": 0.90,
        "sporty": 0.82,
        "relaxed": 0.90,
        "minimalist": 0.78,
        "vintage": 0.80,
        "smart casual": 0.68,
        "preppy": 0.52,
        "elegant": 0.38,
        "formal": 0.30,
    },

    "minimalist": {
        "minimalist": 1.00,
        "smart casual": 0.92,
        "elegant": 0.88,
        "casual": 0.82,
        "formal": 0.82,
        "preppy": 0.78,
        "relaxed": 0.82,
        "streetwear": 0.72,
        "vintage": 0.70,
        "sporty": 0.62,
    },

    "elegant": {
        "elegant": 1.00,
        "formal": 0.95,
        "smart casual": 0.82,
        "minimalist": 0.88,
        "preppy": 0.75,
        "vintage": 0.70,
        "casual": 0.58,
        "streetwear": 0.38,
        "sporty": 0.30,
        "relaxed": 0.48,
    },

    "vintage": {
        "vintage": 1.00,
        "casual": 0.75,
        "streetwear": 0.80,
        "preppy": 0.78,
        "smart casual": 0.78,
        "relaxed": 0.82,
        "minimalist": 0.70,
        "elegant": 0.70,
        "formal": 0.62,
        "sporty": 0.55,
    },

    "preppy": {
        "preppy": 1.00,
        "smart casual": 0.90,
        "minimalist": 0.78,
        "elegant": 0.75,
        "casual": 0.72,
        "vintage": 0.78,
        "formal": 0.70,
        "relaxed": 0.62,
        "streetwear": 0.52,
        "sporty": 0.40,
    },

    "relaxed": {
        "relaxed": 1.00,
        "casual": 0.92,
        "streetwear": 0.90,
        "sporty": 0.85,
        "minimalist": 0.82,
        "vintage": 0.82,
        "smart casual": 0.82,
        "preppy": 0.62,
        "elegant": 0.48,
        "formal": 0.42,
    },

}


def style_compatibility(
    style_a,
    style_b
):

    if style_a in STYLE_COMPATIBILITY:

        return STYLE_COMPATIBILITY[
            style_a
        ].get(
            style_b,
            0.5
        )

    return 0.5


# ============================================================
# OUTFIT SCORE — PERSONALIZED AI
# ============================================================

def score_outfit(
    upper,
    lower,
    wardrobe=None
):
    """
    Calculate the final personalized outfit score.

    Stage 3 + Stage 4:

        Style compatibility        30%
        Color compatibility        25%
        Clothing visual similarity 20%
        User preference             25%
    """

    upper_color = upper.get(
        "ai_color",
        upper.get(
            "color",
            "unknown"
        )
    )

    lower_color = lower.get(
        "ai_color",
        lower.get(
            "color",
            "unknown"
        )
    )

    # --------------------------------------------------------
    # GENERAL AI COLOR COMPATIBILITY
    # --------------------------------------------------------

    color_score = (
        color_compatibility(
            upper_color,
            lower_color
        )
    )

    # --------------------------------------------------------
    # GENERAL AI STYLE COMPATIBILITY
    # --------------------------------------------------------

    upper_style = upper.get(
        "ai_style",
        "casual"
    )

    lower_style = lower.get(
        "ai_style",
        "casual"
    )

    style_score = (
        style_compatibility(
            upper_style,
            lower_style
        )
    )

    # --------------------------------------------------------
    # FASHIONCLIP CLOTHING SIMILARITY
    # --------------------------------------------------------

    embedding_score = 0.5

    if (
        upper.get("embedding")
        and
        lower.get("embedding")
    ):

        similarity = (
            cosine_similarity(
                upper["embedding"],
                lower["embedding"]
            )
        )

        embedding_score = max(
            0.0,
            min(
                1.0,
                (
                    similarity
                    +
                    1.0
                )
                /
                2.0
            )
        )

    # --------------------------------------------------------
    # USER PREFERENCE
    # --------------------------------------------------------

    preference_score = 0.5

    if wardrobe is not None:

        preference_score, _ = (
            calculate_user_preference_score(
                [
                    upper,
                    lower
                ],
                wardrobe
            )
        )

    # --------------------------------------------------------
    # FINAL PERSONALIZED SCORE
    # --------------------------------------------------------

    score = (

        style_score * 0.30

        +

        color_score * 0.25

        +

        embedding_score * 0.20

        +

        preference_score * 0.25

    )

    print(
        "========================================"
    )

    print(
        "PERSONALIZED OUTFIT SCORE"
    )

    print(
        "Style:",
        round(
            style_score,
            3
        )
    )

    print(
        "Color:",
        round(
            color_score,
            3
        )
    )

    print(
        "Visual:",
        round(
            embedding_score,
            3
        )
    )

    print(
        "User preference:",
        round(
            preference_score,
            3
        )
    )

    print(
        "FINAL:",
        round(
            score,
            3
        )
    )

    print(
        "========================================"
    )

    return float(
        score
    )

# ============================================================
# OUTFIT REASON
# ============================================================
# ============================================================
# OUTFIT REASON — PERSONALIZED
# ============================================================

def create_outfit_reason(
    upper,
    lower,
    score,
    wardrobe=None
):

    upper_color = upper.get(
        "ai_color",
        upper.get(
            "color",
            "unknown"
        )
    )

    lower_color = lower.get(
        "ai_color",
        lower.get(
            "color",
            "unknown"
        )
    )

    upper_style = upper.get(
        "ai_style",
        "casual"
    )

    lower_style = lower.get(
        "ai_style",
        "casual"
    )

    neutral_colors = {
        "black",
        "white",
        "gray",
        "light gray",
        "dark gray",
    }

    if (
        upper_color in neutral_colors
        or
        lower_color in neutral_colors
    ):

        color_reason = (
            "The neutral color balance "
            "makes the pieces easy to coordinate."
        )

    elif (
        upper_color ==
        lower_color
    ):

        color_reason = (
            "The similar color family "
            "creates a cohesive appearance."
        )

    else:

        color_reason = (
            "The colors create balanced "
            "contrast without looking excessive."
        )

    if (
        upper_style ==
        lower_style
    ):

        style_reason = (
            f"Both pieces have a "
            f"{upper_style} aesthetic."
        )

    else:

        style_reason = (
            f"The {upper_style} top and "
            f"{lower_style} bottom create "
            f"a balanced mixed style."
        )

    # --------------------------------------------------------
    # USER PERSONALIZATION
    # --------------------------------------------------------

    personalization_reason = ""

    if wardrobe is not None:

        preference_score, profile = (
            calculate_user_preference_score(
                [
                    upper,
                    lower
                ],
                wardrobe
            )
        )

        feedback_count = profile.get(
            "total_feedback",
            0
        )

        if feedback_count >= 3:

            if preference_score >= 0.65:

                personalization_reason = (
                    " It also matches patterns "
                    "from outfits you previously liked."
                )

            elif preference_score <= 0.35:

                personalization_reason = (
                    " The AI selected it despite "
                    "weaker personal preference signals "
                    "because its overall clothing "
                    "compatibility is strong."
                )

    percentage = round(
        score * 100
    )

    return (
        f"AI compatibility score: "
        f"{percentage}/100. "
        f"{color_reason} "
        f"{style_reason}"
        f"{personalization_reason}"
    )


# ============================================================
# BUILD OUTFIT RESPONSE
# ============================================================

def build_outfit_response(
    selected
):

    outfit_items = []

    for item in selected["items"]:

        outfit_items.append({

            "id":
                item["id"],

            "name":
                item["name"],

            "category":
                item["category"],

            "color":
                item.get(
                    "color",
                    "unknown"
                ),

            "image_url":
                item["image_url"],

            "ai_style":
                item.get(
                    "ai_style",
                    "unknown"
                ),

            "ai_style_confidence":
                item.get(
                    "ai_style_confidence",
                    0.0
                ),

            "ai_color":
                item.get(
                    "ai_color",
                    "unknown"
                ),

            "ai_color_confidence":
                item.get(
                    "ai_color_confidence",
                    0.0
                ),

        })

    if (
        len(selected["items"])
        == 2
    ):

        upper = selected[
            "items"
        ][0]

        lower = selected[
            "items"
        ][1]

        reason = create_outfit_reason(
            upper,
            lower,
            selected["score"],
            wardrobe=selected.get(
                "wardrobe"
            )
        )

    else:

        item = selected[
            "items"
        ][0]

        preference_score = 0.5

        if selected.get("wardrobe") is not None:

            preference_score, profile = (
                calculate_user_preference_score(
                    [item],
                    selected["wardrobe"]
                )
            )

        if (
            selected.get(
                "wardrobe"
            )
            and
            profile.get(
                "total_feedback",
                0
            ) >= 3
            and
            preference_score >= 0.65
        ):

            reason = (
                "AI selected this "
                f"{item.get('ai_style', 'stylish')} "
                "piece because it matches your "
                "previous outfit preferences."
            )

        else:

            reason = (
                "AI selected this "
                f"{item.get('ai_style', 'stylish')} "
                "full-body piece as the main outfit."
            )

    return {

        "title":
            "AI Stylist Pick",

        "items":
            outfit_items,

        "reason":
            reason,

        "score":
            round(
                selected["score"] * 100
            ),

        "outfit_key":
            list(
                selected["outfit_key"]
            ),

    }


# ============================================================
# GENERATE OUTFIT
# ============================================================

def generate_outfit_from_wardrobe(
    items,
    excluded_outfits=None
):

    if excluded_outfits is None:

        excluded_outfits = []

    excluded_set = {
        tuple(x)
        for x in excluded_outfits
    }

    upper = [
        item
        for item in items
        if item.get(
            "category"
        ) == "upper"
    ]

    lower = [
        item
        for item in items
        if item.get(
            "category"
        ) == "lower"
    ]

    full = [
        item
        for item in items
        if item.get(
            "category"
        ) == "full"
    ]

    candidates = []

    # --------------------------------------------------------
    # FULL-BODY OUTFITS
    # --------------------------------------------------------

    for item in full:

        outfit_key = (
            item["id"],
        )

        if outfit_key in excluded_set:
            continue

        style = item.get(
            "ai_style",
            "casual"
        )

        style_bonus = {

            "elegant": 0.04,

            "formal": 0.04,

            "smart casual": 0.03,

            "minimalist": 0.03,

            "casual": 0.02,

            "streetwear": 0.02,

            "sporty": 0.01,

            "vintage": 0.02,

            "preppy": 0.03,

            "relaxed": 0.02,

        }.get(
            style,
            0.02
        )

        # --------------------------------------------------------
        # PERSONALIZED FULL-BODY SCORE
        # --------------------------------------------------------

        preference_score, _ = (
            calculate_user_preference_score(
                [item],
                items
            )
        )

        score = (
            0.55
            +
            style_bonus
            +
            preference_score * 0.25
        )

        score = min(
            1.0,
            score
        )

        candidates.append({

            "items": [
                item
            ],

            "score":
                score,

            "outfit_key":
                outfit_key,

             "wardrobe":
                 items,

        })

    # --------------------------------------------------------
    # UPPER + LOWER OUTFITS
    # --------------------------------------------------------

    for top, bottom in product(
        upper,
        lower
    ):

        outfit_key = (
            top["id"],
            bottom["id"]
        )

        if outfit_key in excluded_set:
            continue

        score = score_outfit(
            top,
            bottom,
            wardrobe=items
        )

        candidates.append({

            "items": [
                top,
                bottom
            ],

            "score":
                score,

            "outfit_key":
                outfit_key,

        })

    # --------------------------------------------------------
    # No valid outfit
    # --------------------------------------------------------

    if not candidates:

        return {

            "title":
                "No More Outfits",

            "items": [],

            "reason":
                "You have already viewed "
                "all possible outfit combinations.",

            "score":
                0,

            "available_outfits":
                0,

            "outfit_key":
                [],

        }

    # --------------------------------------------------------
    # Sort by AI stylist score
    # --------------------------------------------------------

    candidates.sort(
        key=lambda x:
        x["score"],
        reverse=True
    )

    top_count = min(
        5,
        len(candidates)
    )

    pool = candidates[
        :top_count
    ]

    weights = []

    for index in range(
        len(pool)
    ):

        weights.append(
            1.0 /
            (index + 1)
        )

    selected = random.choices(
        pool,
        weights=weights,
        k=1
    )[0]

    return build_outfit_response(
        selected
    )


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():

    return {

        "message":
            "AI Wardrobe backend is running",

        "device":
            str(DEVICE),

        "fashion_model":
            FASHION_CLIP_MODEL,

        "style_color_model":
            STYLE_COLOR_CLIP_MODEL,

        "fashionclip_mode":
            "vision_encoder_pooler_output",

        "projection_disabled":
            True,

        "ai_style_classification":
            True,

        "ai_color_classification":
            True,

        # NEW
        "outfit_feedback":
            True,

    }


# ============================================================
# PROCESS CLOTHING
# ============================================================

@app.post(
    "/process-clothing"
)
def process_clothing(
    file: UploadFile = File(...),
    category: str = Form(...)
):

    print(
        "\n================================"
    )

    print(
        "PROCESS CLOTHING"
    )

    print(
        "FILE NAME:",
        file.filename
    )

    print(
        "CONTENT TYPE:",
        file.content_type
    )

    print(
        "CATEGORY:",
        category
    )

    print(
        "================================"
    )

    if category not in {
        "upper",
        "lower",
        "full",
    }:

        raise HTTPException(
            status_code=400,
            detail=(
                "Category must be "
                "upper, lower or full."
            )
        )

    if (
        not file.content_type
        or not file.content_type.startswith(
            "image/"
        )
    ):

        raise HTTPException(
            status_code=400,
            detail="Invalid image type."
        )

    data = file.file.read()

    print(
        "FILE SIZE:",
        len(data)
    )

    if not data:

        raise HTTPException(
            status_code=400,
            detail="Uploaded file is empty."
        )

    if len(data) > (
        15 * 1024 * 1024
    ):

        raise HTTPException(
            status_code=400,
            detail="Image is too large."
        )

    item_id = str(
        uuid.uuid4()
    )

    input_path = (
        UPLOAD_DIR /
        f"{item_id}.jpg"
    )

    output_path = (
        PROCESSED_DIR /
        f"{item_id}.jpg"
    )

    try:

        image = Image.open(
            io.BytesIO(data)
        )

        image = ImageOps.exif_transpose(
            image
        ).convert("RGB")

        image.save(
            input_path,
            "JPEG",
            quality=95
        )

        clothing = (
            create_aesthetic_clothing_image(
                data,
                output_path,
                category,
                item_id
            )
        )

        fallback_color = detect_color(
            clothing
        )

        print(
            "FALLBACK COLOR:",
            fallback_color
        )

        with FASHION_LOCK:

            with STYLE_COLOR_LOCK:

                attributes = (
                    analyze_clothing_with_ai(
                        clothing
                    )
                )

        embedding = (
            attributes["embedding"]
        )

        ai_style = (
            attributes["style"]
        )

        ai_style_confidence = (
            attributes["style_confidence"]
        )

        ai_color = (
            attributes["ai_color"]
        )

        ai_color_confidence = (
            attributes["color_confidence"]
        )

        print(
            "AI STYLE:",
            ai_style
        )

        print(
            "AI STYLE CONFIDENCE:",
            ai_style_confidence
        )

        print(
            "AI COLOR:",
            ai_color
        )

        print(
            "AI COLOR CONFIDENCE:",
            ai_color_confidence
        )

        print(
            "EMBEDDING LENGTH:",
            len(embedding)
        )

        category_name = (
            category_to_display_name(
                category
            )
        )

        name = (
            f"{ai_color.title()} "
            f"{category_name}"
        )

        image_url = (
            f"/processed/"
            f"{item_id}.jpg"
        )

        item = {

            "id":
                item_id,

            "name":
                name,

            "category":
                category,

            "color":
                ai_color,

            "image_url":
                image_url,

            "ai_style":
                ai_style,

            "ai_style_confidence":
                ai_style_confidence,

            "style_scores":
                attributes[
                    "style_scores"
                ],

            "ai_color":
                ai_color,

            "ai_color_confidence":
                ai_color_confidence,

            "color_scores":
                attributes[
                    "color_scores"
                ],

            "embedding":
                embedding,

        }

        wardrobe = load_wardrobe()

        wardrobe.append(
            item
        )

        save_wardrobe(
            wardrobe
        )

        reset_generated_outfits()

        return {

            "id":
                item_id,

            "name":
                name,

            "category":
                category,

            "color":
                ai_color,

            "ai_style":
                ai_style,

            "ai_style_confidence":
                ai_style_confidence,

            "ai_color":
                ai_color,

            "ai_color_confidence":
                ai_color_confidence,

            "image_url":
                image_url,

            "message":
                "Clothing processed successfully.",

        }

    except HTTPException:

        raise

    except Exception as e:

        print(
            "PROCESSING ERROR:",
            repr(e)
        )

        if output_path.exists():

            output_path.unlink()

        if input_path.exists():

            input_path.unlink()

        raise HTTPException(
            status_code=500,
            detail=(
                "Image processing failed: "
                f"{e}"
            )
        )


# ============================================================
# GET WARDROBE
# ============================================================

@app.get(
    "/wardrobe"
)
def get_wardrobe():

    wardrobe = load_wardrobe()

    response_items = []

    for item in wardrobe:

        clean = {
            key: value
            for key, value
            in item.items()
            if key != "embedding"
        }

        response_items.append(
            clean
        )

    return {

        "items":
            response_items

    }


# ============================================================
# DELETE WARDROBE ITEM
# ============================================================

@app.delete(
    "/wardrobe/{item_id}"
)
def delete_wardrobe_item(
    item_id: str
):

    wardrobe = load_wardrobe()

    item = next(
        (
            item
            for item in wardrobe
            if item.get("id") == item_id
        ),
        None
    )

    if item is None:

        raise HTTPException(
            status_code=404,
            detail="Wardrobe item not found."
        )

    wardrobe = [
        item
        for item in wardrobe
        if item.get("id") != item_id
    ]

    save_wardrobe(
        wardrobe
    )

    processed_path = (
        PROCESSED_DIR /
        f"{item_id}.jpg"
    )

    if processed_path.exists():
        processed_path.unlink()

    original_path = (
        UPLOAD_DIR /
        f"{item_id}.jpg"
    )

    if original_path.exists():
        original_path.unlink()

    parsing_debug = (
        DEBUG_DIR /
        f"{item_id}_parsing.png"
    )

    mask_debug = (
        DEBUG_DIR /
        f"{item_id}_mask.png"
    )

    if parsing_debug.exists():
        parsing_debug.unlink()

    if mask_debug.exists():
        mask_debug.unlink()

    reset_generated_outfits()

    return {

        "message":
            "Wardrobe item deleted."

    }


# ============================================================
# PROCESSED IMAGE
# ============================================================

@app.get(
    "/processed/{filename}"
)
def processed_image(
    filename: str
):

    safe_filename = Path(
        filename
    ).name

    path = (
        PROCESSED_DIR /
        safe_filename
    )

    if not path.exists():

        raise HTTPException(
            status_code=404,
            detail="Image not found."
        )

    return FileResponse(
        path,
        media_type="image/jpeg"
    )


# ============================================================
# DEBUG IMAGE
# ============================================================

@app.get(
    "/debug/{filename}"
)
def debug_image(
    filename: str
):

    safe_filename = Path(
        filename
    ).name

    path = (
        DEBUG_DIR /
        safe_filename
    )

    if not path.exists():

        raise HTTPException(
            status_code=404,
            detail="Image not found."
        )

    return FileResponse(
        path,
        media_type="image/png"
    )


# ============================================================
# COUNT POSSIBLE OUTFITS
# ============================================================

def count_possible_outfits(
    wardrobe
):

    upper_count = len([
        item
        for item in wardrobe
        if item.get(
            "category"
        ) == "upper"
    ])

    lower_count = len([
        item
        for item in wardrobe
        if item.get(
            "category"
        ) == "lower"
    ])

    full_count = len([
        item
        for item in wardrobe
        if item.get(
            "category"
        ) == "full"
    ])

    return (
        upper_count *
        lower_count
        +
        full_count
    )


# ============================================================
# GENERATE OUTFIT
# ============================================================

@app.post(
    "/generate-outfit"
)
def generate_outfit_endpoint():

    global GENERATED_OUTFITS

    wardrobe = load_wardrobe()

    if not wardrobe:

        raise HTTPException(
            status_code=400,
            detail="Your wardrobe is empty."
        )

    result = (
        generate_outfit_from_wardrobe(
            wardrobe,
            GENERATED_OUTFITS
        )
    )

    if not result.get(
        "items"
    ):

        if (
            result.get("title")
            ==
            "No More Outfits"
        ):

            GENERATED_OUTFITS = []

            result = (
                generate_outfit_from_wardrobe(
                    wardrobe,
                    []
                )
            )

            result["reason"] = (
                result.get(
                    "reason",
                    ""
                )
                +
                " All outfit combinations "
                "have been shown, so the AI "
                "stylist has started a new "
                "outfit cycle."
            )

    outfit_key = tuple(
        result.get(
            "outfit_key",
            []
        )
    )

    if outfit_key:

        if outfit_key not in (
            GENERATED_OUTFITS
        ):

            GENERATED_OUTFITS.append(
                outfit_key
            )

    available = (
        count_possible_outfits(
            wardrobe
        )
    )

    result[
        "available_outfits"
    ] = available

    result[
        "generated_outfits"
    ] = len(
        GENERATED_OUTFITS
    )

    return result


# ============================================================
# GENERATE ANOTHER OUTFIT
# ============================================================

@app.post(
    "/generate-outfit/another"
)
def generate_another_outfit():

    global GENERATED_OUTFITS

    wardrobe = load_wardrobe()

    if not wardrobe:

        raise HTTPException(
            status_code=400,
            detail="Your wardrobe is empty."
        )

    result = (
        generate_outfit_from_wardrobe(
            wardrobe,
            GENERATED_OUTFITS
        )
    )

    if not result.get(
        "items"
    ):

        GENERATED_OUTFITS = []

        result = (
            generate_outfit_from_wardrobe(
                wardrobe,
                []
            )
        )

        result["reason"] = (
            result.get(
                "reason",
                ""
            )
            +
            " All outfit combinations "
            "have been shown, so the AI "
            "stylist has started a new "
            "outfit cycle."
        )

    outfit_key = tuple(
        result.get(
            "outfit_key",
            []
        )
    )

    if outfit_key:

        if outfit_key not in (
            GENERATED_OUTFITS
        ):

            GENERATED_OUTFITS.append(
                outfit_key
            )

    result[
        "available_outfits"
    ] = count_possible_outfits(
        wardrobe
    )

    result[
        "generated_outfits"
    ] = len(
        GENERATED_OUTFITS
    )

    return result


# ============================================================
# NEW — SAVE OUTFIT LIKE / DISLIKE
# ============================================================

@app.post(
    "/outfit-feedback"
)
def save_outfit_feedback(
    data: OutfitFeedback
):

    # --------------------------------------------------------
    # Validate feedback
    # --------------------------------------------------------

    if data.feedback not in {
        "like",
        "dislike",
    }:

        raise HTTPException(
            status_code=400,
            detail=(
                "Feedback must be "
                "'like' or 'dislike'."
            )
        )

    # --------------------------------------------------------
    # Validate outfit
    # --------------------------------------------------------

    if not data.outfit_key:

        raise HTTPException(
            status_code=400,
            detail="Outfit key cannot be empty."
        )

    # --------------------------------------------------------
    # Sort the IDs.
    #
    # This means:
    #
    # [shirt, pants]
    #
    # and
    #
    # [pants, shirt]
    #
    # are treated as the same outfit.
    # --------------------------------------------------------

    outfit_key = sorted(
        data.outfit_key
    )

    # Convert to tuple internally when comparing.

    outfit_key_tuple = tuple(
        outfit_key
    )

    # --------------------------------------------------------
    # Save preference
    # --------------------------------------------------------

    with PREFERENCES_LOCK:

        preferences = load_preferences()

        liked = preferences[
            "liked_outfits"
        ]

        disliked = preferences[
            "disliked_outfits"
        ]

        # Remove the outfit from both lists first.
        #
        # This allows the user to change:
        #
        # Like -> Dislike
        #
        # or
        #
        # Dislike -> Like

        liked[:] = [
            existing
            for existing in liked
            if tuple(existing)
            != outfit_key_tuple
        ]

        disliked[:] = [
            existing
            for existing in disliked
            if tuple(existing)
            != outfit_key_tuple
        ]

        # ----------------------------------------------------
        # Add to correct list
        # ----------------------------------------------------

        if data.feedback == "like":

            liked.append(
                outfit_key
            )

        else:

            disliked.append(
                outfit_key
            )

        save_preferences(
            preferences
        )

    print(
        "========================================"
    )

    print(
        "OUTFIT FEEDBACK SAVED"
    )

    print(
        "OUTFIT:",
        outfit_key
    )

    print(
        "FEEDBACK:",
        data.feedback
    )

    print(
        "========================================"
    )

    return {

        "success":
            True,

        "feedback":
            data.feedback,

        "outfit_key":
            outfit_key,

        "message":
            "Outfit feedback saved successfully.",

    }


# ============================================================
# NEW — GET OUTFIT FEEDBACK
# ============================================================

@app.get(
    "/outfit-feedback"
)
def get_outfit_feedback():

    with PREFERENCES_LOCK:

        preferences = load_preferences()

    return {

        "liked_outfits":
            preferences[
                "liked_outfits"
            ],

        "disliked_outfits":
            preferences[
                "disliked_outfits"
            ],

    }



@app.get("/preference-profile")
def get_preference_profile():

    wardrobe = load_wardrobe()

    profile = build_preference_profile(wardrobe)
    visual_profile = build_visual_preference_profile(wardrobe)

    return {
        "total_feedback": profile["total_feedback"],
        "learning_strength": profile["learning_strength"],

        "color_preferences": profile["color_preferences"],
        "style_preferences": profile["style_preferences"],
        "category_preferences": profile["category_preferences"],

        "visual_learning": {
            "liked_items": visual_profile["liked_count"],
            "disliked_items": visual_profile["disliked_count"],
            "enabled": (
                visual_profile["liked_embedding"] is not None
                or visual_profile["disliked_embedding"] is not None
            )
        }
    }

# ============================================================
# STAGE 3 — ATTRIBUTE PREFERENCE SCORE
# ============================================================

def get_attribute_preference_score(
    item,
    profile
):
    """
    Calculate preference for one wardrobe item
    based on learned color, style and category preferences.

    Returns a score from 0.0 to 1.0.
    """

    scores = []

    # --------------------------------------------------------
    # COLOR
    # --------------------------------------------------------

    color = item.get(
        "ai_color",
        item.get(
            "color",
            ""
        )
    )

    if color:

        color = str(
            color
        ).lower()

        color_data = profile.get(
            "color_preferences",
            {}
        ).get(
            color
        )

        if color_data:

            scores.append(
                0.5
                +
                (
                    color_data["score"]
                    * 0.5
                )
            )

    # --------------------------------------------------------
    # STYLE
    # --------------------------------------------------------

    style = item.get(
        "ai_style",
        ""
    )

    if style:

        style = str(
            style
        ).lower()

        style_data = profile.get(
            "style_preferences",
            {}
        ).get(
            style
        )

        if style_data:

            scores.append(
                0.5
                +
                (
                    style_data["score"]
                    * 0.5
                )
            )

    # --------------------------------------------------------
    # CATEGORY
    # --------------------------------------------------------

    category = item.get(
        "category",
        ""
    )

    if category:

        category = str(
            category
        ).lower()

        category_data = profile.get(
            "category_preferences",
            {}
        ).get(
            category
        )

        if category_data:

            scores.append(
                0.5
                +
                (
                    category_data["score"]
                    * 0.5
                )
            )

    # --------------------------------------------------------
    # No learned information for this item
    # --------------------------------------------------------

    if not scores:

        return 0.5

    return float(
        max(
            0.0,
            min(
                1.0,
                np.mean(scores)
            )
        )
    )


def calculate_attribute_outfit_preference(
    outfit_items,
    profile
):
    """
    Calculate the average learned attribute preference
    for all pieces in an outfit.
    """

    if not outfit_items:

        return 0.5

    scores = []

    for item in outfit_items:

        scores.append(
            get_attribute_preference_score(
                item,
                profile
            )
        )

    return float(
        np.mean(scores)
    )


def calculate_user_preference_score(
    outfit_items,
    wardrobe
):
    """
    Combine Stage 3 attribute learning and Stage 4
    FashionCLIP visual learning.

    Returns:

        preference_score
        profile
    """

    profile = build_preference_profile(
        wardrobe
    )

    total_feedback = profile.get(
        "total_feedback",
        0
    )

    learning_strength = profile.get(
        "learning_strength",
        0.0
    )

    # --------------------------------------------------------
    # Attribute preference
    # --------------------------------------------------------

    attribute_score = (
        calculate_attribute_outfit_preference(
            outfit_items,
            profile
        )
    )

    # --------------------------------------------------------
    # FashionCLIP visual preference
    # --------------------------------------------------------

    visual_profile = (
        build_visual_preference_profile(
            wardrobe
        )
    )

    visual_score = (
        calculate_visual_preference(
            outfit_items,
            visual_profile
        )
    )

    # --------------------------------------------------------
    # Combine Stage 3 + Stage 4
    # --------------------------------------------------------

    raw_preference = (
        attribute_score * 0.50
        +
        visual_score * 0.50
    )

    # --------------------------------------------------------
    # Gradually activate personalization.
    #
    # This prevents one Like from completely changing
    # the recommendation system.
    # --------------------------------------------------------

    personalized_score = (
        0.5
        +
        (
            raw_preference
            -
            0.5
        )
        *
        learning_strength
    )

    personalized_score = max(
        0.0,
        min(
            1.0,
            personalized_score
        )
    )

    print(
        "----------------------------------------"
    )

    print(
        "USER PREFERENCE ANALYSIS"
    )

    print(
        "Feedback count:",
        total_feedback
    )

    print(
        "Learning strength:",
        round(
            learning_strength,
            3
        )
    )

    print(
        "Attribute preference:",
        round(
            attribute_score,
            3
        )
    )

    print(
        "FashionCLIP preference:",
        round(
            visual_score,
            3
        )
    )

    print(
        "Final user preference:",
        round(
            personalized_score,
            3
        )
    )

    print(
        "----------------------------------------"
    )

    return (
        float(
            personalized_score
        ),
        profile
    )