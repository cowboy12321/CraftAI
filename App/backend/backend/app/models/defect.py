import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), '..', 'SQL', 'JiangZhi.db')

def save_picture(user_id, image_path, processed_path, result_summary, material_lost):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    try:
        cursor.execute('''
            INSERT INTO pictures (user_id, img_path, processed_path, result_summary, material_lost)
            VALUES (?, ?, ?, ?, ?)
        ''', (user_id, image_path, processed_path, result_summary, int(material_lost)))
        conn.commit()
        return True
    except Exception as e:
        print("Error saving picture:", e)
        conn.rollback()
        return False
    finally:
        cursor.close()
        conn.close()

def get_user_by_name(name):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    try:
        cursor.execute('SELECT * FROM users WHERE name = ?', (name,))
        result = cursor.fetchone()
        return result
    except Exception as e:
        print("Error getting user:", e)
        return None
    finally:
        cursor.close()
        conn.close()
