@echo off
REM One-shot runner for Windows (batch).
REM Usage:
REM   From repository root (double-click or run in cmd/powershell):
REM     scripts\run_all.bat
REM   To skip build:
REM     scripts\run_all.bat -SkipBuild

setlocal enabledelayedexpansion

REM Resolve repository root (script located at scripts\)
set SCRIPT_DIR=%~dp0
pushd "%SCRIPT_DIR%..\"
set REPO=%CD%
echo Repository: %REPO%

set SKIPBUILD=0
if "%1"=="-SkipBuild" set SKIPBUILD=1

if %SKIPBUILD%==0 (
  if not exist "%REPO%\build" mkdir "%REPO%\build"
  echo Configuring project (cmake -S . -B build)...
  cmake -S "%REPO%" -B "%REPO%\build"
  echo Building (Release)...
  cmake --build "%REPO%\build" --config Release
)

set EXE=%REPO%\build\Release\EgoPlanCore.exe
if not exist "%EXE%" set EXE=%REPO%\build\EgoPlanCore.exe

if exist "%EXE%" (
  echo Running executable: %EXE%
  "%EXE%"
) else (
  echo WARNING: Executable not found, skipping run.
)

REM Create venv if missing
if not exist "%REPO%\.venv" (
  echo Creating virtual environment (.venv)...
  py -3 -m venv "%REPO%\.venv"
)

set PY=%REPO%\.venv\Scripts\python.exe
if not exist "%PY%" (
  echo venv python not found at %PY%, falling back to python in PATH
  set PY=python
)

echo Ensuring pip and installing plotting dependencies...
%PY% -m pip install -U pip

if exist "%REPO%\scripts\requirements.txt" (
  echo Installing from requirements.txt
  %PY% -m pip install -r "%REPO%\scripts\requirements.txt"
) else (
  %PY% -m pip install matplotlib
)

echo Running plotting script...
%PY% "%REPO%\scripts\plot_trajectory.py"

echo Verification:
if exist "%REPO%\build\trajectory.csv" (
  echo  - build\trajectory.csv : OK
) else (
  echo  - build\trajectory.csv : MISSING
)
if exist "%REPO%\build\trajectory.png" (
  echo  - build\trajectory.png : OK
) else (
  echo  - build\trajectory.png : MISSING
)

popd
endlocal
echo Done.
