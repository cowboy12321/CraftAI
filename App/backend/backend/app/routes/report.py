from flask import Blueprint, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from ..models.base import define_models
from ..services.report import generate_pdf_report
from config import Config
import os
import logging

report_bp = Blueprint('report', __name__)
logger = logging.getLogger(__name__)

@report_bp.route('/report/generate/<int:detection_id>', methods=['POST'])
@jwt_required()
def generate_report(detection_id):
    db = current_app.db
    User, Detection, Report = define_models(db)
    user_id = get_jwt_identity()

    detection = Detection.query.filter_by(id=detection_id, user_id=user_id).first()
    if not detection:
        logger.warning(f"用户 {user_id} 生成报告 {detection_id} 失败：检测记录不存在")
        return jsonify({'error': '检测记录不存在'}), 404

    user = User.query.get(user_id)
    report_filename = f"report_{user_id}_{detection_id}.pdf"
    report_path = os.path.join(Config.REPORT_FOLDER, report_filename)
    report_url = f"{Config.BASE_URL}/Reports/{report_filename}"

    os.makedirs(Config.REPORT_FOLDER, exist_ok=True)
    generate_pdf_report(detection, user.username, report_path)

    report = Report(
        user_id=user_id,
        detection_id=detection_id,
        report_url=report_url
    )
    db.session.add(report)
    db.session.commit()

    logger.info(f"用户 {user_id} 生成报告 {detection_id} 成功")
    return jsonify({
        'report_id': report.id,
        'report_url': report_url,
        'timestamp': report.timestamp.isoformat()
    }), 200

@report_bp.route('/report/history', methods=['GET'])
@jwt_required()
def report_history():
    db = current_app.db
    _, _, Report = define_models(db)
    user_id = get_jwt_identity()

    reports = Report.query.filter_by(user_id=user_id).order_by(Report.timestamp.desc()).all()
    logger.info(f"用户 {user_id} 获取报告历史，记录数: {len(reports)}")
    return jsonify([{
        'report_id': r.id,
        'detection_id': r.detection_id,
        'report_url': r.report_url,
        'timestamp': r.timestamp.isoformat()
    } for r in reports]), 200

@report_bp.route('/report/<int:report_id>', methods=['GET'])
@jwt_required()
def get_report(report_id):
    db = current_app.db
    _, _, Report = define_models(db)
    user_id = get_jwt_identity()

    report = Report.query.filter_by(id=report_id, user_id=user_id).first()
    if not report:
        logger.warning(f"用户 {user_id} 获取报告 {report_id} 失败：记录不存在")
        return jsonify({'error': '报告不存在'}), 404

    logger.info(f"用户 {user_id} 获取报告 {report_id} 成功")
    return jsonify({
        'report_id': report.id,
        'detection_id': report.detection_id,
        'report_url': report.report_url,
        'timestamp': report.timestamp.isoformat()
    }), 200