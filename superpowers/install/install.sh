#!/usr/bin/env bash
# superpowers 方法论 skill 集 —— 一键分发到 Claude Code / Qoder
#
# 用法(Git Bash / 任意 POSIX sh):
#   ./install.sh                         # 装到全局 Claude Code: ~/.claude/skills/
#   ./install.sh --project /path/to/proj # 装到某项目: .claude/skills/ + 追加 CLAUDE.md 引导
#   ./install.sh --project /path --with-qoder  # 同时装 Qoder: .qoder/skills/ + .qoder/rules/
#   ./install.sh --dry-run ...           # 只打印将执行的动作,不写盘
#   ./install.sh --uninstall ...         # 按哨兵精确移除(不误删用户内容)
#
# 审阅满意后再运行。默认不碰 live 环境之外的东西;--dry-run 可先干跑。

set -euo pipefail

# --- 定位仓库根(脚本在 install/ 下) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_SKILLS="$REPO_ROOT/skills"
SRC_COMMANDS="$REPO_ROOT/commands"
SNIPPET="$REPO_ROOT/bootstrap/CLAUDE.md.snippet"
QODER_RULE="$REPO_ROOT/bootstrap/qoder-rule.md"

BEGIN="<!-- superpowers-sinosafe:begin -->"
END="<!-- superpowers-sinosafe:end -->"

SKILL_NAMES=(
  superpowers
  brainstorming
  writing-plans
  test-driven-development
  systematic-debugging
  verification-before-completion
)

# --- 参数解析 ---
DRY_RUN=0
UNINSTALL=0
PROJECT=""
WITH_QODER=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2;;
    --with-qoder) WITH_QODER=1; shift;;
    --dry-run) DRY_RUN=1; shift;;
    --uninstall) UNINSTALL=1; shift;;
    -h|--help)
      sed -n '2,15p' "$0"; exit 0;;
    *) echo "未知参数: $1" >&2; exit 2;;
  esac
done

run() { # 打印并(非 dry-run 时)执行
  echo "+ $*"
  [ "$DRY_RUN" -eq 1 ] || "$@"
}

# --- 哨兵块操作:在 CLAUDE.md 里增/删 superpowers 引导段 ---
inject_block() { # $1 = 目标 CLAUDE.md
  local f="$1"
  local tmp
  tmp="$(mktemp)"
  # 先去掉旧块(若存在),再追加新块
  if [ -f "$f" ]; then
    remove_block "$f" > "$tmp"
  fi
  echo "" >> "$tmp"
  cat "$SNIPPET" >> "$tmp"
  run cp "$tmp" "$f"
  rm -f "$tmp"
}

remove_block() { # $1 = 目标 CLAUDE.md ; 输出剔除后的内容到 stdout
  local f="$1"
  if [ ! -f "$f" ]; then echo -n ""; return; fi
  awk -v b="$BEGIN" -v e="$END" '
    $0==b {skip=1; next}
    $0==e {skip=0; next}
    !skip {print}
  ' "$f"
}

# --- 安装到 Claude Code ---
install_claude() {
  local dest_root="$1"      # ~/.claude 或 <project>/.claude
  local skills_dir="$dest_root/skills"
  echo "===> Claude Code: $dest_root"
  mkdir -p "$skills_dir" 2>/dev/null || true
  for s in "${SKILL_NAMES[@]}"; do
    run rm -rf "$skills_dir/$s"
    run cp -r "$SRC_SKILLS/$s" "$skills_dir/$s"
  done
  # /superpowers slash 命令(Claude Code 专用;Qoder 用 superpowers skill 触发)
  local cmds_dir="$dest_root/commands"
  mkdir -p "$cmds_dir" 2>/dev/null || true
  run cp "$SRC_COMMANDS/superpowers.md" "$cmds_dir/superpowers.md"
  # 引导:仅项目级 CLAUDE.md 自动注入;全局模式只提示
  if [ -n "$PROJECT" ]; then
    run inject_block "$PROJECT/CLAUDE.md"
  else
    echo "    (全局模式:未自动改 CLAUDE.md。如需引导,在项目根 CLAUDE.md 追加 bootstrap/CLAUDE.md.snippet)"
  fi
}

# --- 安装到 Qoder(项目级) ---
install_qoder() {
  local proj="$1"
  local skills_dir="$proj/.qoder/skills"
  local rules_dir="$proj/.qoder/rules"
  echo "===> Qoder: $proj/.qoder"
  mkdir -p "$skills_dir" "$rules_dir" 2>/dev/null || true
  for s in "${SKILL_NAMES[@]}"; do
    run rm -rf "$skills_dir/$s"
    run cp -r "$SRC_SKILLS/$s" "$skills_dir/$s"
  done
  run cp "$QODER_RULE" "$rules_dir/superpowers-sinosafe.md"
}

# --- 卸载 ---
do_uninstall() {
  if [ -n "$PROJECT" ]; then
    local claude_root="$PROJECT/.claude/skills"
    echo "===> 卸载 Claude Code(项目): $claude_root"
    for s in "${SKILL_NAMES[@]}"; do run rm -rf "$claude_root/$s"; done
    run rm -f "$PROJECT/.claude/commands/superpowers.md"
    if [ -f "$PROJECT/CLAUDE.md" ]; then
      local tmp; tmp="$(mktemp)"; remove_block "$PROJECT/CLAUDE.md" > "$tmp"
      run cp "$tmp" "$PROJECT/CLAUDE.md"; rm -f "$tmp"
    fi
    if [ "$WITH_QODER" -eq 1 ]; then
      echo "===> 卸载 Qoder(项目): $PROJECT/.qoder"
      for s in "${SKILL_NAMES[@]}"; do run rm -rf "$PROJECT/.qoder/skills/$s"; done
      run rm -f "$PROJECT/.qoder/rules/superpowers-sinosafe.md"
    fi
  else
    local claude_root="$HOME/.claude/skills"
    echo "===> 卸载 Claude Code(全局): $claude_root"
    for s in "${SKILL_NAMES[@]}"; do run rm -rf "$claude_root/$s"; done
    run rm -f "$HOME/.claude/commands/superpowers.md"
    echo "    (全局模式未动 CLAUDE.md)"
  fi
  echo "卸载完成。"
  exit 0
}

# --- 主流程 ---
[ "$UNINSTALL" -eq 1 ] && do_uninstall

if [ -z "$PROJECT" ]; then
  # 全局 Claude Code
  install_claude "$HOME/.claude"
  if [ "$WITH_QODER" -eq 1 ]; then
    echo "错误:--with-qoder 需配合 --project <dir>(Qoder 为项目级)" >&2; exit 2
  fi
else
  install_claude "$PROJECT/.claude"
  [ "$WITH_QODER" -eq 1 ] && install_qoder "$PROJECT"
fi

echo
echo "完成。$( [ "$DRY_RUN" -eq 1 ] && echo '(dry-run,未实际写入)' )"
echo "下一步:在 Claude Code 里输入 /superpowers(或 Qoder 里说『启用 superpowers』),后续任务即自动按方法论执行。"
