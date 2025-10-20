# =============================================================================
# BTI DWG QA Pipeline - Firewall Setup
# =============================================================================
# Purpose: Configure GCP VPC firewall + Windows Firewall for n8n
# =============================================================================

param(
    [string]$ProjectId = "swiftchair",
    [string]$Zone = "us-central1-f",
    [string]$InstanceName = "instance-20251019-062935",
    [int]$N8nPort = 5678
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Firewall Setup for BTI DWG QA Pipeline" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# 1. GCP VPC Firewall Rule
# =============================================================================

Write-Host "[1/3] Creating GCP firewall rule..." -ForegroundColor Yellow

# Check if firewall rule already exists
$existingRule = gcloud compute firewall-rules list --filter="name=allow-n8n-5678" --format="value(name)" 2>$null

if ($existingRule) {
    Write-Host "  Firewall rule 'allow-n8n-5678' already exists" -ForegroundColor Gray
} else {
    Write-Host "  Creating firewall rule 'allow-n8n-5678'..." -ForegroundColor Gray
    
    gcloud compute firewall-rules create allow-n8n-5678 `
        --network=default `
        --allow=tcp:$N8nPort `
        --target-tags=n8n `
        --direction=INGRESS `
        --source-ranges=0.0.0.0/0 `
        --description="Allow n8n BTI DWG QA Pipeline access" `
        --project=$ProjectId
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Firewall rule created successfully" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: Failed to create firewall rule" -ForegroundColor Red
    }
}

# =============================================================================
# 2. Add Network Tag to Instance
# =============================================================================

Write-Host "[2/3] Adding network tag to instance..." -ForegroundColor Yellow

gcloud compute instances add-tags $InstanceName `
    --zone=$Zone `
    --tags=n8n `
    --project=$ProjectId

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Network tag 'n8n' added to $InstanceName" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Failed to add network tag (may already exist)" -ForegroundColor Yellow
}

# =============================================================================
# 3. Windows Firewall Rule
# =============================================================================

Write-Host "[3/3] Creating Windows Firewall rule..." -ForegroundColor Yellow

# Check if rule exists
$existingWinRule = Get-NetFirewallRule -DisplayName "n8n BTI Pipeline" -ErrorAction SilentlyContinue

if ($existingWinRule) {
    Write-Host "  Windows Firewall rule already exists" -ForegroundColor Gray
} else {
    New-NetFirewallRule `
        -DisplayName "n8n BTI Pipeline" `
        -Direction Inbound `
        -LocalPort $N8nPort `
        -Protocol TCP `
        -Action Allow `
        -Description "Allow n8n BTI DWG QA Pipeline HTTP access"
    
    Write-Host "  Windows Firewall rule created" -ForegroundColor Green
}

# =============================================================================
# Summary
# =============================================================================

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Firewall Setup Complete!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "n8n is now accessible at:" -ForegroundColor Yellow
Write-Host "  Internal: http://localhost:$N8nPort" -ForegroundColor White
Write-Host ""
Write-Host "To get external IP:" -ForegroundColor Yellow
Write-Host "  gcloud compute instances describe $InstanceName --zone=$Zone --format='get(networkInterfaces[0].accessConfigs[0].natIP)'" -ForegroundColor Gray
Write-Host ""

# Get and display external IP
$externalIp = gcloud compute instances describe $InstanceName `
    --zone=$Zone `
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)" `
    --project=$ProjectId 2>$null

if ($externalIp) {
    Write-Host "  External: http://$externalIp`:$N8nPort" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "Firewall rules configured:" -ForegroundColor Yellow
Write-Host "  ✓ GCP VPC: allow-n8n-5678 (tcp:$N8nPort)" -ForegroundColor Green
Write-Host "  ✓ Network Tag: n8n" -ForegroundColor Green
Write-Host "  ✓ Windows Firewall: n8n BTI Pipeline" -ForegroundColor Green
Write-Host ""

