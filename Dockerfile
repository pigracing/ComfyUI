# 使用 CUDA 11.8 的官方运行时镜像
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV TZ=Asia/Shanghai

# 安装系统依赖 + Python 3.12
RUN apt-get update && apt-get install -y \
    software-properties-common curl git tzdata build-essential \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    python3.12 python3.12-venv python3.12-distutils \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 \
    && ln -s /usr/bin/python3.12 /usr/bin/python \
    && ln -s /usr/local/bin/pip /usr/bin/pip \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装 PyTorch 稳定版（CUDA 11.8 对 Pascal 架构最稳定）
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

# 启动 ComfyUI（如果你有需要也可以加启动参数）
CMD ["python", "main.py"]
