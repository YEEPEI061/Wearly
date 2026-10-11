import os
import math

from fastapi import (
    FastAPI,
    UploadFile,
    File,
    HTTPException,
    Form
)
from pydantic import BaseModel
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from database.db import get_connection

from database.clothing import (
    create_clothing_item,
    update_clothing_item,
)
from database.outfit import (
    submit_outfit_feedback,
)
from wardrobe import (
    PROCESSED_DIR,
    UPLOAD_DIR,
    process_clothing,
    get_wardrobe,
    get_clothing_item,
    delete_clothing,
    reset_generated_outfits,
    detect_category,
)

from outfit import (
    generate_outfits,
    generate_another_outfit,
    submit_feedback,
    OUTFIT_PREVIEW_DIR,
)
from fastapi.staticfiles import StaticFiles


# -------------------------------------------------------------------
# FastAPI
# -------------------------------------------------------------------

app = FastAPI(
    title="Wearly AI Wardrobe API",
    version="1.0.0",
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
def delete_wardrobe_item(
    item_id: str,
):

    success = delete_clothing(
        item_id
    )

    if not success:
        raise HTTPException(
            status_code=404,
            detail="Clothing item not found.",
        )

    return {
        "success": True,
        "message": "Clothing item deleted.",
    }


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
def generate_outfit():

    outfits = generate_outfits(
        count=5
    )

    outfits = sanitize_json_value(outfits)

    print("🔥 FINAL OUTFIT IMAGE URL:")
    print(outfits[0].get("image_url") if outfits else "NO OUTFITS")

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