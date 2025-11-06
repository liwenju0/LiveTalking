# Copyright (c) 2020-2022, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto.  Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.

# ARM版本使用标准Ubuntu镜像
# 如果是NVIDIA Jetson设备，可以使用: nvcr.io/nvidia/l4t-pytorch:r35.2.1-pth2.0-py3
ARG BASE_IMAGE=ubuntu:20.04
FROM $BASE_IMAGE

RUN apt-get update -yq --fix-missing \
 && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    pkg-config \
    wget \
    cmake \
    curl \
    git \
    vim \
    build-essential \
    python3-dev \
    libffi-dev \
    libssl-dev \
    libblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    gfortran \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libopus-dev \
    libvpx-dev \
    libsrtp2-dev \
    portaudio19-dev \
    libasound2-dev \
    libsndfile1 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libx11-dev \
    libfreetype6-dev \
    libpng-dev \
    zlib1g-dev \
    libjpeg-dev \
    ffmpeg

#ENV PYTHONDONTWRITEBYTECODE=1
#ENV PYTHONUNBUFFERED=1

# nvidia-container-runtime
#ENV NVIDIA_VISIBLE_DEVICES all
#ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics

# ARM64架构使用aarch64版本的Miniconda（使用清华镜像源）
RUN wget --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-aarch64.sh && \
    sh Miniconda3-latest-Linux-aarch64.sh -b -u -p ~/miniconda3 && \
    rm Miniconda3-latest-Linux-aarch64.sh

ENV PATH="/root/miniconda3/bin:${PATH}"

# Accept conda terms of service for official channels first
RUN conda config --set channel_priority flexible && \
    conda config --set always_yes yes && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Configure Tsinghua mirrors for faster download
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch && \
    conda config --set show_channel_urls yes && \
    conda create -n nerfstream python=3.10 && \
    conda clean -afy

# Activate conda environment and install dependencies
SHELL ["/bin/bash", "-c"]

# ARM架构安装CPU版本的PyTorch（无CUDA支持）
# 如果是NVIDIA Jetson，需要按官方文档安装特定版本的PyTorch
RUN source /root/miniconda3/etc/profile.d/conda.sh && \
    conda activate nerfstream && \
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip install torch==1.12.1 torchvision==0.13.1 --extra-index-url https://download.pytorch.org/whl/cpu && \
    conda clean -afy

COPY requirements-arm.txt ./

# ARM架构优化：先安装一些需要编译的基础包
RUN source /root/miniconda3/etc/profile.d/conda.sh && \
    conda activate nerfstream && \
    # 使用conda安装numpy等科学计算包（有优化的ARM版本）
    conda install numpy scipy scikit-learn -y && \
    conda clean -afy

# 安装其他依赖
RUN source /root/miniconda3/etc/profile.d/conda.sh && \
    conda activate nerfstream && \
    # 设置编译环境变量以加速
    export MAKEFLAGS="-j$(nproc)" && \
    # 跳过可选的GUI库（服务器不需要）
    pip install -r requirements-arm.txt --no-cache-dir

# COPY ../nerfstream /nerfstream
WORKDIR /nerfstream
CMD ["python3", "app.py"]
