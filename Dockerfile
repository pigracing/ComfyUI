FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV TZ=Asia/Shanghai

# UTF-8 test
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8
ENV LC_ALL=C

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    python3.12 python3-pip python3.12-venv git curl tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 设置 python 和 pip 指向 python3.10
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# 安装 PyTorch Nightly + CUDA 12.8 支持
RUN pip install --upgrade pip && \
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu124

# 克隆 ComfyUI 项目
WORKDIR /app
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI

# 安装 ComfyUI 的依赖
RUN pip install -r requirements.txt

# Start the server by default, this can be overwritten at runtime
EXPOSE 8188

# 设置默认启动命令（你可以根据实际需求调整）
CMD ["python", "main.py"]


