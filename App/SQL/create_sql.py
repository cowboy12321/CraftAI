from flask_sqlalchemy import SQLAlchemy
import sys
import os

# 1. 把 models 所在路径加进去
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend', 'backend', 'app')))

# 2. 然后你就可以正常导入
from models.defect import User, Admin, Picture, MaterialLostPic
from models.base import db


def init_db(app):
    db.init_app(app)
    with app.app_context():
        db.create_all()
        # 创建初始管理员
        if not Admin.query.filter_by(name="admin").first():
            admin = Admin(name="admin", password="admin123")
            admin.save()