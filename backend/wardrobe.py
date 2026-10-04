import os
import json
import uuid
from datetime import datetime
from typing import List, Dict, Optional

from fastapi import UploadFile

from ai_service import (
    analyse_clothing,
    create_processed_image,
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

    # AI analysis information remains available
    # in the backend for recommendation/evaluation.
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
    #
    # Only store user-facing wardrobe information here.
    # AI confidence values and embeddings remain in `analysis`
    # for backend AI/recommendation use.
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
            analysis["category"],
        ),

        "category": analysis["category"],

        "subcategory": "unknown",

        "brand": "unknown",

        "color": analysis["color"],

        "style": analysis["style"],

        "material": "unknown",

        "image_path": f"/uploads/{filename}",

        "processed_image_path": f"/processed/{processed_filename}",

        "original_filename": original_name,

        "model_name": analysis[
            "model_name"
        ],

        "created_at": datetime.now().isoformat(),
    }

    # ---------------------------------------------------------------
    # Temporary wardrobe storage
    #
    # This will later be replaced with MySQL.
    # ---------------------------------------------------------------

    wardrobe = load_wardrobe()

    wardrobe.append(
        item
    )

    save_wardrobe(
        wardrobe
    )

    # New wardrobe means old generated
    # outfit combinations may no longer
    # represent the current wardrobe.
    reset_generated_outfits()

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