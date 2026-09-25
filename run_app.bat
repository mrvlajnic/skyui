@echo off
setlocal
pushd "%~dp0" || exit /b 1
python "%~dp0run_app.py"
set "exitCode=%errorlevel%"
popd
exit /b %exitCode%
