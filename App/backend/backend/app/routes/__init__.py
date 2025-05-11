from app.routes.defect import defect_bp

def register_routes(app):
    app.register_blueprint(defect_bp, url_prefix='/defect')