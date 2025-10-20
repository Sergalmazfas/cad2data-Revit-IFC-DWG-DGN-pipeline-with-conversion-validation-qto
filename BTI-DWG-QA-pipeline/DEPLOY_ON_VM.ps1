# =============================================================================
# BTI DWG QA Pipeline - Deploy on Windows VM (PowerShell)
# =============================================================================
# Execute this script DIRECTLY on Windows VM PowerShell
# Project: talkhint
# Instance: instance-20251019-062935
# =============================================================================

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  BTI DWG QA Pipeline - Deployment Starting" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project: talkhint" -ForegroundColor White
Write-Host "Instance: instance-20251019-062935" -ForegroundColor White
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 1: Clone Repository
# =============================================================================

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 1: Cloning Repository" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

cd C:\Users\Administrator

# Check if git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing git..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe" -OutFile "C:\git-installer.exe"
    Start-Process "C:\git-installer.exe" -ArgumentList "/VERYSILENT" -Wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
}

# Clone repository
if (Test-Path "cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto") {
    Write-Host "Repository already exists, pulling latest..." -ForegroundColor Yellow
    cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto
    git pull origin release/DWG-QA-v1
} else {
    Write-Host "Cloning repository..." -ForegroundColor Yellow
    git clone https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git
    cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto
}

git checkout release/DWG-QA-v1

Write-Host "✅ Repository cloned!" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 2: Navigate to Deployment
# =============================================================================

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 2: Preparing Deployment Scripts" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

cd BTI-DWG-QA-pipeline\deployment

# List deployment scripts
Write-Host "Available deployment scripts:" -ForegroundColor Yellow
Get-ChildItem *.ps1 | ForEach-Object { Write-Host "  ✓ $($_.Name)" -ForegroundColor Green }
Write-Host ""

# Check template
if (Test-Path "..\templates\BasmanTitleBlock.dwg") {
    $templateSize = (Get-Item "..\templates\BasmanTitleBlock.dwg").Length / 1KB
    Write-Host "✅ Basmanny template found: $([math]::Round($templateSize, 1)) KB" -ForegroundColor Green
} else {
    Write-Host "⚠️  Basmanny template not found (will be downloaded from repo)" -ForegroundColor Yellow
}

Write-Host ""

# =============================================================================
# Step 3: Run Deployment
# =============================================================================

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 3: Starting Deployment (30-40 minutes)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press Enter to start deployment or Ctrl+C to cancel..." -ForegroundColor Yellow
Read-Host

# Execute deployment
.\deploy_all.ps1 -ProjectId "talkhint" -Zone "us-central1-f" -InstanceName "instance-20251019-062935"

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Deployment Script Complete!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open n8n: http://104.198.201.212:5678" -ForegroundColor White
Write-Host "  2. Activate workflows (BTI_0_Watch_Input + BTI_4_Telegram_Webhook)" -ForegroundColor White
Write-Host "  3. Test Telegram: Send DWG to @N8Ndwg_bot" -ForegroundColor White
Write-Host ""

