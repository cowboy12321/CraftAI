from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
import os
import uuid
from datetime import datetime
from ..services.model_runner import DefectDetector
from ..models.defect import db, User, Picture, MaterialLostPic


bp = Blueprint('api', __name__, url_prefix='/api')
detector = DefectDetector(model_path=r".\app\models\best.pt")

# 设置图片保存路径
RAW_UPLOAD_FOLDER = 'static/upload/raw'
RESULT_UPLOAD_FOLDER = 'static/upload/results'
os.makedirs(RAW_UPLOAD_FOLDER, exist_ok=True)
os.makedirs(RESULT_UPLOAD_FOLDER, exist_ok=True)


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg'}


@bp.route('/login', methods=['POST'])
def login():
    """用户登录接口"""
    data = request.get_json()
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': '缺少用户名或密码'}), 400

    user = User.query.filter_by(username=data['username']).first()
    if not user or not check_password_hash(user.password, data['password']):
        return jsonify({'error': '用户名或密码错误'}), 401

    return jsonify({
        'success': True,
        'user_id': user.id,
        'username': user.username,
        'message': '登录成功'
    })


@bp.route('/predict', methods=['POST', 'GET'])
def predict_defect():
    """图片预测接口（保留GET方法）"""
    if request.method == 'GET':
        return jsonify({
            'message': '请使用POST方法上传图片',
            'required_fields': {
                'file': '图片文件',
                'user_id': '用户ID'
            }
        })

    # POST方法处理
    if 'file' not in request.files or 'user_id' not in request.form:
        return jsonify({'error': '缺少文件或用户 ID'}), 400

    file = request.files['file']
    user_id = request.form['user_id']

    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': '无效文件或不支持的格式'}), 400

    try:
        file_ext = file.filename.rsplit('.', 1)[1].lower()
        unique_id = uuid.uuid4().hex
        filename = f"{unique_id}.{file_ext}"
        raw_path = os.path.join(RAW_UPLOAD_FOLDER, filename)
        file.save(raw_path)

        result_path, boxes = detector.predict(raw_path)
        if not result_path:
            raise RuntimeError("模型预测失败")

        result_filename = f"result_{filename}"
        final_result_path = os.path.join(RESULT_UPLOAD_FOLDER, result_filename)
        os.rename(result_path, final_result_path)

        # 判断是否有材料缺失
        has_material_lost = any(int(box[5]) == 1 for box in boxes)  # 假设 class_id==1 表示缺失

        # 保存 Picture 记录
        picture = Picture(
            user_id=user_id,
            img_path=raw_path,
            processed_path=final_result_path,
            timestamp=datetime.utcnow(),
            result_summary=str(_parse_boxes(boxes)),
            material_lost=has_material_lost
        )
        db.session.add(picture)
        db.session.flush()  # 让 picture.pic_id 可用（但不提交）

        # 如果有缺失，写入 MaterialLostPic 表
        if has_material_lost:
            material_info = _extract_material_info(boxes)
            material_pic = MaterialLostPic(
                pic_id=picture.pic_id,
                severity=material_info['severity'],
                coordinates=material_info['coordinates']
            )
            db.session.add(material_pic)

        db.session.commit()

        return jsonify({
            'success': True,
            'pic_id': picture.pic_id,
            'result_image': picture.processed_path,
            'material_lost': picture.material_lost
        })

    except Exception as e:
        db.session.rollback()
        if 'raw_path' in locals() and os.path.exists(raw_path):
            os.remove(raw_path)
        if 'final_result_path' in locals() and os.path.exists(final_result_path):
            os.remove(final_result_path)
        return jsonify({'error': str(e)}), 500


def _parse_boxes(boxes):
    """将 YOLO 格式的检测框转换为 JSON 格式"""
    return [
        {
            "x1": float(box[0]),
            "y1": float(box[1]),
            "x2": float(box[2]),
            "y2": float(box[3]),
            "confidence": float(box[4]),
            "class_id": int(box[5])
        }
        for box in boxes
    ]


def _extract_material_info(boxes):
    """提取缺失材料的严重程度与坐标"""
    material_boxes = [box for box in boxes if int(box[5]) == 1]
    severity = sum(float(box[4]) for box in material_boxes) / (len(material_boxes) or 1)
    coordinates = _parse_boxes(material_boxes)
    return {
        "severity": severity,
        "coordinates": coordinates
    }