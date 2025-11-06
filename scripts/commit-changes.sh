#!/bin/bash
# Git 提交脚本 - ARM 架构适配
# 用途：提交所有 ARM 架构相关的修改

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${PROJECT_DIR}"

echo "📦 准备提交 ARM 架构适配相关修改..."
echo ""

# 1. 添加新文件
echo "➕ 添加新文件..."
git add requirements-arm.txt
git add scripts/build.sh
git add scripts/setup-git-lfs.sh
git add scripts/commit-changes.sh
git add .gitattributes 2>/dev/null || true

# 2. 添加修改的文件
echo "📝 添加修改的文件..."
git add Dockerfile
git add scripts/run.sh
git add scripts/run-bash.sh

# 3. 检查是否有其他需要提交的修改
echo ""
echo "📊 当前状态："
git status --short

echo ""
echo "🔍 准备提交的更改："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "• Dockerfile: ARM 架构适配"
echo "  - 使用 ARM64 基础镜像"
echo "  - 添加所有必需的系统依赖"
echo "  - 配置清华镜像源"
echo "  - 安装 CPU 版本的 PyTorch"
echo ""
echo "• requirements-arm.txt: ARM 优化的依赖列表"
echo "  - 移除 ARM 不兼容的包"
echo "  - 优化编译选项"
echo ""
echo "• scripts/build.sh: 镜像构建脚本"
echo "• scripts/run.sh: 简化的容器运行脚本"
echo "• scripts/run-bash.sh: 调试用 bash 脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
read -p "✅ 确认提交这些更改？(y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 取消提交"
    exit 1
fi

# 4. 提交
echo ""
echo "💾 提交更改..."
git commit -m "feat: ARM64 架构适配

🎯 主要更新：
- ✅ 支持 ARM64 架构的 Docker 镜像构建
- ✅ 优化系统依赖，添加所有必需的库
- ✅ 使用国内镜像源（清华、阿里云）加速构建
- ✅ 安装 CPU 版本的 PyTorch（无 CUDA）
- ✅ 创建 ARM 优化的 requirements.txt
- ✅ 简化容器启动脚本，移除运行时安装
- ✅ 添加构建和管理脚本

📦 新增文件：
- requirements-arm.txt: ARM 架构专用依赖列表
- scripts/build.sh: Docker 镜像构建脚本
- scripts/setup-git-lfs.sh: Git LFS 配置脚本

🔧 修改文件：
- Dockerfile: 完整的 ARM64 支持
  * Ubuntu 20.04 基础镜像
  * 添加 libsndfile1, libgl1-mesa-glx, ffmpeg 等必需库
  * Miniconda ARM64 版本
  * 清华镜像源配置
  
- scripts/run.sh: 简化启动流程
  * 移除运行时依赖安装
  * 所有依赖集成到镜像中

- scripts/run-bash.sh: 修正镜像名称和移除 GPU 参数

⚠️ 注意事项：
- ARM CPU 性能较 GPU 慢，推理速度受限
- 所有代码已兼容 CPU，通过 torch.cuda.is_available() 自动适配
- 推荐使用 lightreal 或 wav2lip 模型以获得较好性能

🏗️ 构建方法：
\`\`\`bash
./scripts/build.sh
./scripts/run.sh
\`\`\`

测试环境：ARM64 (aarch64) | Ubuntu 20.04"

echo ""
echo "✅ 提交完成！"
echo ""

# 5. 推送
read -p "🚀 是否推送到远程仓库？(y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📤 推送到 origin/dev..."
    git push origin dev
    echo ""
    echo "🎉 推送成功！"
else
    echo "⏸️  跳过推送，稍后可以手动执行："
    echo "   git push origin dev"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ 完成！所有更改已提交到 Git"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

