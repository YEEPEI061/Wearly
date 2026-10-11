import json

from database.db import get_connection


def create_clothing_item(
    user_id: int,
    name: str,
    category: str,
    subcategory: str,
    brand: str,
    color: str,
    style: str,
    material: str,
    image_path: str,
    processed_image_path: str,
    ai_analysis: dict | None = None,
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            INSERT INTO clothing_items (
                user_id,
                name,
                category,
                subcategory,
                brand,
                color,
                style,
                material,
                image_path,
                processed_image_path
            )
            VALUES (
                %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s
            )
        """

        values = (
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
        )

        cursor.execute(query, values)

        item_id = cursor.lastrowid

        if ai_analysis is not None:
            ai_query = """
                INSERT INTO clothing_ai_analysis (
                    clothing_id,
                    detected_category,
                    category_confidence,
                    detected_color,
                    color_confidence,
                    detected_style,
                    style_confidence,
                    analysis_version
                )
                VALUES (
                    %s, %s, %s, %s, %s,
                    %s, %s, %s
                )
            """

            ai_values = (
                item_id,
                ai_analysis.get("category"),
                ai_analysis.get("category_confidence"),
                ai_analysis.get("color"),
                ai_analysis.get("color_confidence"),
                ai_analysis.get("style"),
                ai_analysis.get("style_confidence"),
                "1.0",
            )

            cursor.execute(
                ai_query,
                ai_values,
            )

        connection.commit()

        return {
            "id": item_id,
            "user_id": user_id,
            "name": name,
            "category": category,
            "subcategory": subcategory,
            "brand": brand,
            "color": color,
            "style": style,
            "material": material,
            "image_path": image_path,
            "processed_image_path": processed_image_path,
        }

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


def get_clothing_items(
    user_id: int = 1,
):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            SELECT
                ci.id,
                ci.user_id,
                ci.name,
                ci.category,
                ci.subcategory,
                ci.brand,
                ci.color,
                ci.style,
                ci.material,
                ci.image_path,
                ci.processed_image_path,
                ci.created_at,
                ci.updated_at,

                cai.detected_category,
                cai.category_confidence,
                cai.detected_color,
                cai.color_confidence,
                cai.detected_style,
                cai.style_confidence,
                cai.analysis_version

            FROM clothing_items ci

            LEFT JOIN clothing_ai_analysis cai
                ON cai.clothing_id = ci.id

            WHERE ci.user_id = %s
              AND ci.is_active = 1

            ORDER BY ci.created_at DESC
        """

        cursor.execute(
            query,
            (user_id,),
        )

        items = cursor.fetchall()

        for item in items:
            if item.get("created_at") is not None:
                item["created_at"] = item["created_at"].isoformat()

            if item.get("updated_at") is not None:
                item["updated_at"] = item["updated_at"].isoformat()

            if item.get("category_confidence") is not None:
                item["category_confidence"] = float(
                    item["category_confidence"]
                )

            if item.get("color_confidence") is not None:
                item["color_confidence"] = float(
                    item["color_confidence"]
                )

            if item.get("style_confidence") is not None:
                item["style_confidence"] = float(
                    item["style_confidence"]
                )

        return items

    finally:
        cursor.close()
        connection.close()


def update_clothing_item(
    clothing_id: int,
    user_id: int,
    name: str,
    brand: str,
    category: str,
    color: str,
    style: str,
    material: str,
):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        query = """
            UPDATE clothing_items
            SET
                name = %s,
                brand = %s,
                category = %s,
                color = %s,
                style = %s,
                material = %s,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
              AND user_id = %s
              AND is_active = 1
        """

        values = (
            name,
            brand,
            category,
            color,
            style,
            material,
            clothing_id,
            user_id,
        )

        cursor.execute(query, values)

        if cursor.rowcount == 0:
            connection.rollback()
            return False

        connection.commit()
        return True

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()