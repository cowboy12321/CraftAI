# E:\CraftAI app\CraftAI\App\backend\backend\app\services\storage.py
import os
from flask import current_app
from werkzeug.utils import secure_filename

def save_file(file_path, filename):
    """
    将文件保存到本地 Uploads 文件夹，并返回可访问的 URL
    :param file_path: 临时文件路径
    :param filename: 保存的文件名
    :return: 文件的 URL
    """
    filename = secure_filename(filename)
    upload_folder = current_app.config['UPLOAD_FOLDER']
    destination = os.path.join(upload_folder, filename)

    os.makedirs(upload_folder, exist_ok=True)
    os.rename(file_path, destination)

    base_url = current_app.config['BASE_URL']
    file_url = f"{base_url}/Uploads/{filename}"
    return file_url