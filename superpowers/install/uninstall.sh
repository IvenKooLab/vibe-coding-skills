#!/usr/bin/env bash
# superpowers skill 集 —— 卸载脚本(自包含,无需原仓库)
#
# 用法(Git Bash / 任意 POSIX sh):
#   ./uninstall.sh                         # 卸载全局 Claude Code(~/.claude)
#   ./uninstall.sh --project /path/to/proj # 卸载某项目(.claude/ 下的 skill 与命令、CLAUDE.md 引导段)
#   ./uninstall.sh --project /path --with-qoder  # 同时卸载 Qoder(.qoder/)
#   ./uninstall.sh --dry-run ...           # 只打印将删除什么,不真删
#
# 安全:只删本套装进去的东西(6 个 skill + /superpowers 命令 + 哨兵引导段 +
#       Qoder rule),绝不删用户自己写的内容。
# 注:本脚本与 install.sh --uninstall 等价、逻辑独立;若改了 skill 列表,两边同步。

set -euo pipefail

SKILL_NAMES=(
  superpowers
  brainstorming
  writing-plans
  test-driven-development
  systematic-debugging
  verification-before-completion
)

BEGIN="<!-- superpowers-sinosafe:begin -->"
END="<!-- superpowers-sinosafe:end -->"

DRY_RUN=0
PROJECT=""
WITH_QODER=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2;;
    --with-qoder) WITH_QODER=1; shift;;
    --dry-run) DRY_RUN=1; shift;;
    -h|--help) sed -n '2,13p' "$0"; exit 0;;
    *) echo "未知参数: $1" >&2; exit 2;;
  esac
done

run() { echo "+ $*"; [ "$DRY_RUN" -eq 1 ] || "$@"; }

remove_block() { # $1 = CLAUDE.md ; 输出剔除哨兵块后的内容到 stdout
  [ -f "$1" ] || { echo -n ""; return; }
  awk -v b="$BEGIN" -v e="$END" '
    $0==b {skip=1; next}
    $0==e {skip=0; next}
    !skip {print}
  ' "$1"
}

if [ -z "$PROJECT" ]; then
  echo "===> 卸载全局 Claude Code: $HOME/.claude"
  for s in "${SKILL_NAMES[@]}"; do run rm -rf "$HOME/.claude/skills/$s"; done
  run rm -f "$HOME/.claude/commands/superpowers.md"
  echo "    (全局模式:未动 CLAUDE.md)"
else
  echo "===> 卸载项目 Claude Code: $PROJECT/.claude"
  for s in "${SKILL_NAMES[@]}"; do run rm -rf "$PROJECT/.claude/skills/$s"; done
  run rm -f "$PROJECT/.claude/commands/superpowers.md"
  if [ -f "$PROJECT/CLAUDE.md" ]; then
    tmp="$(mktemp)"; remove_block "$PROJECT/CLAUDE.md" > "$tmp"
    run cp "$tmp" "$PROJECT/CLAUDE.md"; rm -f "$tmp"
  fi
  if [ "$WITH_QODER" -eq 1 ]; then
    echo "===> 卸载 Qoder: $PROJECT/.qoder"
    for s in "${SKILL_NAMES[@]}"; do run rm -rf "$PROJECT/.qoder/skills/$s"; done
    run rm -f "$PROJECT/.qoder/rules/superpowers-sinosafe.md"
  fi
fi

echo
echo "卸载完成。$( [ "$DRY_RUN" -eq 1 ] && echo '(dry-run,未实际删除)' )"
echo "如需重装:bash install/install.sh(或远程一行,见 分享说明.md)"
