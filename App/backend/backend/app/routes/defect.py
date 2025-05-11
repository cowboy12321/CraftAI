from flask import Blueprint, request, jsonify
import os
from app.services.model_runner import run_yolov11_detection
from app.models.defect import save_picture, get_user_by_name

defect_bp = Blueprint('defect', __name__)

UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), '../static/uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@defect_bp.route('/upload', methods=['POST'])
def upload_image():
    username = request.form.get('username')
    image = request.files.get('image')

    if not username or not image:
        return jsonify({'error': '缺少用户名或图片'}), 400

    user = get_user_by_name(username)
    if not user:
        return jsonify({'error': '用户不存在'}), 404

    user_id = user[0]
    filename = image.filename
    image_path = os.path.join(UPLOAD_FOLDER, filename)
    image.save(image_path)

    result = run_yolov11_detection(image_path)
    processed_path = image_path  # 简化：实际应为检测后生成的文件路径
    save_success = save_picture(
        user_id, image_path, processed_path,
        result['summary'], result['material_lost']
    )
    if save_success:
        return jsonify({'message': '上传并检测成功', 'result': result})
    else:
        return jsonify({'error': '数据库保存失败'}), 500