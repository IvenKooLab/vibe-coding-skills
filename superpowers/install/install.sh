#!/usr/bin/env bash
# superpowers skill set - one-click deploy to Claude Code / Qoder / Trae (POSIX sh / bash)
#
# Usage (Git Bash / any POSIX sh):
#   ./install.sh                         # global: adapt every IDE already installed
#   ./install.sh --with-claude           # force Claude Code (global ~/.claude | project .claude)
#   ./install.sh --with-qoder            # also Qoder (global ~/.qoder | project .qoder)
#   ./install.sh --with-trae             # also Trae  (global ~/.trae-cn / ~/.trae | project .trae)
#   ./install.sh --with-all              # Claude Code + Qoder + Trae together
#   ./install.sh --project /path/to/proj # project: .claude/skills/ + CLAUDE.md bootstrap
#   ./install.sh --dry-run ...           # print only, no writes
#   ./install.sh --uninstall ...         # remove by sentinel (never touches user content)
#
# No -Project, global: auto-adapts every IDE config dir that already exists (~/.claude,
# ~/.qoder, ~/.trae-cn, ~/.trae). Dirs for IDEs you do NOT have are never created. If
# none exist, the run aborts with a hint (run an IDE once, or pass --with-* / --with-all).
#
# Legacy cleanup: this project used to be named "superpower" (singular). Before each
# install the dest is scanned for leftovers (skills/superpower/, commands/superpower.md,
# qoder rule superpower-sinosafe.md). A folder/file is removed ONLY after a content
# fingerprint check confirms it is ours - a third-party item named "superpower" is left
# untouched. The OLD CLAUDE.md sentinel block (superpower-sinosafe:begin..end) IS safely
# stripped here (awk; the .bat cannot).

set -euo pipefail

# --- locate repo root (script lives in install/) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_SKILLS="$REPO_ROOT/skills"
SRC_COMMANDS="$REPO_ROOT/commands"
SNIPPET="$REPO_ROOT/bootstrap/CLAUDE.md.snippet"
QODER_RULE="$REPO_ROOT/bootstrap/qoder-rule.md"

BEGIN="<!-- superpowers-sinosafe:begin -->"
END="<!-- superpowers-sinosafe:end -->"
LEGACY_BEGIN="<!-- superpower-sinosafe:begin -->"
LEGACY_END="<!-- superpower-sinosafe:end -->"

SKILL_NAMES=(
  superpowers
)
# Note: brainstorming / writing-plans / test-driven-development / systematic-debugging /
# verification-before-completion were merged into the single `superpowers` skill. The
# array above is the only skill dir installed now; old per-discipline dirs are cleaned
# up by cleanup_legacy_skills_dir (fingerprinted on "superpowers").

# --- argument parsing ---
DRY_RUN=0
UNINSTALL=0
PROJECT=""
WITH_CLAUDE=0
WITH_QODER=0
WITH_TRAE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2;;
    --with-claude) WITH_CLAUDE=1; shift;;
    --with-qoder) WITH_QODER=1; shift;;
    --with-trae) WITH_TRAE=1; shift;;
    --with-all) WITH_CLAUDE=1; WITH_QODER=1; WITH_TRAE=1; shift;;
    --dry-run) DRY_RUN=1; shift;;
    --uninstall) UNINSTALL=1; shift;;
    -h|--help) sed -n '2,22p' "$0"; exit 0;;
    *) echo "unknown argument: $1" >&2; exit 2;;
  esac
done

run() { # print and (unless dry-run) execute
  echo "+ $*"
  [ "$DRY_RUN" -eq 1 ] || "$@"
}

# --- sentinel block ops: strip a begin/end block from CLAUDE.md (stdout) ---
remove_block() { # $1=file  $2=begin(optional, default $BEGIN)  $3=end(optional, default $END)
  local f="$1" b="${2:-$BEGIN}" e="${3:-$END}"
  if [ ! -f "$f" ]; then echo -n ""; return; fi
  awk -v b="$b" -v e="$e" '
    $0==b {skip=1; next}
    $0==e {skip=0; next}
    !skip {print}
  ' "$f"
}

# strip BOTH old singular and newplural blocks, then append fresh snippet
inject_block() { # $1 = target CLAUDE.md
  local f="$1" tmp1 tmp2
  tmp1="$(mktemp)"; tmp2="$(mktemp)"
  if [ -f "$f" ]; then
    remove_block "$f" > "$tmp1"
    remove_block "$tmp1" "$LEGACY_BEGIN" "$LEGACY_END" > "$tmp2"
  fi
  echo "" >> "$tmp2"
  cat "$SNIPPET" >> "$tmp2"
  run cp "$tmp2" "$f"
  rm -f "$tmp1" "$tmp2"
}

# --- legacy fingerprint: is this dir our old "superpower" build? ---
is_our_legacy_dir() { # $1=dir ; return 0=ours, 1=not
  local f="$1/SKILL.md"
  [ -f "$f" ] || return 1
  if grep -qF "Superpowers Methodology" "$f"; then return 0; fi
  if grep -qF "brainstorming" "$f" && grep -qF "writing-plans" "$f"; then return 0; fi
  return 1
}

rm_legacy_file() { # $1=path $2=fingerprint needle
  local p="$1" needle="$2"
  if [ ! -f "$p" ]; then return 0; fi
  if grep -qF "$needle" "$p"; then
    run rm -f "$p"
  else
    echo "    [skip] $p - content does not look like our legacy, left untouched."
  fi
}

cleanup_legacy_skills_dir() { # $1=skills dir
  # 1) clean the oldest single-name "superpower" (pre-rename) dir
  local ld="$1/superpower"
  [ -d "$ld" ] && {
    if is_our_legacy_dir "$ld"; then run rm -rf "$ld"
    else echo "    [skip] $ld - fingerprint mismatch, not our legacy, left untouched."
    fi
  }
  # 2) clean the 5 pre-merge per-discipline dirs (merged into superpowers)
  local d
  for d in brainstorming writing-plans test-driven-development systematic-debugging verification-before-completion; do
    ld="$1/$d"
    [ -d "$ld" ] || continue
    if is_our_legacy_dir "$ld"; then
      run rm -rf "$ld"
    else
      echo "    [skip] $ld - fingerprint mismatch, not our legacy, left untouched."
    fi
  done
}

copy_skills_to() { # $1=dest skills dir
  mkdir -p "$1" 2>/dev/null || true
  for s in "${SKILL_NAMES[@]}"; do
    run rm -rf "$1/$s"
    run cp -r "$SRC_SKILLS/$s" "$1/$s"
  done
}

# --- install to Claude Code ---
install_claude() {
  local dest_root="$1"      # ~/.claude or <project>/.claude
  echo "===> Claude Code: $dest_root"
  cleanup_legacy_skills_dir "$dest_root/skills"
  rm_legacy_file "$dest_root/commands/superpower.md" "brainstorming"
  copy_skills_to "$dest_root/skills"
  # /superpowers slash command (Claude Code only; Qoder/Trae use the superpowers skill)
  local cmds_dir="$dest_root/commands"
  mkdir -p "$cmds_dir" 2>/dev/null || true
  run cp "$SRC_COMMANDS/superpowers.md" "$cmds_dir/superpowers.md"
  if [ -n "$PROJECT" ]; then
    run inject_block "$PROJECT/CLAUDE.md"
  else
    echo "    (global mode: CLAUDE.md not touched. For bootstrap, append bootstrap/CLAUDE.md.snippet to a project CLAUDE.md)"
  fi
}

# --- install to Qoder (global ~/.qoder or project .qoder) ---
install_qoder() { # $1=parent $2=scope
  local parent="$1" scope="$2"
  local root="$parent/.qoder"
  echo "===> Qoder [$scope]: $root"
  cleanup_legacy_skills_dir "$root/skills"
  rm_legacy_file "$root/rules/superpower-sinosafe.md" "brainstorming"
  mkdir -p "$root/skills" "$root/rules" 2>/dev/null || true
  copy_skills_to "$root/skills"
  run cp "$QODER_RULE" "$root/rules/superpowers-sinosafe.md"
}

# --- Trae root: global prefers ~/.trae-cn, falls back to ~/.trae; project uses .trae ---
resolve_trae_root() { # $1=parent $2=scope ; echoes the root
  if [ "$2" = "global" ]; then
    if [ -d "$1/.trae-cn" ]; then echo "$1/.trae-cn"
    elif [ -d "$1/.trae" ]; then echo "$1/.trae"
    else echo "$1/.trae-cn"   # neither exists (forced): default to CN build
    fi
  else
    echo "$1/.trae"
  fi
}

install_trae() { # $1=parent $2=scope
  local parent="$1" scope="$2" root
  root="$(resolve_trae_root "$parent" "$scope")"
  echo "===> Trae [$scope]: $root"
  cleanup_legacy_skills_dir "$root/skills"
  rm_legacy_file "$root/rules/superpower-sinosafe.md" "brainstorming"
  mkdir -p "$root/skills" "$root/rules" 2>/dev/null || true
  copy_skills_to "$root/skills"
  run cp "$QODER_RULE" "$root/rules/superpowers-sinosafe.md"
}

# --- uninstall ---
do_uninstall() {
  if [ -n "$PROJECT" ]; then
    local claude_root="$PROJECT/.claude/skills"
    echo "===> Uninstall Claude Code (project): $claude_root"
    for s in "${SKILL_NAMES[@]}"; do run rm -rf "$claude_root/$s"; done
    run rm -f "$PROJECT/.claude/commands/superpowers.md"
    if [ -f "$PROJECT/CLAUDE.md" ]; then
      local tmp1 tmp2; tmp1="$(mktemp)"; tmp2="$(mktemp)"
      remove_block "$PROJECT/CLAUDE.md" > "$tmp1"
      remove_block "$tmp1" "$LEGACY_BEGIN" "$LEGACY_END" > "$tmp2"
      run cp "$tmp2" "$PROJECT/CLAUDE.md"; rm -f "$tmp1" "$tmp2"
    fi
    if [ "$WITH_QODER" -eq 1 ]; then
      echo "===> Uninstall Qoder (project): $PROJECT/.qoder"
      for s in "${SKILL_NAMES[@]}"; do run rm -rf "$PROJECT/.qoder/skills/$s"; done
      run rm -f "$PROJECT/.qoder/rules/superpowers-sinosafe.md"
    fi
    if [ "$WITH_TRAE" -eq 1 ]; then
      echo "===> Uninstall Trae (project): $PROJECT/.trae"
      for s in "${SKILL_NAMES[@]}"; do run rm -rf "$PROJECT/.trae/skills/$s"; done
      run rm -f "$PROJECT/.trae/rules/superpowers-sinosafe.md"
    fi
  else
    local claude_root="$HOME/.claude/skills"
    echo "===> Uninstall Claude Code (global): $claude_root"
    for s in "${SKILL_NAMES[@]}"; do run rm -rf "$claude_root/$s"; done
    run rm -f "$HOME/.claude/commands/superpowers.md"
    if [ "$WITH_QODER" -eq 1 ]; then
      echo "===> Uninstall Qoder (global): $HOME/.qoder"
      for s in "${SKILL_NAMES[@]}"; do run rm -rf "$HOME/.qoder/skills/$s"; done
      run rm -f "$HOME/.qoder/rules/superpowers-sinosafe.md"
    fi
    if [ "$WITH_TRAE" -eq 1 ]; then
      local troot; troot="$(resolve_trae_root "$HOME" "global")"
      echo "===> Uninstall Trae (global): $troot"
      for s in "${SKILL_NAMES[@]}"; do run rm -rf "$troot/skills/$s"; done
      run rm -f "$troot/rules/superpowers-sinosafe.md"
    fi
    echo "    (global mode: CLAUDE.md not touched)"
  fi
  echo "Uninstall done."
  exit 0
}

# --- main ---
[ "$UNINSTALL" -eq 1 ] && do_uninstall

if [ -z "$PROJECT" ]; then
  # auto-adapt: only IDEs whose config dir already exists (or were forced on)
  if [ "$WITH_CLAUDE" -eq 0 ] && [ -d "$HOME/.claude" ]; then
    echo "--- auto-detected Claude Code config: $HOME/.claude"
    WITH_CLAUDE=1
  fi
  if [ "$WITH_QODER" -eq 0 ] && [ -d "$HOME/.qoder" ]; then
    echo "--- auto-detected Qoder config: $HOME/.qoder"
    WITH_QODER=1
  fi
  if [ "$WITH_TRAE" -eq 0 ] && { [ -d "$HOME/.trae-cn" ] || [ -d "$HOME/.trae" ]; }; then
    echo "--- auto-detected Trae config: $HOME/.trae-cn / .trae"
    WITH_TRAE=1
  fi
  if [ "$WITH_CLAUDE" -eq 0 ] && [ "$WITH_QODER" -eq 0 ] && [ "$WITH_TRAE" -eq 0 ]; then
    echo ""
    echo "No IDE config dir found under your home (.claude / .qoder / .trae-cn / .trae)."
    echo "Run Claude Code / Qoder / Trae once to create its config dir, then re-run;"
    echo "or force an install with: --with-claude  --with-qoder  --with-trae  --with-all"
    echo ""
    exit 1
  fi
  [ "$WITH_CLAUDE" -eq 1 ] && install_claude "$HOME/.claude"
  [ "$WITH_QODER" -eq 1 ] && install_qoder "$HOME" global
  [ "$WITH_TRAE" -eq 1 ] && install_trae "$HOME" global
else
  install_claude "$PROJECT/.claude"
  [ "$WITH_QODER" -eq 1 ] && install_qoder "$PROJECT" project
  [ "$WITH_TRAE" -eq 1 ] && install_trae "$PROJECT" project
fi

echo
echo "Done.$( [ "$DRY_RUN" -eq 1 ] && echo ' (dry-run, nothing written)' )"
echo "Next: in Claude Code type /superpowers (or in Qoder / Trae say 'enable superpowers'); all following tasks then follow the methodology."
