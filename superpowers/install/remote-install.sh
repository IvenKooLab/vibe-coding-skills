#!/usr/bin/env bash
# superpowers skill 集 —— 远程一行安装(从内网 git 仓库拉取并安装)
#
# 用法(同事无需手动 clone):
#   bash remote-install.sh                              # 全局:装了哪个 IDE(Claude Code/Qoder/Trae)就往哪个里装
#   bash remote-install.sh --project /path/to/proj      # 装到某项目
#   bash remote-install.sh --with-all                   # 强制三端
#   bash remote-install.sh --project /path --with-all
#
# 托管在内网 git 后,一行命令(参数透传):
#   curl -fsSL <仓库>/raw/main/install/remote-install.sh | bash -s -- --project /path
#
# 卸载也用一行(自包含,不依赖仓库):
#   curl -fsSL <仓库>/raw/main/install/uninstall.sh | bash -s -- --project /path
#
# === 改这里:填你司内网 git 仓库地址 ===
REPO_URL="${SUPERPOWERS_REPO:-https://gitlab.your-corp.com/sinosafe/superpowers.git}"
BRANCH="${SUPERPOWERS_BRANCH:-main}"

set -euo pipefail

echo "==> 克隆 $REPO_URL (分支 $BRANCH) ..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$TMP/repo"

echo "==> 运行安装器(透传参数:$*) ..."
bash "$TMP/repo/install/install.sh" "$@"

echo "==> 完成,临时目录已自动清理。"
echo "在 Claude Code 里输入 /superpowers(Qoder/Trae 里说 启用 superpowers)即可开始;卸载见 install/uninstall.sh。"
