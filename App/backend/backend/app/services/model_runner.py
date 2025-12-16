from ultralytics import YOLO
import os
import logging
import json

logger = logging.getLogger(__name__)

def run_yolo(image_path, categories=None):
    try:
        model_path = os.path.join(os.path.dirname(__file__), '../models/best.pt')
        if not os.path.exists(model_path):
            logger.error(f"YOLO 模型文件不存在: {model_path}")
            raise FileNotFoundError(f"YOLO 模型文件不存在: {model_path}")

        model = YOLO(model_path)
        results = model.predict(image_path, conf=0.5)

        material_lost = False
        severity = '无'
        coordinates = []
        defect_types = set()

        for result in results:
            for box in result.boxes:
                defect_type = result.names[int(box.cls[0])] if result.names else 'unknown'
                if categories and defect_type not in categories:
                    continue
                material_lost = True
                conf = float(box.conf[0])
                defect_types.add(defect_type)
                severity = '严重' if conf > 0.8 else '中度' if conf > 0.5 else '轻微'
                coords = {
                    'x': float(box.xyxy[0][0]),
                    'y': float(box.xyxy[0][1]),
                    'w': float(box.xyxy[0][2] - box.xyxy[0][0]),
                    'h': float(box.xyxy[0][3] - box.xyxy[0][1]),
                    'class': defect_type,
                    'confidence': conf
                }
                coordinates.append(coords)

        output = {
            'material_lost': material_lost,
            'severity': severity,
            'coordinates': coordinates,
            'defect_types': list(defect_types),
            'summary': '检测到缺陷' if material_lost else '未检测到缺陷'
        }

        logger.info(f"YOLO 检测完成: {json.dumps(output, ensure_ascii=False)}")
        return output
    except FileNotFoundError as e:
        logger.error(f"YOLO 检测失败: {str(e)}")
        raise
    except Exception as e:
        logger.error(f"YOLO 检测失败: {str(e)}", exc_info=True)
        raise