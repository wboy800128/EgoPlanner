<#
One-shot runner for Windows (PowerShell).
Usage:
  - From repository root in PowerShell:
      .\scripts\run_all.ps1
  - To skip build (use existing build artifacts):
      .\scripts\run_all.ps1 -SkipBuild

What it does:
  1. Configure & build with CMake (Release)
  2. Run the produced executable to write build/trajectory.csv
  3. Create a virtualenv `.venv` (if missing)
  4. Install `matplotlib` into the venv (or requirements.txt if present)
  5. Run `scripts/plot_trajectory.py` using the venv python
  6. Print verification of `build/trajectory.csv` and `build/trajectory.png`
#>

Param(
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $repo

Write-Host "Repository: $repo"

if (-not $SkipBuild) {
    if (-not (Test-Path (Join-Path $repo 'build'))) {
        New-Item -ItemType Directory -Path (Join-Path $repo 'build') | Out-Null
    }
    Write-Host "Configuring project (cmake -S . -B build) ..."
    cmake -S $repo -B (Join-Path $repo 'build')
    Write-Host "Building (Release) ..."
    cmake --build (Join-Path $repo 'build') --config Release
}

$exe = Join-Path $repo 'build\Release\EgoPlanCore.exe'
if (-not (Test-Path $exe)) {
    $exe = Join-Path $repo 'build\EgoPlanCore.exe'
}

if (Test-Path $exe) {
    Write-Host "Running executable: $exe"
    & $exe
} else {
    Write-Warning "Executable not found at expected locations. Skipping run."
}

# Virtual environment setup
$venv = Join-Path $repo '.venv'
if (-not (Test-Path $venv)) {
    Write-Host "Creating virtual environment (.venv) ..."
    py -3 -m venv $venv
}

$py = Join-Path $venv 'Scripts\python.exe'
if (-not (Test-Path $py)) {
    Write-Warning "venv python not found at $py. Falling back to 'python' in PATH."
    $py = 'python'
}

Write-Host "Ensuring pip and installing plotting dependencies..."
& $py -m pip install -U pip

$req = Join-Path $repo 'scripts\requirements.txt'
if (Test-Path $req) {
    Write-Host "Installing from requirements.txt"
    & $py -m pip install -r $req
} else {
    & $py -m pip install matplotlib
}

Write-Host "Running plotting script..."
& $py (Join-Path $repo 'scripts\plot_trajectory.py')

Write-Host "Verification:"
Write-Host " - build/trajectory.csv :" (Test-Path (Join-Path $repo 'build\trajectory.csv'))
Write-Host " - build/trajectory.png :" (Test-Path (Join-Path $repo 'build\trajectory.png'))

Write-Host "run_all.ps1 finished."
