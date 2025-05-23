import os

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p62005')
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', 'postgresql://postgres:123456@localhost:5432/jiangzhi')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'x9y8z7w6v5u4t3s2r1q0p9o8n7m6l5k4')
    REPORT_FOLDER = os.getenv('REPORT_FOLDER', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Reports'))
    UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Uploads'))
    BASE_URL = os.getenv('BASE_URL', 'http://127.0.0.1:5000')
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 限制上传文件大小为 16MB
    SCHEDULER_API_ENABLED = True
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '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')