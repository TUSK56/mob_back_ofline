@echo off
REM Publish backend for MonsterASP.net using win-x64 by default.
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0publish.ps1" -Runtime win-x64 -SelfContained true -Output "publish_output" %*
if %ERRORLEVEL% neq 0 pause
