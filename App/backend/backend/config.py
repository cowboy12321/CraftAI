import os
from pathlib import Path


class Config:
    BASE_DIR = Path(r"E:\CraftAI app\CraftAI\App\backend\backend\app")
    SQLALCHEMY_DATABASE_URI = f"sqlite:///{BASE_DIR / 'SQL' / 'JiangZhi.db'}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    UPLOAD_FOLDER = BASE_DIR / 'static' / 'uploads'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB

