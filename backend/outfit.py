import os
import json
import uuid
import random
from datetime import datetime
from typing import List, Dict, Optional

from ai_service import (
    category_group,
    compare_embeddings,
)
from wardrobe import load_wardrobe


BASE_DIR = os.path.dirname(
    os.path.abspath(__file__)
)

GENERATED_OUTFITS_FILE = os.path.join(
    BASE_DIR,
    "generated_outfits.json",
)

PREFERENCES_FILE = os.path.join(
    BASE_DIR,
    "preferences.json",
)


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


# -------------------------------------------------------------------
# Generated outfit storage
# -------------------------------------------------------------------

def load_generated_outfits():

    return _load_json(
        GENERATED_OUTFITS_FILE,
        [],
    )


def save_generated_outfits(
    outfits: List[Dict],
):
    _save_json(
        GENERATED_OUTFITS_FILE,
        outfits,
    )


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

def calculate_pair_score(
    item_a: Dict,
    item_b: Dict,
) -> Dict:

    style = style_score(
        item_a.get("style", ""),
        item_b.get("style", ""),
    )

    color = color_score(
        item_a.get("color", ""),
        item_b.get("color", ""),
    )

    visual = compare_embeddings(
        item_a.get("visual_embedding"),
        item_b.get("visual_embedding"),
    )

    # Convert cosine similarity
    # from [-1, 1] to approximately [0, 1].
    visual_normalized = (
        visual + 1
    ) / 2

    final_score = (
        style * 0.40
        + color * 0.35
        + visual_normalized * 0.25
    )

    return {
        "style_score": round(style, 4),
        "color_score": round(color, 4),
        "visual_score": round(
            visual_normalized,
            4,
        ),
        "score": round(
            final_score,
            4,
        ),
    }


# -------------------------------------------------------------------
# Personalisation score
# -------------------------------------------------------------------

def personalization_bonus(
    outfit: Dict,
) -> float:

    preferences = load_preferences()

    bonus = 0.0

    preferred_styles = preferences.get(
        "preferred_styles",
        [],
    )

    preferred_colors = preferences.get(
        "preferred_colors",
        [],
    )

    disliked_styles = preferences.get(
        "disliked_styles",
        [],
    )

    disliked_colors = preferences.get(
        "disliked_colors",
        [],
    )

    for item in outfit["items"]:

        style = item.get(
            "style",
            "",
        ).lower()

        color = item.get(
            "color",
            "",
        ).lower()

        if style in preferred_styles:
            bonus += 0.05

        if color in preferred_colors:
            bonus += 0.05

        if style in disliked_styles:
            bonus -= 0.10

        if color in disliked_colors:
            bonus -= 0.10

    return bonus


# -------------------------------------------------------------------
# Generate outfit
# -------------------------------------------------------------------

def generate_outfits(
    count: int = 5,
) -> List[Dict]:

    wardrobe = load_wardrobe()

    if len(wardrobe) < 2:
        return []

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

        score = 0.75

        score += personalization_bonus(
            outfit
        )

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

            score = (
                scores["score"]
                + personalization_bonus(
                    outfit
                )
            )

            score = min(
                1.0,
                max(0.0, score),
            )

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
            })

    # ---------------------------------------------------------------
    # Sort
    # ---------------------------------------------------------------

    candidates.sort(
        key=lambda x: x["score"],
        reverse=True,
    )

    # Remove duplicate item combinations
    seen = set()

    results = []

    for candidate in candidates:

        ids = tuple(
            sorted(
                str(item["id"])
                for item in candidate["items"]
            )
        )

        if ids in seen:
            continue

        seen.add(ids)

        outfit_id = str(
            uuid.uuid4()
        )

        result = {
            "id": outfit_id,
            "title": "AI Outfit",
            "items": candidate["items"],
            "score": round(
                candidate["score"],
                4,
            ),
            "reason": candidate["reason"],
            "score_breakdown": candidate.get(
                "score_breakdown"
            ),
            "created_at": datetime.now().isoformat(),
        }

        results.append(result)

        if len(results) >= count:
            break

    save_generated_outfits(
        results
    )

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
    outfit_id: str,
    feedback: str,
) -> Optional[Dict]:

    feedback = feedback.upper()

    if feedback not in (
        "LIKE",
        "DISLIKE",
    ):
        raise ValueError(
            "Feedback must be LIKE or DISLIKE."
        )

    outfits = load_generated_outfits()

    outfit = None

    for item in outfits:
        if str(item["id"]) == str(
            outfit_id
        ):
            outfit = item
            break

    if outfit is None:
        return None

    preferences = load_preferences()

    if feedback == "LIKE":

        for item in outfit["items"]:

            style = item.get(
                "style"
            )

            color = item.get(
                "color"
            )

            if (
                style
                and style not in preferences[
                    "preferred_styles"
                ]
            ):
                preferences[
                    "preferred_styles"
                ].append(style)

            if (
                color
                and color not in preferences[
                    "preferred_colors"
                ]
            ):
                preferences[
                    "preferred_colors"
                ].append(color)

    else:

        for item in outfit["items"]:

            style = item.get(
                "style"
            )

            color = item.get(
                "color"
            )

            if (
                style
                and style not in preferences[
                    "disliked_styles"
                ]
            ):
                preferences[
                    "disliked_styles"
                ].append(style)

            if (
                color
                and color not in preferences[
                    "disliked_colors"
                ]
            ):
                preferences[
                    "disliked_colors"
                ].append(color)

    save_preferences(
        preferences
    )

    outfit["feedback"] = feedback

    save_generated_outfits(
        outfits
    )

    return outfit