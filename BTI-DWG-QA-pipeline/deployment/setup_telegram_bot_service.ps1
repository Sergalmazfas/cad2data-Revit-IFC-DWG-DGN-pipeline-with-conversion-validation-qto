# =============================================================================
# BTI DWG QA Pipeline - Setup Telegram Bot as Windows Service
# =============================================================================
# Purpose: Install and configure Telegram bot server as Windows Service
# =============================================================================

param(
    [string]$BotScriptPath = "C:\bti\scripts\telegram_bot_server.py",
    [string]$ServiceName = "N8NdwgBot"
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Setup Telegram Bot as Windows Service" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$BTI_BASE = "C:\bti"
$SCRIPTS_PATH = "$BTI_BASE\scripts"
$REQUIREMENTS_FILE = "$BTI_BASE\..\requirements.txt"

# =============================================================================
# 1. Check Python Installation
# =============================================================================

Write-Host "[1/6] Checking Python installation..." -ForegroundColor Yellow

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Python 3.12..." -ForegroundColor Gray
    
    $pythonInstaller = "$BTI_BASE\temp\python-installer.exe"
    Invoke-WebRequest `
        -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe" `
        -OutFile $pythonInstaller `
        -UseBasicParsing
    
    Start-Process $pythonInstaller `
        -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" `
        -Wait -NoNewWindow
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-Host "  Python installed" -ForegroundColor Green
} else {
    $pythonVersion = python --version
    Write-Host "  Python already installed: $pythonVersion" -ForegroundColor Gray
}

# =============================================================================
# 2. Install Python Dependencies
# =============================================================================

Write-Host "[2/6] Installing Python dependencies..." -ForegroundColor Yellow

if (Test-Path $REQUIREMENTS_FILE) {
    Write-Host "  Installing from requirements.txt..." -ForegroundColor Gray
    python -m pip install --quiet --upgrade pip
    python -m pip install --quiet -r $REQUIREMENTS_FILE
    Write-Host "  Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "  Installing aiogram and requests..." -ForegroundColor Gray
    python -m pip install --quiet --upgrade pip
    python -m pip install --quiet aiogram requests aiohttp
    Write-Host "  Dependencies installed" -ForegroundColor Green
}

# Verify aiogram
try {
    python -c "import aiogram; print(f'aiogram version: {aiogram.__version__}')" 2>$null
    Write-Host "  ✓ aiogram: $(python -c 'import aiogram; print(aiogram.__version__)' 2>$null)" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ aiogram verification failed" -ForegroundColor Yellow
}

# =============================================================================
# 3. Verify Bot Script
# =============================================================================

Write-Host "[3/6] Verifying bot script..." -ForegroundColor Yellow

if (Test-Path $BotScriptPath) {
    Write-Host "  ✓ Bot script found: $BotScriptPath" -ForegroundColor Green
} else {
    Write-Host "  ✗ Bot script not found: $BotScriptPath" -ForegroundColor Red
    Write-Host "  Please ensure telegram_bot_server.py is in $SCRIPTS_PATH" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# 4. Check Environment Variables
# =============================================================================

Write-Host "[4/6] Checking environment variables..." -ForegroundColor Yellow

$token = [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
if ($token) {
    Write-Host "  ✓ TELEGRAM_BOT_TOKEN: configured" -ForegroundColor Green
} else {
    Write-Host "  ✗ TELEGRAM_BOT_TOKEN: not set" -ForegroundColor Red
    Write-Host "  Run setup_telegram.ps1 first to configure secrets" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# 5. Create Windows Service
# =============================================================================

Write-Host "[5/6] Creating Windows Service for Telegram bot..." -ForegroundColor Yellow

$nssmExe = "C:\nssm\nssm-2.24\win64\nssm.exe"

if (-not (Test-Path $nssmExe)) {
    Write-Host "  ✗ NSSM not found. Run deploy_bti_pipeline.ps1 first" -ForegroundColor Red
    exit 1
}

# Stop and remove existing service if exists
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "  Stopping existing service..." -ForegroundColor Gray
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    & $nssmExe remove $ServiceName confirm
    Start-Sleep -Seconds 2
}

# Get Python executable path
$pythonExe = (Get-Command python).Source

# Install service
Write-Host "  Installing $ServiceName service..." -ForegroundColor Gray
& $nssmExe install $ServiceName "$pythonExe" "$BotScriptPath"
& $nssmExe set $ServiceName AppDirectory "$SCRIPTS_PATH"
& $nssmExe set $ServiceName DisplayName "BTI Telegram Bot (@N8Ndwg_bot)"
& $nssmExe set $ServiceName Description "Telegram bot for BTI DWG QA Pipeline - receives DWG files and sends results"
& $nssmExe set $ServiceName Start SERVICE_AUTO_START

# Set stdout/stderr logs
$logDir = "$BTI_BASE\output\logs"
& $nssmExe set $ServiceName AppStdout "$logDir\telegram_bot_stdout.log"
& $nssmExe set $ServiceName AppStderr "$logDir\telegram_bot_stderr.log"

Write-Host "  Service created successfully" -ForegroundColor Green

# =============================================================================
# 6. Start Service
# =============================================================================

Write-Host "[6/6] Starting Telegram bot service..." -ForegroundColor Yellow

Start-Service -Name $ServiceName
Start-Sleep -Seconds 5

$service = Get-Service -Name $ServiceName
if ($service.Status -eq "Running") {
    Write-Host "  ✓ Service started successfully" -ForegroundColor Green
} else {
    Write-Host "  ✗ Service failed to start" -ForegroundColor Red
    & $nssmExe status $ServiceName
    exit 1
}

# =============================================================================
# Summary
# =============================================================================

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Telegram Bot Service Setup Complete!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Service Information:" -ForegroundColor Yellow
Get-Service -Name $ServiceName | Format-Table -AutoSize
Write-Host ""

Write-Host "Bot Configuration:" -ForegroundColor Yellow
Write-Host "  ✓ Bot Name: @N8Ndwg_bot" -ForegroundColor Green
Write-Host "  ✓ Script: $BotScriptPath" -ForegroundColor Green
Write-Host "  ✓ Upload Path: C:\bti\input\" -ForegroundColor Green
Write-Host "  ✓ Output Path: C:\bti\output\" -ForegroundColor Green
Write-Host "  ✓ Max File Size: 50 MB" -ForegroundColor Green
Write-Host ""

Write-Host "Logs:" -ForegroundColor Yellow
Write-Host "  stdout: $logDir\telegram_bot_stdout.log" -ForegroundColor Gray
Write-Host "  stderr: $logDir\telegram_bot_stderr.log" -ForegroundColor Gray
Write-Host "  bot: $logDir\telegram_bot.log" -ForegroundColor Gray
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Test bot: Send /start to @N8Ndwg_bot in Telegram" -ForegroundColor White
Write-Host "  2. Upload test DWG file to bot" -ForegroundColor White
Write-Host "  3. Wait for processing (~30-60 seconds)" -ForegroundColor White
Write-Host "  4. Receive results: DWG + QA log + QTO report" -ForegroundColor White
Write-Host ""

Write-Host "Service commands:" -ForegroundColor Yellow
Write-Host "  Restart: Restart-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "  Stop: Stop-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "  Status: Get-Service -Name $ServiceName" -ForegroundColor Gray
Write-Host "  Logs: Get-Content $logDir\telegram_bot.log -Tail 50" -ForegroundColor Gray
Write-Host ""

