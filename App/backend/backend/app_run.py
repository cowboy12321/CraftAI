from dotenv import load_dotenv
import sys
import os
from dotenv import load_dotenv

# 添加 backend/ 到 sys.path
sys.path.insert(0, os.path.dirname(__file__))
from app import create_app
from flask_apscheduler import APScheduler
import logging

# 配置日志
logging.basicConfig(
    level=logging.DEBUG,
    filename='app.log',
    filemode='a',
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 加载环境变量
load_dotenv()

# 创建应用
app = create_app()
def ensure_directories():
    for folder in [app.config['UPLOAD_FOLDER'], app.config['REPORT_FOLDER']]:
        try:
            os.makedirs(folder, exist_ok=True)
            if not os.access(folder, os.W_OK):
                logger.error(f"目录 {folder} 不可写")
                raise PermissionError(f"目录 {folder} 不可写")
            logger.info(f"目录 {folder} 已准备好")
        except Exception as e:
            logger.error(f"创建目录 {folder} 失败: {str(e)}")
            raise

with app.app_context():
    ensure_directories()
# 初始化异步任务调度器
scheduler = APScheduler()
scheduler.init_app(app)
scheduler.start()

if __name__ == '__main__':
    logger.info("启动 Flask 应用")
    app.run(host='0.0.0.0', port=5000, debug=True)