from flask import current_app
from ..models.base import define_models
import logging
import json

logger = logging.getLogger(__name__)

def save_detection(user_id, image_url, results, summary, annotated_image_url=None):
    db = current_app.db
    _, Detection, _ = define_models(db)
    try:
        # 使用 json.dumps 序列化 coordinates
        coordinates = json.dumps(results.get('coordinates', []), ensure_ascii=False)
        logger.debug(f"保存 coordinates: {coordinates}")

        detection = Detection(
            user_id=user_id,
            image_url=image_url,
            material_lost=results.get('material_lost', False),
            severity=results.get('severity', 'N/A'),
            coordinates=coordinates,
            summary=summary,
            annotated_image_url=annotated_image_url
        )
        db.session.add(detection)
        db.session.commit()
        logger.info(f"检测记录保存成功：user_id={user_id}, detection_id={detection.id}")
        return detection
    except Exception as e:
        logger.error(f"保存检测记录失败：{str(e)}", exc_info=True)
        db.session.rollback()
        raise