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
        connection.commit()

        item_id = cursor.lastrowid

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

    finally:
        cursor.close()
        connection.close()