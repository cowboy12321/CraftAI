import cv2
import os
import logging

logger = logging.getLogger(__name__)

def annotate_image(image_path, coordinates, output_path):
    try:
        image = cv2.imread(image_path)
        if image is None:
            logger.error(f"无法读取图片: {image_path}")
            raise ValueError(f"无法读取图片: {image_path}")

        for coord in coordinates:
            x, y, w, h = int(coord['x']), int(coord['y']), int(coord['w']), int(coord['h'])
            defect_class = coord['class']
            confidence = coord['confidence']
            color = (0, 0, 255) if confidence > 0.8 else (0, 255, 255)
            cv2.rectangle(image, (int(x - w/2), int(y - h/2)), (int(x + w/2), int(y + h/2)), color, 2)
            label = f"{defect_class} ({confidence:.2f})"
            cv2.putText(image, label, (int(x - w/2), int(y - h/2) - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

        cv2.imwrite(output_path, image)
        if not os.path.exists(output_path):
            logger.error(f"保存标注图片失败: {output_path}")
            raise ValueError(f"保存标注图片失败: {output_path}")
        logger.info(f"生成标注图片: {output_path}")
    except Exception as e:
        logger.error(f"生成标注图片失败: {str(e)}", exc_info=True)
        raise