from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token
from App.backend.backend.app.models.base import define_models
import logging

auth_bp = Blueprint('auth', __name__)
logger = logging.getLogger(__name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    db = current_app.db
    User, _ = define_models(db)
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        if not username or not password:
            logger.warning("注册失败：缺少用户名或密码")
            return jsonify({'error': 'Missing username or password'}), 400

        user = User.query.filter_by(username=username).first()
        if user:
            logger.warning(f"注册失败：用户名 {username} 已存在")
            return jsonify({'error': 'Username exists'}), 400

        hashed_password = generate_password_hash(password)
        user = User(username=username, password=hashed_password)
        db.session.add(user)
        db.session.commit()

        logger.info(f"用户 {username} 注册成功")
        return jsonify({'message': 'User created', 'user_id': user.id}), 201
    except Exception as e:
        logger.error(f"注册失败：{str(e)}")
        db.session.rollback()
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    db = current_app.db
    User, _ = define_models(db)
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        user = User.query.filter_by(username=username).first()
        if user and check_password_hash(user.password, password):
            access_token = create_access_token(identity=user.id)
            logger.info(f"用户 {username} 登录成功")
            return jsonify({'user_id': user.id, 'access_token': access_token}), 200
        logger.warning(f"登录失败：用户名 {username} 无效凭据")
        return jsonify({'error': 'Invalid credentials'}), 401
    except Exception as e:
        logger.error(f"登录失败：{str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500