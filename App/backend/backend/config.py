import os
from pathlib import Path


class Config:
    # 使用绝对路径（直接复制你的真实路径）
    BASE_DIR = Path(r"E:\CraftAI app\CraftAI\App\backend\backend\app")

    # 数据库配置（两种写法任选其一）
    # 写法1：Path对象（推荐）
    SQLALCHEMY_DATABASE_URI = f"sqlite:///{BASE_DIR / 'SQL' / 'JiangZhi.db'}"

    # 写法2：os.path拼接
    # SQLALCHEMY_DATABASE_URI = f"sqlite:///{os.path.join(BASE_DIR, 'SQL', 'JiangZhi.db')}"

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    UPLOAD_FOLDER = BASE_DIR / 'static' / 'uploads'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB


