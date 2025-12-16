server {
    listen 80;
    server_name localhost;

    # 前端静态文件目录
    root /usr/share/nginx/html;
    index index.html index.htm;

    # 1. 核心配置：解决 Flutter Web 刷新报 404 的问题
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 2. API 反向代理：将 /api 开头的请求转发给后端容器
    # 这样前端代码里只需要写 '/api/login'，不需要写 'http://localhost:5000/api/login'
    location /api/ {
        # 'jiangzhi_backend' 是我们在 docker-compose.yml 里定义的后端服务名
        proxy_pass http://jiangzhi_backend:5000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # 3. 图片资源代理
    location /Uploads/ {
        proxy_pass http://jiangzhi_backend:5000/Uploads/;
    }
}