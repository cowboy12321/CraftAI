import sqlite3

# 创建或连接数据库文件
conn = sqlite3.connect('JiangZhi.db') 
cursor = conn.cursor()

#创建管理员库
cursor.execute("DROP TABLE IF EXISTS admins")
cursor.excute('''
CREATE TABLE admin(
    admin_id INTEGER PRIMARY KEY ,
    name TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
)
''')

#创建用户库
#注意name应避免与管理员id相同
cursor.execute("DROP TABLE IF EXISTS users")
cursor.execute('''
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL, 
    password TEXT NOT NULL
)
''')

#创建图像库
#在此先只给出材料损失一种缺陷
cursor.execute("DROP TABLE IF EXISTS pictures")
cursor.execute('''
CREATE TABLE pictures(
    pic_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    img_path TEXT NOT NULL UNIQUE,
    processed_path TEXT NOT NULL UNIQUE,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    result_summary TEXT,
    material_lost BOOLEAN DEFAULT FALSE NOT NULL,
    FOREIGN KEY (user_id) REFERENCE users(user_id) ON DELETE CASCADE
)
''')

#创建包含材料损失缺陷的图像库
cursor.execute("DROP TABLE IF EXISTS material_lost_pic")
cursor.execute('''
CREATE TABLE material_lost_pic(
    material_lost_pic_id INTEGER PRIMARY KEY AUTOINCREMENT,
    pic_id INTEGER NOT NULL,
    FOREIGN KEY (pic_id) REFERENCE pictures(pic_id) ON DELETE CASCADE
)
''')

# 保存更改并关闭连接
conn.commit()
conn.close()
