from flask import Flask
from config import Config
from app.models.base import db

import sys
import os

# 添加 App 根目录路径（E:\CraftAI app\CraftAI\App）
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))

from SQL.create_sql import init_db


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    init_db(app)

    from app.routes.defect import bp as defect_bp
    app.register_blueprint(defect_bp, url_prefix='/api')

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)
