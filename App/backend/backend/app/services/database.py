from sqlalchemy.exc import SQLAlchemyError
from ..models.base import db

class DatabaseService:
    @staticmethod
    def create_picture_record(user_id, prediction_result):
        """创建完整的检测记录"""
        try:
            # 创建主记录
            new_picture = Picture(
                user_id=user_id,
                img_path=prediction_result["raw_path"],
                processed_path=prediction_result["result_path"],
                material_lost=prediction_result["material_lost"],
                result_summary=str(prediction_result["defects"])
            )
            new_picture.save()

            # 如果存在材料缺失，创建详细记录
            if prediction_result["material_lost"]:
                main_defect = next(
                    (d for d in prediction_result["defects"] if d["class"] == "material_lost"),
                    None
                )
                if main_defect:
                    MaterialLostPic(
                        pic_id=new_picture.id,
                        severity=main_defect["confidence"],
                        coordinates=main_defect["coordinates"]
                    ).save()

            return new_picture
        except SQLAlchemyError as e:
            db.session.rollback()
            print(f"数据库操作失败: {str(e)}")
            return None