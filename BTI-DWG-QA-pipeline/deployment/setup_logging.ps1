# =============================================================================
# BTI DWG QA Pipeline - Cloud Logging Setup
# =============================================================================
# Purpose: Install Google Cloud Ops Agent and configure log collection
# =============================================================================

param(
    [string]$ProjectId = "talkhint",
    [string]$Zone = "us-central1-f",
    [string]$InstanceName = "instance-20251019-062935"
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Cloud Logging Setup for BTI DWG QA Pipeline" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$BTI_BASE = "C:\bti"
$OPS_AGENT_CONFIG = "C:\ProgramData\Google\Cloud Operations\Ops Agent\config\config.yaml"

# =============================================================================
# 1. Install Google Cloud Ops Agent
# =============================================================================

Write-Host "[1/4] Installing Google Cloud Ops Agent..." -ForegroundColor Yellow

# Check if already installed
if (Get-Service -Name "google-cloud-ops-agent" -ErrorAction SilentlyContinue) {
    Write-Host "  Google Cloud Ops Agent already installed" -ForegroundColor Gray
} else {
    Write-Host "  Downloading Ops Agent installer..." -ForegroundColor Gray
    $installerScript = "$BTI_BASE\temp\add-google-cloud-ops-agent-repo.ps1"
    
    Invoke-WebRequest `
        -Uri "https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.ps1" `
        -OutFile $installerScript `
        -UseBasicParsing
    
    Write-Host "  Running installer..." -ForegroundColor Gray
    powershell -ExecutionPolicy Bypass -File $installerScript
    
    Write-Host "  Installing Ops Agent package..." -ForegroundColor Gray
    googet -noconfirm install google-cloud-ops-agent
    
    Write-Host "  Google Cloud Ops Agent installed" -ForegroundColor Green
}

# =============================================================================
# 2. Create Ops Agent Configuration
# =============================================================================

Write-Host "[2/4] Creating Ops Agent configuration..." -ForegroundColor Yellow

# Create config directory if not exists
$configDir = Split-Path -Parent $OPS_AGENT_CONFIG
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# Configuration YAML
$opsAgentConfig = @"
# Google Cloud Ops Agent Configuration for BTI DWG QA Pipeline
# Collects QA logs and n8n service logs

logging:
  receivers:
    # BTI QA JSON logs
    bti_qa_json_logs:
      type: files
      include_paths:
        - $BTI_BASE\output\logs\*.json
      
    # BTI QA text logs
    bti_qa_text_logs:
      type: files
      include_paths:
        - $BTI_BASE\output\logs\*.txt
    
    # Windows Event Logs (Application, System)
    windows_events:
      type: windows_event_log
      channels:
        - Application
        - System
  
  processors:
    # Parse JSON logs
    parse_json:
      type: parse_json
      field: message
      time_key: timestamp
      time_format: "%Y-%m-%dT%H:%M:%S"
    
    # Add metadata
    add_metadata:
      type: modify_fields
      fields:
        pipeline_name:
          static_value: "BTI-DWG-QA"
        instance_name:
          static_value: "$InstanceName"
  
  service:
    pipelines:
      # JSON logs pipeline
      json_pipeline:
        receivers:
          - bti_qa_json_logs
        processors:
          - parse_json
          - add_metadata
      
      # Text logs pipeline
      text_pipeline:
        receivers:
          - bti_qa_text_logs
        processors:
          - add_metadata
      
      # Windows events pipeline
      windows_pipeline:
        receivers:
          - windows_events

metrics:
  receivers:
    # System metrics
    hostmetrics:
      type: hostmetrics
      collection_interval: 60s
  
  service:
    pipelines:
      default_pipeline:
        receivers:
          - hostmetrics
"@

# Write configuration
$opsAgentConfig | Out-File -FilePath $OPS_AGENT_CONFIG -Encoding utf8 -Force

Write-Host "  Configuration created: $OPS_AGENT_CONFIG" -ForegroundColor Green

# =============================================================================
# 3. Restart Ops Agent Service
# =============================================================================

Write-Host "[3/4] Restarting Google Cloud Ops Agent..." -ForegroundColor Yellow

try {
    Restart-Service -Name "google-cloud-ops-agent" -Force
    Start-Sleep -Seconds 3
    
    $service = Get-Service -Name "google-cloud-ops-agent"
    if ($service.Status -eq "Running") {
        Write-Host "  Ops Agent restarted successfully" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Ops Agent service not running" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ERROR: Failed to restart Ops Agent" -ForegroundColor Red
    Write-Host "  $_" -ForegroundColor Red
}

# =============================================================================
# 4. Enable Serial Port Logging
# =============================================================================

Write-Host "[4/4] Enabling Serial Port 1..." -ForegroundColor Yellow

gcloud compute instances add-metadata $InstanceName `
    --zone=$Zone `
    --metadata serial-port-enable=TRUE `
    --project=$ProjectId

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Serial Port 1 enabled" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Failed to enable Serial Port" -ForegroundColor Yellow
}

# =============================================================================
# Summary
# =============================================================================

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Cloud Logging Setup Complete!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Logging configured:" -ForegroundColor Yellow
Write-Host "  ✓ Google Cloud Ops Agent: Running" -ForegroundColor Green
Write-Host "  ✓ Log collectors:" -ForegroundColor Green
Write-Host "    - $BTI_BASE\output\logs\*.json" -ForegroundColor Gray
Write-Host "    - $BTI_BASE\output\logs\*.txt" -ForegroundColor Gray
Write-Host "    - Windows Event Logs (Application, System)" -ForegroundColor Gray
Write-Host "  ✓ Serial Port 1: Enabled" -ForegroundColor Green
Write-Host ""
Write-Host "View logs at:" -ForegroundColor Yellow
Write-Host "  https://console.cloud.google.com/logs/query?project=$ProjectId" -ForegroundColor Cyan
Write-Host ""
Write-Host "Filter by:" -ForegroundColor Yellow
Write-Host "  resource.type=`"gce_instance`"" -ForegroundColor Gray
Write-Host "  jsonPayload.pipeline_name=`"BTI-DWG-QA`"" -ForegroundColor Gray
Write-Host ""
Write-Host "Serial Port Console:" -ForegroundColor Yellow
Write-Host "  gcloud compute instances get-serial-port-output $InstanceName --zone=$Zone --port=1" -ForegroundColor Gray
Write-Host ""

