from flask import Flask, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_migrate import Migrate
import psycopg2
import os
import logging

logging.basicConfig(level=logging.DEBUG, filename='app.log', filemode='a', format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

db = SQLAlchemy()
jwt = JWTManager()
migrate = Migrate()

def create_app():
    app = Flask(__name__)
    app.config.from_object('config.Config')

    try:
        db.init_app(app)
        jwt.init_app(app)
        migrate.init_app(app, db)
        CORS(app)
        logger.info("Flask 扩展初始化成功")
    except Exception as e:
        logger.error(f"初始化 Flask 扩展失败: {e}")
        raise

    with app.app_context():
        from .models.base import define_models
        define_models(db)  # 初始化模型
        from .routes.auth import auth_bp
        from .routes.defect import defect_bp
        from .routes.report import report_bp  # 新增报告路由
        app.register_blueprint(auth_bp, url_prefix='/api')
        app.register_blueprint(defect_bp, url_prefix='/api')
        app.register_blueprint(report_bp, url_prefix='/api')

    @app.route('/Uploads/<filename>')
    def uploaded_file(filename):
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

    @app.route('/Reports/<filename>')
    def report_file(filename):
        return send_from_directory(app.config['REPORT_FOLDER'], filename)

    def test_db_connection():
        try:
            db_uri = app.config['SQLALCHEMY_DATABASE_URI']
            logger.debug(f"尝试连接数据库: {db_uri}")
            conn = psycopg2.connect(db_uri)
            conn.close()
            logger.info("数据库连接成功")
            return True
        except Exception as e:
            logger.error(f"数据库连接失败: {e}")
            return False

    with app.app_context():
        if not test_db_connection():
            logger.error("数据库连接失败，退出")
            raise Exception("数据库连接失败")

    app.db = db
    return app