from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def define_models(db):
    if not hasattr(db, '_user_model'):
        class User(db.Model):
            __tablename__ = 'user'
            __table_args__ = {'extend_existing': True}
            id = db.Column(db.Integer, primary_key=True)
            username = db.Column(db.String(80), unique=True, nullable=False)
            password = db.Column(db.String(256), nullable=False)
        db._user_model = User
    else:
        User = db._user_model

    if not hasattr(db, '_detection_model'):
        class Detection(db.Model):
            __tablename__ = 'detection'
            __table_args__ = {'extend_existing': True}
            id = db.Column(db.Integer, primary_key=True)
            user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
            image_url = db.Column(db.String(255), nullable=False)
            material_lost = db.Column(db.Boolean, nullable=False)
            severity = db.Column(db.String(50))
            coordinates = db.Column(db.Text)
            summary = db.Column(db.Text)
            timestamp = db.Column(db.DateTime, default=datetime.utcnow)
            annotated_image_url = db.Column(db.String(255))  # 带标注的图片
        db._detection_model = Detection
    else:
        Detection = db._detection_model

    if not hasattr(db, '_report_model'):
        class Report(db.Model):
            __tablename__ = 'report'
            __table_args__ = {'extend_existing': True}
            id = db.Column(db.Integer, primary_key=True)
            user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
            detection_id = db.Column(db.Integer, db.ForeignKey('detection.id'), nullable=False)
            report_url = db.Column(db.String(255), nullable=False)
            timestamp = db.Column(db.DateTime, default=datetime.utcnow)
        db._report_model = Report
    else:
        Report = db._report_model

    return User, Detection, Report