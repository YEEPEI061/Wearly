import os
import json
import uuid
from datetime import datetime
from typing import List, Dict, Optional

from fastapi import UploadFile

from ai_service import (
    analyse_clothing,
    detect_clothing,
    create_processed_image,
    detect_clothing_occlusion,
    load_models
)


BASE_DIR = os.path.dirname(
    os.path.abspath(__file__)
)

UPLOAD_DIR = os.path.join(
    BASE_DIR,
    "uploads",
)

PROCESSED_DIR = os.path.join(
    BASE_DIR,
    "processed",
)

DEBUG_DIR = os.path.join(
    BASE_DIR,
    "debug",
)

WARDROBE_FILE = os.path.join(
    BASE_DIR,
    "wardrobe.json",
)

GENERATED_OUTFITS_FILE = os.path.join(
    BASE_DIR,
    "generated_outfits.json",
)


os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(PROCESSED_DIR, exist_ok=True)
os.makedirs(DEBUG_DIR, exist_ok=True)


# -------------------------------------------------------------------
# JSON helpers
# -------------------------------------------------------------------

def _load_json(
    path: str,
    default,
):
    if not os.path.exists(path):
        return default

    try:
        with open(
            path,
            "r",
            encoding="utf-8",
        ) as file:
            return json.load(file)

    except Exception:
        return default


def _save_json(
    path: str,
    data,
):
    with open(
        path,
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            data,
            file,
            indent=2,
        )


def load_wardrobe() -> List[Dict]:
    return _load_json(
        WARDROBE_FILE,
        [],
    )


def save_wardrobe(
    wardrobe: List[Dict],
):
    _save_json(
        WARDROBE_FILE,
        wardrobe,
    )


# -------------------------------------------------------------------
# Generated outfit reset
# -------------------------------------------------------------------

def reset_generated_outfits():

    _save_json(
        GENERATED_OUTFITS_FILE,
        [],
    )

    print(
        "✓ Generated outfits reset because wardrobe changed."
    )


# -------------------------------------------------------------------
# Get wardrobe
# -------------------------------------------------------------------

def get_wardrobe() -> List[Dict]:
    return load_wardrobe()


# -------------------------------------------------------------------
# Get one item
# -------------------------------------------------------------------

def get_clothing_item(
    item_id: str,
) -> Optional[Dict]:

    wardrobe = load_wardrobe()

    for item in wardrobe:
        if str(item["id"]) == str(item_id):
            return item

    return None


# -------------------------------------------------------------------
# Process uploaded clothing
# -------------------------------------------------------------------
async def process_clothing(
    file: UploadFile,
    selected_category: str | None = None,
) -> Dict:
    
    original_name = file.filename or "clothing.jpg"

    extension = os.path.splitext(
        original_name
    )[1].lower()

    if extension not in (
        ".jpg",
        ".jpeg",
        ".png",
        ".webp",
    ):
        extension = ".jpg"

    item_id = str(
        uuid.uuid4()
    )

    filename = (
        f"{item_id}{extension}"
    )

    original_path = os.path.join(
        UPLOAD_DIR,
        filename,
    )

    processed_filename = (
        f"{item_id}.jpg"
    )

    processed_path = os.path.join(
        PROCESSED_DIR,
        processed_filename,
    )

    contents = await file.read()

    with open(
        original_path,
        "wb",
    ) as output:
        output.write(contents)

    print(
        f"✓ Saved uploaded image: {filename}"
    )

    # ---------------------------------------------------------------
    # AI analysis
    # ---------------------------------------------------------------

    analysis = analyse_clothing(
        original_path
    )

    # ---------------------------------------------------------------
    # Final category
    #
    # AI detects the category, but the user's manual selection
    # takes priority when provided.
    # ---------------------------------------------------------------

    ai_category = analysis["category"]

    valid_categories = {
        "upper",
        "lower",
        "full",
    }

    if selected_category in valid_categories:
        final_category = selected_category
    else:
        final_category = ai_category


    print(
        f"✓ AI category: {analysis['category']} "
        f"({analysis['category_confidence']:.3f})"
    )

    print(
        f"✓ AI color: {analysis['color']} "
        f"({analysis['color_confidence']:.3f})"
    )

    print(
        f"✓ AI style: {analysis['style']} "
        f"({analysis['style_confidence']:.3f})"
    )

    # ---------------------------------------------------------------
    # Create clean processed image
    # ---------------------------------------------------------------

    processing_result = create_processed_image(
        original_path,
        processed_path,
    )

    # ---------------------------------------------------------------
    # Build wardrobe item
    # ---------------------------------------------------------------

    def generate_clothing_name(color: str, category: str) -> str:
        category_names = {
            "upper": "Top",
            "lower": "Bottom",
            "full": "Full Body",
            "top": "Top",
            "pants": "Pants",
            "skirt": "Skirt",
            "dress": "Dress",
        }

        display_category = category_names.get(
            category.lower(),
            category.title(),
        )

        return f"{color.title()} {display_category}"

    item = {
        "id": item_id,

        "name": generate_clothing_name(
            analysis["color"],
            final_category,
        ),

        "category": final_category,

        "subcategory": "unknown",

        "brand": "unknown",

        "color": analysis["color"],

        "style": analysis["style"],

        "material": "unknown",

        "image_path": f"/uploads/{filename}",

        "processed_image_path": f"/processed/{processed_filename}",

        "original_filename": original_name,

        # ---------------------------------------------------------------
        # AI analysis
        # ---------------------------------------------------------------

        "detected_category": analysis["category"],

        "category_confidence": analysis[
            "category_confidence"
        ],

        "detected_color": analysis["color"],

        "color_confidence": analysis[
            "color_confidence"
        ],

        "detected_style": analysis["style"],

        "style_confidence": analysis[
            "style_confidence"
        ],

        "analysis_version": "1.0",

        "created_at": datetime.now().isoformat(),
    }

    # ---------------------------------------------------------------
    # Return processed item
    #
    # The item is NOT saved here.
    # The user must confirm it from Clothing Detail first.
    # ---------------------------------------------------------------

    return item


# -------------------------------------------------------------------
# Delete clothing
# -------------------------------------------------------------------

def delete_clothing(
    item_id: str,
) -> bool:

    wardrobe = load_wardrobe()

    item = None

    for clothing in wardrobe:
        if str(clothing["id"]) == str(item_id):
            item = clothing
            break

    if item is None:
        return False

    wardrobe = [
        clothing
        for clothing in wardrobe
        if str(clothing["id"]) != str(item_id)
    ]

    save_wardrobe(
        wardrobe
    )

    # Delete original image
    image_path = item.get(
        "image_path"
    )

    if image_path and os.path.exists(
        image_path
    ):
        try:
            os.remove(image_path)
        except Exception:
            pass

    # Delete processed image
    processed_path = item.get(
        "processed_image_path"
    )

    if (
        processed_path
        and os.path.exists(processed_path)
    ):
        try:
            os.remove(processed_path)
        except Exception:
            pass

    reset_generated_outfits()

    return True


# ============================================================
# LIGHTWEIGHT CATEGORY DETECTION
# ============================================================

def detect_category(
    image_path: str,
) -> Dict:

    load_models()

    detection = detect_clothing(
        image_path
    )

    detected_category = detection.get(
        "category"
    )

    category_map = {
        "top": "upper",
        "pants": "lower",
        "skirt": "lower",
        "dress": "full",
    }

    category = category_map.get(
        detected_category,
        "upper",
    )

    return {
        "category": category,
        "category_confidence": detection.get(
            "confidence",
            0.0,
        ),
        "detected_label": detected_category,
    }