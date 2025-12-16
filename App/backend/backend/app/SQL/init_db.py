import sys
import os
import logging

# ==========================================
# 核心修正：路径注入
# ==========================================
# 获取当前脚本所在目录 (.../app/SQL)
current_dir = os.path.dirname(os.path.abspath(__file__))
# 获取 app 目录 (.../app)
app_dir = os.path.dirname(current_dir)
# 获取后端根目录 (.../backend)
backend_root = os.path.dirname(app_dir)

# 将后端根目录加入 Python 搜索路径，这样才能 import app
sys.path.insert(0, backend_root)

# 现在可以正常导入了
from app import create_app
from app.models.base import define_models

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def init_db():
    app = create_app()
    db = app.db
    
    # 必须在上下文环境中操作
    with app.app_context():
        try:
            # 确保模型被加载
            define_models(db)
            
            # 创建表
            db.create_all()
            logger.info("✅ 数据库表结构创建成功！")
            print("Database initialization completed successfully.")
            
        except Exception as e:
            logger.error(f"❌ 数据库初始化失败: {str(e)}", exc_info=True)
            print(f"Error: {str(e)}")

if __name__ == '__main__':
    init_db()