from ultralytics import YOLO
import os
import logging

logger = logging.getLogger(__name__)

def run_yolo(image_path):
    try:
        model_path = os.path.join(os.path.dirname(__file__), '../models/best.pt')
        if not os.path.exists(model_path):
            logger.error(f"YOLO 模型文件不存在: {model_path}")
            raise FileNotFoundError(f"Model file not found: {model_path}")

        model = YOLO(model_path)
        results = model.predict(image_path, conf=0.5)  # 设置置信度阈值

        material_lost = False
        severity = 'N/A'
        coordinates = []

        for result in results:
            for box in result.boxes:
                material_lost = True
                conf = float(box.conf[0])  # 置信度
                cls = box.cls[0]  # 类别
                # 示例：根据置信度或类别确定严重程度
                severity = '严重' if conf > 0.8 else '中度' if conf > 0.5 else '轻微'
                coords = {
                    'x': float(box.xyxy[0][0]),
                    'y': float(box.xyxy[0][1]),
                    'w': float(box.xyxy[0][2] - box.xyxy[0][0]),
                    'h': float(box.xyxy[0][3] - box.xyxy[0][1]),
                    'class': result.names[int(cls)] if result.names else 'unknown',
                    'confidence': conf
                }
                coordinates.append(coords)

        output = {
            'material_lost': material_lost,
            'severity': severity,
            'coordinates': coordinates if coordinates else {}
        }

        logger.info(f"YOLO 检测完成: {output}")
        return output
    except Exception as e:
        logger.error(f"YOLO 检测失败: {str(e)}")
        raise