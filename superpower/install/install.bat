@echo off
setlocal enableextensions

rem ===========================================================================
rem  superpowers skill set - one-click deploy to Claude Code / Qoder (pure cmd)
rem
rem  This file is deliberately ASCII-only: cmd.exe reads a .bat via the OEM
rem  codepage (GBK/936 on a Chinese Windows), so any non-ASCII byte here would
rem  become mojibake. Chinese only lives inside the data files we copy, never in
rem  this script body.
rem
rem  Usage:
rem    install.bat                                        global Claude Code: %USERPROFILE%\.claude\
rem    install.bat --project D:\code\myproj               project: .claude\skills\ + CLAUDE.md bootstrap
rem    install.bat --project D:\code\myproj --with-qoder  also Qoder: .qoder\skills\ + .qoder\rules\
rem    install.bat --dry-run ...                          print actions only, write nothing
rem    install.bat --uninstall [--project X] [--with-qoder]   remove skills + command
rem    install.bat -h | --help                            show this help
rem
rem  Review the staging repo first; use --dry-run to preview.
rem ===========================================================================

set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%.."
set "SRC_SKILLS=%REPO_ROOT%\skills"
set "SRC_COMMANDS=%REPO_ROOT%\commands"
set "SNIPPET=%REPO_ROOT%\bootstrap\CLAUDE.md.snippet"
set "QODER_RULE=%REPO_ROOT%\bootstrap\qoder-rule.md"

set "SKILLS=superpower brainstorming writing-plans test-driven-development systematic-debugging verification-before-completion"
set "BEGIN=superpower-sinosafe:begin"

set "PROJECT="
set "QODER="
set "DRY="
set "UNINSTALL="

rem ----------------------------- argument parsing ---------------------------
:parse
if "%~1"=="" goto parsed
set "ARG=%~1"
if /i "%ARG%"=="--project"    ( set "PROJECT=%~2" & shift & shift & goto parse )
if /i "%ARG%"=="--with-qoder" ( set "QODER=1"    & shift & goto parse )
if /i "%ARG%"=="--dry-run"    ( set "DRY=1"      & shift & goto parse )
if /i "%ARG%"=="--uninstall"  ( set "UNINSTALL=1"& shift & goto parse )
if /i "%ARG%"=="-h"           goto help
if /i "%ARG%"=="--help"       goto help
echo ERROR: unknown argument "%ARG%" 1>&2
exit /b 2
:parsed

if defined UNINSTALL goto uninstall

if not defined PROJECT (
  call :install_claude "%USERPROFILE%\.claude"
  if defined QODER (
    echo ERROR: --with-qoder requires --project. Qoder is project-scoped. 1>&2
    exit /b 2
  )
) else (
  call :install_claude "%PROJECT%\.claude"
  if defined QODER call :install_qoder "%PROJECT%"
)

echo.
if defined DRY ( echo Done. [dry-run, nothing written] ) else ( echo Done. )
echo Next: in Claude Code type /superpower, or in Qoder say "enable superpowers".
endlocal
exit /b 0

rem ===========================================================================
rem  :install_claude  %1 = dest root  -  %USERPROFILE%\.claude  or  <proj>\.claude
rem ===========================================================================
:install_claude
echo ===^> Claude Code: %~1
set "SD=%~1\skills"
if not defined DRY mkdir "%SD%" 2>nul
for %%s in (%SKILLS%) do call :recopy_dir "%SRC_SKILLS%\%%s" "%SD%\%%s"
set "CD=%~1\commands"
if not defined DRY mkdir "%CD%" 2>nul
call :copy_file "%SRC_COMMANDS%\superpower.md" "%CD%\superpower.md"
if defined PROJECT ( call :inject_block "%PROJECT%\CLAUDE.md" ) else ( echo     [global mode] CLAUDE.md not touched. For bootstrap, append bootstrap\CLAUDE.md.snippet to a project CLAUDE.md. )
goto :eof

rem ===========================================================================
rem  :install_qoder  %1 = project dir
rem ===========================================================================
:install_qoder
echo ===^> Qoder: %~1\.qoder
set "SD=%~1\.qoder\skills"
set "RD=%~1\.qoder\rules"
if not defined DRY ( mkdir "%SD%" 2>nul & mkdir "%RD%" 2>nul )
for %%s in (%SKILLS%) do call :recopy_dir "%SRC_SKILLS%\%%s" "%SD%\%%s"
call :copy_file "%QODER_RULE%" "%RD%\superpower-sinosafe.md"
goto :eof

rem ===========================================================================
rem  :inject_block  %1 = target CLAUDE.md  -  safe idempotent binary append
rem  (cmd cannot safely remove a multi-line block, so this only ever appends;
rem   re-runs are skipped when the begin sentinel is already present)
rem ===========================================================================
:inject_block
if not exist "%~1" (
  echo + create "%~1"
  call :copy_file "%SNIPPET%" "%~1"
  goto :eof
)
findstr /C:"%BEGIN%" "%~1" >nul 2>&1
if not errorlevel 1 (
  echo     [skip] CLAUDE.md already has the superpowers block
  goto :eof
)
echo + append superpowers block to "%~1"
if defined DRY goto :eof
copy /b "%~1"+"%SNIPPET%" "%~1.superpower.tmp" >nul
if errorlevel 1 ( echo ERROR: failed to update "%~1" 1>&2 & goto :eof )
move /Y "%~1.superpower.tmp" "%~1" >nul
goto :eof

rem ===========================================================================
rem  :uninstall  -  removes skills + command. NOTE: does NOT edit CLAUDE.md
rem  (cmd cannot safely strip the multi-line bootstrap block; use install.ps1
rem   --uninstall for that, or delete the begin/end sentinel lines by hand).
rem ===========================================================================
:uninstall
if defined PROJECT (
  echo ===^> Uninstall Claude Code [project]: %PROJECT%\.claude\skills
  for %%s in (%SKILLS%) do call :rm_dir "%PROJECT%\.claude\skills\%%s"
  call :rm_file "%PROJECT%\.claude\commands\superpower.md"
  if exist "%PROJECT%\CLAUDE.md" echo     [note] CLAUDE.md bootstrap block left in place - remove with install.ps1 --uninstall or delete the superpower-sinosafe begin/end lines.
  if defined QODER (
    echo ===^> Uninstall Qoder [project]: %PROJECT%\.qoder
    for %%s in (%SKILLS%) do call :rm_dir "%PROJECT%\.qoder\skills\%%s"
    call :rm_file "%PROJECT%\.qoder\rules\superpower-sinosafe.md"
  )
) else (
  echo ===^> Uninstall Claude Code [global]: %USERPROFILE%\.claude\skills
  for %%s in (%SKILLS%) do call :rm_dir "%USERPROFILE%\.claude\skills\%%s"
  call :rm_file "%USERPROFILE%\.claude\commands\superpower.md"
  echo     [global mode] CLAUDE.md not touched
)
echo Uninstall done.
endlocal
exit /b 0

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
echo.
echo Usage:
echo   install.bat                                        global Claude Code: %%USERPROFILE%%\.claude\
echo   install.bat --project D:\code\myproj               project: .claude\skills\ + CLAUDE.md bootstrap
echo   install.bat --project D:\code\myproj --with-qoder  also Qoder: .qoder\skills\ + .qoder\rules\
echo   install.bat --dry-run ...                          print actions only, write nothing
echo   install.bat --uninstall [--project X] [--with-qoder]   remove skills + command
echo   install.bat -h ^| --help                           show this help
echo.
echo Note: on uninstall this .bat removes skills + command only. It does NOT
echo edit CLAUDE.md, because cmd cannot safely strip a multi-line block. For a
echo clean CLAUDE.md cleanup run  install.ps1 --uninstall  instead, or delete
echo the lines between the superpower-sinosafe begin/end markers by hand.
endlocal
exit /b 0
