@echo off
setlocal enableextensions

rem ===========================================================================
rem  superpowers skill set - one-click deploy to Claude Code / Qoder / Trae (pure cmd)
rem
rem  This file is deliberately ASCII-only: cmd.exe reads a .bat via the OEM
rem  codepage (GBK/936 on a Chinese Windows), so any non-ASCII byte here would
rem  become mojibake. Chinese only lives inside the data files we copy, never in
rem  this script body.
rem
rem  Usage:
rem    install.bat                                        global Claude Code: %USERPROFILE%\.claude\
rem    install.bat --project D:\code\myproj               project: .claude\skills\ + CLAUDE.md bootstrap
rem    install.bat --with-claude                          force Claude Code (global ~/.claude or project .claude)
rem    install.bat --with-qoder                           also Qoder (global ~/.qoder or project .qoder)
rem    install.bat --with-trae                            also Trae  (global ~/.trae-cn / ~/.trae or project .trae)
rem    install.bat --with-all                             Claude Code + Qoder + Trae together
rem    install.bat --dry-run ...                          print actions only, write nothing
rem    install.bat --uninstall [--project X] [--with-claude] [--with-qoder] [--with-trae]   remove skills + command
rem    install.bat -h | --help                            show this help
rem
rem  Double-click (run with no args), global mode: AUTO-ADAPTS every IDE config
rem  dir that already exists (~/.claude, ~/.qoder, ~/.trae-cn, ~/.trae) -- skills
rem  are copied into each. Dirs for IDEs you do NOT have are never created. If none
rem  exist, the run aborts with a hint (run an IDE once, or pass --with-* / --with-all).
rem  In project mode, .claude is always installed; Qoder/Trae need a --with-* flag.
rem  Re-running is always safe.
rem
rem  Legacy cleanup: this project used to be named "superpower" (singular). The
rem  old build left behind skills\superpower\, commands\superpower.md and the
rem  qoder rule superpower-sinosafe.md. Before each install the destination is
rem  scanned for these leftovers. A folder/file is removed ONLY after a content
rem  fingerprint check confirms it is ours, so a third-party item that merely
rem  happens to be called "superpower" is left untouched. The old multi-line
rem  CLAUDE.md sentinel block (superpower-sinosafe:begin..end) is detected and
rem  reported, but NOT auto-stripped by cmd (use install.ps1 --uninstall, or
rem  delete the begin/end lines by hand).
rem
rem  Review the staging repo first; use --dry-run to preview.
rem ===========================================================================

set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%.."
set "SRC_SKILLS=%REPO_ROOT%\skills"
set "SRC_COMMANDS=%REPO_ROOT%\commands"
set "SNIPPET=%REPO_ROOT%\bootstrap\CLAUDE.md.snippet"
set "QODER_RULE=%REPO_ROOT%\bootstrap\qoder-rule.md"

set "SKILLS=superpowers brainstorming writing-plans test-driven-development systematic-debugging verification-before-completion"
set "BEGIN=superpowers-sinosafe:begin"

rem --- legacy (old single-name "superpower") markers we clean up ---
set "LEGACY_DIR=superpower"
set "LEGACY_CMD=superpower.md"
set "LEGACY_QODER_RULE=superpower-sinosafe.md"
set "LEGACY_BEGIN=superpower-sinosafe:begin"
rem ASCII-only fingerprint words (work under GBK codepage; no Chinese here)
set "FP_TITLE=Superpowers Methodology"
set "FP_SKILL1=brainstorming"
set "FP_SKILL2=writing-plans"

set "PROJECT="
set "CLAUDE="
set "QODER="
set "TRAE="
set "DRY="
set "UNINSTALL="
set "INTERACTIVE=1"

rem ----------------------------- argument parsing ---------------------------
:parse
if "%~1"=="" goto parsed
set "INTERACTIVE="
set "ARG=%~1"
if /i "%ARG%"=="--project"    ( set "PROJECT=%~2" & shift & shift & goto parse )
if /i "%ARG%"=="--with-claude" ( set "CLAUDE=1"  & shift & goto parse )
if /i "%ARG%"=="--with-qoder" ( set "QODER=1"   & shift & goto parse )
if /i "%ARG%"=="--with-trae"  ( set "TRAE=1"    & shift & goto parse )
if /i "%ARG%"=="--with-all"   ( set "CLAUDE=1"  & set "QODER=1" & set "TRAE=1" & shift & goto parse )
if /i "%ARG%"=="--dry-run"    ( set "DRY=1"      & shift & goto parse )
if /i "%ARG%"=="--uninstall"  ( set "UNINSTALL=1"& shift & goto parse )
if /i "%ARG%"=="-h"           goto help
if /i "%ARG%"=="--help"       goto help
echo ERROR: unknown argument "%ARG%" 1>&2
exit /b 2
:parsed

if defined UNINSTALL goto uninstall

rem Double-click (no args), global: adapt ONLY IDEs whose config dir already exists
rem (or were forced on). Nothing is created for IDEs you do not have installed.
if not defined PROJECT (
  call :auto_claude_global
  call :auto_qoder_global
  call :auto_trae_global
  if not defined CLAUDE if not defined QODER if not defined TRAE goto no_ide
  if defined CLAUDE ( call :detect "%USERPROFILE%\.claude" global ) else ( echo === INSTALLING superpowers [global] )
  if defined CLAUDE call :install_claude "%USERPROFILE%\.claude"
  if defined QODER call :install_qoder "%USERPROFILE%" global
  if defined TRAE  call :install_trae "%USERPROFILE%" global
) else (
  call :detect "%PROJECT%\.claude" project
  call :install_claude "%PROJECT%\.claude"
  if defined QODER call :install_qoder "%PROJECT%" project
  if defined TRAE  call :install_trae "%PROJECT%" project
)

echo.
if defined DRY ( echo Done. [dry-run, nothing written] ) else if defined EXISTING ( echo Updated. ) else ( echo Installed. )
echo Next: in Claude Code type /superpowers; in Qoder / Trae say "enable superpowers".
if defined INTERACTIVE pause
endlocal
exit /b 0

rem ===========================================================================
rem  :detect  %1 = dest root (.claude dir), %2 = scope label (global|project)
rem           Sets EXISTING=1 + MODE=UPDATING if the master-switch skill is
rem           already installed there, else MODE=INSTALLING. Prints the banner.
rem           (Banner lives here so %MODE% expands after the set, not at the
rem           caller's block-parse time -- avoids cmd's delayed-expansion trap.)
rem ===========================================================================
:no_ide
echo.
echo No IDE config dir found under your home (.claude / .qoder / .trae-cn / .trae).
echo Run Claude Code / Qoder / Trae once to create its config dir, then re-run;
echo or force an install with: --with-claude  --with-qoder  --with-trae  --with-all
echo.
if defined INTERACTIVE pause
endlocal
exit /b 1

:detect
set "EXISTING="
set "MODE=INSTALLING"
if exist "%~1\skills\superpowers\SKILL.md" ( set "EXISTING=1" & set "MODE=UPDATING" )
echo === %MODE% superpowers [%~2]
goto :eof

rem ===========================================================================
rem  :install_claude  %1 = dest root  -  %USERPROFILE%\.claude  or  <proj>\.claude
rem ===========================================================================
:install_claude
echo ===^> Claude Code: %~1
call :cleanup_legacy_claude "%~1"
set "SD=%~1\skills"
if not defined DRY mkdir "%SD%" 2>nul
call :copy_skills_to "%SD%"
set "CD=%~1\commands"
if not defined DRY mkdir "%CD%" 2>nul
call :copy_file "%SRC_COMMANDS%\superpowers.md" "%CD%\superpowers.md"
if defined PROJECT ( call :inject_block "%PROJECT%\CLAUDE.md" ) else ( echo     [global mode] CLAUDE.md not touched. For bootstrap, append bootstrap\CLAUDE.md.snippet to a project CLAUDE.md. )
goto :eof

rem ===========================================================================
rem  :install_qoder  %1 = parent dir (user home for global, project root for project)
rem                  %2 = scope label (global|project)  ->  <parent>\.qoder
rem ===========================================================================
:install_qoder
set "QROOT=%~1\.qoder"
echo ===^> Qoder [%~2]: %QROOT%
call :cleanup_legacy_qoder "%QROOT%"
set "SD=%QROOT%\skills"
set "RD=%QROOT%\rules"
if not defined DRY ( mkdir "%SD%" 2>nul & mkdir "%RD%" 2>nul )
call :copy_skills_to "%SD%"
call :copy_file "%QODER_RULE%" "%RD%\superpowers-sinosafe.md"
goto :eof

rem ===========================================================================
rem  :install_trae  %1 = parent dir, %2 = scope (global|project)
rem    global -> ~/.trae-cn (CN build); falls back to ~/.trae if only that exists
rem    project -> <proj>\.trae
rem  (Resolved with goto, not an if-block, so %TROOT% is live when used.)
rem ===========================================================================
:install_trae
set "TROOT=%~1\.trae"
if /i not "%~2"=="global" goto trae_resolved
set "TROOT=%~1\.trae-cn"
if exist "%~1\.trae-cn" goto trae_resolved
if exist "%~1\.trae" set "TROOT=%~1\.trae"
:trae_resolved
echo ===^> Trae [%~2]: %TROOT%
call :cleanup_legacy_trae "%TROOT%"
set "SD=%TROOT%\skills"
set "RD=%TROOT%\rules"
if not defined DRY ( mkdir "%SD%" 2>nul & mkdir "%RD%" 2>nul )
call :copy_skills_to "%SD%"
call :copy_file "%QODER_RULE%" "%RD%\superpowers-sinosafe.md"
goto :eof

rem ===========================================================================
rem  :inject_block  %1 = target CLAUDE.md  -  safe idempotent binary append
rem  (cmd cannot safely remove a multi-line block, so this only ever appends;
rem   re-runs are skipped when the begin sentinel is already present. The OLD
rem   singular sentinel superpower-sinosafe:begin is reported if found.)
rem ===========================================================================
:inject_block
if not exist "%~1" (
  echo + create "%~1"
  call :copy_file "%SNIPPET%" "%~1"
  goto :eof
)
findstr /C:"%LEGACY_BEGIN%" "%~1" >nul 2>&1
if not errorlevel 1 echo     [note] old "%LEGACY_BEGIN%" block found in "%~1" - cmd will not auto-strip it; run install.ps1 --uninstall or delete the superpower-sinosafe begin/end lines by hand.
findstr /C:"%BEGIN%" "%~1" >nul 2>&1
if not errorlevel 1 (
  echo     [skip] CLAUDE.md already has the superpowers block
  goto :eof
)
echo + append superpowers block to "%~1"
if defined DRY goto :eof
copy /b "%~1"+"%SNIPPET%" "%~1.superpowers.tmp" >nul
if errorlevel 1 ( echo ERROR: failed to update "%~1" 1>&2 & goto :eof )
move /Y "%~1.superpowers.tmp" "%~1" >nul
goto :eof

rem ===========================================================================
rem  auto-detect helpers (global double-click mode only)
rem    Turn QODER / TRAE on if the corresponding config dir already exists,
rem    so a double-click covers every IDE the user actually has installed.
rem    (Uses "if defined" at the caller -- runtime check, no delayed expansion.)
rem ===========================================================================
:auto_claude_global
if defined CLAUDE goto :eof
if exist "%USERPROFILE%\.claude" (
  echo --- auto-detected Claude Code config: %USERPROFILE%\.claude
  set "CLAUDE=1"
)
goto :eof

:auto_qoder_global
if defined QODER goto :eof
if exist "%USERPROFILE%\.qoder" (
  echo --- auto-detected Qoder config: %USERPROFILE%\.qoder
  set "QODER=1"
)
goto :eof

:auto_trae_global
if defined TRAE goto :eof
if exist "%USERPROFILE%\.trae-cn" set "TRAE=1"
if exist "%USERPROFILE%\.trae" set "TRAE=1"
if defined TRAE echo --- auto-detected Trae config: %USERPROFILE%\.trae-cn or .trae
goto :eof

rem ===========================================================================
rem  legacy cleanup dispatchers - one per IDE; called at the top of each install
rem ===========================================================================
:cleanup_legacy_claude
rem %1 = .claude root
call :cleanup_legacy_skills_dir "%~1\skills"
if exist "%~1\commands\%LEGACY_CMD%" call :rm_legacy_cmd "%~1\commands\%LEGACY_CMD%"
goto :eof

:cleanup_legacy_qoder
rem %1 = .qoder root
call :cleanup_legacy_skills_dir "%~1\skills"
if exist "%~1\rules\%LEGACY_QODER_RULE%" call :rm_legacy_qoder_rule "%~1\rules\%LEGACY_QODER_RULE%"
goto :eof

:cleanup_legacy_trae
rem %1 = trae root (.trae-cn / .trae). Old builds never wrote Trae, but scan anyway.
call :cleanup_legacy_skills_dir "%~1\skills"
if exist "%~1\rules\%LEGACY_QODER_RULE%" call :rm_legacy_qoder_rule "%~1\rules\%LEGACY_QODER_RULE%"
goto :eof

rem ===========================================================================
rem  :cleanup_legacy_skills_dir  %1 = skills dir
rem    Removes <skills>\superpower\ only if :is_our_legacy_dir confirms it is ours.
rem ===========================================================================
:cleanup_legacy_skills_dir
set "LD=%~1\%LEGACY_DIR%"
if not exist "%LD%\SKILL.md" goto :eof
call :is_our_legacy_dir "%LD%"
if errorlevel 1 (
  echo     [skip] "%LD%" - fingerprint mismatch, not our legacy, left untouched.
  goto :eof
)
call :rm_dir "%LD%"
goto :eof

rem ===========================================================================
rem  :is_our_legacy_dir  %1 = dir   ->  exit /b 0 = ours,  exit /b 1 = not ours
rem    ours if SKILL.md contains the methodology title, OR both core skill names.
rem ===========================================================================
:is_our_legacy_dir
if not exist "%~1\SKILL.md" exit /b 1
findstr /I /C:"%FP_TITLE%" "%~1\SKILL.md" >nul 2>&1
if not errorlevel 1 exit /b 0
findstr /I /C:"%FP_SKILL1%" "%~1\SKILL.md" >nul 2>&1
if errorlevel 1 exit /b 1
findstr /I /C:"%FP_SKILL2%" "%~1\SKILL.md" >nul 2>&1
if errorlevel 1 exit /b 1
exit /b 0

rem ===========================================================================
rem  :rm_legacy_cmd  %1 = commands\superpower.md  -  verify, then remove
rem ===========================================================================
:rm_legacy_cmd
findstr /I /C:"%FP_SKILL1%" "%~1" >nul 2>&1
if errorlevel 1 (
  echo     [skip] "%~1" - content does not look like our legacy command, left untouched.
  goto :eof
)
call :rm_file "%~1"
goto :eof

rem ===========================================================================
rem  :rm_legacy_qoder_rule  %1 = rules\superpower-sinosafe.md  -  verify, remove
rem ===========================================================================
:rm_legacy_qoder_rule
findstr /I /C:"%FP_SKILL1%" "%~1" >nul 2>&1
if errorlevel 1 (
  echo     [skip] "%~1" - content does not look like our legacy rule, left untouched.
  goto :eof
)
call :rm_file "%~1"
goto :eof

rem ===========================================================================
rem  :copy_skills_to  %1 = dest skills dir   /   :rm_skills_from  %1 = skills dir
rem ===========================================================================
:copy_skills_to
for %%s in (%SKILLS%) do call :recopy_dir "%SRC_SKILLS%\%%s" "%~1\%%s"
goto :eof

:rm_skills_from
for %%s in (%SKILLS%) do call :rm_dir "%~1\%%s"
goto :eof

rem ===========================================================================
rem  :uninstall  -  removes skills + command (+ qoder/trae if asked).
rem  NOTE: does NOT edit CLAUDE.md (cmd cannot safely strip the multi-line block;
rem   use install.ps1 --uninstall, or delete the superpowers-sinosafe begin/end
rem   lines by hand).
rem ===========================================================================
:uninstall
if defined PROJECT (
  echo ===^> Uninstall Claude Code [project]: %PROJECT%\.claude\skills
  call :rm_skills_from "%PROJECT%\.claude\skills"
  call :rm_file "%PROJECT%\.claude\commands\superpowers.md"
  if exist "%PROJECT%\CLAUDE.md" echo     [note] CLAUDE.md bootstrap block left in place - remove with install.ps1 --uninstall or delete the superpowers-sinosafe begin/end lines.
  if defined QODER (
    echo ===^> Uninstall Qoder [project]: %PROJECT%\.qoder
    call :rm_skills_from "%PROJECT%\.qoder\skills"
    call :rm_file "%PROJECT%\.qoder\rules\superpowers-sinosafe.md"
  )
  if defined TRAE (
    echo ===^> Uninstall Trae [project]: %PROJECT%\.trae
    call :rm_skills_from "%PROJECT%\.trae\skills"
    call :rm_file "%PROJECT%\.trae\rules\superpowers-sinosafe.md"
  )
) else (
  echo ===^> Uninstall Claude Code [global]: %USERPROFILE%\.claude\skills
  call :rm_skills_from "%USERPROFILE%\.claude\skills"
  call :rm_file "%USERPROFILE%\.claude\commands\superpowers.md"
  if defined QODER (
    echo ===^> Uninstall Qoder [global]: %USERPROFILE%\.qoder
    call :rm_skills_from "%USERPROFILE%\.qoder\skills"
    call :rm_file "%USERPROFILE%\.qoder\rules\superpowers-sinosafe.md"
  )
  if defined TRAE call :uninstall_trae_global
  echo     [global mode] CLAUDE.md not touched
)
echo Uninstall done.
endlocal
exit /b 0

rem  Trae global uninstall: prefer ~/.trae-cn, fall back to ~/.trae.
rem  (Separate label, sequential statements - no delayed-expansion hazard.)
:uninstall_trae_global
set "TROOT=%USERPROFILE%\.trae-cn"
if exist "%USERPROFILE%\.trae-cn" goto utg_done
if exist "%USERPROFILE%\.trae" set "TROOT=%USERPROFILE%\.trae"
:utg_done
echo ===^> Uninstall Trae [global]: %TROOT%
call :rm_skills_from "%TROOT%\skills"
call :rm_file "%TROOT%\rules\superpowers-sinosafe.md"
goto :eof

rem ===========================================================================
rem  primitive helpers
rem ===========================================================================
:recopy_dir
echo + copy "%~1" -^> "%~2"
if defined DRY goto :eof
rmdir /S /Q "%~2" 2>nul
robocopy "%~1" "%~2" /E /NFL /NDL /NJH /NJS /NP >nul 2>&1
if errorlevel 8 echo   WARN: robocopy reported errors for "%~1"
goto :eof

:copy_file
echo + copy "%~1" -^> "%~2"
if defined DRY goto :eof
copy /Y "%~1" "%~2" >nul
goto :eof

:rm_dir
echo + rmdir "%~1"
if not defined DRY rmdir /S /Q "%~1" 2>nul
goto :eof

:rm_file
echo + del "%~1"
if not defined DRY del /F /Q "%~1" 2>nul
goto :eof

:help
echo superpowers skill set - pure-cmd installer (no PowerShell needed)
echo Deploys to Claude Code, Qoder, Trae - and cleans up the old "superpower" build.
echo.
echo Usage:
echo   install.bat                                        global: adapt every IDE already installed
echo   install.bat --with-claude                          force Claude Code (global ~/.claude ^| project .claude)
echo   install.bat --with-qoder                           also Qoder (global ~/.qoder ^| project .qoder)
echo   install.bat --with-trae                            also Trae  (global ~/.trae-cn / ~/.trae ^| project .trae)
echo   install.bat --with-all                             Claude Code + Qoder + Trae together
echo   install.bat --project D:\code\myproj               project: .claude\skills\ + CLAUDE.md bootstrap
echo   install.bat --dry-run ...                          print actions only, write nothing
echo   install.bat --uninstall [--project X] [--with-claude] [--with-qoder] [--with-trae]
echo   install.bat -h ^| --help                           show this help
echo.
echo Double-click (no args), global: auto-adapts every IDE config dir that already
echo exists (~/.claude, ~/.qoder, ~/.trae-cn, ~/.trae). Dirs for IDEs you don't have
echo are never created. If none exist, it aborts with a hint - run an IDE once, or
echo pass --with-claude / --with-qoder / --with-trae / --with-all. Re-running is safe.
echo In project mode .claude is always installed; Qoder/Trae need a --with-* flag.
echo.
echo Legacy cleanup: leftovers of the old "superpower" (singular) build are removed
echo from each dest BEFORE install, but only after a fingerprint check confirms they
echo are ours - a third-party folder named superpower is left untouched.
echo.
echo Note: on uninstall this .bat removes skills + command only. It does NOT
echo edit CLAUDE.md, because cmd cannot safely strip a multi-line block. For a
echo clean CLAUDE.md cleanup run  install.ps1 --uninstall  instead, or delete
echo the lines between the superpowers-sinosafe begin/end markers by hand.
endlocal
exit /b 0
