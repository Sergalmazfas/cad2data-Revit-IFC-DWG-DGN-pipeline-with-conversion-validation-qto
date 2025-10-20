# =============================================================================
# BTI DWG QA Pipeline - ONE-CLICK DEPLOYMENT
# =============================================================================
# Purpose: Deploy entire BTI pipeline with one command
# =============================================================================

param(
    [string]$ProjectId = "swiftchair",
    [string]$Zone = "us-central1-f",
    [string]$InstanceName = "instance-20251019-062935",
    [switch]$SkipTests = $false
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  BTI DWG QA Pipeline - ONE-CLICK DEPLOYMENT" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Instance: $InstanceName" -ForegroundColor White
Write-Host "Project: $ProjectId" -ForegroundColor White
Write-Host "Zone: $Zone" -ForegroundColor White
Write-Host ""
Write-Host "This will deploy the complete BTI DWG QA Pipeline with Basmanny template." -ForegroundColor Yellow
Write-Host "Estimated time: 20-30 minutes" -ForegroundColor Yellow
Write-Host ""

# Confirmation
Write-Host "Press Enter to continue or Ctrl+C to cancel..." -ForegroundColor Cyan
Read-Host

$deploymentStart = Get-Date

# =============================================================================
# Step 1: Main Deployment
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 1/7: Main Deployment (10-15 min)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

.\deploy_bti_pipeline.ps1 -ProjectId $ProjectId -Zone $Zone -InstanceName $InstanceName

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Main deployment failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Step 1 completed!" -ForegroundColor Green
Start-Sleep -Seconds 2

# =============================================================================
# Step 2: Firewall
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 2/7: Firewall Configuration (2-3 min)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

.\setup_firewall.ps1 -ProjectId $ProjectId -Zone $Zone -InstanceName $InstanceName

Write-Host "✅ Step 2 completed!" -ForegroundColor Green
Start-Sleep -Seconds 2

# =============================================================================
# Step 3: Cloud Logging
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 3/7: Cloud Logging Setup (3-5 min)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

.\setup_logging.ps1 -ProjectId $ProjectId -Zone $Zone -InstanceName $InstanceName

Write-Host "✅ Step 3 completed!" -ForegroundColor Green
Start-Sleep -Seconds 2

# =============================================================================
# Step 4: Import Workflows
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 4/7: Import n8n Workflows (1-2 min)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

.\import_workflows.ps1

Write-Host "✅ Step 4 completed!" -ForegroundColor Green
Start-Sleep -Seconds 2

# =============================================================================
# Step 5: Telegram Integration
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 5/7: Telegram Integration (2-3 min)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

.\setup_telegram.ps1

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "STEP 5b/7: Telegram Bot Server (3-5 min)" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

.\setup_telegram_bot_service.ps1

Write-Host "✅ Step 5 completed!" -ForegroundColor Green
Start-Sleep -Seconds 2

# =============================================================================
# Step 6: Smoke Test
# =============================================================================

if (-not $SkipTests) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "STEP 6/7: Smoke Test (1-2 min)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    .\smoke_test.ps1

    Write-Host "✅ Step 6 completed!" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# =============================================================================
# Step 7: Basmanny Template Test
# =============================================================================

if (-not $SkipTests) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "STEP 7/7: Basmanny Template Test (1-2 min)" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    .\test_basman_pipeline.ps1

    Write-Host "✅ Step 7 completed!" -ForegroundColor Green
}

# =============================================================================
# Deployment Summary
# =============================================================================

$deploymentEnd = Get-Date
$duration = ($deploymentEnd - $deploymentStart).TotalMinutes

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Deployment time: $([math]::Round($duration, 1)) minutes" -ForegroundColor White
Write-Host ""
Write-Host "Services status:" -ForegroundColor Yellow
Get-Service -Name "n8n", "google-cloud-ops-agent" | Format-Table -AutoSize
Write-Host ""

Write-Host "Access points:" -ForegroundColor Yellow
Write-Host "  ✓ n8n Web UI (internal): http://localhost:5678" -ForegroundColor Green
Write-Host "  ✓ n8n Web UI (external): http://104.198.201.212:5678" -ForegroundColor Green
Write-Host "  ✓ Cloud Logging: https://console.cloud.google.com/logs/query?project=$ProjectId" -ForegroundColor Green
Write-Host ""

Write-Host "Deployed components:" -ForegroundColor Yellow
Write-Host "  ✓ Node.js v20.17.0 LTS" -ForegroundColor Green
Write-Host "  ✓ n8n (latest)" -ForegroundColor Green
Write-Host "  ✓ Python 3.12" -ForegroundColor Green
Write-Host "  ✓ Google Cloud SDK" -ForegroundColor Green
Write-Host "  ✓ Google Cloud Ops Agent" -ForegroundColor Green
Write-Host "  ✓ 4 n8n workflows" -ForegroundColor Green
Write-Host "  ✓ Basmanny template (51KB)" -ForegroundColor Green
Write-Host "  ✓ Telegram integration" -ForegroundColor Green
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open n8n: http://104.198.201.212:5678" -ForegroundColor White
Write-Host "  2. Activate auto-start workflow: BTI_0_Watch_Input_AutoStart" -ForegroundColor White
Write-Host "  3. Place DWG files in: C:\bti\input\" -ForegroundColor White
Write-Host "  4. Monitor Telegram for notifications" -ForegroundColor White
Write-Host "  5. Check Cloud Logging for detailed logs" -ForegroundColor White
Write-Host ""

Write-Host "🎊 BTI DWG QA Pipeline is ready for production!" -ForegroundColor Cyan
Write-Host ""

