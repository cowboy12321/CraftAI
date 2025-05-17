from flask import current_app
from App.backend.backend.app.models.base import define_models
import logging

logger = logging.getLogger(__name__)

def save_detection(user_id, image_url, results, summary):
    db = current_app.db
    _, Detection = define_models(db)
    try:
        detection = Detection(
            user_id=user_id,
            image_url=image_url,
            material_lost=results.get('material_lost', False),
            severity=results.get('severity', 'N/A'),
            coordinates=str(results.get('coordinates', {})),
            summary=summary
        )
        db.session.add(detection)
        db.session.commit()
        logger.info(f"检测记录保存成功：user_id={user_id}")
        return detection
    except Exception as e:
        logger.error(f"保存检测记录失败：{str(e)}")
        db.session.rollback()
        raise