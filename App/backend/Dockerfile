FROM python:3.9-slim

WORKDIR /app

# 1. 换源：解决 apt-get 卡顿
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources 2>/dev/null || sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# 2. 安装系统依赖 (使用新的 libgl1 包名)
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    fontconfig \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

# 3. 升级 pip
RUN pip install --no-cache-dir --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple

# 【核心优化】先单独安装 CPU 版 PyTorch
# 好处1：体积小（几百M vs 2G），下载快，成功率高
# 好处2：这一层构建成功后会被缓存。以后你改 requirements.txt 加别的库，这一步不会重新跑！
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# 4. 复制依赖清单
COPY requirements.txt .

# 5. 安装其余依赖
# --default-timeout=1000：防止网络波动导致的中断
# ultralytics 会检测到已有 torch，跳过大文件下载
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --default-timeout=1000

# 6. 复制代码
COPY . .

EXPOSE 5000

CMD ["python", "app_run.py"]
