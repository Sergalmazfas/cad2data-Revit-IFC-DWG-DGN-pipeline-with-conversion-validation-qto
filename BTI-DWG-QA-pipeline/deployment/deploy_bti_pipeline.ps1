# =============================================================================
# BTI DWG QA Pipeline - Main Deployment Script
# =============================================================================
# Purpose: Automated deployment on Windows Server 2025 Core (GCE)
# Instance: instance-20251019-062935 (n2-standard-2, us-central1-f)
# Author: DataDrivenConstruction
# Version: 1.0.0
# =============================================================================

param(
    [string]$ProjectId = "talkhint",
    [string]$Zone = "us-central1-f",
    [string]$InstanceName = "instance-20251019-062935",
    [string]$RepoPath = "C:\Users\Administrator\cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto"
)

# =============================================================================
# Configuration
# =============================================================================

$BTI_BASE = "C:\bti"
$N8N_PORT = 5678
$EXTERNAL_IP = "104.198.201.212"

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  BTI DWG QA Pipeline - Automated Deployment" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Instance: $InstanceName"
Write-Host "Zone: $Zone"
Write-Host "Project: $ProjectId"
Write-Host "Base Directory: $BTI_BASE"
Write-Host "n8n Port: $N8N_PORT"
Write-Host ""

# =============================================================================
# Step 1: Create Directory Structure
# =============================================================================

Write-Host "[1/9] Creating directory structure..." -ForegroundColor Yellow

$directories = @(
    "$BTI_BASE\input",
    "$BTI_BASE\output",
    "$BTI_BASE\output\logs",
    "$BTI_BASE\scripts",
    "$BTI_BASE\config",
    "$BTI_BASE\workflows",
    "$BTI_BASE\temp"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Exists: $dir" -ForegroundColor Gray
    }
}

# =============================================================================
# Step 2: Copy Project Files
# =============================================================================

Write-Host "[2/9] Copying project files from repository..." -ForegroundColor Yellow

if (Test-Path "$RepoPath\BTI-DWG-QA-pipeline") {
    # Copy scripts
    Copy-Item "$RepoPath\BTI-DWG-QA-pipeline\scripts\*" -Destination "$BTI_BASE\scripts" -Recurse -Force
    Write-Host "  Copied: scripts\" -ForegroundColor Green
    
    # Copy config
    Copy-Item "$RepoPath\BTI-DWG-QA-pipeline\config\*" -Destination "$BTI_BASE\config" -Recurse -Force
    Write-Host "  Copied: config\" -ForegroundColor Green
    
    # Copy workflows
    Copy-Item "$RepoPath\BTI-DWG-QA-pipeline\n8n_*.json" -Destination "$BTI_BASE\workflows" -Force
    Write-Host "  Copied: workflows\n8n_*.json" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Repository not found at $RepoPath" -ForegroundColor Red
    Write-Host "  Please clone the repository first!" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Install Node.js
# =============================================================================

Write-Host "[3/9] Installing Node.js LTS..." -ForegroundColor Yellow

$nodeInstaller = "$BTI_BASE\temp\node.msi"
$nodeVersion = "v20.17.0"
$nodeUrl = "https://nodejs.org/dist/$nodeVersion/node-$nodeVersion-x64.msi"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "  Downloading Node.js $nodeVersion..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller -UseBasicParsing
    
    Write-Host "  Installing Node.js (silent)..." -ForegroundColor Gray
    Start-Process msiexec.exe -ArgumentList "/i `"$nodeInstaller`" /qn /norestart" -Wait -NoNewWindow
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-Host "  Node.js installed successfully" -ForegroundColor Green
    node --version
    npm --version
} else {
    Write-Host "  Node.js already installed: $(node --version)" -ForegroundColor Gray
}

# =============================================================================
# Step 4: Install n8n globally
# =============================================================================

Write-Host "[4/9] Installing n8n..." -ForegroundColor Yellow

if (-not (Get-Command n8n -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing n8n globally..." -ForegroundColor Gray
    npm install -g n8n --loglevel=error
    Write-Host "  n8n installed successfully" -ForegroundColor Green
} else {
    Write-Host "  n8n already installed" -ForegroundColor Gray
}

# =============================================================================
# Step 5: Install NSSM (Non-Sucking Service Manager)
# =============================================================================

Write-Host "[5/9] Installing NSSM for Windows Service..." -ForegroundColor Yellow

$nssmZip = "$BTI_BASE\temp\nssm.zip"
$nssmPath = "C:\nssm"

if (-not (Test-Path "$nssmPath\win64\nssm.exe")) {
    Write-Host "  Downloading NSSM..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile $nssmZip -UseBasicParsing
    
    Write-Host "  Extracting NSSM..." -ForegroundColor Gray
    Expand-Archive -Path $nssmZip -DestinationPath $nssmPath -Force
    
    Write-Host "  NSSM installed: $nssmPath\nssm-2.24\win64\nssm.exe" -ForegroundColor Green
} else {
    Write-Host "  NSSM already installed" -ForegroundColor Gray
}

$nssmExe = "$nssmPath\nssm-2.24\win64\nssm.exe"

# =============================================================================
# Step 6: Create n8n Windows Service
# =============================================================================

Write-Host "[6/9] Creating n8n Windows Service..." -ForegroundColor Yellow

# Stop and remove existing service if exists
$existingService = Get-Service -Name "n8n" -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "  Stopping existing n8n service..." -ForegroundColor Gray
    Stop-Service -Name "n8n" -Force -ErrorAction SilentlyContinue
    & $nssmExe remove n8n confirm
}

# Get npx.cmd path
$npxPath = (Get-Command npx).Source

Write-Host "  Installing n8n service..." -ForegroundColor Gray
& $nssmExe install n8n "$npxPath" "n8n"
& $nssmExe set n8n AppDirectory "$BTI_BASE"
& $nssmExe set n8n AppParameters "start"
& $nssmExe set n8n AppEnvironmentExtra "N8N_HOST=0.0.0.0" "N8N_PORT=$N8N_PORT"
& $nssmExe set n8n DisplayName "n8n BTI DWG QA Pipeline"
& $nssmExe set n8n Description "n8n workflow automation for BTI DWG QA"
& $nssmExe set n8n Start SERVICE_AUTO_START

Write-Host "  n8n service created (not started yet)" -ForegroundColor Green

# =============================================================================
# Step 7: Configure Google Cloud (gcloud SDK)
# =============================================================================

Write-Host "[7/9] Configuring Google Cloud SDK..." -ForegroundColor Yellow

if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "  Downloading Google Cloud SDK..." -ForegroundColor Gray
    $gcloudInstaller = "$BTI_BASE\temp\GoogleCloudSDKInstaller.exe"
    Invoke-WebRequest -Uri "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe" -OutFile $gcloudInstaller -UseBasicParsing
    
    Write-Host "  Installing Google Cloud SDK (silent)..." -ForegroundColor Gray
    Start-Process $gcloudInstaller -ArgumentList "/S" -Wait -NoNewWindow
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-Host "  Google Cloud SDK installed" -ForegroundColor Green
} else {
    Write-Host "  Google Cloud SDK already installed" -ForegroundColor Gray
}

# Configure project
Write-Host "  Setting project: $ProjectId" -ForegroundColor Gray
gcloud config set project $ProjectId 2>$null

Write-Host "  Google Cloud configured" -ForegroundColor Green

# =============================================================================
# Step 8: Retrieve Secrets from Secret Manager
# =============================================================================

Write-Host "[8/9] Retrieving secrets from Secret Manager..." -ForegroundColor Yellow

try {
    Write-Host "  Fetching TELEGRAM_BOT_TOKEN..." -ForegroundColor Gray
    $telegramToken = gcloud secrets versions access latest --secret=TELEGRAM_BOT_TOKEN 2>$null
    
    if ($telegramToken) {
        [Environment]::SetEnvironmentVariable("TELEGRAM_BOT_TOKEN", $telegramToken, "Machine")
        Write-Host "  TELEGRAM_BOT_TOKEN configured" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: TELEGRAM_BOT_TOKEN not found in Secret Manager" -ForegroundColor Yellow
    }
    
    Write-Host "  Fetching TELEGRAM_CHAT_ID..." -ForegroundColor Gray
    $telegramChatId = gcloud secrets versions access latest --secret=TELEGRAM_CHAT_ID 2>$null
    
    if ($telegramChatId) {
        [Environment]::SetEnvironmentVariable("TELEGRAM_CHAT_ID", $telegramChatId, "Machine")
        Write-Host "  TELEGRAM_CHAT_ID configured" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: TELEGRAM_CHAT_ID not found in Secret Manager" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ERROR: Failed to retrieve secrets. Check IAM permissions." -ForegroundColor Red
    Write-Host "  Required role: roles/secretmanager.secretAccessor" -ForegroundColor Yellow
}

# =============================================================================
# Step 9: Start n8n Service
# =============================================================================

Write-Host "[9/9] Starting n8n service..." -ForegroundColor Yellow

Start-Service -Name "n8n"
Start-Sleep -Seconds 5

$service = Get-Service -Name "n8n"
if ($service.Status -eq "Running") {
    Write-Host "  n8n service started successfully" -ForegroundColor Green
    Write-Host "  Access n8n at: http://localhost:$N8N_PORT" -ForegroundColor Cyan
} else {
    Write-Host "  ERROR: n8n service failed to start" -ForegroundColor Red
    & $nssmExe status n8n
}

# =============================================================================
# Deployment Summary
# =============================================================================

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Deployment Complete!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: .\setup_firewall.ps1 (open port $N8N_PORT)" -ForegroundColor White
Write-Host "  2. Run: .\setup_logging.ps1 (configure Cloud Logging)" -ForegroundColor White
Write-Host "  3. Run: .\import_workflows.ps1 (import n8n workflows)" -ForegroundColor White
Write-Host "  4. Run: .\setup_telegram.ps1 (configure Telegram bot)" -ForegroundColor White
Write-Host "  5. Run: .\smoke_test.ps1 (test the pipeline)" -ForegroundColor White
Write-Host ""
Write-Host "n8n Web UI: http://$EXTERNAL_IP`:$N8N_PORT" -ForegroundColor Cyan
Write-Host "Base Directory: $BTI_BASE" -ForegroundColor Gray
Write-Host ""
Write-Host "Service Status:" -ForegroundColor Yellow
Get-Service -Name "n8n" | Format-Table -AutoSize
Write-Host ""

