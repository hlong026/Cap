# Cap Desktop Development Environment Launcher
# Run this script to start the desktop app development server

Write-Host "Starting Cap Desktop Development..." -ForegroundColor Green

# Reload environment variables from registry (for current session)
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
$env:LIBCLANG_PATH = [System.Environment]::GetEnvironmentVariable("LIBCLANG_PATH", "User")

# Verify tools
Write-Host "`nVerifying tools:" -ForegroundColor Cyan
$allGood = $true

$cargoVersion = & cargo --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Cargo: $cargoVersion" -ForegroundColor Green
} else {
    Write-Host "  Cargo: NOT FOUND" -ForegroundColor Red
    $allGood = $false
}

$clangPath = "C:\Program Files\LLVM\bin\libclang.dll"
if (Test-Path $clangPath) {
    Write-Host "  Clang: Found at $clangPath" -ForegroundColor Green
} else {
    Write-Host "  Clang: NOT FOUND" -ForegroundColor Red
    $allGood = $false
}

$cmakeVersion = & cmake --version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  CMake: $cmakeVersion" -ForegroundColor Green
} else {
    Write-Host "  CMake: NOT FOUND" -ForegroundColor Red
    $allGood = $false
}

if (-not $allGood) {
    Write-Host "`nError: Some tools are missing. Please run fix-path-simple.ps1 first." -ForegroundColor Red
    Write-Host "Then RESTART your terminal and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nAll tools verified! Starting development server..." -ForegroundColor Green
Write-Host "----------------------------------------`n" -ForegroundColor DarkGray

pnpm dev:desktop
