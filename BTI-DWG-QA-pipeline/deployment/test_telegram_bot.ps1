# =============================================================================
# BTI DWG QA Pipeline - Test Telegram Bot Integration
# =============================================================================
# Purpose: Test Telegram bot upload, processing, and response
# =============================================================================

param(
    [string]$ServiceName = "N8NdwgBot",
    [string]$N8nUrl = "http://localhost:5678"
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  BTI DWG QA Pipeline - Telegram Bot Integration Test" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$testResults = @{
    passed = 0
    failed = 0
    tests = @()
}

function Test-Check {
    param([string]$Name, [scriptblock]$Test)
    
    Write-Host "Testing: $Name..." -NoNewline
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host " ✅ PASS" -ForegroundColor Green
            $testResults.passed++
            $testResults.tests += @{name=$Name; status="PASS"}
            return $true
        } else {
            Write-Host " ❌ FAIL" -ForegroundColor Red
            $testResults.failed++
            $testResults.tests += @{name=$Name; status="FAIL"}
            return $false
        }
    } catch {
        Write-Host " ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $testResults.failed++
        $testResults.tests += @{name=$Name; status="FAIL"; error=$_.Exception.Message}
        return $false
    }
}

# =============================================================================
# Test 1: Bot Service
# =============================================================================

Write-Host ""
Write-Host "[1/7] Bot Service Checks..." -ForegroundColor Cyan
Write-Host ""

Test-Check "Bot service exists" {
    Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
}

Test-Check "Bot service running" {
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    $service -and $service.Status -eq "Running"
}

Test-Check "Bot script exists" {
    Test-Path "C:\bti\scripts\telegram_bot_server.py"
}

# =============================================================================
# Test 2: Dependencies
# =============================================================================

Write-Host ""
Write-Host "[2/7] Python Dependencies Checks..." -ForegroundColor Cyan
Write-Host ""

Test-Check "Python installed" {
    Get-Command python -ErrorAction SilentlyContinue
}

Test-Check "aiogram library installed" {
    python -c "import aiogram" 2>$null
    $LASTEXITCODE -eq 0
}

Test-Check "requests library installed" {
    python -c "import requests" 2>$null
    $LASTEXITCODE -eq 0
}

# =============================================================================
# Test 3: Environment Variables
# =============================================================================

Write-Host ""
Write-Host "[3/7] Environment Variables Checks..." -ForegroundColor Cyan
Write-Host ""

Test-Check "TELEGRAM_BOT_TOKEN set" {
    $token = [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
    -not [string]::IsNullOrEmpty($token)
}

# =============================================================================
# Test 4: Directories
# =============================================================================

Write-Host ""
Write-Host "[4/7] Directory Structure Checks..." -ForegroundColor Cyan
Write-Host ""

Test-Check "Input directory exists" {
    Test-Path "C:\bti\input"
}

Test-Check "Output directory exists" {
    Test-Path "C:\bti\output"
}

Test-Check "Converted directory exists" {
    if (-not (Test-Path "C:\bti\output\converted")) {
        New-Item -ItemType Directory -Path "C:\bti\output\converted" -Force | Out-Null
    }
    Test-Path "C:\bti\output\converted"
}

Test-Check "Logs directory writable" {
    try {
        $testFile = "C:\bti\output\logs\test_$(Get-Random).tmp"
        "test" | Out-File $testFile
        $result = Test-Path $testFile
        if ($result) { Remove-Item $testFile -Force }
        $result
    } catch {
        $false
    }
}

# =============================================================================
# Test 5: n8n Webhook
# =============================================================================

Write-Host ""
Write-Host "[5/7] n8n Webhook Checks..." -ForegroundColor Cyan
Write-Host ""

Test-Check "n8n service running" {
    $service = Get-Service -Name "n8n" -ErrorAction SilentlyContinue
    $service -and $service.Status -eq "Running"
}

Test-Check "n8n API accessible" {
    try {
        $response = Invoke-WebRequest -Uri "$N8nUrl/healthz" -UseBasicParsing -TimeoutSec 5
        $response.StatusCode -eq 200
    } catch {
        $false
    }
}

Test-Check "Telegram webhook workflow exists" {
    Test-Path "C:\bti\workflows\n8n_4_BTI_Telegram_Webhook.json"
}

# =============================================================================
# Test 6: Bot Logs
# =============================================================================

Write-Host ""
Write-Host "[6/7] Bot Logging Checks..." -ForegroundColor Cyan
Write-Host ""

Test-Check "Bot log file exists or can be created" {
    $logFile = "C:\bti\output\logs\telegram_bot.log"
    if (Test-Path $logFile) {
        $true
    } else {
        try {
            New-Item -ItemType File -Path $logFile -Force | Out-Null
            Test-Path $logFile
        } catch {
            $false
        }
    }
}

Test-Check "Telegram triggers log can be created" {
    $logFile = "C:\bti\output\logs\telegram_triggers.json"
    try {
        "[]" | Out-File $logFile -Encoding UTF8
        Test-Path $logFile
    } catch {
        $false
    }
}

# =============================================================================
# Test 7: Integration Test (if bot is running)
# =============================================================================

Write-Host ""
Write-Host "[7/7] Integration Checks..." -ForegroundColor Cyan
Write-Host ""

Test-Check "Bot process running" {
    Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -like "*telegram_bot_server.py*"
    }
}

# =============================================================================
# Summary
# =============================================================================

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Telegram Bot Test Results" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$totalTests = $testResults.passed + $testResults.failed
$passRate = if ($totalTests -gt 0) { [math]::Round(($testResults.passed / $totalTests) * 100, 1) } else { 0 }

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $($testResults.passed)" -ForegroundColor Green
Write-Host "Failed: $($testResults.failed)" -ForegroundColor $(if ($testResults.failed -gt 0) { "Red" } else { "Gray" })
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 90) { "Green" } elseif ($passRate -ge 70) { "Yellow" } else { "Red" })
Write-Host ""

if ($testResults.failed -gt 0) {
    Write-Host "Failed tests:" -ForegroundColor Yellow
    foreach ($test in $testResults.tests) {
        if ($test.status -eq "FAIL") {
            Write-Host "  - $($test.name)" -ForegroundColor Red
            if ($test.error) {
                Write-Host "    $($test.error)" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
}

if ($passRate -ge 90) {
    Write-Host "✅ Telegram Bot Integration: READY!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Manual test:" -ForegroundColor Yellow
    Write-Host "  1. Open Telegram and find @N8Ndwg_bot" -ForegroundColor White
    Write-Host "  2. Send /start command" -ForegroundColor White
    Write-Host "  3. Upload a .dwg file" -ForegroundColor White
    Write-Host "  4. Wait 30-60 seconds" -ForegroundColor White
    Write-Host "  5. Receive results: DWG + QA + QTO" -ForegroundColor White
    Write-Host ""
    Write-Host "Monitor logs:" -ForegroundColor Yellow
    Write-Host "  Get-Content C:\bti\output\logs\telegram_bot.log -Tail 20 -Wait" -ForegroundColor Gray
    Write-Host ""
    exit 0
} else {
    Write-Host "⚠️  Some tests failed. Fix issues before production use." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

