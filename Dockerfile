# 使用 CUDA 11.8 的官方运行时镜像
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV TZ=Asia/Shanghai

# 安装系统依赖 + Python 3.12
# 安装基础依赖
RUN apt-get update && apt-get install -y \
    curl git tzdata build-essential gnupg lsb-release software-properties-common

# 手动添加 deadsnakes PPA（替代 add-apt-repository）
RUN curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x6A755776 \
    | gpg --dearmor -o /usr/share/keyrings/deadsnakes.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/deadsnakes.gpg] http://ppa.launchpad.net/deadsnakes/ppa/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/deadsnakes.list && \
    apt-get update

# 安装 Python 3.12
RUN apt-get install -y python3.12 python3.12-venv python3.12-distutils

# 安装 pip 并链接
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    ln -s /usr/bin/python3.12 /usr/bin/python && \
    ln -s /usr/local/bin/pip /usr/bin/pip

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
