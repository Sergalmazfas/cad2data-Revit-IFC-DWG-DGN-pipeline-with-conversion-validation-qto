# =============================================================================
# BTI DWG QA Pipeline - Smoke Test
# =============================================================================
# Purpose: End-to-end smoke test of the BTI DWG QA Pipeline
# =============================================================================

param(
    [string]$N8nUrl = "http://localhost:5678",
    [string]$TestDwgPath = "C:\bti\input\test.dwg"
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  BTI DWG QA Pipeline - Smoke Test" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$BTI_BASE = "C:\bti"
$testResults = @{
    passed = 0
    failed = 0
    warnings = 0
    tests = @()
}

# =============================================================================
# Helper Functions
# =============================================================================

function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$Test
    )
    
    Write-Host "Testing: $Name" -ForegroundColor Yellow
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host "  ✓ PASS: $Name" -ForegroundColor Green
            $testResults.passed++
            $testResults.tests += @{name=$Name; status="PASS"; message=""}
            return $true
        } else {
            Write-Host "  ✗ FAIL: $Name" -ForegroundColor Red
            $testResults.failed++
            $testResults.tests += @{name=$Name; status="FAIL"; message="Test returned false"}
            return $false
        }
    } catch {
        Write-Host "  ✗ FAIL: $Name - $($_.Exception.Message)" -ForegroundColor Red
        $testResults.failed++
        $testResults.tests += @{name=$Name; status="FAIL"; message=$_.Exception.Message}
        return $false
    }
}

# =============================================================================
# 1. Directory Structure
# =============================================================================

Write-Host "[1/9] Checking directory structure..." -ForegroundColor Cyan
Write-Host ""

Test-Component "BTI base directory exists" {
    Test-Path $BTI_BASE
}

Test-Component "Input directory exists" {
    Test-Path "$BTI_BASE\input"
}

Test-Component "Output directory exists" {
    Test-Path "$BTI_BASE\output"
}

Test-Component "Logs directory exists" {
    Test-Path "$BTI_BASE\output\logs"
}

Test-Component "Scripts directory exists" {
    Test-Path "$BTI_BASE\scripts"
}

Test-Component "Config directory exists" {
    Test-Path "$BTI_BASE\config"
}

Test-Component "Workflows directory exists" {
    Test-Path "$BTI_BASE\workflows"
}

Write-Host ""

# =============================================================================
# 2. Required Files
# =============================================================================

Write-Host "[2/9] Checking required files..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Validation rules config" {
    Test-Path "$BTI_BASE\config\validation_rules.json"
}

Test-Component "Converter settings config" {
    Test-Path "$BTI_BASE\config\converter_settings.json"
}

Test-Component "QA logger script" {
    Test-Path "$BTI_BASE\scripts\qa_logger.js"
}

Test-Component "DWG validator script" {
    Test-Path "$BTI_BASE\scripts\dwg_validator.js"
}

Test-Component "Telegram notification script" {
    Test-Path "$BTI_BASE\scripts\send_telegram_report.py"
}

Write-Host ""

# =============================================================================
# 3. Software Installation
# =============================================================================

Write-Host "[3/9] Checking software installation..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Node.js installed" {
    Get-Command node -ErrorAction SilentlyContinue
}

Test-Component "npm installed" {
    Get-Command npm -ErrorAction SilentlyContinue
}

Test-Component "n8n installed" {
    Get-Command n8n -ErrorAction SilentlyContinue
}

Test-Component "Python installed" {
    Get-Command python -ErrorAction SilentlyContinue
}

Test-Component "gcloud installed" {
    Get-Command gcloud -ErrorAction SilentlyContinue
}

Write-Host ""

# =============================================================================
# 4. Windows Services
# =============================================================================

Write-Host "[4/9] Checking Windows services..." -ForegroundColor Cyan
Write-Host ""

Test-Component "n8n service exists" {
    Get-Service -Name "n8n" -ErrorAction SilentlyContinue
}

Test-Component "n8n service running" {
    $service = Get-Service -Name "n8n" -ErrorAction SilentlyContinue
    $service -and $service.Status -eq "Running"
}

Test-Component "Google Cloud Ops Agent service exists" {
    Get-Service -Name "google-cloud-ops-agent" -ErrorAction SilentlyContinue
}

Test-Component "Google Cloud Ops Agent running" {
    $service = Get-Service -Name "google-cloud-ops-agent" -ErrorAction SilentlyContinue
    $service -and $service.Status -eq "Running"
}

Write-Host ""

# =============================================================================
# 5. Environment Variables
# =============================================================================

Write-Host "[5/9] Checking environment variables..." -ForegroundColor Cyan
Write-Host ""

Test-Component "TELEGRAM_BOT_TOKEN configured" {
    $token = [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
    -not [string]::IsNullOrEmpty($token)
}

Test-Component "TELEGRAM_CHAT_ID configured" {
    $chatId = [Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "Machine")
    -not [string]::IsNullOrEmpty($chatId)
}

Write-Host ""

# =============================================================================
# 6. Network Connectivity
# =============================================================================

Write-Host "[6/9] Checking network connectivity..." -ForegroundColor Cyan
Write-Host ""

Test-Component "n8n web service responding" {
    try {
        $response = Invoke-WebRequest -Uri "$N8nUrl/healthz" -Method GET -UseBasicParsing -TimeoutSec 5
        $response.StatusCode -eq 200
    } catch {
        $false
    }
}

Test-Component "n8n REST API accessible" {
    try {
        $response = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET -TimeoutSec 5
        $true
    } catch {
        $false
    }
}

Test-Component "Telegram API reachable" {
    try {
        $response = Invoke-WebRequest -Uri "https://api.telegram.org" -Method GET -UseBasicParsing -TimeoutSec 5
        $response.StatusCode -eq 200
    } catch {
        $false
    }
}

Write-Host ""

# =============================================================================
# 7. Firewall Rules
# =============================================================================

Write-Host "[7/9] Checking firewall rules..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Windows Firewall rule for n8n" {
    Get-NetFirewallRule -DisplayName "n8n BTI Pipeline" -ErrorAction SilentlyContinue
}

Test-Component "GCP firewall rule for n8n" {
    $rule = gcloud compute firewall-rules list --filter="name=allow-n8n-5678" --format="value(name)" 2>$null
    -not [string]::IsNullOrEmpty($rule)
}

Write-Host ""

# =============================================================================
# 8. Cloud Logging Configuration
# =============================================================================

Write-Host "[8/9] Checking Cloud Logging configuration..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Ops Agent config file exists" {
    Test-Path "C:\ProgramData\Google\Cloud Operations\Ops Agent\config\config.yaml"
}

Write-Host ""

# =============================================================================
# 9. n8n Workflows
# =============================================================================

Write-Host "[9/9] Checking n8n workflows..." -ForegroundColor Cyan
Write-Host ""

Test-Component "n8n workflows imported" {
    try {
        $workflows = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET -TimeoutSec 5
        $workflows.Count -ge 3
    } catch {
        $false
    }
}

Write-Host ""

# =============================================================================
# Test Summary
# =============================================================================

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Smoke Test Results" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$totalTests = $testResults.passed + $testResults.failed
$passRate = if ($totalTests -gt 0) { [math]::Round(($testResults.passed / $totalTests) * 100, 1) } else { 0 }

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $($testResults.passed)" -ForegroundColor Green
Write-Host "Failed: $($testResults.failed)" -ForegroundColor $(if ($testResults.failed -gt 0) { "Red" } else { "Gray" })
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 90) { "Green" } elseif ($passRate -ge 70) { "Yellow" } else { "Red" })
Write-Host ""

# Overall status
if ($testResults.failed -eq 0) {
    Write-Host "✓ ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "BTI DWG QA Pipeline is ready to use!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Place DWG files in: $BTI_BASE\input\" -ForegroundColor White
    Write-Host "  2. Open n8n: $N8nUrl" -ForegroundColor White
    Write-Host "  3. Execute workflows manually or via API" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "✗ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host "Failed tests:" -ForegroundColor Yellow
    foreach ($test in $testResults.tests) {
        if ($test.status -eq "FAIL") {
            Write-Host "  - $($test.name)" -ForegroundColor Red
            if ($test.message) {
                Write-Host "    $($test.message)" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
    Write-Host "Please fix the issues and run the smoke test again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

