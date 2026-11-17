@echo off
setlocal DisableDelayedExpansion
set "ERRORLEVEL="
set "SPIELRAUM_NODE="

rem Follow the host-runtime lookup used by OpenAI's Codex Security plugin.
if defined CODEX_MCP_NODE_PATH if exist "%CODEX_MCP_NODE_PATH%" (
  set "SPIELRAUM_NODE=%CODEX_MCP_NODE_PATH%"
  goto run
)
rem Prefer relocated runtimes: WindowsApps paths may exist but not be executable.
if defined LOCALAPPDATA for /d %%D in ("%LOCALAPPDATA%\OpenAI\Codex\runtimes\cua_node\*") do if exist "%%~fD\bin\node.exe" (
  set "SPIELRAUM_NODE=%%~fD\bin\node.exe"
  goto run
)
if defined XDG_CACHE_HOME if exist "%XDG_CACHE_HOME%\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe" (
  set "SPIELRAUM_NODE=%XDG_CACHE_HOME%\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
  goto run
)
if defined USERPROFILE if exist "%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe" (
  set "SPIELRAUM_NODE=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe"
  goto run
)
if defined CODEX_BROWSER_USE_NODE_PATH if exist "%CODEX_BROWSER_USE_NODE_PATH%" (
  set "SPIELRAUM_NODE=%CODEX_BROWSER_USE_NODE_PATH%"
  goto run
)
if defined CODEX_ELECTRON_RESOURCES_PATH if exist "%CODEX_ELECTRON_RESOURCES_PATH%\cua_node\bin\node.exe" (
  set "SPIELRAUM_NODE=%CODEX_ELECTRON_RESOURCES_PATH%\cua_node\bin\node.exe"
  goto run
)
if defined CODEX_CLI_PATH for %%I in ("%CODEX_CLI_PATH%") do if exist "%%~dpIcua_node\bin\node.exe" (
  set "SPIELRAUM_NODE=%%~dpIcua_node\bin\node.exe"
  goto run
)

rem Resolve PATH once and invoke that exact executable, without CALL reparsing.
set "SPIELRAUM_NODE_SEARCH_PATH=%PATH:"=%"
for %%I in (node.exe) do set "SPIELRAUM_NODE=%%~$SPIELRAUM_NODE_SEARCH_PATH:I"
if defined SPIELRAUM_NODE goto run

echo Spielraum could not find Node.js 24+. Update the desktop app or set CODEX_MCP_NODE_PATH to an executable Node runtime. 1>&2
exit /b 127

:run
"%SPIELRAUM_NODE%" "%~dp0..\dist\stdio.js" %*
exit /b %errorlevel%
