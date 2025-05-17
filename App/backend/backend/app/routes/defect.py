from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from App.backend.backend.app.services.model_runner import run_yolo
from App.backend.backend.app.services.database import save_detection
from App.backend.backend.app.models.base import define_models
from App.backend.backend.config import Config
import os
from openai import OpenAI

defect_bp = Blueprint('defect', __name__)

def generate_gpt_summary(results):
    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key or api_key == 'dummy':
        return "暂无GPT摘要"
    client = OpenAI(api_key=api_key)
    prompt = f"基于以下古建筑检测结果生成简要报告：{results}"
    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        print(f"GPT API error: {e}")
        return "GPT摘要生成失败"

@defect_bp.route('/predict', methods=['POST'])
@jwt_required()
def predict():
    user_id = get_jwt_identity()
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    os.makedirs(Config.UPLOAD_FOLDER, exist_ok=True)
    filename = f"{user_id}_{file.filename}"
    file_path = os.path.join(Config.UPLOAD_FOLDER, filename)
    file.save(file_path)

    image_url = f"{Config.BASE_URL}/Uploads/{filename}"
    results = run_yolo(file_path)
    summary = generate_gpt_summary(results)
    detection = save_detection(user_id, image_url, results, summary)

    return jsonify({
        'id': detection.id,
        'image_url': image_url,
        'material_lost': detection.material_lost,
        'severity': detection.severity,
        'coordinates': detection.coordinates,
        'summary': summary,
        'timestamp': detection.timestamp.isoformat()
    }), 200

@defect_bp.route('/history', methods=['GET'])
@jwt_required()
def history():
    db = current_app.db
    _, Detection = define_models(db)
    user_id = get_jwt_identity()
    detections = Detection.query.filter_by(user_id=user_id).all()
    return jsonify([{
        'id': d.id,
        'image_url': d.image_url,
        'material_lost': d.material_lost,
        'severity': d.severity,
        'coordinates': d.coordinates,
        'summary': d.summary,
        'timestamp': d.timestamp.isoformat()
    } for d in detections]), 200

@defect_bp.route('/detection/<int:detection_id>', methods=['GET'])
@jwt_required()
def get_detection(detection_id):
    db = current_app.db
    _, Detection = define_models(db)
    user_id = get_jwt_identity()
    detection = Detection.query.filter_by(id=detection_id, user_id=user_id).first()
    if not detection:
        return jsonify({'error': 'Detection not found'}), 404
    return jsonify({
        'id': detection.id,
        'image_url': detection.image_url,
        'material_lost': detection.material_lost,
        'severity': detection.severity,
        'coordinates': detection.coordinates,
        'summary': detection.summary,
        'timestamp': detection.timestamp.isoformat()
    }), 200