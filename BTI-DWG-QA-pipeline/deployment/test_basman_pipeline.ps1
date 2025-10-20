# =============================================================================
# BTI DWG QA Pipeline - Basmanny Template Test Suite
# =============================================================================
# Purpose: Comprehensive testing of Basmanny template application
# =============================================================================

param(
    [string]$N8nUrl = "http://localhost:5678",
    [string]$TestDwgPath = "C:\bti\input\test_basman_001.dwg",
    [switch]$AutoStart = $false
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  BTI DWG QA Pipeline - Basmanny Template Test Suite" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$BTI_BASE = "C:\bti"
$testResults = @{
    passed = 0
    failed = 0
    warnings = 0
    tests = @()
    start_time = Get-Date
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
            $testResults.tests += @{name=$Name; status="PASS"; message=""; timestamp=(Get-Date)}
            return $true
        } else {
            Write-Host "  ✗ FAIL: $Name" -ForegroundColor Red
            $testResults.failed++
            $testResults.tests += @{name=$Name; status="FAIL"; message="Test returned false"; timestamp=(Get-Date)}
            return $false
        }
    } catch {
        Write-Host "  ✗ FAIL: $Name - $($_.Exception.Message)" -ForegroundColor Red
        $testResults.failed++
        $testResults.tests += @{name=$Name; status="FAIL"; message=$_.Exception.Message; timestamp=(Get-Date)}
        return $false
    }
}

# =============================================================================
# Test 1: Templates Configuration
# =============================================================================

Write-Host "[1/10] Testing templates configuration..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Templates config exists" {
    Test-Path "$BTI_BASE\config\templates.json"
}

Test-Component "Templates config is valid JSON" {
    try {
        $config = Get-Content "$BTI_BASE\config\templates.json" -Raw | ConvertFrom-Json
        $config.templates.Basmanny -ne $null
    } catch {
        $false
    }
}

Test-Component "Basmanny template enabled" {
    $config = Get-Content "$BTI_BASE\config\templates.json" -Raw | ConvertFrom-Json
    $config.templates.Basmanny.enabled -eq $true
}

Test-Component "Basmanny template has required layers" {
    $config = Get-Content "$BTI_BASE\config\templates.json" -Raw | ConvertFrom-Json
    $layers = $config.templates.Basmanny.layers.PSObject.Properties.Name
    ("WALLS" -in $layers) -and ("DOORS" -in $layers) -and ("WINDOWS" -in $layers)
}

Write-Host ""

# =============================================================================
# Test 2: Template Application Script
# =============================================================================

Write-Host "[2/10] Testing template application script..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Template script exists" {
    Test-Path "$BTI_BASE\scripts\apply_basman_template.py"
}

Test-Component "Python is installed" {
    Get-Command python -ErrorAction SilentlyContinue
}

Write-Host ""

# =============================================================================
# Test 3: Auto-Start Workflow
# =============================================================================

Write-Host "[3/10] Testing auto-start workflow..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Auto-start workflow file exists" {
    Test-Path "$BTI_BASE\workflows\n8n_0_BTI_Watch_Input.json"
}

Test-Component "n8n service running" {
    $service = Get-Service -Name "n8n" -ErrorAction SilentlyContinue
    $service -and $service.Status -eq "Running"
}

Test-Component "n8n REST API accessible" {
    try {
        $response = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET -TimeoutSec 5
        $true
    } catch {
        $false
    }
}

Write-Host ""

# =============================================================================
# Test 4: Directory Structure for Basmanny
# =============================================================================

Write-Host "[4/10] Testing directory structure..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Input directory exists" {
    Test-Path "$BTI_BASE\input"
}

Test-Component "Output converted directory" {
    $dir = "$BTI_BASE\output\converted"
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Test-Path $dir
}

Test-Component "Output logs directory" {
    Test-Path "$BTI_BASE\output\logs"
}

Write-Host ""

# =============================================================================
# Test 5: Create Test DWG File
# =============================================================================

Write-Host "[5/10] Creating test DWG file..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Create test DWG file" {
    $testContent = @"
0
SECTION
2
HEADER
0
ENDSEC
0
SECTION
2
ENTITIES
0
LINE
8
WALLS
10
0.0
20
0.0
11
100.0
21
0.0
0
ENDSEC
0
EOF
"@
    try {
        $testContent | Out-File -FilePath $TestDwgPath -Encoding ASCII -Force
        Test-Path $TestDwgPath
    } catch {
        $false
    }
}

Write-Host ""

# =============================================================================
# Test 6: Apply Basmanny Template
# =============================================================================

Write-Host "[6/10] Testing template application..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Apply Basmanny template to test file" {
    try {
        $result = python "$BTI_BASE\scripts\apply_basman_template.py" $TestDwgPath 2>&1
        $LASTEXITCODE -eq 0
    } catch {
        $false
    }
}

Test-Component "Output file created" {
    $expectedOutput = "$BTI_BASE\output\converted\test_basman_001_basman.dwg"
    Test-Path $expectedOutput
}

Test-Component "Template result log created" {
    Test-Path "$BTI_BASE\output\logs\template_results.json"
}

Write-Host ""

# =============================================================================
# Test 7: Validation Rules for Basmanny
# =============================================================================

Write-Host "[7/10] Testing validation rules..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Validation rules include Basmanny requirements" {
    $config = Get-Content "$BTI_BASE\config\templates.json" -Raw | ConvertFrom-Json
    $rules = $config.templates.Basmanny.validation_rules
    ($rules.required_layers.Count -ge 4)
}

Test-Component "Coordinate system defined" {
    $config = Get-Content "$BTI_BASE\config\templates.json" -Raw | ConvertFrom-Json
    $rules = $config.templates.Basmanny.validation_rules
    $rules.coordinate_system -eq "MSK-Moscow"
}

Write-Host ""

# =============================================================================
# Test 8: Telegram Integration
# =============================================================================

Write-Host "[8/10] Testing Telegram integration..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Telegram script exists" {
    Test-Path "$BTI_BASE\scripts\send_telegram_report.py"
}

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
# Test 9: Cloud Logging
# =============================================================================

Write-Host "[9/10] Testing Cloud Logging..." -ForegroundColor Cyan
Write-Host ""

Test-Component "Ops Agent service running" {
    $service = Get-Service -Name "google-cloud-ops-agent" -ErrorAction SilentlyContinue
    $service -and $service.Status -eq "Running"
}

Test-Component "Ops Agent config exists" {
    Test-Path "C:\ProgramData\Google\Cloud Operations\Ops Agent\config\config.yaml"
}

Test-Component "Log files being created" {
    (Get-ChildItem "$BTI_BASE\output\logs\*.json" -ErrorAction SilentlyContinue).Count -gt 0
}

Write-Host ""

# =============================================================================
# Test 10: Auto-Start Test (if enabled)
# =============================================================================

if ($AutoStart) {
    Write-Host "[10/10] Testing auto-start functionality..." -ForegroundColor Cyan
    Write-Host ""
    
    Test-Component "Copy test file to input folder" {
        $autoTestFile = "$BTI_BASE\input\auto_test_$(Get-Date -Format 'yyyyMMddHHmmss').dwg"
        Copy-Item $TestDwgPath $autoTestFile -Force
        Test-Path $autoTestFile
    }
    
    Write-Host "  Waiting 10 seconds for auto-processing..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
    
    Test-Component "Auto-start log created" {
        Test-Path "$BTI_BASE\output\logs\auto_start.json"
    }
} else {
    Write-Host "[10/10] Auto-start test skipped (use -AutoStart to enable)" -ForegroundColor Gray
    Write-Host ""
}

# =============================================================================
# Test Results Summary
# =============================================================================

$testResults.end_time = Get-Date
$duration = ($testResults.end_time - $testResults.start_time).TotalSeconds

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Basmanny Template Test Results" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$totalTests = $testResults.passed + $testResults.failed
$passRate = if ($totalTests -gt 0) { [math]::Round(($testResults.passed / $totalTests) * 100, 1) } else { 0 }

Write-Host "Test Duration: $([math]::Round($duration, 1)) seconds" -ForegroundColor White
Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $($testResults.passed)" -ForegroundColor Green
Write-Host "Failed: $($testResults.failed)" -ForegroundColor $(if ($testResults.failed -gt 0) { "Red" } else { "Gray" })
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 90) { "Green" } elseif ($passRate -ge 70) { "Yellow" } else { "Red" })
Write-Host ""

# Save results to JSON
$resultsFile = "$BTI_BASE\output\logs\basman_test_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$testResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsFile -Encoding UTF8
Write-Host "Results saved to: $resultsFile" -ForegroundColor Gray
Write-Host ""

# Overall status
if ($testResults.failed -eq 0) {
    Write-Host "✓ ALL BASMANNY TESTS PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Basmanny template is ready for production!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Import n8n_0_BTI_Watch_Input.json to n8n" -ForegroundColor White
    Write-Host "  2. Activate auto-start workflow" -ForegroundColor White
    Write-Host "  3. Place DWG files in: $BTI_BASE\input\" -ForegroundColor White
    Write-Host "  4. Monitor logs in: $BTI_BASE\output\logs\" -ForegroundColor White
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
    Write-Host "Please fix the issues and run the test again." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

