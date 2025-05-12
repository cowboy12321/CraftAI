import cv2
from pathlib import Path
from ultralytics import YOLO
import uuid
from datetime import datetime
from ..models.defect import Picture, MaterialLostPic, db


class DefectDetector:
    def __init__(self, model_path='best.pt'):
        self.model = YOLO(model_path)
        self.class_names = self.model.names  # 获取类别名称字典

    def predict(self, image_path):
        """执行预测并返回结构化结果"""
        try:
            # 生成唯一文件名
            unique_id = uuid.uuid4().hex
            raw_filename = f"{unique_id}_raw{Path(image_path).suffix}"
            result_filename = f"{unique_id}_result.jpg"

            # 执行预测
            results = self.model.predict(
                source=image_path,
                imgsz=640,
                conf=0.25,
                save=True,
                save_txt=False,
                show=False
            )

            # 处理第一个检测结果
            result = results[0]

            # 保存带标注的图片
            output_dir = Path("static/results")
            output_dir.mkdir(exist_ok=True)
            result_path = output_dir / result_filename
            result.save(filename=str(result_path))

            # 提取检测信息
            material_lost = False
            defect_details = []
            for box in result.boxes:
                class_id = int(box.cls)
                if self.class_names[class_id] == "material_lost":
                    material_lost = True
                    defect_details.append({
                        "class": self.class_names[class_id],
                        "confidence": float(box.conf),
                        "coordinates": box.xyxy[0].cpu().numpy().tolist()
                    })

            return {
                "raw_path": str(image_path),
                "result_path": str(result_path),
                "material_lost": material_lost,
                "defects": defect_details,
                "timestamp": datetime.now()
            }

        except Exception as e:
            print(f"预测过程中发生错误: {str(e)}")
            return None