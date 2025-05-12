from datetime import datetime
from .base import db, BaseModel

class User(BaseModel):
    __tablename__ = 'users'
    user_id = db.Column(db.Integer, primary_key=True)  # 明确指定user_id
    name = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(120), nullable=False)
    pictures = db.relationship('Picture', backref='user', lazy=True)

class Admin(BaseModel):
    __tablename__ = 'admins'
    name = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(120), nullable=False)

class Picture(BaseModel):
    __tablename__ = 'pictures'
    pic_id = db.Column(db.Integer, primary_key=True)  # 明确指定pic_id
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'), nullable=False)
    img_path = db.Column(db.String(255), unique=True, nullable=False)
    processed_path = db.Column(db.String(255), unique=True, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    result_summary = db.Column(db.Text)
    material_lost = db.Column(db.Boolean, default=False, nullable=False)
    material_details = db.relationship('MaterialLostPic', backref='picture', uselist=False)

class MaterialLostPic(BaseModel):
    __tablename__ = 'material_lost_pic'
    pic_id = db.Column(db.Integer, db.ForeignKey('pictures.pic_id'), nullable=False)
    severity = db.Column(db.Float)  # 新增严重程度字段
    coordinates = db.Column(db.JSON)  # 存储坐标信息
