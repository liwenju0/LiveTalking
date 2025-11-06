#!/bin/bash
# Git LFS 配置和提交脚本
# 用途：配置 Git LFS 来管理大文件（模型、视频等）

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${PROJECT_DIR}"

echo "🔧 配置 Git LFS..."

# 1. 安装 Git LFS（如果尚未安装）
if ! command -v git-lfs &> /dev/null; then
    echo "📦 安装 Git LFS..."
    sudo apt-get update -qq
    sudo apt-get install -y git-lfs
fi

# 2. 初始化 Git LFS
echo "🎯 初始化 Git LFS..."
git lfs install

# 3. 配置 Git LFS 跟踪规则
echo "📋 配置 LFS 跟踪规则..."

# 模型文件
git lfs track "*.pth"
git lfs track "*.onnx"
git lfs track "*.safetensors"
git lfs track "*.bin"
git lfs track "*.ckpt"
git lfs track "*.pb"
git lfs track "*.h5"
git lfs track "*.pkl"

# 媒体文件
git lfs track "*.mp4"
git lfs track "*.avi"
git lfs track "*.mov"
git lfs track "*.mkv"
git lfs track "*.wav"
git lfs track "*.mp3"
git lfs track "*.flac"

# 大数据文件
git lfs track "*.zip"
git lfs track "*.tar.gz"
git lfs track "*.tar.bz2"

# 头像数据目录
git lfs track "data/avatars/**"

echo ""
echo "✅ Git LFS 配置完成！"
echo ""

# 显示当前 LFS 跟踪的文件类型
echo "📊 当前 LFS 跟踪的文件类型："
cat .gitattributes

echo ""
echo "📝 接下来请执行提交操作..."

