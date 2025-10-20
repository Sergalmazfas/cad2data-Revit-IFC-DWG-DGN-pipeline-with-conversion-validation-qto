# =============================================================================
# BTI DWG QA Pipeline - Import n8n Workflows
# =============================================================================
# Purpose: Import all BTI workflows into n8n via REST API
# =============================================================================

param(
    [string]$N8nUrl = "http://localhost:5678",
    [string]$WorkflowsPath = "C:\bti\workflows"
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Import n8n Workflows for BTI DWG QA Pipeline" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Wait for n8n to be ready
# =============================================================================

Write-Host "[0/3] Waiting for n8n to be ready..." -ForegroundColor Yellow

$maxAttempts = 30
$attempt = 0
$n8nReady = $false

while (-not $n8nReady -and $attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "$N8nUrl/healthz" -Method GET -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $n8nReady = $true
            Write-Host "  n8n is ready!" -ForegroundColor Green
        }
    } catch {
        $attempt++
        Write-Host "  Waiting for n8n... (attempt $attempt/$maxAttempts)" -ForegroundColor Gray
        Start-Sleep -Seconds 2
    }
}

if (-not $n8nReady) {
    Write-Host "  ERROR: n8n is not responding after $maxAttempts attempts" -ForegroundColor Red
    Write-Host "  Please check if n8n service is running: Get-Service -Name n8n" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Import Workflows
# =============================================================================

$workflows = @(
    "n8n_1_BTI_Convert.json",
    "n8n_2_BTI_Validation.json",
    "n8n_3_BTI_QTO.json"
)

$imported = 0
$failed = 0

foreach ($workflowFile in $workflows) {
    $workflowPath = Join-Path $WorkflowsPath $workflowFile
    $workflowName = [System.IO.Path]::GetFileNameWithoutExtension($workflowFile)
    
    Write-Host "[$(($imported + $failed + 1))/3] Importing $workflowFile..." -ForegroundColor Yellow
    
    if (-not (Test-Path $workflowPath)) {
        Write-Host "  ERROR: Workflow file not found: $workflowPath" -ForegroundColor Red
        $failed++
        continue
    }
    
    try {
        # Read workflow JSON
        $workflowJson = Get-Content $workflowPath -Raw -Encoding UTF8
        
        # Import via REST API
        $headers = @{
            "Content-Type" = "application/json"
            "Accept" = "application/json"
        }
        
        $response = Invoke-RestMethod `
            -Uri "$N8nUrl/rest/workflows" `
            -Method POST `
            -Headers $headers `
            -Body $workflowJson `
            -ContentType "application/json; charset=utf-8"
        
        if ($response.id) {
            Write-Host "  ✓ Imported: $workflowName (ID: $($response.id))" -ForegroundColor Green
            $imported++
        } else {
            Write-Host "  ✗ Failed: $workflowName (no ID returned)" -ForegroundColor Red
            $failed++
        }
    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -like "*already exists*" -or $errorMessage -like "*duplicate*") {
            Write-Host "  ⚠ Already exists: $workflowName" -ForegroundColor Yellow
            $imported++
        } else {
            Write-Host "  ✗ Failed: $workflowName" -ForegroundColor Red
            Write-Host "    Error: $errorMessage" -ForegroundColor Red
            $failed++
        }
    }
}

# =============================================================================
# Summary
# =============================================================================

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Workflow Import Complete!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Import Summary:" -ForegroundColor Yellow
Write-Host "  ✓ Imported: $imported workflows" -ForegroundColor Green
Write-Host "  ✗ Failed: $failed workflows" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })
Write-Host ""
Write-Host "Access n8n Web UI:" -ForegroundColor Yellow
Write-Host "  $N8nUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open n8n Web UI in browser" -ForegroundColor White
Write-Host "  2. Configure workflow paths (update DWG converter path)" -ForegroundColor White
Write-Host "  3. Test each workflow manually" -ForegroundColor White
Write-Host ""

# List imported workflows
Write-Host "Imported workflows:" -ForegroundColor Yellow
try {
    $allWorkflows = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET
    $allWorkflows | ForEach-Object {
        Write-Host "  - $($_.name) (ID: $($_.id))" -ForegroundColor Gray
    }
} catch {
    Write-Host "  (Unable to list workflows)" -ForegroundColor Gray
}

Write-Host ""

