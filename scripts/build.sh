#!/bin/bash
# Docker 镜像构建脚本
# 用途：构建 ARM64 架构的 lightmountain-digital 镜像

set -e

IMAGE_NAME="lightmountain-digital:v1.0.0"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "开始构建 Docker 镜像..."
echo "镜像名称: ${IMAGE_NAME}"
echo "项目目录: ${PROJECT_DIR}"
echo ""

cd ${PROJECT_DIR}

echo "🔨 开始构建（ARM64 架构）..."
docker build \
  --platform linux/arm64 \
  -t ${IMAGE_NAME} \
  -f Dockerfile \
  .

echo ""
echo "✅ 镜像构建成功！"
echo ""
echo "镜像信息:"
docker images | grep lightmountain-digital

echo ""
echo "📋 下一步操作:"
echo "  运行容器: ./scripts/run.sh"
echo "  进入调试: ./scripts/run-bash.sh"
echo ""
