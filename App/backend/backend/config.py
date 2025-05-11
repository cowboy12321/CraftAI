# 配置文件
# config.py
import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')

# SQLite数据库位置
DATABASE = os.path.join(BASE_DIR, '../SQL/JiangZhi.db')

# 允许上传图片的格式
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
