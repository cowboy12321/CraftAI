import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), 'JiangZhi.db')
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# 管理员表
cursor.execute("DROP TABLE IF EXISTS admin")
cursor.execute('''
CREATE TABLE admin (
    admin_id INTEGER PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
)
''')

# 用户表
cursor.execute("DROP TABLE IF EXISTS users")
cursor.execute('''
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
)
''')

# 图像表
cursor.execute("DROP TABLE IF EXISTS pictures")
cursor.execute('''
CREATE TABLE pictures (
    pic_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    img_path TEXT NOT NULL UNIQUE,
    processed_path TEXT NOT NULL UNIQUE,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    result_summary TEXT,
    material_lost BOOLEAN DEFAULT FALSE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
)
''')

# 材料缺失图像表
cursor.execute("DROP TABLE IF EXISTS material_lost_pic")
cursor.execute('''
CREATE TABLE material_lost_pic (
    material_lost_pic_id INTEGER PRIMARY KEY AUTOINCREMENT,
    pic_id INTEGER NOT NULL,
    FOREIGN KEY (pic_id) REFERENCES pictures(pic_id) ON DELETE CASCADE
)
''')

conn.commit()
conn.close()
print("数据库初始化完成：JiangZhi.db 已创建")
