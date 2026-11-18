import os
import math
import uuid
import json

from fastapi import (
    FastAPI,
    UploadFile,
    File,
    HTTPException,
    Form
)
from pydantic import BaseModel, Field
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from database.db import get_connection
from typing import List, Optional

from database.clothing import (
    create_clothing_item,
    update_clothing_item,
)
from database.outfit import (
    submit_outfit_feedback,
    get_outfit_feedback,
    find_existing_outfit,
    category_group_for_role,
)
from wardrobe import (
    PROCESSED_DIR,
    UPLOAD_DIR,
    process_clothing,
    get_clothing_item,
    reset_generated_outfits,
    detect_category,
)

from outfit import (
    generate_outfits,
    generate_another_outfit,
    create_outfit_preview,
    OUTFIT_PREVIEW_DIR,
    create_vto_garment_reference,
)
from fastapi.staticfiles import StaticFiles

class UserPreferencesRequest(BaseModel):
    gender: str | None = None

    preferred_styles: list[str] = Field(default_factory=list)
    preferred_colors: list[str] = Field(default_factory=list)
    preferred_categories: list[str] = Field(default_factory=list)
    preferred_occasions: list[str] = Field(default_factory=list)
    disliked_styles: list[str] = Field(default_factory=list)
    disliked_colors: list[str] = Field(default_factory=list)

class SeasonalColorRequest(BaseModel):
    undertone: str
    hair_color: str
    eye_color: str
    contrast_level: str
    season: str

# -------------------------------------------------------------------
# FastAPI
# -------------------------------------------------------------------

app = FastAPI(
    title="Wearly AI Wardrobe API",
    version="1.0.0",
)

# ========================================================
# PROFILE IMAGE STORAGE
# ========================================================

PROFILE_UPLOAD_DIR = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "uploads",
    "profile"
)

os.makedirs(PROFILE_UPLOAD_DIR, exist_ok=True)

app.mount(
    "/uploads/profile",
    StaticFiles(directory=PROFILE_UPLOAD_DIR),
    name="profile_images"
)

app.mount(
    "/processed",
    StaticFiles(directory=PROCESSED_DIR),
    name="processed",
)

app.mount(
    "/outfit-previews",
    StaticFiles(directory=OUTFIT_PREVIEW_DIR),
    name="outfit-previews",
)


# -------------------------------------------------------------------
# CORS
# -------------------------------------------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# -------------------------------------------------------------------
# Request models
# -------------------------------------------------------------------

class OutfitFeedbackRequest(BaseModel):
    feedback: str

class OutfitHistoryRequest(BaseModel):
    item_ids: Optional[List[str]] = None
    outfit_id: Optional[int] = None
    worn_date: str
    notes: Optional[str] = None

class OutfitGenerationRequest(BaseModel):
    occasion: str
    mood: str

# -------------------------------------------------------------------
# Basic route
# -------------------------------------------------------------------

@app.get("/")
def root():

    return {
        "app": "Wearly",
        "status": "running",
        "message": "Wearly AI Wardrobe API",
    }


# -------------------------------------------------------------------
# Wardrobe
# -------------------------------------------------------------------

@app.get("/wardrobe")
async def get_wardrobe():
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        query = """
            SELECT
                id,
                user_id,
                name,
                category,
                subcategory,
                brand,
                color,
                style,
                material,
                image_path,
                processed_image_path,
                is_favorite,
                is_active,
                created_at,
                updated_at
            FROM clothing_items
            WHERE is_active = TRUE
            ORDER BY created_at DESC
        """

        cursor.execute(query)

        items = cursor.fetchall()

        cursor.close()
        connection.close()

        return {
            "success": True,
            "items": items,
        }

    except Exception as e:
        print(f"❌ Failed to load wardrobe: {e}")

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

@app.get("/wardrobe/wear-index")
def get_wear_index():

    user_id = 1  # TEMPORARY DEMO USER

    connection = get_connection()
    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                COUNT(DISTINCT ci.id) AS total_items,
                COUNT(DISTINCT CASE
                    WHEN oh.id IS NOT NULL THEN ci.id
                END) AS worn_items
            FROM clothing_items ci
            LEFT JOIN outfit_items oi
                ON ci.id = oi.clothing_id
            LEFT JOIN outfit_history oh
                ON oi.outfit_id = oh.outfit_id
                AND oh.user_id = ci.user_id
            WHERE ci.user_id = %s
            AND ci.is_active = TRUE;
            """,
            (user_id,)
        )

        result = cursor.fetchone()

        print("WEAR INDEX USER ID:", user_id)
        print("WEAR INDEX SQL RESULT:", result)

        total_items = result["total_items"]
        worn_items = result["worn_items"]

        wear_index = (
            round((worn_items / total_items) * 100)
            if total_items > 0
            else 0
        )

        return {
            "total_items": total_items,
            "worn_items": worn_items,
            "wear_index": wear_index
        }


    finally:
        if cursor:
            cursor.close()

        connection.close()

@app.get("/wardrobe/color-palette")
def get_wardrobe_color_palette():

    user_id = 1  # TEMPORARY DEMO USER

    connection = get_connection()
    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                LOWER(TRIM(color)) AS color,
                COUNT(*) AS item_count
            FROM clothing_items
            WHERE user_id = %s
                AND is_active = TRUE
                AND color IS NOT NULL
                AND TRIM(color) != ''
            GROUP BY LOWER(TRIM(color))
            ORDER BY item_count DESC
            LIMIT 5;
            """,
            (user_id,)
        )

        results = cursor.fetchall()

        color_map = {
            "black": "#222222",
            "white": "#F5F5F5",
            "light gray": "#D3D3D3",
            "dark gray": "#555555",
            "gray": "#808080",
            "beige": "#D8C3A5",
            "brown": "#795548",
            "navy blue": "#1E3A5F",
            "blue": "#2196F3",
            "green": "#4F7942",
            "red": "#C62828",
            "orange": "#E68A35",
            "yellow": "#E5C453",
            "pink": "#E8A0B5",
            "purple": "#8064A2",
            "multicolor": "#A78BBA",
        }

        colors = []

        for item in results:
            color_name = item["color"]

            colors.append({
                "name": color_name.title(),
                "color": color_map.get(color_name, "#A0A0A0"),
                "count": item["item_count"],
            })

        return {
            "success": True,
            "colors": colors,
        }

    finally:
        if cursor:
            cursor.close()

        connection.close()

@app.get("/wardrobe/style-preferences")
def get_style_preferences():

    user_id = 1  # TEMPORARY DEMO USER

    connection = get_connection()
    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                LOWER(TRIM(COALESCE(
                    NULLIF(TRIM(ci.style), ''),
                    NULLIF(TRIM(ai.detected_style), '')
                ))) AS style,
                COUNT(DISTINCT ci.id) AS item_count
            FROM clothing_items ci
            LEFT JOIN clothing_ai_analysis ai
                ON ci.id = ai.clothing_id
            WHERE ci.user_id = %s
                AND ci.is_active = TRUE
                AND COALESCE(
                    NULLIF(TRIM(ci.style), ''),
                    NULLIF(TRIM(ai.detected_style), '')
                ) IS NOT NULL
            GROUP BY
                LOWER(TRIM(COALESCE(
                    NULLIF(TRIM(ci.style), ''),
                    NULLIF(TRIM(ai.detected_style), '')
                )));
            """,
            (user_id,)
        )

        results = cursor.fetchall()

        groups = {
            "Relaxed Tailoring": [
                "casual",
                "relaxed",
                "smart casual",
            ],
            "Oversized Outerwear": [
                "streetwear",
                "sporty",
                "vintage",
            ],
            "Structured Minimal": [
                "formal",
                "minimalist",
                "elegant",
                "preppy",
            ],
        }

        counts = {
            group: 0
            for group in groups
        }

        for item in results:
            style = item["style"]

            for group, styles in groups.items():
                if style in styles:
                    counts[group] += item["item_count"]
                    break

        total = sum(counts.values())

        preferences = []

        for group, count in counts.items():
            percentage = (
                round((count / total) * 100)
                if total > 0
                else 0
            )

            preferences.append({
                "title": group,
                "count": count,
                "percentage": percentage,
            })

        preferences.sort(
            key=lambda item: item["count"],
            reverse=True,
        )

        return {
            "success": True,
            "total_items": total,
            "preferences": preferences,
        }

    except Exception as e:
        import traceback

        print("STYLE PREFERENCES ERROR:")
        traceback.print_exc()

        raise

    finally:
        if cursor:
            cursor.close()

        connection.close()


@app.get("/wardrobe/{item_id}")
def wardrobe_item(
    item_id: str,
):

    item = get_clothing_item(
        item_id
    )

    if item is None:
        raise HTTPException(
            status_code=404,
            detail="Clothing item not found.",
        )

    return item

class SaveClothingRequest(BaseModel):
    name: str
    category: str
    subcategory: str
    brand: str
    color: str
    style: str
    material: str
    image_path: str
    processed_image_path: str
    ai_analysis: dict | None = None

@app.post("/wardrobe")
async def save_wardrobe_item(request: SaveClothingRequest):
    try:
        item = create_clothing_item(
            user_id=1,
            name=request.name,
            category=request.category,
            subcategory=request.subcategory,
            brand=request.brand,
            color=request.color,
            style=request.style,
            material=request.material,
            image_path=request.image_path,
            processed_image_path=request.processed_image_path,
            ai_analysis=request.ai_analysis,
        )

        reset_generated_outfits()

        return {
            "success": True,
            "item": item,
        }

    except Exception as e:
        print(f"❌ Failed to save clothing: {e}")
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

class UpdateClothingRequest(BaseModel):
    name: str
    brand: str
    category: str
    color: str
    style: str
    material: str

@app.put("/wardrobe/{clothing_id}")
async def update_wardrobe_item(
    clothing_id: int,
    request: UpdateClothingRequest,
):
    try:
        success = update_clothing_item(
            clothing_id=clothing_id,
            user_id=1,
            name=request.name,
            brand=request.brand,
            category=request.category,
            color=request.color,
            style=request.style,
            material=request.material,
        )

        if not success:
            raise HTTPException(
                status_code=404,
                detail="Clothing item not found.",
            )

        reset_generated_outfits()

        return {
            "success": True,
            "message": "Clothing item updated successfully.",
        }

    except HTTPException:
        raise

    except Exception as e:
        print(f"❌ Failed to update clothing: {e}")
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )
     
@app.post("/process-clothing")
async def process_clothing_route(
    file: UploadFile = File(...),
    selected_category: str | None = Form(None),
):
    try:

        print(
            f"✓ User selected category: "
            f"{selected_category}"
        )

        item = await process_clothing(
            file,
            selected_category=selected_category,
        )

        return {
            "success": True,
            "item": item,
        }

    except Exception as e:

        print(
            f"❌ Clothing processing error: {e}"
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

@app.delete("/wardrobe/{item_id}")
def delete_wardrobe_item(item_id: str):

    connection = None
    cursor = None

    try:
        connection = get_connection()

        cursor = connection.cursor()

        cursor.execute(
            """
            UPDATE clothing_items
            SET
                is_active = FALSE,
                updated_at = NOW()
            WHERE id = %s
              AND is_active = TRUE
            """,
            (item_id,),
        )

        if cursor.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="Clothing item not found.",
            )

        connection.commit()

        print(
            f"✓ Clothing item removed from wardrobe: {item_id}"
        )

        return {
            "success": True,
            "message": "Clothing item removed.",
            "id": item_id,
        }

    except HTTPException:
        raise

    except Exception as e:

        if connection is not None:
            connection.rollback()

        print(
            "❌ DELETE CLOTHING ERROR:",
            e,
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    finally:

        if cursor is not None:
            cursor.close()

        if connection is not None:
            connection.close()

# -------------------------------------------------------------------
# Processed images
# -------------------------------------------------------------------

@app.get("/processed/{filename}")
def processed_image(
    filename: str,
):

    base_dir = os.path.join(
        os.path.dirname(
            os.path.abspath(__file__)
        ),
        "processed",
    )

    file_path = os.path.join(
        base_dir,
        filename,
    )

    if not os.path.exists(file_path):
        raise HTTPException(
            status_code=404,
            detail="Processed image not found.",
        )

    return FileResponse(
        file_path
    )


# -------------------------------------------------------------------
# Debug images
# -------------------------------------------------------------------

@app.get("/debug/{filename}")
def debug_image(
    filename: str,
):

    base_dir = os.path.join(
        os.path.dirname(
            os.path.abspath(__file__)
        ),
        "debug",
    )

    file_path = os.path.join(
        base_dir,
        filename,
    )

    if not os.path.exists(file_path):
        raise HTTPException(
            status_code=404,
            detail="Debug image not found.",
        )

    return FileResponse(
        file_path
    )


# -------------------------------------------------------------------
# Outfit generation
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


@app.post("/generate-outfit")
def generate_outfit(
    request: OutfitGenerationRequest,
):

    print(
        "🎯 OUTFIT CONTEXT:",
        "OCCASION =", request.occasion,
        "MOOD =", request.mood,
    )

    outfits = generate_outfits(
        count=5,
        occasion=request.occasion,
        mood=request.mood,
    )

    # ------------------------------------------------------------
    # Load existing Like / Dislike feedback
    # ------------------------------------------------------------

    for outfit in outfits:

        outfit_id = outfit.get("id")

        if outfit_id is not None:
            feedback = get_outfit_feedback(
                outfit_id=int(outfit_id)
            )

            outfit["feedback"] = feedback

    outfits = sanitize_json_value(outfits)

    # ------------------------------------------------------------
    # Debug
    # ------------------------------------------------------------

    print("🔥 FINAL GENERATED RESULTS")

    for outfit in outfits:
        print(
            "OUTFIT:",
            outfit.get("id"),
            "FEEDBACK:",
            outfit.get("feedback"),
            "IMAGE:",
            outfit.get("image_url"),
        )

    return {
        "success": True,
        "outfits": outfits,
    }

@app.post("/generate-outfit/another")
def another_outfit():

    outfit = generate_another_outfit()

    if outfit is None:
        raise HTTPException(
            status_code=400,
            detail=(
                "Not enough clothing items "
                "to generate an outfit."
            ),
        )

    return {
        "success": True,
        "outfit": outfit,
    }


# -------------------------------------------------------------------
# Like / Dislike
# -------------------------------------------------------------------

@app.post(
    "/outfit/{outfit_id}/feedback"
)
def outfit_feedback(
    outfit_id: int,
    request: OutfitFeedbackRequest,
):

    try:

        result = submit_outfit_feedback(
            outfit_id=outfit_id,
            feedback=request.feedback,
        )

        result = sanitize_json_value(
            result
        )

        if result is None:
            raise HTTPException(
                status_code=404,
                detail="Outfit not found.",
            )

        return {
            "success": True,
            "outfit": result,
        }

    except ValueError as e:

        raise HTTPException(
            status_code=400,
            detail=str(e),
        )

    
# ============================================================
# LIGHTWEIGHT CATEGORY DETECTION
# ============================================================

@app.post("/detect-category")
async def detect_category_route(
    file: UploadFile = File(...),
):

    try:

        # ----------------------------------------------------
        # Save temporary uploaded image
        # ----------------------------------------------------

        import uuid

        extension = os.path.splitext(
            file.filename or ".jpg"
        )[1].lower()

        if extension not in (
            ".jpg",
            ".jpeg",
            ".png",
            ".webp",
        ):
            extension = ".jpg"

        temp_filename = (
            f"category_{uuid.uuid4()}{extension}"
        )

        temp_path = os.path.join(
            UPLOAD_DIR,
            temp_filename,
        )

        contents = await file.read()

        with open(
            temp_path,
            "wb",
        ) as output:
            output.write(contents)

        print(
            f"✓ Category detection image saved: "
            f"{temp_filename}"
        )

        # ----------------------------------------------------
        # FASHN category detection
        # ----------------------------------------------------

        result = detect_category(
            temp_path
        )

        print(
            f"✓ Detected category: "
            f"{result['category']} "
            f"({result['category_confidence']:.3f})"
        )

        # ----------------------------------------------------
        # Remove temporary image
        # ----------------------------------------------------

        try:
            os.remove(temp_path)
        except Exception:
            pass

        return {
            "success": True,
            **result,
        }

    except Exception as e:

        print(
            f"❌ Category detection error: {e}"
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )



# ============================================================
# RECORD OUTFIT PREVIEW
# ============================================================

@app.post("/record-outfit-preview")
def record_outfit_preview(data: dict):
    try:
        item_ids = data.get("item_ids", [])

        if not item_ids:
            raise HTTPException(
                status_code=400,
                detail="No clothing items selected.",
            )

        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        placeholders = ", ".join(["%s"] * len(item_ids))

        query = f"""
            SELECT
                id,
                user_id,
                name,
                category,
                subcategory,
                brand,
                color,
                style,
                material,
                image_path,
                processed_image_path,
                is_favorite,
                is_active,
                created_at,
                updated_at
            FROM clothing_items
            WHERE id IN ({placeholders})
              AND is_active = TRUE
        """

        cursor.execute(
            query,
            tuple(item_ids),
        )

        selected_items = cursor.fetchall()

        cursor.close()
        connection.close()

        if not selected_items:
            raise HTTPException(
                status_code=404,
                detail="Selected clothing items were not found.",
            )

        # Make sure every requested item was found.
        selected_ids = {
            str(item["id"])
            for item in selected_items
        }

        missing_ids = [
            str(item_id)
            for item_id in item_ids
            if str(item_id) not in selected_ids
        ]

        if missing_ids:
            raise HTTPException(
                status_code=404,
                detail=f"Clothing items not found: {missing_ids}",
            )

        preview_id = f"record_{uuid.uuid4().hex}"

        preview_image = create_outfit_preview(
            preview_id,
            selected_items,
        )

        if preview_image is None:
            raise HTTPException(
                status_code=400,
                detail="Unable to create outfit preview.",
            )

        return {
            "image_url": preview_image,
            "items": selected_items,
        }

    except HTTPException:
        raise

    except Exception as e:
        print(
            "❌ RECORD OUTFIT PREVIEW ERROR:",
            e,
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

@app.get("/outfit-history")
def get_outfit_history(
    year: int,
    month: int,
):
    connection = None
    cursor = None

    try:
        user_id = 1

        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        # ============================================================
        # GET OUTFIT HISTORY
        # ============================================================

        cursor.execute(
            """
            SELECT
                oh.id AS history_id,
                oh.worn_date,
                oh.notes,

                o.id AS outfit_id,
                o.title AS outfit_title,
                o.image_url,

                oi.clothing_id,
                oi.role,
                oi.display_order,

                ci.name AS clothing_name,
                ci.category,
                ci.processed_image_path,
                ci.image_path

            FROM outfit_history oh

            INNER JOIN outfits o
                ON o.id = oh.outfit_id

            INNER JOIN outfit_items oi
                ON oi.outfit_id = o.id

            INNER JOIN clothing_items ci
                ON ci.id = oi.clothing_id

            WHERE oh.user_id = %s
              AND YEAR(oh.worn_date) = %s
              AND MONTH(oh.worn_date) = %s
              AND ci.is_active = TRUE

            ORDER BY
                oh.worn_date DESC,
                oh.id DESC,
                oi.display_order ASC
            """,
            (
                user_id,
                year,
                month,
            ),
        )

        rows = cursor.fetchall()

        # ============================================================
        # GROUP CLOTHING ITEMS BY HISTORY ENTRY
        # ============================================================

        history_map = {}

        for row in rows:

            history_id = row["history_id"]

            if history_id not in history_map:
                history_map[history_id] = {
                    "history_id": history_id,
                    "worn_date": str(row["worn_date"]),
                    "notes": row["notes"],
                    "outfit_id": row["outfit_id"],
                    "title": row["outfit_title"] or "Recorded Look",
                    "image_url": row["image_url"],
                    "items": [],
                }

            history_map[history_id]["items"].append(
                {
                    "id": row["clothing_id"],
                    "name": row["clothing_name"],
                    "category": row["category"],
                    "processed_image_path": row[
                        "processed_image_path"
                    ],
                    "image_path": row["image_path"],
                    "role": row["role"],
                    "display_order": row["display_order"],
                }
            )

        history = list(history_map.values())

        # ============================================================
        # ROTATION RATE
        # ============================================================

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM clothing_items
            WHERE user_id = %s
              AND is_active = TRUE
            """,
            (user_id,),
        )

        total_active_items = cursor.fetchone()["COUNT(*)"]

        cursor.execute(
            """
            SELECT COUNT(DISTINCT oi.clothing_id)
            FROM outfit_history oh

            INNER JOIN outfit_items oi
                ON oi.outfit_id = oh.outfit_id

            INNER JOIN clothing_items ci
                ON ci.id = oi.clothing_id

            WHERE oh.user_id = %s
              AND YEAR(oh.worn_date) = %s
              AND MONTH(oh.worn_date) = %s
              AND ci.is_active = TRUE
            """,
            (
                user_id,
                year,
                month,
            ),
        )

        used_items = cursor.fetchone()[
            "COUNT(DISTINCT oi.clothing_id)"
        ]

        if total_active_items > 0:
            rotation_rate = round(
                (used_items / total_active_items) * 100
            )
        else:
            rotation_rate = 0

        return {
            "success": True,
            "year": year,
            "month": month,
            "rotation_rate": rotation_rate,
            "total_active_items": total_active_items,
            "used_items": used_items,
            "history": history,
        }

    except Exception as e:

        print(
            "❌ GET OUTFIT HISTORY ERROR:",
            e,
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    finally:

        if cursor is not None:
            cursor.close()

        if connection is not None:
            connection.close()

@app.post("/outfit-history")
def save_outfit_history(
    request: OutfitHistoryRequest,
):
    connection = None
    cursor = None

    try:
        user_id = 1

        # ========================================================
        # 1. STYLIST PAGE
        #    Existing generated outfit ID was provided
        # ========================================================

        if request.outfit_id is not None:

            connection = get_connection()
            cursor = connection.cursor(
                dictionary=True
            )

            cursor.execute(
                """
                SELECT id
                FROM outfits
                WHERE id = %s
                  AND user_id = %s
                LIMIT 1
                """,
                (
                    request.outfit_id,
                    user_id,
                ),
            )

            existing_outfit = cursor.fetchone()

            if existing_outfit is None:
                raise HTTPException(
                    status_code=404,
                    detail="Outfit not found.",
                )

            outfit_id = request.outfit_id

            print(
                f"✓ Using stylist outfit: "
                f"{outfit_id}"
            )

        # ========================================================
        # 2. RECORD OUTFIT PAGE
        #    Clothing item IDs were provided
        # ========================================================

        elif request.item_ids:

            existing_outfit = find_existing_outfit(
                clothing_ids=request.item_ids,
                user_id=user_id,
            )

            # ====================================================
            # Existing outfit found
            # ====================================================

            if existing_outfit:

                outfit_id = existing_outfit["id"]

                print(
                    f"✓ Using existing outfit: "
                    f"{outfit_id}"
                )

            # ====================================================
            # New outfit
            # ====================================================

            else:

                # =================================================
                # 3. Create new recorded outfit
                # =================================================

                connection = get_connection()
                cursor = connection.cursor()

                if len(request.item_ids) == 1:
                    title = "Recorded Outfit"
                else:
                    title = "Recorded Look"

                cursor.execute(
                    """
                    INSERT INTO outfits (
                        user_id,
                        title,
                        recommendation_score,
                        is_generated,
                        is_saved
                    )
                    VALUES (
                        %s,
                        %s,
                        %s,
                        FALSE,
                        TRUE
                    )
                    """,
                    (
                        user_id,
                        title,
                        0.0,
                    ),
                )

                outfit_id = cursor.lastrowid

                # =============================================
                # Save outfit clothing items
                # =============================================

                for display_order, item_id in enumerate(
                    request.item_ids
                ):

                    cursor.execute(
                        """
                        SELECT
                            category
                        FROM clothing_items
                        WHERE id = %s
                          AND is_active = TRUE
                        LIMIT 1
                        """,
                        (item_id,),
                    )

                    item = cursor.fetchone()

                    if item is None:
                        raise HTTPException(
                            status_code=404,
                            detail=(
                                f"Clothing item "
                                f"{item_id} "
                                "was not found."
                            ),
                        )

                    category = item[0]

                    role = category_group_for_role(
                        category
                    )

                    cursor.execute(
                        """
                        INSERT INTO outfit_items (
                            outfit_id,
                            clothing_id,
                            role,
                            display_order
                        )
                        VALUES (
                            %s,
                            %s,
                            %s,
                            %s
                        )
                        """,
                        (
                            outfit_id,
                            item_id,
                            role,
                            display_order,
                        ),
                    )

                # =============================================
                # Generate outfit preview
                # =============================================

                cursor.execute(
                    """
                    SELECT
                        ci.id,
                        ci.category,
                        ci.processed_image_path,
                        ci.image_path
                    FROM clothing_items ci
                    INNER JOIN outfit_items oi
                        ON oi.clothing_id = ci.id
                    WHERE oi.outfit_id = %s
                    ORDER BY oi.display_order ASC
                    """,
                    (outfit_id,),
                )

                outfit_items = cursor.fetchall()

                preview_items = []

                for item in outfit_items:

                    preview_items.append(
                        {
                            "id": item[0],
                            "category": item[1],
                            "processed_image_path": item[2],
                            "image_path": item[3],
                        }
                    )

                image_url = create_outfit_preview(
                    str(outfit_id),
                    preview_items,
                )

                # =============================================
                # Save preview URL to outfits table
                # =============================================

                if image_url is not None:

                    cursor.execute(
                        """
                        UPDATE outfits
                        SET image_url = %s
                        WHERE id = %s
                        """,
                        (
                            image_url,
                            outfit_id,
                        ),
                    )

                    print(
                        f"✓ Saved outfit preview: "
                        f"{image_url}"
                    )

                else:

                    print(
                        "⚠ Could not create outfit preview."
                    )

                print(
                    f"✓ Created recorded outfit: "
                    f"{outfit_id}"
                )

        # ========================================================
        # 4. Nothing supplied
        # ========================================================

        else:

            raise HTTPException(
                status_code=400,
                detail=(
                    "Please provide either "
                    "outfit_id or item_ids."
                ),
            )

        # ========================================================
        # 5. Save to outfit_history
        # ========================================================

        if connection is None:

            connection = get_connection()
            cursor = connection.cursor()

        cursor.execute(
            """
            INSERT INTO outfit_history (
                user_id,
                outfit_id,
                worn_date,
                notes
            )
            VALUES (
                %s,
                %s,
                %s,
                %s
            )
            """,
            (
                user_id,
                outfit_id,
                request.worn_date,
                request.notes or None,
            ),
        )

        history_id = cursor.lastrowid

        # ========================================================
        # 6. Commit everything
        # ========================================================

        connection.commit()

        print(
            f"✓ Outfit history saved: "
            f"history_id={history_id}, "
            f"outfit_id={outfit_id}, "
            f"date={request.worn_date}"
        )

        return {
            "success": True,
            "history_id": history_id,
            "outfit_id": outfit_id,
            "message": "Outfit recorded successfully.",
        }

    except HTTPException:

        if connection is not None:
            connection.rollback()

        raise

    except Exception as e:

        if connection is not None:
            connection.rollback()

        print(
            "❌ SAVE OUTFIT HISTORY ERROR:",
            e,
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    finally:

        if cursor is not None:
            cursor.close()

        if connection is not None:
            connection.close()


@app.put("/outfit-history/{history_id}")
def update_outfit_history(
    history_id: int,
    request: OutfitHistoryRequest,
):
    connection = None
    cursor = None

    try:
        user_id = 1

        # ========================================================
        # 1. CHECK HISTORY RECORD EXISTS
        # ========================================================

        connection = get_connection()
        cursor = connection.cursor(
            dictionary=True
        )

        cursor.execute(
            """
            SELECT
                id,
                outfit_id,
                worn_date,
                notes
            FROM outfit_history
            WHERE id = %s
              AND user_id = %s
            LIMIT 1
            """,
            (
                history_id,
                user_id,
            ),
        )

        history = cursor.fetchone()

        if history is None:
            raise HTTPException(
                status_code=404,
                detail="Outfit history record not found.",
            )

        old_outfit_id = history["outfit_id"]

        print(
            f"✏️ Editing history: "
            f"{history_id}, "
            f"old outfit={old_outfit_id}"
        )

        # ========================================================
        # 2. DETERMINE OUTFIT
        # ========================================================

        if request.item_ids:

            # ----------------------------------------------------
            # Try to reuse an outfit containing exactly
            # these clothing items
            # ----------------------------------------------------

            existing_outfit = find_existing_outfit(
                clothing_ids=request.item_ids,
                user_id=user_id,
            )

            if existing_outfit:

                new_outfit_id = existing_outfit["id"]

                print(
                    f"✓ Reusing existing outfit: "
                    f"{new_outfit_id}"
                )

            else:

                # ------------------------------------------------
                # Create a new recorded outfit
                # ------------------------------------------------

                if len(request.item_ids) == 1:
                    title = "Recorded Outfit"
                else:
                    title = "Recorded Look"

                cursor.execute(
                    """
                    INSERT INTO outfits (
                        user_id,
                        title,
                        recommendation_score,
                        is_generated,
                        is_saved
                    )
                    VALUES (
                        %s,
                        %s,
                        %s,
                        FALSE,
                        TRUE
                    )
                    """,
                    (
                        user_id,
                        title,
                        0.0,
                    ),
                )

                new_outfit_id = cursor.lastrowid

                # ================================================
                # SAVE CLOTHING ITEMS FOR NEW OUTFIT
                # ================================================

                for display_order, item_id in enumerate(
                    request.item_ids
                ):

                    cursor.execute(
                        """
                        SELECT category
                        FROM clothing_items
                        WHERE id = %s
                          AND user_id = %s
                          AND is_active = TRUE
                        LIMIT 1
                        """,
                        (
                            item_id,
                            user_id,
                        ),
                    )

                    item = cursor.fetchone()

                    if item is None:
                        raise HTTPException(
                            status_code=404,
                            detail=(
                                f"Clothing item "
                                f"{item_id} "
                                "was not found."
                            ),
                        )

                    category = item["category"]

                    role = category_group_for_role(
                        category
                    )

                    cursor.execute(
                        """
                        INSERT INTO outfit_items (
                            outfit_id,
                            clothing_id,
                            role,
                            display_order
                        )
                        VALUES (
                            %s,
                            %s,
                            %s,
                            %s
                        )
                        """,
                        (
                            new_outfit_id,
                            item_id,
                            role,
                            display_order,
                        ),
                    )

                print(
                    f"✓ Created new recorded outfit: "
                    f"{new_outfit_id}"
                )

        # ========================================================
        # 3. EXISTING OUTFIT ID PROVIDED
        # ========================================================

        elif request.outfit_id is not None:

            cursor.execute(
                """
                SELECT id
                FROM outfits
                WHERE id = %s
                  AND user_id = %s
                LIMIT 1
                """,
                (
                    request.outfit_id,
                    user_id,
                ),
            )

            existing_outfit = cursor.fetchone()

            if existing_outfit is None:
                raise HTTPException(
                    status_code=404,
                    detail="Outfit not found.",
                )

            new_outfit_id = request.outfit_id

        else:

            raise HTTPException(
                status_code=400,
                detail=(
                    "Please provide either "
                    "outfit_id or item_ids."
                ),
            )

        # ========================================================
        # 4. UPDATE EXISTING HISTORY RECORD
        # ========================================================

        cursor.execute(
            """
            UPDATE outfit_history
            SET
                outfit_id = %s,
                worn_date = %s,
                notes = %s
            WHERE id = %s
              AND user_id = %s
            """,
            (
                new_outfit_id,
                request.worn_date,
                request.notes or None,
                history_id,
                user_id,
            ),
        )

        connection.commit()

        print(
            f"✓ Outfit history updated: "
            f"history_id={history_id}, "
            f"old_outfit={old_outfit_id}, "
            f"new_outfit={new_outfit_id}, "
            f"date={request.worn_date}"
        )

        return {
            "success": True,
            "history_id": history_id,
            "outfit_id": new_outfit_id,
            "message": "Outfit history updated successfully.",
        }

    except HTTPException:

        if connection is not None:
            connection.rollback()

        raise

    except Exception as e:

        if connection is not None:
            connection.rollback()

        print(
            "❌ UPDATE OUTFIT HISTORY ERROR:",
            e,
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    finally:

        if cursor is not None:
            cursor.close()

        if connection is not None:
            connection.close()


@app.delete("/outfit-history/{history_id}")
def delete_outfit_history(
    history_id: int,
):
    connection = None
    cursor = None

    try:
        user_id = 1

        connection = get_connection()
        cursor = connection.cursor()

        # ========================================================
        # 1. Check history belongs to current user
        # ========================================================

        cursor.execute(
            """
            SELECT id
            FROM outfit_history
            WHERE id = %s
              AND user_id = %s
            LIMIT 1
            """,
            (
                history_id,
                user_id,
            ),
        )

        history = cursor.fetchone()

        if history is None:
            raise HTTPException(
                status_code=404,
                detail="Outfit history not found.",
            )

        # ========================================================
        # 2. Delete only the history record
        # ========================================================

        cursor.execute(
            """
            DELETE FROM outfit_history
            WHERE id = %s
              AND user_id = %s
            """,
            (
                history_id,
                user_id,
            ),
        )

        # ========================================================
        # 3. Commit
        # ========================================================

        connection.commit()

        print(
            f"✓ Outfit history deleted: "
            f"history_id={history_id}"
        )

        return {
            "success": True,
            "history_id": history_id,
            "message": "Outfit history deleted successfully.",
        }

    except HTTPException:

        if connection is not None:
            connection.rollback()

        raise

    except Exception as e:

        if connection is not None:
            connection.rollback()

        print(
            "❌ DELETE OUTFIT HISTORY ERROR:",
            e,
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    finally:

        if cursor is not None:
            cursor.close()

        if connection is not None:
            connection.close()


# ============================================================
# TEMPORARY VTO GARMENT REFERENCE
# ============================================================

@app.post("/vto-garment-reference")
def vto_garment_reference(data: dict):

    try:

        item_ids = data.get("item_ids", [])

        if not item_ids:
            raise HTTPException(
                status_code=400,
                detail="No clothing items selected.",
            )

        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        placeholders = ", ".join(
            ["%s"] * len(item_ids)
        )

        query = f"""
            SELECT
                id,
                user_id,
                name,
                category,
                subcategory,
                brand,
                color,
                style,
                material,
                image_path,
                processed_image_path,
                is_favorite,
                is_active,
                created_at,
                updated_at
            FROM clothing_items
            WHERE id IN ({placeholders})
              AND is_active = TRUE
        """

        cursor.execute(
            query,
            tuple(item_ids),
        )

        selected_items = cursor.fetchall()

        cursor.close()
        connection.close()

        if not selected_items:
            raise HTTPException(
                status_code=404,
                detail="Selected clothing items were not found.",
            )

        # --------------------------------------------------------
        # Make sure every requested item was found
        # --------------------------------------------------------

        selected_ids = {
            str(item["id"])
            for item in selected_items
        }

        missing_ids = [
            str(item_id)
            for item_id in item_ids
            if str(item_id) not in selected_ids
        ]

        if missing_ids:
            raise HTTPException(
                status_code=404,
                detail=f"Clothing items not found: {missing_ids}",
            )

        # --------------------------------------------------------
        # Generate temporary VTO garment reference
        # --------------------------------------------------------

        reference_id = f"vto_{uuid.uuid4().hex}"

        image_url = create_vto_garment_reference(
            reference_id,
            selected_items,
        )

        if image_url is None:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Unable to create VTO garment reference."
                ),
            )

        print(
            f"✓ VTO garment reference created: "
            f"{image_url}"
        )

        return {
            "success": True,
            "image_url": image_url,
            "items": selected_items,
        }

    except HTTPException:
        raise

    except Exception as e:

        print(
            "❌ VTO GARMENT REFERENCE ERROR:",
            e,
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )


# ========================================================
# GET USER PREFERENCES
# ========================================================

@app.get("/user-preferences")
def get_user_preferences():

    connection = get_connection()
    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Get user's gender
        cursor.execute(
            """
            SELECT gender
            FROM users
            WHERE id = %s
            """,
            (DEMO_USER_ID,)
        )

        user = cursor.fetchone()

        if user is None:
            raise HTTPException(
                status_code=404,
                detail="User not found."
            )

        # Get saved preferences
        cursor.execute(
            """
            SELECT
                preferred_styles,
                preferred_colors,
                preferred_categories,
                preferred_occasions,
                disliked_styles,
                disliked_colors
            FROM user_preferences
            WHERE user_id = %s
            """,
            (DEMO_USER_ID,)
        )

        preferences = cursor.fetchone()

        # Default preferences for a new user
        if preferences is None:
            preferences = {
                "preferred_styles": [],
                "preferred_colors": [],
                "preferred_categories": [],
                "preferred_occasions": [],
                "disliked_styles": [],
                "disliked_colors": [],
            }

        else:
            # Convert JSON values into Python lists
            for key, value in preferences.items():

                if value is None:
                    preferences[key] = []

                elif isinstance(value, str):
                    preferences[key] = json.loads(value)

        return {
            "success": True,
            "gender": user["gender"],
            "preferences": preferences
        }

    except HTTPException:
        raise

    except Exception as e:
        print("GET USER PREFERENCES ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to retrieve user preferences."
        )

    finally:
        if cursor:
            cursor.close()

        connection.close()

# ========================================================
# UPDATE USER PREFERENCES
# ========================================================

@app.put("/user-preferences")
def update_user_preferences(
    request: UserPreferencesRequest
):

    connection = get_connection()
    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Check whether the user exists
        cursor.execute(
            """
            SELECT id
            FROM users
            WHERE id = %s
            """,
            (DEMO_USER_ID,)
        )

        user = cursor.fetchone()

        if user is None:
            raise HTTPException(
                status_code=404,
                detail="User not found."
            )

        # Update gender
        cursor.execute(
            """
            UPDATE users
            SET gender = %s
            WHERE id = %s
            """,
            (request.gender, DEMO_USER_ID)
        )

        # Convert preference lists into JSON strings
        preferred_styles = json.dumps(request.preferred_styles)
        preferred_colors = json.dumps(request.preferred_colors)
        preferred_categories = json.dumps(request.preferred_categories)
        preferred_occasions = json.dumps(request.preferred_occasions)
        disliked_styles = json.dumps(request.disliked_styles)
        disliked_colors = json.dumps(request.disliked_colors)

        # Insert or update preferences
        cursor.execute(
            """
            INSERT INTO user_preferences (
                user_id,
                preferred_styles,
                preferred_colors,
                preferred_categories,
                preferred_occasions,
                disliked_styles,
                disliked_colors
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)

            ON DUPLICATE KEY UPDATE
                preferred_styles = VALUES(preferred_styles),
                preferred_colors = VALUES(preferred_colors),
                preferred_categories = VALUES(preferred_categories),
                preferred_occasions = VALUES(preferred_occasions),
                disliked_styles = VALUES(disliked_styles),
                disliked_colors = VALUES(disliked_colors)
            """,
            (
                DEMO_USER_ID,
                preferred_styles,
                preferred_colors,
                preferred_categories,
                preferred_occasions,
                disliked_styles,
                disliked_colors
            )
        )

        connection.commit()

        return {
            "success": True,
            "message": "User preferences updated successfully."
        }

    except HTTPException:
        raise

    except Exception as e:
        connection.rollback()

        print("UPDATE USER PREFERENCES ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to update user preferences."
        )

    finally:
        if cursor:
            cursor.close()

        connection.close()


# ========================================================
# SAVE SEASONAL COLOR ANALYSIS
# ========================================================

@app.post("/seasonal-color")
def save_seasonal_color(request: SeasonalColorRequest):

    connection = get_connection()
    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Check whether the user exists
        cursor.execute(
            """
            SELECT id
            FROM users
            WHERE id = %s
            """,
            (DEMO_USER_ID,)
        )

        user = cursor.fetchone()

        if user is None:
            raise HTTPException(
                status_code=404,
                detail="User not found."
            )

        # Insert or update seasonal color analysis
        cursor.execute(
            """
            INSERT INTO user_seasonal_colors (
                user_id,
                undertone,
                hair_color,
                eye_color,
                contrast_level,
                season
            )
            VALUES (%s, %s, %s, %s, %s, %s)

            ON DUPLICATE KEY UPDATE
                undertone = VALUES(undertone),
                hair_color = VALUES(hair_color),
                eye_color = VALUES(eye_color),
                contrast_level = VALUES(contrast_level),
                season = VALUES(season)
            """,
            (
                DEMO_USER_ID,
                request.undertone,
                request.hair_color,
                request.eye_color,
                request.contrast_level,
                request.season
            )
        )

        connection.commit()

        return {
            "success": True,
            "message": "Seasonal color analysis saved successfully."
        }

    except HTTPException:
        raise

    except Exception as e:
        connection.rollback()

        print("SAVE SEASONAL COLOR ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to save seasonal color analysis."
        )

    finally:
        if cursor:
            cursor.close()

        connection.close()

# ========================================================
# GET SEASONAL COLOR ANALYSIS
# ========================================================

@app.get("/seasonal-color")
def get_seasonal_color():

    connection = get_connection()
    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                undertone,
                hair_color,
                eye_color,
                contrast_level,
                season,
                created_at,
                updated_at
            FROM user_seasonal_colors
            WHERE user_id = %s
            """,
            (DEMO_USER_ID,)
        )

        result = cursor.fetchone()

        return {
            "success": True,
            "seasonal_color": result
        }

    except Exception as e:
        print("GET SEASONAL COLOR ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to retrieve seasonal color analysis."
        )

    finally:
        if cursor:
            cursor.close()

        connection.close()
        
# ========================================================
# TEMPORARY DEMO USER
# ========================================================

DEMO_USER_ID = 1

# ========================================================
# GET USER PROFILE
# ========================================================

@app.get("/profile")
def get_profile():

    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        cursor.execute(
            """
            SELECT
                id,
                name,
                email,
                gender,
                profile_image,
                created_at,
                updated_at
            FROM users
            WHERE id = %s
            """,
            (DEMO_USER_ID,)
        )

        user = cursor.fetchone()

        if user is None:
            raise HTTPException(
                status_code=404,
                detail="User profile not found."
            )

        return {
            "success": True,
            "profile": user
        }

    except HTTPException:
        raise

    except Exception as e:

        print("❌ GET PROFILE ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to retrieve user profile."
        )

    finally:
        cursor.close()
        connection.close()


# ========================================================
# UPLOAD PROFILE IMAGE
# ========================================================

@app.post("/profile/image")
async def upload_profile_image(file: UploadFile = File(...)):
    print("PROFILE IMAGE FILENAME:", file.filename)
    print("PROFILE IMAGE CONTENT TYPE:", file.content_type)

    allowed_extensions = {
        ".jpg": ".jpg",
        ".jpeg": ".jpg",
        ".png": ".png",
        ".webp": ".webp",
    }

    file_extension = os.path.splitext(file.filename or "")[1].lower()

    if file_extension not in allowed_extensions:
        raise HTTPException(
            status_code=400,
            detail="Only JPG, PNG and WEBP images are allowed."
        )

    extension = allowed_extensions[file_extension]

    image_data = await file.read()

    if not image_data:
        raise HTTPException(
            status_code=400,
            detail="The uploaded image is empty."
        )

    if len(image_data) > 5 * 1024 * 1024:
        raise HTTPException(
            status_code=400,
            detail="Image size must not exceed 5 MB."
        )

    connection = None
    cursor = None
    image_path = None

    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        # Check whether the demo user exists
        cursor.execute(
            "SELECT id FROM users WHERE id = %s",
            (DEMO_USER_ID,)
        )

        user = cursor.fetchone()

        if user is None:
            raise HTTPException(
                status_code=404,
                detail="User profile not found."
            )

        # Generate a unique filename
        filename = f"{uuid.uuid4().hex}{extension}"

        image_path = os.path.join(
            PROFILE_UPLOAD_DIR,
            filename
        )

        # Save image to backend
        with open(image_path, "wb") as image_file:
            image_file.write(image_data)

        # Save image URL path to MySQL
        database_image_path = f"/uploads/profile/{filename}"

        cursor.execute(
            """
            UPDATE users
            SET profile_image = %s
            WHERE id = %s
            """,
            (database_image_path, DEMO_USER_ID)
        )

        connection.commit()

        return {
            "success": True,
            "message": "Profile image uploaded successfully.",
            "profile_image": database_image_path
        }

    except HTTPException:
        raise

    except Exception as e:
        if connection:
            connection.rollback()

        # Remove uploaded file if database update fails
        if image_path and os.path.exists(image_path):
            os.remove(image_path)

        print("UPLOAD PROFILE IMAGE ERROR:", e)

        raise HTTPException(
            status_code=500,
            detail="Unable to upload profile image."
        )

    finally:
        if cursor:
            cursor.close()

        if connection:
            connection.close()

        await file.close()


@app.get("/profile/insights")
def get_profile_insights():

    user_id = 1  # TEMPORARY DEMO USER

    connection = get_connection()
    cursor = None

    try:
        cursor = connection.cursor(dictionary=True)

        # Get active wardrobe category counts
        cursor.execute(
            """
            SELECT
                LOWER(TRIM(category)) AS category,
                COUNT(*) AS item_count
            FROM clothing_items
            WHERE user_id = %s
                AND is_active = TRUE
            GROUP BY LOWER(TRIM(category));
            """,
            (user_id,)
        )

        results = cursor.fetchall()

        category_counts = {
            "upper": 0,
            "lower": 0,
            "full": 0,
        }

        for item in results:
            category = item["category"]

            if category in ["upper", "top"]:
                category_counts["upper"] += item["item_count"]

            elif category in ["lower", "bottom"]:
                category_counts["lower"] += item["item_count"]

            elif category in ["full", "dress", "jumpsuit"]:
                category_counts["full"] += item["item_count"]

        upper_count = category_counts["upper"]
        lower_count = category_counts["lower"]
        full_count = category_counts["full"]

        outfit_potential = (
            upper_count * lower_count
        ) + full_count

        total_items = upper_count + lower_count + full_count

        # Count unique clothing items that have never been worn
        cursor.execute(
            """
            SELECT COUNT(*) AS unworn_items
            FROM clothing_items ci
            WHERE ci.user_id = %s
                AND ci.is_active = TRUE
                AND NOT EXISTS (
                    SELECT 1
                    FROM outfit_items oi
                    JOIN outfit_history oh
                        ON oi.outfit_id = oh.outfit_id
                    WHERE oi.clothing_id = ci.id
                        AND oh.user_id = ci.user_id
                );
            """,
            (user_id,)
        )

        usage_result = cursor.fetchone()

        unworn_items = usage_result["unworn_items"]

        # Generate insight
        title = "Your Outfit Potential"

        description = (
            f"Your {total_items} wardrobe pieces can create "
            f"up to {outfit_potential} basic outfit combinations "
            f"using your current upper and lower items."
        )

        if unworn_items > 0:
            description += (
                f" You also have {unworn_items} "
                f"items waiting to be worn."
            )

        return {
            "success": True,
            "title": title,
            "description": description,
            "total_items": total_items,
            "upper_count": upper_count,
            "lower_count": lower_count,
            "full_count": full_count,
            "outfit_potential": outfit_potential,
            "unworn_items": unworn_items,
        }

    finally:
        if cursor:
            cursor.close()

        connection.close()


# -------------------------------------------------------------------
# Run directly
# -------------------------------------------------------------------

if __name__ == "__main__":

    import uvicorn

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
