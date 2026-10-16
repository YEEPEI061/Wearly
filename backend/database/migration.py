import os
import mysql.connector
from mysql.connector import Error


# ============================================================
# DATABASE CONFIGURATION
# ============================================================

DB_HOST = os.environ.get("DB_HOST", "127.0.0.1")
DB_PORT = int(os.environ.get("DB_PORT", 3306))
DB_NAME = os.environ.get("DB_NAME", "wearly")
DB_USER = os.environ.get("DB_USER", "root")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "")


# ============================================================
# CONNECT TO MYSQL SERVER
# ============================================================

def connect_to_mysql(database=None):
    try:
        config = {
            "host": DB_HOST,
            "port": DB_PORT,
            "user": DB_USER,
            "password": DB_PASSWORD,
        }

        if database:
            config["database"] = database

        connection = mysql.connector.connect(**config)

        if connection.is_connected():
            return connection

    except Error as e:
        print(f"❌ MySQL connection error: {e}")
        return None

    return None


# ============================================================
# CREATE DATABASE
# ============================================================

def create_database():
    connection = connect_to_mysql()

    if not connection:
        return False

    try:
        cursor = connection.cursor()

        cursor.execute(
            f"""
            CREATE DATABASE IF NOT EXISTS `{DB_NAME}`
            CHARACTER SET utf8mb4
            COLLATE utf8mb4_unicode_ci
            """
        )

        print(f"✓ Database `{DB_NAME}` is ready.")

        cursor.close()
        connection.close()

        return True

    except Error as e:
        print(f"❌ Failed to create database: {e}")

        try:
            connection.close()
        except Exception:
            pass

        return False


# ============================================================
# CREATE TABLES
# ============================================================

def create_tables():
    connection = connect_to_mysql(DB_NAME)

    if not connection:
        return False

    try:
        cursor = connection.cursor()

        # ====================================================
        # 1. USERS
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS users (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                name VARCHAR(100) NOT NULL,

                email VARCHAR(255) UNIQUE,

                gender VARCHAR(30),

                profile_image VARCHAR(500),

                created_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,

                updated_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP
            )
            """
        )

        print("✓ users")


        # ====================================================
        # 2. USER PREFERENCES
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS user_preferences (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                user_id BIGINT UNSIGNED NOT NULL UNIQUE,

                preferred_styles JSON,

                preferred_colors JSON,

                preferred_categories JSON,

                preferred_occasions JSON,

                disliked_styles JSON,

                disliked_colors JSON,

                updated_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP,

                CONSTRAINT fk_preferences_user
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE
            )
            """
        )

        print("✓ user_preferences")


        # ====================================================
        # 3. CLOTHING ITEMS
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS clothing_items (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                user_id BIGINT UNSIGNED NOT NULL,

                name VARCHAR(150),

                category VARCHAR(50) NOT NULL,

                subcategory VARCHAR(50),

                brand VARCHAR(100),

                color VARCHAR(50),

                style VARCHAR(50),

                material VARCHAR(150),

                image_path VARCHAR(500),

                processed_image_path VARCHAR(500),

                is_favorite BOOLEAN NOT NULL DEFAULT FALSE,

                is_active BOOLEAN NOT NULL DEFAULT TRUE,

                created_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,

                updated_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP,

                CONSTRAINT fk_clothing_user
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE,

                INDEX idx_clothing_user (user_id),

                INDEX idx_clothing_category (category)
            )
            """
        )

        print("✓ clothing_items")


        # ====================================================
        # 4. CLOTHING AI ANALYSIS
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS clothing_ai_analysis (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                clothing_id BIGINT UNSIGNED NOT NULL UNIQUE,

                detected_category VARCHAR(50),

                category_confidence DECIMAL(5,4),

                detected_color VARCHAR(50),

                color_confidence DECIMAL(5,4),

                detected_style VARCHAR(50),

                style_confidence DECIMAL(5,4),

                analysis_version VARCHAR(50),

                analyzed_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,

                CONSTRAINT fk_ai_clothing
                    FOREIGN KEY (clothing_id)
                    REFERENCES clothing_items(id)
                    ON DELETE CASCADE
            )
            """
        )

        print("✓ clothing_ai_analysis")


        # ====================================================
        # 5. OUTFITS
        #
        # Outfit IDs use UUID strings because the current
        # recommendation system generates UUIDs.
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS outfits (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                user_id BIGINT UNSIGNED NOT NULL,

                title VARCHAR(150),

                occasion VARCHAR(50),

                mood VARCHAR(50),

                style VARCHAR(50),

                weather_condition VARCHAR(100),

                temperature DECIMAL(5,2),

                recommendation_score DECIMAL(6,4),

                image_url VARCHAR(500),

                is_generated BOOLEAN NOT NULL DEFAULT TRUE,

                is_saved BOOLEAN NOT NULL DEFAULT FALSE,

                created_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,

                CONSTRAINT fk_outfit_user
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE,

                INDEX idx_outfit_user (user_id)
            )
            """
        )

        print("✓ outfits")


        # ====================================================
        # 6. OUTFIT ITEMS
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS outfit_items (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                outfit_id BIGINT UNSIGNED NOT NULL,

                clothing_id BIGINT UNSIGNED NOT NULL,

                role VARCHAR(50) NOT NULL,

                display_order INT NOT NULL DEFAULT 0,

                CONSTRAINT fk_outfit_items_outfit
                    FOREIGN KEY (outfit_id)
                    REFERENCES outfits(id)
                    ON DELETE CASCADE,

                CONSTRAINT fk_outfit_items_clothing
                    FOREIGN KEY (clothing_id)
                    REFERENCES clothing_items(id)
                    ON DELETE CASCADE,

                UNIQUE KEY unique_outfit_clothing (
                    outfit_id,
                    clothing_id
                ),

                INDEX idx_outfit_items_outfit (
                    outfit_id
                ),

                INDEX idx_outfit_items_clothing (
                    clothing_id
                )
            )
            """
        )

        print("✓ outfit_items")


        # ====================================================
        # 7. OUTFIT FEEDBACK
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS outfit_feedback (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                user_id BIGINT UNSIGNED NOT NULL,

                outfit_id BIGINT UNSIGNED NOT NULL,

                feedback ENUM(
                    'LIKE',
                    'DISLIKE'
                ) NOT NULL,

                created_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,

                CONSTRAINT fk_feedback_user
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE,

                CONSTRAINT fk_feedback_outfit
                    FOREIGN KEY (outfit_id)
                    REFERENCES outfits(id)
                    ON DELETE CASCADE,

                UNIQUE KEY unique_user_outfit_feedback (
                    user_id,
                    outfit_id
                ),

                INDEX idx_feedback_user (
                    user_id
                ),

                INDEX idx_feedback_outfit (
                    outfit_id
                )
            )
            """
        )

        print("✓ outfit_feedback")


        # ====================================================
        # 8. OUTFIT HISTORY
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS outfit_history (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                user_id BIGINT UNSIGNED NOT NULL,

                outfit_id BIGINT UNSIGNED NOT NULL,

                worn_date DATE NOT NULL,

                notes VARCHAR(500),

                created_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,

                CONSTRAINT fk_history_user
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE,

                CONSTRAINT fk_history_outfit
                    FOREIGN KEY (outfit_id)
                    REFERENCES outfits(id)
                    ON DELETE CASCADE,

                INDEX idx_history_user_date (
                    user_id,
                    worn_date
                ),

                INDEX idx_history_outfit (
                    outfit_id
                )
            )
            """
        )

        print("✓ outfit_history")


        # ====================================================
        # 9. VIRTUAL TRY-ON
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS virtual_try_on (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                user_id BIGINT UNSIGNED NOT NULL,

                clothing_id BIGINT UNSIGNED,

                user_image_path VARCHAR(500) NOT NULL,

                clothing_image_path VARCHAR(500),

                result_image_path VARCHAR(500),

                status ENUM(
                    'PENDING',
                    'PROCESSING',
                    'COMPLETED',
                    'FAILED'
                ) NOT NULL DEFAULT 'PENDING',

                error_message VARCHAR(500),

                created_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,

                completed_at DATETIME,

                CONSTRAINT fk_tryon_user
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE,

                CONSTRAINT fk_tryon_clothing
                    FOREIGN KEY (clothing_id)
                    REFERENCES clothing_items(id)
                    ON DELETE SET NULL,

                INDEX idx_tryon_user (
                    user_id
                )
            )
            """
        )

        print("✓ virtual_try_on")


        # ====================================================
        # 10. TRAVEL PLANS
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS travel_plans (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                user_id BIGINT UNSIGNED NOT NULL,

                destination VARCHAR(150) NOT NULL,

                country VARCHAR(100),

                start_date DATE,

                end_date DATE,

                trip_type VARCHAR(50),

                notes VARCHAR(1000),

                weather_summary VARCHAR(500),

                created_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP,

                updated_at DATETIME NOT NULL
                    DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP,

                CONSTRAINT fk_travel_user
                    FOREIGN KEY (user_id)
                    REFERENCES users(id)
                    ON DELETE CASCADE,

                INDEX idx_travel_user (
                    user_id
                )
            )
            """
        )

        print("✓ travel_plans")


        # ====================================================
        # 11. TRAVEL OUTFITS
        # ====================================================

        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS travel_outfits (
                id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

                travel_plan_id BIGINT UNSIGNED NOT NULL,

                outfit_id BIGINT UNSIGNED,

                day_number INT NOT NULL,

                date DATE,

                weather_condition VARCHAR(100),

                temperature DECIMAL(5,2),

                recommendation_reason VARCHAR(500),

                CONSTRAINT fk_travel_outfit_plan
                    FOREIGN KEY (travel_plan_id)
                    REFERENCES travel_plans(id)
                    ON DELETE CASCADE,

                CONSTRAINT fk_travel_outfit_outfit
                    FOREIGN KEY (outfit_id)
                    REFERENCES outfits(id)
                    ON DELETE SET NULL,

                UNIQUE KEY unique_travel_day (
                    travel_plan_id,
                    day_number
                ),

                INDEX idx_travel_outfit_outfit (
                    outfit_id
                )
            )
            """
        )

        print("✓ travel_outfits")


        # ====================================================
        # COMMIT
        # ====================================================

        connection.commit()

        cursor.close()
        connection.close()

        return True

    except Error as e:
        print()
        print("❌ Failed to create tables:")
        print(e)

        try:
            connection.rollback()
        except Exception:
            pass

        try:
            cursor.close()
        except Exception:
            pass

        try:
            connection.close()
        except Exception:
            pass

        return False


# ============================================================
# CREATE DEVELOPMENT USER
# ============================================================

def create_demo_user():
    connection = connect_to_mysql(DB_NAME)

    if not connection:
        return False

    try:
        cursor = connection.cursor()

        # ----------------------------------------------------
        # Create Demo User
        # ----------------------------------------------------

        cursor.execute(
            """
            INSERT INTO users (
                id,
                name,
                email,
                gender
            )
            VALUES (
                1,
                'Demo User',
                'demo@wearly.local',
                NULL
            )
            ON DUPLICATE KEY UPDATE
                name = VALUES(name),
                email = VALUES(email)
            """
        )

        # ----------------------------------------------------
        # Create Demo User Preferences
        # ----------------------------------------------------

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
            VALUES (
                1,
                JSON_ARRAY(),
                JSON_ARRAY(),
                JSON_ARRAY(),
                JSON_ARRAY(),
                JSON_ARRAY(),
                JSON_ARRAY()
            )
            ON DUPLICATE KEY UPDATE
                user_id = user_id
            """
        )

        connection.commit()

        print("✓ Demo user created (ID: 1)")

        cursor.close()
        connection.close()

        return True

    except Error as e:
        print(f"❌ Failed to create demo user: {e}")

        try:
            connection.rollback()
        except Exception:
            pass

        try:
            cursor.close()
        except Exception:
            pass

        try:
            connection.close()
        except Exception:
            pass

        return False


# ============================================================
# VERIFY DATABASE
# ============================================================

def verify_database():
    connection = connect_to_mysql(DB_NAME)

    if not connection:
        return False

    try:
        cursor = connection.cursor()

        cursor.execute("SHOW TABLES")

        tables = [
            row[0]
            for row in cursor.fetchall()
        ]

        expected_tables = [
            "users",
            "user_preferences",
            "clothing_items",
            "clothing_ai_analysis",
            "outfits",
            "outfit_items",
            "outfit_feedback",
            "outfit_history",
            "virtual_try_on",
            "travel_plans",
            "travel_outfits",
        ]

        print()
        print("Database verification:")
        print()

        all_exist = True

        for table in expected_tables:
            if table in tables:
                print(f"  ✓ {table}")
            else:
                print(f"  ❌ {table} MISSING")
                all_exist = False

        cursor.close()
        connection.close()

        return all_exist

    except Error as e:
        print(f"❌ Database verification failed: {e}")

        try:
            connection.close()
        except Exception:
            pass

        return False


# ============================================================
# MAIN
# ============================================================

def main():

    print()
    print("==============================================")
    print("          WEARLY DATABASE MIGRATION")
    print("==============================================")
    print()

    # --------------------------------------------------------
    # 1. Create database
    # --------------------------------------------------------

    print("Creating database...")

    if not create_database():
        print()
        print("❌ Migration stopped.")
        return

    # --------------------------------------------------------
    # 2. Create tables
    # --------------------------------------------------------

    print()
    print("Creating tables...")
    print()

    if not create_tables():
        print()
        print("❌ Migration stopped.")
        return

    # --------------------------------------------------------
    # 3. Create demo user
    # --------------------------------------------------------

    print()
    print("Creating development user...")

    if not create_demo_user():
        print()
        print("❌ Migration stopped.")
        return

    # --------------------------------------------------------
    # 4. Verify
    # --------------------------------------------------------

    print()
    print("Verifying database...")

    if not verify_database():
        print()
        print("❌ Database verification failed.")
        return

    # --------------------------------------------------------
    # Complete
    # --------------------------------------------------------

    print()
    print("==============================================")
    print("      ✓ MIGRATION COMPLETED SUCCESSFULLY")
    print("==============================================")
    print()

    print(f"Database      : {DB_NAME}")
    print("Demo User ID  : 1")
    print()

    print("Tables created:")
    print("  1. users")
    print("  2. user_preferences")
    print("  3. clothing_items")
    print("  4. clothing_ai_analysis")
    print("  5. outfits")
    print("  6. outfit_items")
    print("  7. outfit_feedback")
    print("  8. outfit_history")
    print("  9. virtual_try_on")
    print(" 10. travel_plans")
    print(" 11. travel_outfits")
    print()


# ============================================================
# RUN MIGRATION
# ============================================================

if __name__ == "__main__":
    main()

