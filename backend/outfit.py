import os
import json
import math
import numpy as np
import random
from datetime import datetime
from typing import List, Dict, Optional
from PIL import Image


from ai_service import (
    category_group,
    compare_embeddings,
)
from database.clothing import get_clothing_items
from database.outfit import (
    save_generated_outfits,
    update_outfit_preview,
    find_existing_outfit,
    submit_outfit_feedback,
    get_feedback_preferences,
)
from database.db import get_connection


BASE_DIR = os.path.dirname(
    os.path.abspath(__file__)
)

GENERATED_OUTFITS_FILE = os.path.join(
    BASE_DIR,
    "generated_outfits.json",
)

OUTFIT_PREVIEW_DIR = os.path.join(
    BASE_DIR,
    "outfit_previews",
)

os.makedirs(
    OUTFIT_PREVIEW_DIR,
    exist_ok=True,
)

PREFERENCES_FILE = os.path.join(
    BASE_DIR,
    "preferences.json",
)


# -------------------------------------------------------------------
# JSON helpers
# -------------------------------------------------------------------
def sanitize_json_value(value):
    if isinstance(value, float):
        if not math.isfinite(value):
            return 0.0
        return value

    if isinstance(value, dict):
        return {
            key: sanitize_json_value(val)
            for key, val in value.items()
        }

    if isinstance(value, list):
        return [
            sanitize_json_value(item)
            for item in value
        ]

    return value

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


# -------------------------------------------------------------------
# Generated outfit storage
# -------------------------------------------------------------------

def load_generated_outfits():

    return _load_json(
        GENERATED_OUTFITS_FILE,
        [],
    )


# def save_generated_outfits(
#     outfits: List[Dict],
# ):
#     _save_json(
#         GENERATED_OUTFITS_FILE,
#         outfits,
#     )


# -------------------------------------------------------------------
# Preferences
# -------------------------------------------------------------------

def load_preferences():

    return _load_json(
        PREFERENCES_FILE,
        {
            "preferred_styles": [],
            "preferred_colors": [],
            "disliked_styles": [],
            "disliked_colors": [],
        },
    )


def save_preferences(
    preferences: Dict,
):
    _save_json(
        PREFERENCES_FILE,
        preferences,
    )


# -------------------------------------------------------------------
# Basic compatibility
# -------------------------------------------------------------------

STYLE_COMPATIBILITY = {
    "casual": {
        "casual",
        "smart casual",
        "relaxed",
        "sporty",
        "streetwear",
    },

    "smart casual": {
        "casual",
        "smart casual",
        "minimalist",
        "elegant",
        "preppy",
    },

    "formal": {
        "formal",
        "elegant",
        "minimalist",
        "smart casual",
    },

    "sporty": {
        "sporty",
        "casual",
        "streetwear",
        "relaxed",
    },

    "streetwear": {
        "streetwear",
        "casual",
        "sporty",
        "relaxed",
    },

    "minimalist": {
        "minimalist",
        "elegant",
        "smart casual",
        "formal",
    },

    "elegant": {
        "elegant",
        "formal",
        "minimalist",
        "smart casual",
    },

    "vintage": {
        "vintage",
        "casual",
        "preppy",
        "relaxed",
    },

    "preppy": {
        "preppy",
        "smart casual",
        "casual",
        "vintage",
    },

    "relaxed": {
        "relaxed",
        "casual",
        "sporty",
        "streetwear",
    },
}


COLOR_COMPATIBILITY = {
    "black": {
        "white",
        "beige",
        "gray",
        "light gray",
        "dark gray",
        "red",
        "blue",
        "navy blue",
        "green",
        "pink",
        "purple",
        "brown",
    },

    "white": {
        "black",
        "beige",
        "gray",
        "light gray",
        "dark gray",
        "blue",
        "navy blue",
        "green",
        "red",
        "brown",
        "pink",
    },

    "beige": {
        "white",
        "black",
        "brown",
        "navy blue",
        "blue",
        "green",
        "gray",
        "dark gray",
    },

    "brown": {
        "beige",
        "white",
        "black",
        "cream",
        "green",
        "navy blue",
        "blue",
    },

    "navy blue": {
        "white",
        "beige",
        "gray",
        "light gray",
        "brown",
        "pink",
        "green",
    },

    "blue": {
        "white",
        "black",
        "beige",
        "gray",
        "navy blue",
        "brown",
    },

    "gray": {
        "black",
        "white",
        "beige",
        "navy blue",
        "blue",
        "pink",
        "green",
    },

    "light gray": {
        "black",
        "white",
        "navy blue",
        "blue",
        "pink",
        "green",
    },

    "dark gray": {
        "white",
        "black",
        "beige",
        "pink",
        "blue",
    },

    "green": {
        "white",
        "black",
        "beige",
        "brown",
        "navy blue",
        "blue",
    },

    "red": {
        "black",
        "white",
        "gray",
        "navy blue",
        "beige",
    },

    "pink": {
        "black",
        "white",
        "gray",
        "navy blue",
        "green",
    },

    "purple": {
        "black",
        "white",
        "gray",
        "beige",
    },

    "orange": {
        "black",
        "white",
        "blue",
        "navy blue",
        "beige",
    },

    "yellow": {
        "black",
        "white",
        "navy blue",
        "blue",
        "gray",
    },
}


# -------------------------------------------------------------------
# Style score
# -------------------------------------------------------------------

def style_score(
    style_a: str,
    style_b: str,
) -> float:

    style_a = style_a.lower()
    style_b = style_b.lower()

    if style_a == style_b:
        return 1.0

    compatible = STYLE_COMPATIBILITY.get(
        style_a,
        set(),
    )

    if style_b in compatible:
        return 0.80

    compatible_reverse = STYLE_COMPATIBILITY.get(
        style_b,
        set(),
    )

    if style_a in compatible_reverse:
        return 0.80

    return 0.40


# -------------------------------------------------------------------
# Colour score
# -------------------------------------------------------------------

def color_score(
    color_a: str,
    color_b: str,
) -> float:

    color_a = color_a.lower()
    color_b = color_b.lower()

    if color_a == color_b:
        return 0.70

    if color_a == "multicolor":
        return 0.65

    if color_b == "multicolor":
        return 0.65

    compatible = COLOR_COMPATIBILITY.get(
        color_a,
        set(),
    )

    if color_b in compatible:
        return 1.0

    compatible_reverse = COLOR_COMPATIBILITY.get(
        color_b,
        set(),
    )

    if color_a in compatible_reverse:
        return 1.0

    return 0.35


# -------------------------------------------------------------------
# Pair score
# -------------------------------------------------------------------

def calculate_pair_score(item_a, item_b):

    style = style_score(
        item_a.get("style", "casual"),
        item_b.get("style", "casual"),
    )

    color = color_score(
        item_a.get("color", "unknown"),
        item_b.get("color", "unknown"),
    )

    visual = compare_embeddings(
        item_a,
        item_b,
    )

    if not math.isfinite(visual):
        visual = 0.0

    visual_normalized = (visual + 1.0) / 2.0

    if not math.isfinite(visual_normalized):
        visual_normalized = 0.0

    final_score = (
        style * 0.40
        + color * 0.35
        + visual_normalized * 0.25
    )

    if not math.isfinite(final_score):
        final_score = 0.0

    return {
        "score": final_score,
        "style_score": style,
        "color_score": color,
        "visual_score": visual_normalized,
    }

# -------------------------------------------------------------------
# Personalisation score
# -------------------------------------------------------------------

def personalization_bonus(
    outfit: Dict,
    preferences: Dict,
) -> float:

    bonus = 0.0

    preferred_styles = preferences.get(
        "preferred_styles",
        {},
    )

    preferred_colors = preferences.get(
        "preferred_colors",
        {},
    )

    disliked_styles = preferences.get(
        "disliked_styles",
        {},
    )

    disliked_colors = preferences.get(
        "disliked_colors",
        {},
    )

    for item in outfit["items"]:

        style = (
            item.get("style") or ""
        ).lower().strip()

        color = (
            item.get("color") or ""
        ).lower().strip()

        # ========================================================
        # Positive feedback
        # ========================================================

        style_likes = preferred_styles.get(
            style,
            0,
        )

        color_likes = preferred_colors.get(
            color,
            0,
        )

        # ========================================================
        # Negative feedback
        # ========================================================

        style_dislikes = disliked_styles.get(
            style,
            0,
        )

        color_dislikes = disliked_colors.get(
            color,
            0,
        )

        # ========================================================
        # Apply weighted personalisation
        # ========================================================

        bonus += min(
            style_likes * 0.02,
            0.06,
        )

        bonus += min(
            color_likes * 0.02,
            0.06,
        )

        bonus -= min(
            style_dislikes * 0.03,
            0.09,
        )

        bonus -= min(
            color_dislikes * 0.03,
            0.09,
        )

    # ============================================================
    # Prevent personalisation from overwhelming compatibility
    # ============================================================

    return max(
        -0.20,
        min(0.20, bonus),
    )

# -------------------------------------------------------------------
# Outfit preview image
# -------------------------------------------------------------------

def _remove_wearly_background(
    image: Image.Image,
) -> Image.Image:

    image = image.convert("RGBA")

    pixels = image.load()

    width, height = image.size

    background_color = (
        248,
        247,
        244,
    )

    tolerance = 18

    for y in range(height):

        for x in range(width):

            r, g, b, a = pixels[x, y]

            distance = (
                abs(r - background_color[0])
                + abs(g - background_color[1])
                + abs(b - background_color[2])
            )

            if distance <= tolerance * 3:

                pixels[x, y] = (
                    r,
                    g,
                    b,
                    0,
                )

    bbox = image.getbbox()

    if bbox is None:
        return image

    return image.crop(bbox)


def _load_processed_clothing(
    item: Dict,
) -> Optional[Image.Image]:

    processed_path = item.get(
        "processed_image_path"
    )

    if not processed_path:
        return None

    # Example:
    # /processed/abc123.jpg
    filename = os.path.basename(
        processed_path
    )

    path = os.path.join(
        BASE_DIR,
        "processed",
        filename,
    )

    if not os.path.exists(path):

        print(
            f"⚠ Outfit image not found: {path}"
        )

        return None

    try:

        image = Image.open(
            path
        ).convert("RGBA")

        return _remove_wearly_background(
            image
        )

    except Exception as e:

        print(
            f"⚠ Failed to load outfit image: {e}"
        )

        return None


def create_outfit_preview(
    outfit_id: str,
    items: List[Dict],
) -> Optional[str]:

    if not items:
        return None

    # ---------------------------------------------------------------
    # Full-body outfit
    # ---------------------------------------------------------------

    full_item = next(
        (
            item
            for item in items
            if category_group(
                item.get("category", "")
            ) == "full"
        ),
        None,
    )

    if full_item is not None:

        clothing = _load_processed_clothing(
            full_item
        )

        if clothing is None:
            return None

        canvas = Image.new(
            "RGBA",
            (
                800,
                1000,
            ),
            (
                0,
                0,
                0,
                0,
            ),
        )

        clothing.thumbnail(
            (
                620,
                850,
            ),
            Image.Resampling.LANCZOS,
        )

        x = (
            canvas.width
            - clothing.width
        ) // 2

        y = (
            canvas.height
            - clothing.height
        ) // 2

        canvas.alpha_composite(
            clothing,
            (
                x,
                y,
            ),
        )

    else:

        # -----------------------------------------------------------
        # Upper + lower outfit
        # -----------------------------------------------------------

        upper_item = next(
            (
                item
                for item in items
                if category_group(
                    item.get("category", "")
                ) == "upper"
            ),
            None,
        )

        lower_item = next(
            (
                item
                for item in items
                if category_group(
                    item.get("category", "")
                ) == "lower"
            ),
            None,
        )

        if upper_item is None or lower_item is None:

            print(
                "⚠ Cannot create outfit preview: "
                "upper/lower item missing."
            )

            return None

        upper_image = _load_processed_clothing(
            upper_item
        )

        lower_image = _load_processed_clothing(
            lower_item
        )

        if upper_image is None or lower_image is None:

            return None

        # -----------------------------------------------------------
        # Final outfit canvas
        # -----------------------------------------------------------

        canvas = Image.new(
            "RGBA",
            (
                800,
                800,
            ),
            (
                0,
                0,
                0,
                0,
            ),
        )


        # -------------------------
        # UPPER
        # -------------------------

        upper_image.thumbnail(
            (
                360,
                230,
            ),
            Image.Resampling.LANCZOS,
        )

        upper_x = (
            canvas.width
            - upper_image.width
        ) // 2

        upper_y = 25

        canvas.alpha_composite(
            upper_image,
            (
                upper_x,
                upper_y,
            ),
        )


        # -------------------------
        # LOWER
        # -------------------------

        lower_image.thumbnail(
            (
                560,
                500,
            ),
            Image.Resampling.LANCZOS,
        )

        lower_x = (
            canvas.width
            - lower_image.width
        ) // 2

        lower_y = 270

        canvas.alpha_composite(
            lower_image,
            (
                lower_x,
                lower_y,
            ),
        )

    # ---------------------------------------------------------------
    # Save
    # ---------------------------------------------------------------

    filename = (
        f"{outfit_id}.png"
    )

    output_path = os.path.join(
        OUTFIT_PREVIEW_DIR,
        filename,
    )

    canvas.save(
        output_path,
        "PNG",
    )

    print(
        f"✓ Outfit preview created: {output_path}"
    )

    return (
        f"/outfit-previews/{filename}"
    )

def cleanup_old_outfit_previews(
    keep_latest: int = 20,
):
    files = []

    for filename in os.listdir(
        OUTFIT_PREVIEW_DIR
    ):
        if not filename.lower().endswith(".png"):
            continue

        path = os.path.join(
            OUTFIT_PREVIEW_DIR,
            filename,
        )

        if os.path.isfile(path):
            files.append(path)

    files.sort(
        key=os.path.getmtime,
        reverse=True,
    )

    # -------------------------------------------------------
    # Get preview filenames currently referenced by MySQL
    # -------------------------------------------------------

    referenced_previews = set()

    connection = get_connection()
    cursor = connection.cursor(
        dictionary=True
    )

    try:
        cursor.execute(
            """
            SELECT image_url
            FROM outfits
            WHERE image_url IS NOT NULL
              AND image_url != ''
            """
        )

        rows = cursor.fetchall()

        for row in rows:
            image_url = row.get("image_url")

            if not image_url:
                continue

            filename = os.path.basename(
                image_url
            )

            if filename:
                referenced_previews.add(
                    filename
                )

    finally:
        cursor.close()
        connection.close()

    # -------------------------------------------------------
    # Remove old files
    #
    # Never delete a preview that is still referenced
    # by an outfit in MySQL.
    # -------------------------------------------------------

    for path in files[keep_latest:]:
        filename = os.path.basename(path)

        if filename in referenced_previews:
            print(
                "🔒 Keeping referenced outfit preview:",
                filename,
            )
            continue

        try:
            os.remove(path)

            print(
                f"🗑️ Removed old outfit preview: {path}"
            )

        except Exception as e:
            print(
                f"⚠ Failed to remove old preview: {e}"
            )

# -------------------------------------------------------------------
# Occasion + Mood recommendation bonus
# -------------------------------------------------------------------

def occasion_mood_bonus(
    outfit: Dict,
    occasion: str,
    mood: str,
) -> Dict[str, float]:

    occasion_styles = {
        "casual": {
            "casual",
            "relaxed",
            "streetwear",
        },
        "work": {
            "smart casual",
            "formal",
            "minimalist",
            "preppy",
        },
        "evening": {
            "elegant",
            "formal",
            "minimalist",
        },
        "going out": {
            "streetwear",
            "casual",
            "elegant",
            "preppy",
        },
    }

    mood_styles = {
        "relaxed": {
            "relaxed",
            "casual",
        },
        "smart": {
            "smart casual",
            "formal",
            "preppy",
            "minimalist",
        },
        "elegant": {
            "elegant",
            "formal",
            "minimalist",
        },
        "trendy": {
            "streetwear",
            "preppy",
            "casual",
        },
    }

    occasion_key = occasion.strip().lower()
    mood_key = mood.strip().lower()

    matching_occasion_styles = occasion_styles.get(
        occasion_key,
        set(),
    )

    matching_mood_styles = mood_styles.get(
        mood_key,
        set(),
    )

    styles = []

    for item in outfit.get("items", []):

        style = item.get("style")

        if style:
            styles.append(
                style.strip().lower()
            )

    if not styles:
        return {
            "occasion_bonus": 0.0,
            "mood_bonus": 0.0,
        }

    occasion_matches = sum(
        1
        for style in styles
        if style in matching_occasion_styles
    )

    mood_matches = sum(
        1
        for style in styles
        if style in matching_mood_styles
    )

    occasion_score = (
        occasion_matches / len(styles)
    )

    mood_score = (
        mood_matches / len(styles)
    )

    # Maximum:
    # Occasion = +0.06
    # Mood     = +0.04
    occasion_bonus = occasion_score * 0.06
    mood_bonus = mood_score * 0.04

    return {
        "occasion_bonus": occasion_bonus,
        "mood_bonus": mood_bonus,
    }

# -------------------------------------------------------------------
# Generate outfit
# -------------------------------------------------------------------

def generate_outfits(
    count: int = 5,
    occasion: str = "Casual",
    mood: str = "Relaxed",
) -> List[Dict]:

    wardrobe = get_clothing_items()

    if len(wardrobe) < 2:
        return []

    preferences = get_feedback_preferences()

    upper = [
        item
        for item in wardrobe
        if category_group(
            item.get("category", "")
        ) == "upper"
    ]

    lower = [
        item
        for item in wardrobe
        if category_group(
            item.get("category", "")
        ) == "lower"
    ]

    full = [
        item
        for item in wardrobe
        if category_group(
            item.get("category", "")
        ) == "full"
    ]

    candidates = []

    # ---------------------------------------------------------------
    # Full-body outfits
    # ---------------------------------------------------------------

    for dress in full:

        outfit = {
            "items": [dress],
        }

        base_score = 0.75

        personalization = personalization_bonus(
            outfit,
            preferences,
        )

        context_bonus = occasion_mood_bonus(
            outfit,
            occasion,
            mood,
        )

        occasion_bonus = context_bonus["occasion_bonus"]
        mood_bonus = context_bonus["mood_bonus"]

        score = (
            base_score
            + personalization
            + occasion_bonus
            + mood_bonus
        )

        score = min(
            1.0,
            max(0.0, score),
        )

        print("========================================")
        print("🧠 PERSONALIZATION")
        print(
            "Outfit:",
            [
                item.get("id")
                for item in outfit["items"]
            ],
        )
        print(
            "Base score:",
            round(base_score, 4),
        )
        print(
            "Personalization bonus:",
            f"{personalization:+.4f}",
        )
        print(
            "Occasion bonus:",
            f"{occasion_bonus:+.4f}",
        )
        print(
            "Mood bonus:",
            f"{mood_bonus:+.4f}",
        )
        print(
            "Final score:",
            round(score, 4),
        )
        print("========================================")

        candidates.append({
            "items": [dress],
            "score": min(
                1.0,
                max(0.0, score),
            ),
            "reason": (
                f"{dress.get('style', 'versatile').title()} "
                f"full-body look in "
                f"{dress.get('color', 'a versatile color')}."
            ),
            "occasion": occasion,
            "mood": mood,
            "style": dress.get("style"),
        })

    # ---------------------------------------------------------------
    # Upper + lower
    # ---------------------------------------------------------------

    for top in upper:

        for bottom in lower:

            scores = calculate_pair_score(
                top,
                bottom,
            )

            outfit = {
                "items": [
                    top,
                    bottom,
                ],
            }

            base_score = scores["score"]

            personalization = personalization_bonus(
                outfit,
                preferences,
            )

            context_bonus = occasion_mood_bonus(
                outfit,
                occasion,
                mood,
            )

            occasion_bonus = context_bonus["occasion_bonus"]
            mood_bonus = context_bonus["mood_bonus"]

            score = (
                base_score
                + personalization
                + occasion_bonus
                + mood_bonus
            )

            score = min(
                1.0,
                max(0.0, score),
            )

            print("========================================")
            print("🧠 PERSONALIZATION")
            print(
                "Outfit:",
                [
                    item.get("id")
                    for item in outfit["items"]
                ],
            )
            print(
                "Base score:",
                round(base_score, 4),
            )
            print(
                "Personalization bonus:",
                f"{personalization:+.4f}",
            )
            print(
                "Occasion bonus:",
                f"{occasion_bonus:+.4f}",
            )
            print(
                "Mood bonus:",
                f"{mood_bonus:+.4f}",
            )
            print(
                "Final score:",
                round(score, 4),
            )
            
            print("========================================")

            reason = (
                f"{top.get('style', 'casual').title()} "
                f"combines with "
                f"{bottom.get('style', 'casual').title()} "
                f"and balances "
                f"{top.get('color', 'neutral')} with "
                f"{bottom.get('color', 'neutral')}."
            )

            candidates.append({
                "items": [
                    top,
                    bottom,
                ],
                "score": score,
                "reason": reason,
                "score_breakdown": scores,
                "occasion": occasion,
                "mood": mood,
                "style": top.get("style"),
            })

    # ---------------------------------------------------------------
    # Sort
    # ---------------------------------------------------------------

    candidates.sort(
        key=lambda x: x["score"],
        reverse=True,
    )

    # ---------------------------------------------------------------
    # Recommendation variety
    #
    # Use the strongest candidates, but vary their order so repeated
    # generation does not always return exactly the same outfits.
    # Higher-scoring outfits remain more likely to appear first.
    # ---------------------------------------------------------------

    candidate_pool = candidates[:10]

    if candidate_pool:

        weights = [
            max(candidate["score"], 0.01)
            for candidate in candidate_pool
        ]

        varied_candidates = []

        remaining_candidates = candidate_pool.copy()
        remaining_weights = weights.copy()

        while remaining_candidates:

            selected = random.choices(
                remaining_candidates,
                weights=remaining_weights,
                k=1,
            )[0]

            selected_index = remaining_candidates.index(
                selected
            )

            varied_candidates.append(
                selected
            )

            remaining_candidates.pop(
                selected_index
            )

            remaining_weights.pop(
                selected_index
            )

        varied_candidates.sort(
            key=lambda outfit: outfit.get("score", 0),
            reverse=True,
        )

    else:
        varied_candidates = []

    # ---------------------------------------------------------------
    # Remove duplicate item combinations
    # ---------------------------------------------------------------

    seen = set()

    # Existing outfits that can be reused
    results = []

    # Brand-new outfits that still need to be saved
    new_outfits = []

    for candidate in varied_candidates:

        ids = tuple(
            sorted(
                str(item["id"])
                for item in candidate["items"]
            )
        )

        if ids in seen:
            continue

        seen.add(ids)

        # -----------------------------------------------------------
        # Check whether this exact clothing combination already exists
        # -----------------------------------------------------------

        clothing_ids = [
            int(item["id"])
            for item in candidate["items"]
        ]

        existing_outfit = find_existing_outfit(
            clothing_ids=clothing_ids,
        )

        if existing_outfit is not None:

            print(
                "🔎 EXISTING OUTFIT FOUND:",
                existing_outfit["id"],
            )

            # -------------------------------------------------------
            # Skip if previously disliked
            # -------------------------------------------------------

            if existing_outfit.get("feedback") == "DISLIKE":

                print(
                    "👎 EXISTING OUTFIT WAS DISLIKED - SKIPPING:",
                    existing_outfit["id"],
                )

                continue

            # -------------------------------------------------------
            # Reuse existing outfit
            # -------------------------------------------------------

            print(
                "♻️ REUSING EXISTING OUTFIT:",
                existing_outfit["id"],
            )

            existing_image_url = existing_outfit.get(
                "image_url"
            )

            # -------------------------------------------------------
            # Check whether the existing preview file still exists
            # -------------------------------------------------------

            preview_exists = False

            if existing_image_url:
                preview_filename = os.path.basename(
                    existing_image_url
                )

                preview_path = os.path.join(
                    OUTFIT_PREVIEW_DIR,
                    preview_filename,
                )

                preview_exists = os.path.isfile(
                    preview_path
                )

            # -------------------------------------------------------
            # Regenerate missing preview
            # -------------------------------------------------------

            if not preview_exists:

                print(
                    "⚠ Existing outfit preview is missing."
                )

                print(
                    "🔄 Regenerating preview for outfit:",
                    existing_outfit["id"],
                )

                regenerated_preview = create_outfit_preview(
                    str(existing_outfit["id"]),
                    candidate["items"],
                )

                if regenerated_preview is not None:

                    existing_image_url = regenerated_preview

                    update_outfit_preview(
                        outfit_id=existing_outfit["id"],
                        image_url=regenerated_preview,
                    )

                    print(
                        "🔥 REGENERATED OUTFIT IMAGE URL:",
                        regenerated_preview,
                    )

                else:
                    print(
                        "⚠ Failed to regenerate outfit preview."
                    )

            # -------------------------------------------------------
            # Build result
            # -------------------------------------------------------

            result = {
                "id": existing_outfit["id"],
                "title": existing_outfit.get(
                    "title",
                    "AI Outfit",
                ),
                "items": candidate["items"],
                "occasion": candidate.get("occasion"),
                "mood": candidate.get("mood"),
                "style": candidate.get("style"),
                "image_url": existing_image_url,
                "score": round(
                    candidate["score"],
                    4,
                ),
                "reason": candidate["reason"],
                "score_breakdown": candidate.get(
                    "score_breakdown"
                ),
                "created_at": (
                    existing_outfit["created_at"].isoformat()
                    if existing_outfit.get("created_at")
                    else None
                ),
            }

            results.append(result)

        else:

            print(
                "👕 PREVIEW ITEMS:",
                [
                    (
                        item.get("id"),
                        item.get("name"),
                        item.get("category"),
                        item.get("processed_image_path"),
                    )
                    for item in candidate["items"]
                ],
            )

            # -------------------------------------------------------
            # New outfit
            #
            # No ID yet.
            # MySQL will generate the ID later.
            # -------------------------------------------------------

            result = {
                "title": "AI Outfit",
                "items": candidate["items"],
                "occasion": candidate.get("occasion"),
                "mood": candidate.get("mood"),
                "style": candidate.get("style"),
                "score": round(
                    candidate["score"],
                    4,
                ),
                "reason": candidate["reason"],
                "score_breakdown": candidate.get(
                    "score_breakdown"
                ),
            }

            new_outfits.append(result)

        # -----------------------------------------------------------
        # Stop collecting once we have enough outfits
        # -----------------------------------------------------------

        if len(results) + len(new_outfits) >= count:
            break

    # ---------------------------------------------------------------
    # Save ONLY brand-new outfits to MySQL
    # ---------------------------------------------------------------

    if new_outfits:

        saved_new_outfits = save_generated_outfits(
            new_outfits
        )

        for saved_outfit in saved_new_outfits:

            outfit_id = saved_outfit["id"]

            preview_image = create_outfit_preview(
                str(outfit_id),
                saved_outfit["items"],
            )

            if preview_image is None:
                continue

            saved_outfit["image_url"] = preview_image

            print(
                "🔥 GENERATED OUTFIT IMAGE URL:",
                preview_image,
            )

            update_outfit_preview(
                outfit_id=outfit_id,
                image_url=preview_image,
            )

        results.extend(
            saved_new_outfits
        )


    # ---------------------------------------------------------------
    # Final results
    # ---------------------------------------------------------------

    results = results[:count]

    cleanup_old_outfit_previews(
        keep_latest=50
    )

    print("========================================")
    print("🔥 FINAL GENERATED RESULTS")

    for result in results:
        print(
            "OUTFIT:",
            result.get("id"),
            "ITEMS:",
            [
                item.get("id")
                for item in result.get("items", [])
            ],
            "SCORE:",
            result.get("score"),
            "IMAGE:",
            result.get("image_url"),
        )

    print("========================================")

    return results



# -------------------------------------------------------------------
# Another outfit
# -------------------------------------------------------------------

def generate_another_outfit() -> Optional[Dict]:

    outfits = generate_outfits(
        count=10
    )

    if not outfits:
        return None

    return outfits[0]


# -------------------------------------------------------------------
# Feedback
# -------------------------------------------------------------------
def submit_feedback(
    outfit_id: int,
    feedback: str,
) -> Optional[Dict]:

    result = submit_outfit_feedback(
        outfit_id=outfit_id,
        feedback=feedback,
    )

    if result is None:
        return None

    print(
        "========================================"
    )
    print(
        "FEEDBACK RESULT"
    )
    print(
        result
    )
    print(
        "========================================"
    )

    return result