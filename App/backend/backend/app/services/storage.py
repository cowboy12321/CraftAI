from flask import current_app
from werkzeug.utils import secure_filename
import os
import time
import logging

logger = logging.getLogger(__name__)

def save_file(file, user_id):
    try:
        filename = secure_filename(f"{user_id}_{int(time.time())}_{file.filename}")
        upload_folder = current_app.config['UPLOAD_FOLDER']
        destination = os.path.join(upload_folder, filename)

        os.makedirs(upload_folder, exist_ok=True)
        file.save(destination)

        if not os.path.exists(destination):
            logger.error(f"文件保存失败: {destination}")
            raise ValueError(f"文件保存失败: {destination}")

        base_url = current_app.config['BASE_URL']
        file_url = f"/Uploads/{filename}"
        logger.info(f"文件保存成功: {file_url}")
        return file_url
    except Exception as e:
        logger.error(f"文件保存失败: {str(e)}", exc_info=True)
        raise