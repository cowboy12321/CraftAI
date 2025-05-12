from flask import Blueprint
from .defect import bp as defect_bp

def register_routes(app):
    app.register_blueprint(defect_bp, url_prefix='/api')
