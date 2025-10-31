# Cap Development Environment PATH Fix Script
# This script permanently adds all required tools to the system PATH

Write-Host "=== Cap Development Environment PATH Fix ===" -ForegroundColor Cyan

# Paths to add
$pathsToAdd = @(
    "C:\Users\Administrator\.cargo\bin",
    "C:\Program Files\LLVM\bin",
    "C:\Program Files\CMake\bin"
)

# Check if tools exist
Write-Host "`nChecking tool installations:" -ForegroundColor Yellow
$allExist = $true
foreach ($path in $pathsToAdd) {
    $exists = Test-Path $path
    $tool = Split-Path $path -Parent | Split-Path -Leaf
    if ($exists) {
        Write-Host "  OK: $tool - $path" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: $tool - $path (not found)" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    Write-Host "`nError: Some tools are not installed." -ForegroundColor Red
    exit 1
}

# Get current user PATH
$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathList = $currentUserPath -split ';' | Where-Object { $_ -ne '' }

# Add missing paths
Write-Host "`nUpdating user PATH:" -ForegroundColor Yellow
$modified = $false
foreach ($newPath in $pathsToAdd) {
    if ($pathList -notcontains $newPath) {
        Write-Host "  Adding: $newPath" -ForegroundColor Cyan
        $pathList = @($newPath) + $pathList
        $modified = $true
    } else {
        Write-Host "  Already exists: $newPath" -ForegroundColor Gray
    }
}

if ($modified) {
    $newUserPath = ($pathList | Where-Object { $_ -ne '' }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
    Write-Host "`nUser PATH permanently updated!" -ForegroundColor Green
} else {
    Write-Host "`nAll paths already in PATH." -ForegroundColor Green
}

# Set additional environment variables
Write-Host "`nConfiguring additional environment variables:" -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("LIBCLANG_PATH", "C:\Program Files\LLVM\bin", "User")
Write-Host "  Set: LIBCLANG_PATH = C:\Program Files\LLVM\bin" -ForegroundColor Green

[Environment]::SetEnvironmentVariable("TAURI_CONFIG", $null, "User")
Write-Host "  Cleared: TAURI_CONFIG (was incorrectly set)" -ForegroundColor Green

Write-Host "`n=== Fix Complete! ===" -ForegroundColor Green
Write-Host "`nIMPORTANT:" -ForegroundColor Yellow
Write-Host "  1. Close ALL PowerShell/Terminal windows"
Write-Host "  2. Open a NEW terminal window"
Write-Host "  3. Verify with:" -ForegroundColor Cyan
Write-Host "     cargo --version"
Write-Host "     clang --version"
Write-Host "     cmake --version"
Write-Host "  4. Then run: pnpm dev:desktop"

