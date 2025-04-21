# 使用 Python 3.12 官方镜像（Debian，兼容性强）
FROM python:3.12-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git curl build-essential ffmpeg libgl1 tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装 PyTorch for CUDA 11.8（适配 GTX 1070）
RUN pip install --upgrade pip && \
    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118

# 克隆 ComfyUI 项目
WORKDIR /app
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI

# 安装 ComfyUI 依赖
RUN pip install -r requirements.txt

# 暴露默认端口
EXPOSE 8188

# 启动 ComfyUI
CMD python main.py --listen 0.0.0.0
