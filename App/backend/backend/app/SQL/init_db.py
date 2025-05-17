from App.backend.backend.app import create_app
from App.backend.backend.app.models.base import define_models
import logging

logging.basicConfig(level=logging.DEBUG, filename='app.log', filemode='a', format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def init_db():
    app = create_app()
    db = app.db
    User, Detection = define_models(db)
    with app.app_context():
        try:
            logger.info("数据库初始化完成（使用现有表）")
            print("Database initialization completed (using existing tables)")
        except Exception as e:
            logger.error(f"数据库初始化失败: {str(e)}")
            raise

if __name__ == '__main__':
    init_db()