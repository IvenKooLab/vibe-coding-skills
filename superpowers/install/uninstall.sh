#!/usr/bin/env bash
# superpowers skill 集 —— 卸载脚本(自包含,无需原仓库)
#
# 用法(Git Bash / 任意 POSIX sh):
#   ./uninstall.sh                         # 卸载全局 Claude Code(~/.claude)
#   ./uninstall.sh --with-qoder            # 连全局 Qoder(~/.qoder)一起卸
#   ./uninstall.sh --with-trae             # 连全局 Trae(~/.trae-cn / ~/.trae)一起卸
#   ./uninstall.sh --with-all              # Claude Code + Qoder + Trae 全卸
#   ./uninstall.sh --project /path/to/proj # 卸某项目(.claude/ 下的 skill 与命令、CLAUDE.md 引导段)
#   ./uninstall.sh --project /path --with-all
#   ./uninstall.sh --dry-run ...           # 只打印将删除什么,不真删
#
# 安全:只删本套装进去的东西 + 旧版"superpower"(单数)残留;删除前做指纹校验,
#       绝不误删同名第三方内容;CLAUDE.md 只删哨兵块,用户正文原样保留。
# 注:本脚本与 install.sh --uninstall 等价、逻辑独立;改了 skill 列表两边同步。

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
LEGACY_BEGIN="<!-- superpower-sinosafe:begin -->"
LEGACY_END="<!-- superpower-sinosafe:end -->"
LEGACY_DIR=superpower

DRY_RUN=0
PROJECT=""
WITH_QODER=0
WITH_TRAE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2;;
    --with-qoder) WITH_QODER=1; shift;;
    --with-trae) WITH_TRAE=1; shift;;
    --with-all) WITH_QODER=1; WITH_TRAE=1; shift;;
    --dry-run) DRY_RUN=1; shift;;
    -h|--help) sed -n '2,16p' "$0"; exit 0;;
    *) echo "未知参数: $1" >&2; exit 2;;
  esac
done

run() { echo "+ $*"; [ "$DRY_RUN" -eq 1 ] || "$@"; }

remove_block() { # $1=file  $2=begin(opt)  $3=end(opt)  -> 剔除哨兵块后内容到 stdout
  local f="$1" b="${2:-$BEGIN}" e="${3:-$END}"
  [ -f "$f" ] || { echo -n ""; return; }
  awk -v b="$b" -v e="$e" '$0==b{skip=1;next} $0==e{skip=0;next} !skip{print}' "$f"
}

# --- 旧版 superpower(单数)残留清理:指纹校验后才删 ---
is_our_legacy_dir() {
  local f="$1/SKILL.md"
  [ -f "$f" ] || return 1
  if grep -qF "Superpowers Methodology" "$f"; then return 0; fi
  if grep -qF "brainstorming" "$f" && grep -qF "writing-plans" "$f"; then return 0; fi
  return 1
}
cleanup_legacy() { # $1=skills dir
  local ld="$1/$LEGACY_DIR"
  [ -d "$ld" ] || return 0
  if is_our_legacy_dir "$ld"; then
    run rm -rf "$ld"
  else
    echo "    [skip] $ld - 指纹不匹配,疑似第三方,未删"
  fi
}
rm_legacy_file() { # $1=path  $2=needle
  [ -f "$1" ] || return 0
  if grep -qF "$2" "$1"; then
    run rm -f "$1"
  else
    echo "    [skip] $1 - 内容不符,未删"
  fi
}

strip_claude_md() { # $1=CLAUDE.md - 删新旧哨兵块,保留用户正文
  local f="$1" tmp1 tmp2
  [ -f "$f" ] || return 0
  tmp1="$(mktemp)"; tmp2="$(mktemp)"
  remove_block "$f" > "$tmp1"
  remove_block "$tmp1" "$LEGACY_BEGIN" "$LEGACY_END" > "$tmp2"
  run cp "$tmp2" "$f"
  rm -f "$tmp1" "$tmp2"
}

uninstall_claude() { # $1=根(.claude)
  echo "===> 卸载 Claude Code: $1"
  cleanup_legacy "$1/skills"
  rm_legacy_file "$1/commands/superpower.md" "brainstorming"
  for s in "${SKILL_NAMES[@]}"; do run rm -rf "$1/skills/$s"; done
  run rm -f "$1/commands/superpowers.md"
}
uninstall_qoder() { # $1=根(.qoder)
  echo "===> 卸载 Qoder: $1"
  cleanup_legacy "$1/skills"
  rm_legacy_file "$1/rules/superpower-sinosafe.md" "brainstorming"
  for s in "${SKILL_NAMES[@]}"; do run rm -rf "$1/skills/$s"; done
  run rm -f "$1/rules/superpowers-sinosafe.md"
}
resolve_trae_root() { # $1=parent  $2=scope
  if [ "$2" = "global" ]; then
    if   [ -d "$1/.trae-cn" ]; then echo "$1/.trae-cn"
    elif [ -d "$1/.trae" ];   then echo "$1/.trae"
    else echo "$1/.trae-cn"; fi
  else echo "$1/.trae"; fi
}
uninstall_trae() { # $1=parent  $2=scope
  local root; root="$(resolve_trae_root "$1" "$2")"
  echo "===> 卸载 Trae: $root"
  cleanup_legacy "$root/skills"
  rm_legacy_file "$root/rules/superpower-sinosafe.md" "brainstorming"
  for s in "${SKILL_NAMES[@]}"; do run rm -rf "$root/skills/$s"; done
  run rm -f "$root/rules/superpowers-sinosafe.md"
}

if [ -z "$PROJECT" ]; then
  uninstall_claude "$HOME/.claude"
  [ "$WITH_QODER" -eq 1 ] && uninstall_qoder "$HOME/.qoder"
  [ "$WITH_TRAE" -eq 1 ]  && uninstall_trae "$HOME" global
  echo "    (全局模式:未动 CLAUDE.md)"
else
  uninstall_claude "$PROJECT/.claude"
  strip_claude_md "$PROJECT/CLAUDE.md"
  [ "$WITH_QODER" -eq 1 ] && uninstall_qoder "$PROJECT/.qoder"
  [ "$WITH_TRAE" -eq 1 ]  && uninstall_trae "$PROJECT" project
fi

echo
echo "卸载完成。$( [ "$DRY_RUN" -eq 1 ] && echo '(dry-run,未实际删除)' )"
echo "如需重装:bash install/install.sh(或远程一行,见 分享说明.md)"
