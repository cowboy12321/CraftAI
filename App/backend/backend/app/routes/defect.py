from flask import Blueprint, request, jsonify, current_app, send_from_directory
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..services.model_runner import run_yolo
from ..services.database import save_detection
from ..services.visualizer import annotate_image
from ..models.base import define_models
from ..services.storage import save_file
from config import Config
import os
import json
import logging

defect_bp = Blueprint('defect', __name__)
logger = logging.getLogger(__name__)

@defect_bp.route('/predict', methods=['POST'])
@jwt_required()
def predict():
    user_id = get_jwt_identity()
    if 'file' not in request.files:
        logger.warning("预测失败：未提供文件")
        return jsonify({'error': '请上传图片'}), 400

    file = request.files['file']
    if file.filename == '':
        logger.warning("预测失败：未选择文件")
        return jsonify({'error': '未选择有效图片'}), 400

    if not file.filename.lower().endswith(('.jpg', '.jpeg', '.png')):
        logger.warning(f"预测失败：不支持的文件格式 {file.filename}")
        return jsonify({'error': '仅支持 JPG 或 PNG 格式'}), 400

    try:
        image_url = save_file(file, user_id)
        file_path = os.path.join(Config.UPLOAD_FOLDER, os.path.basename(image_url))

        logger.debug(f"运行 YOLO 预测: {file_path}")
        results = run_yolo(file_path)
        logger.debug(f"YOLO 预测结果: {results}")

        annotated_filename = f"annotated_{os.path.basename(image_url)}"
        annotated_path = os.path.join(Config.UPLOAD_FOLDER, annotated_filename)
        logger.debug(f"生成标注图片: {annotated_path}")
        annotate_image(file_path, results['coordinates'], annotated_path)
        if not os.path.exists(annotated_path):
            logger.error(f"标注图片生成失败: {annotated_path}")
            return jsonify({'error': '标注图片生成失败'}), 500

        annotated_image_url = f"/Uploads/{annotated_filename}"
        logger.debug(f"保存检测记录到数据库")
        detection = save_detection(user_id, image_url, results, results.get('summary', '暂无摘要'), annotated_image_url)

        logger.info(f"用户 {user_id} 单张图片检测成功，检测 ID: {detection.id}")
        return jsonify({
            'id': detection.id,
            'image_url': image_url,
            'annotated_image_url': annotated_image_url,
            'material_lost': detection.material_lost,
            'severity': detection.severity,
            'coordinates': detection.coordinates if detection.coordinates else '[]',  # 保持字符串
            'defect_types': results['defect_types'],
            'summary': detection.summary,
            'timestamp': detection.timestamp.isoformat()
        }), 200
    except Exception as e:
        logger.error(f"图片处理失败: {str(e)}", exc_info=True)
        return jsonify({'error': f'图片处理失败: {str(e)}'}), 422

@defect_bp.route('/detection/single', methods=['POST'])
@jwt_required()
def detect_single():
    return predict()

@defect_bp.route('/detection/batch', methods=['POST'])
@jwt_required()
def detect_batch():
    user_id = get_jwt_identity()
    if 'images' not in request.files:
        logger.warning("批量检测失败：未提供图片")
        return jsonify({'error': '请上传图片'}), 400

    files = request.files.getlist('images')
    if not files or all(file.filename == '' for file in files):
        logger.warning("批量检测失败：未选择有效图片")
        return jsonify({'error': '未选择有效图片'}), 400

    try:
        os.makedirs(Config.UPLOAD_FOLDER, exist_ok=True)
        detections = []

        for file in files:
            if not file.filename.lower().endswith(('.jpg', '.jpeg', '.png')):
                logger.warning(f"批量检测失败：不支持的文件格式 {file.filename}")
                continue
            image_url = save_file(file, user_id)
            file_path = os.path.join(Config.UPLOAD_FOLDER, os.path.basename(image_url))

            logger.debug(f"运行 YOLO 预测: {file_path}")
            results = run_yolo(file_path)
            logger.debug(f"YOLO 预测结果: {results}")

            annotated_filename = f"annotated_{os.path.basename(image_url)}"
            annotated_path = os.path.join(Config.UPLOAD_FOLDER, annotated_filename)
            logger.debug(f"生成标注图片: {annotated_path}")
            annotate_image(file_path, results['coordinates'], annotated_path)
            if not os.path.exists(annotated_path):
                logger.error(f"标注图片生成失败: {annotated_path}")
                continue

            annotated_image_url = f"/Uploads/{annotated_filename}"
            logger.debug(f"保存检测记录到数据库")
            detection = save_detection(user_id, image_url, results, results.get('summary', '暂无摘要'),
                                       annotated_image_url)
            detections.append({
                'id': detection.id,
                'image_url': image_url,
                'annotated_image_url': annotated_image_url,
                'material_lost': detection.material_lost,
                'severity': detection.severity,
                'coordinates': detection.coordinates if detection.coordinates else '[]',  # 保持字符串
                'defect_types': results['defect_types'],
                'summary': detection.summary,
                'timestamp': detection.timestamp.isoformat()
            })

        if not detections:
            logger.warning("批量检测失败：无有效图片处理")
            return jsonify({'error': '无有效图片处理'}), 400

        logger.info(f"用户 {user_id} 批量检测完成，检测数量: {len(detections)}")
        return jsonify(detections), 200
    except Exception as e:
        logger.error(f"批量图片处理失败: {str(e)}", exc_info=True)
        return jsonify({'error': f'批量图片处理失败: {str(e)}'}), 422

@defect_bp.route('/history', methods=['GET'])
@jwt_required()
def history():
    db = current_app.db
    _, Detection, _ = define_models(db)
    user_id = get_jwt_identity()

    severity = request.args.get('severity')
    sort_by = request.args.get('sort_by', 'timestamp')
    sort_order = request.args.get('sort_order', 'desc')

    query = Detection.query.filter_by(user_id=user_id)
    if severity:
        query = query.filter_by(severity=severity)

    if sort_by == 'severity':
        query = query.order_by(Detection.severity.asc() if sort_order == 'asc' else Detection.severity.desc())
    else:
        query = query.order_by(Detection.timestamp.asc() if sort_order == 'asc' else Detection.timestamp.desc())

    detections = query.all()
    logger.info(f"用户 {user_id} 获取单张检测历史，记录数: {len(detections)}")
    return jsonify([{
        'id': d.id,
        'image_url': d.image_url,
        'annotated_image_url': d.annotated_image_url or '',
        'material_lost': d.material_lost,
        'severity': d.severity,
        'coordinates': d.coordinates if d.coordinates else '[]',  # 保持字符串
        'summary': d.summary,
        'timestamp': d.timestamp.isoformat()
    } for d in detections]), 200

@defect_bp.route('/detection/history', methods=['GET'])
@jwt_required()
def detection_history():
    return history()

@defect_bp.route('/detection/<int:detection_id>', methods=['GET'])
@jwt_required()
def get_detection(detection_id):
    db = current_app.db
    _, Detection, _ = define_models(db)
    user_id = get_jwt_identity()
    detection = Detection.query.filter_by(id=detection_id, user_id=user_id).first()
    if not detection:
        logger.warning(f"用户 {user_id} 获取检测 {detection_id} 失败：记录不存在")
        return jsonify({'error': '检测记录不存在'}), 404
    logger.info(f"用户 {user_id} 获取检测 {detection_id} 成功")
    return jsonify({
        'id': detection.id,
        'image_url': detection.image_url,
        'annotated_image_url': detection.annotated_image_url,
        'material_lost': detection.material_lost,
        'severity': detection.severity,
        'coordinates': detection.coordinates if detection.coordinates else '[]',  # 保持字符串
        'summary': detection.summary,
        'timestamp': detection.timestamp.isoformat()
    }), 200

@defect_bp.route('/detection/<int:detection_id>/download', methods=['GET'])
@jwt_required()
def download_detection(detection_id):
    db = current_app.db
    _, Detection, _ = define_models(db)
    user_id = get_jwt_identity()
    detection = Detection.query.filter_by(id=detection_id, user_id=user_id).first()
    if not detection:
        logger.warning(f"用户 {user_id} 下载检测 {detection_id} 失败：记录不存在")
        return jsonify({'error': '检测记录不存在'}), 404

    image_path = os.path.join(Config.UPLOAD_FOLDER, os.path.basename(detection.image_url))
    if not os.path.exists(image_path):
        logger.warning(f"用户 {user_id} 下载检测 {detection_id} 失败：文件不存在")
        return jsonify({'error': '图片文件不存在'}), 404

    logger.info(f"用户 {user_id} 下载检测 {detection_id} 成功")
    return send_from_directory(Config.UPLOAD_FOLDER, os.path.basename(detection.image_url), as_attachment=True)

@defect_bp.route('/statistics', methods=['GET'])
@jwt_required()
def statistics():
    db = current_app.db
    _, Detection, _ = define_models(db)
    user_id = get_jwt_identity()

    total_detections = Detection.query.filter_by(user_id=user_id).count()
    severity_counts = {
        '严重': Detection.query.filter_by(user_id=user_id, severity='严重').count(),
        '中度': Detection.query.filter_by(user_id=user_id, severity='中度').count(),
        '轻微': Detection.query.filter_by(user_id=user_id, severity='轻微').count(),
        '无': Detection.query.filter_by(user_id=user_id, severity='无').count()
    }
    defect_types = db.session.query(Detection.coordinates).filter_by(user_id=user_id).all()
    defect_type_counts = {}
    for coords in defect_types:
        coords_list = json.loads(coords[0]) if coords[0] else []  # 修改为 coords[0]
        for coord in coords_list:
            defect_type = coord.get('class', '未知')
            defect_type_counts[defect_type] = defect_type_counts.get(defect_type, 0) + 1

    logger.info(f"用户 {user_id} 获取统计数据")
    return jsonify({
        'total_detections': total_detections,
        'severity_counts': severity_counts,
        'defect_type_counts': defect_type_counts
    }), 200