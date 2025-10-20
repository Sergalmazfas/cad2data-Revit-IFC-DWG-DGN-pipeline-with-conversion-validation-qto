# =============================================================================
# BTI DWG QA Pipeline - Comprehensive Deployment Verification
# =============================================================================
# Purpose: Verify complete production deployment with detailed reporting
# =============================================================================

param(
    [string]$N8nUrl = "http://localhost:5678",
    [switch]$RunFullTest = $false,
    [string]$ReportPath = "C:\bti\output\logs\deployment_verification_report.json"
)

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  BTI DWG QA Pipeline - Production Deployment Verification" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "Instance: instance-20251019-062935" -ForegroundColor White
Write-Host "Project: swiftchair" -ForegroundColor White
Write-Host ""

$verificationStart = Get-Date
$results = @{
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    instance = "instance-20251019-062935"
    project = "swiftchair"
    version = "1.0.0-basman"
    categories = @{}
    overall_status = "in_progress"
    total_checks = 0
    passed_checks = 0
    failed_checks = 0
    warnings = @()
}

# =============================================================================
# Helper Function
# =============================================================================

function Test-Check {
    param(
        [string]$Category,
        [string]$Name,
        [scriptblock]$Test,
        [string]$FailureMessage = ""
    )
    
    if (-not $results.categories.ContainsKey($Category)) {
        $results.categories[$Category] = @{
            checks = @()
            passed = 0
            failed = 0
        }
    }
    
    Write-Host "  Testing: $Name..." -NoNewline
    
    try {
        $testResult = & $Test
        if ($testResult) {
            Write-Host " ✅ PASS" -ForegroundColor Green
            $results.categories[$Category].checks += @{
                name = $Name
                status = "PASS"
                message = ""
            }
            $results.categories[$Category].passed++
            $results.passed_checks++
        } else {
            Write-Host " ❌ FAIL" -ForegroundColor Red
            $results.categories[$Category].checks += @{
                name = $Name
                status = "FAIL"
                message = $FailureMessage
            }
            $results.categories[$Category].failed++
            $results.failed_checks++
        }
    } catch {
        Write-Host " ❌ FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $results.categories[$Category].checks += @{
            name = $Name
            status = "FAIL"
            message = $_.Exception.Message
        }
        $results.categories[$Category].failed++
        $results.failed_checks++
    }
    
    $results.total_checks++
}

# =============================================================================
# Category 1: Windows Environment (10 checks)
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[1/9] Windows Environment Checks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-Check "Environment" "Windows Server 2025 Core" {
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $os.Caption -like "*Windows Server*"
}

Test-Check "Environment" "PowerShell version >= 5" {
    $PSVersionTable.PSVersion.Major -ge 5
}

Test-Check "Environment" "BTI base directory exists" {
    Test-Path "C:\bti"
}

Test-Check "Environment" "Input directory exists" {
    Test-Path "C:\bti\input"
}

Test-Check "Environment" "Output directory exists" {
    Test-Path "C:\bti\output"
}

Test-Check "Environment" "Logs directory exists" {
    Test-Path "C:\bti\output\logs"
}

Test-Check "Environment" "Scripts directory exists" {
    Test-Path "C:\bti\scripts"
}

Test-Check "Environment" "Config directory exists" {
    Test-Path "C:\bti\config"
}

Test-Check "Environment" "Workflows directory exists" {
    Test-Path "C:\bti\workflows"
}

Test-Check "Environment" "Templates directory exists" {
    Test-Path "C:\bti\templates"
}

# =============================================================================
# Category 2: Software Installation (8 checks)
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[2/9] Software Installation Checks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-Check "Software" "Node.js installed" {
    Get-Command node -ErrorAction SilentlyContinue
}

Test-Check "Software" "Node.js version >= 20" {
    $version = node --version
    [int]($version -replace 'v|\..*') -ge 20
}

Test-Check "Software" "npm installed" {
    Get-Command npm -ErrorAction SilentlyContinue
}

Test-Check "Software" "n8n installed" {
    Get-Command n8n -ErrorAction SilentlyContinue
}

Test-Check "Software" "Python installed" {
    Get-Command python -ErrorAction SilentlyContinue
}

Test-Check "Software" "gcloud SDK installed" {
    Get-Command gcloud -ErrorAction SilentlyContinue
}

Test-Check "Software" "NSSM installed" {
    Test-Path "C:\nssm\nssm-2.24\win64\nssm.exe"
}

Test-Check "Software" "Python requests library" {
    python -c "import requests" 2>$null
    $LASTEXITCODE -eq 0
}

# =============================================================================
# Category 3: Windows Services (4 checks)
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[3/9] Windows Services Checks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-Check "Services" "n8n service exists" {
    Get-Service -Name "n8n" -ErrorAction SilentlyContinue
}

Test-Check "Services" "n8n service running" {
    $service = Get-Service -Name "n8n" -ErrorAction SilentlyContinue
    $service -and $service.Status -eq "Running"
}

Test-Check "Services" "Ops Agent service exists" {
    Get-Service -Name "google-cloud-ops-agent" -ErrorAction SilentlyContinue
}

Test-Check "Services" "Ops Agent service running" {
    $service = Get-Service -Name "google-cloud-ops-agent" -ErrorAction SilentlyContinue
    $service -and $service.Status -eq "Running"
}

# =============================================================================
# Category 4: Basmanny Template (6 checks)
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[4/9] Basmanny Template Checks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-Check "Basmanny" "Template DWG file exists" {
    Test-Path "C:\bti\templates\BasmanTitleBlock.dwg"
}

Test-Check "Basmanny" "Template file size > 0" {
    $file = Get-Item "C:\bti\templates\BasmanTitleBlock.dwg" -ErrorAction SilentlyContinue
    $file -and $file.Length -gt 0
}

Test-Check "Basmanny" "templates.json exists" {
    Test-Path "C:\bti\config\templates.json"
}

Test-Check "Basmanny" "Basmanny template configured" {
    $config = Get-Content "C:\bti\config\templates.json" -Raw | ConvertFrom-Json
    $config.templates.Basmanny -ne $null
}

Test-Check "Basmanny" "Basmanny template enabled" {
    $config = Get-Content "C:\bti\config\templates.json" -Raw | ConvertFrom-Json
    $config.templates.Basmanny.enabled -eq $true
}

Test-Check "Basmanny" "Template script exists" {
    Test-Path "C:\bti\scripts\apply_basman_template.py"
}

# =============================================================================
# Category 5: n8n Workflows (5 checks)
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[5/9] n8n Workflows Checks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-Check "Workflows" "n8n API accessible" {
    try {
        $response = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET -TimeoutSec 5
        $true
    } catch {
        $false
    }
}

Test-Check "Workflows" "Auto-start workflow imported" {
    try {
        $workflows = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET -TimeoutSec 5
        ($workflows | Where-Object { $_.name -like "*Watch*Input*" }).Count -gt 0
    } catch {
        $false
    }
}

Test-Check "Workflows" "Convert workflow imported" {
    try {
        $workflows = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET -TimeoutSec 5
        ($workflows | Where-Object { $_.name -like "*Convert*" }).Count -gt 0
    } catch {
        $false
    }
}

Test-Check "Workflows" "Validation workflow imported" {
    try {
        $workflows = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET -TimeoutSec 5
        ($workflows | Where-Object { $_.name -like "*Validation*" }).Count -gt 0
    } catch {
        $false
    }
}

Test-Check "Workflows" "QTO workflow imported" {
    try {
        $workflows = Invoke-RestMethod -Uri "$N8nUrl/rest/workflows" -Method GET -TimeoutSec 5
        ($workflows | Where-Object { $_.name -like "*QTO*" }).Count -gt 0
    } catch {
        $false
    }
}

# =============================================================================
# Category 6: Secret Manager & Environment (3 checks)
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[6/9] Secret Manager & Environment Checks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-Check "Secrets" "TELEGRAM_BOT_TOKEN configured" {
    $token = [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
    -not [string]::IsNullOrEmpty($token) -and $token.Length -gt 20
}

Test-Check "Secrets" "TELEGRAM_CHAT_ID configured" {
    $chatId = [Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "Machine")
    -not [string]::IsNullOrEmpty($chatId)
}

Test-Check "Secrets" "Telegram script exists" {
    Test-Path "C:\bti\scripts\send_telegram_report.py"
}

# =============================================================================
# Category 7: Network & Firewall (5 checks)
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[7/9] Network & Firewall Checks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-Check "Network" "n8n web UI responding" {
    try {
        $response = Invoke-WebRequest -Uri "$N8nUrl/healthz" -UseBasicParsing -TimeoutSec 5
        $response.StatusCode -eq 200
    } catch {
        $false
    }
}

Test-Check "Network" "Windows Firewall rule exists" {
    Get-NetFirewallRule -DisplayName "n8n BTI Pipeline" -ErrorAction SilentlyContinue
}

Test-Check "Network" "GCP firewall rule exists" {
    $rule = gcloud compute firewall-rules describe allow-n8n-5678 2>$null
    $LASTEXITCODE -eq 0
}

Test-Check "Network" "Telegram API reachable" {
    try {
        $response = Invoke-WebRequest -Uri "https://api.telegram.org" -UseBasicParsing -TimeoutSec 5
        $response.StatusCode -eq 200
    } catch {
        $false
    }
}

Test-Check "Network" "Serial Port 1 enabled" {
    $metadata = gcloud compute instances describe instance-20251019-062935 --zone=us-central1-f --format="get(metadata.items[serial-port-enable])" 2>$null
    $metadata -eq "TRUE"
}

# =============================================================================
# Category 8: Cloud Logging (4 checks)
# =============================================================================

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "[8/9] Cloud Logging Checks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

Test-Check "Logging" "Ops Agent config exists" {
    Test-Path "C:\ProgramData\Google\Cloud Operations\Ops Agent\config\config.yaml"
}

Test-Check "Logging" "Ops Agent config valid" {
    try {
        $config = Get-Content "C:\ProgramData\Google\Cloud Operations\Ops Agent\config\config.yaml" -Raw
        $config -match "bti_qa_json_logs"
    } catch {
        $false
    }
}

Test-Check "Logging" "Log directory writable" {
    try {
        $testFile = "C:\bti\output\logs\test_write_$(Get-Random).tmp"
        "test" | Out-File $testFile
        $result = Test-Path $testFile
        if ($result) { Remove-Item $testFile -Force }
        $result
    } catch {
        $false
    }
}

Test-Check "Logging" "Log files present" {
    (Get-ChildItem "C:\bti\output\logs\*" -ErrorAction SilentlyContinue).Count -gt 0
}

# =============================================================================
# Category 9: End-to-End Test (if requested)
# =============================================================================

if ($RunFullTest) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "[9/9] End-to-End Pipeline Test" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

    # Create test DWG
    $testDwg = "C:\bti\input\verification_test_$(Get-Date -Format 'yyyyMMddHHmmss').dwg"
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
    
    Test-Check "E2E" "Create test DWG file" {
        try {
            $testContent | Out-File -FilePath $testDwg -Encoding ASCII
            Test-Path $testDwg
        } catch {
            $false
        }
    }
    
    Write-Host "  Waiting 30 seconds for auto-processing..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    Test-Check "E2E" "Template applied (output exists)" {
        (Get-ChildItem "C:\bti\output\converted\verification_test_*_basman.dwg" -ErrorAction SilentlyContinue).Count -gt 0
    }
    
    Test-Check "E2E" "XLSX generated" {
        (Get-ChildItem "C:\bti\output\verification_test_*_dwg.xlsx" -ErrorAction SilentlyContinue).Count -gt 0
    }
    
    Test-Check "E2E" "QA log created" {
        Test-Path "C:\bti\output\logs\qa_log.json"
    }
    
    Test-Check "E2E" "Auto-start log updated" {
        Test-Path "C:\bti\output\logs\auto_start.json"
    }
} else {
    Write-Host ""
    Write-Host "[9/9] End-to-End Test: SKIPPED (use -RunFullTest to enable)" -ForegroundColor Gray
}

# =============================================================================
# Summary Report
# =============================================================================

$verificationEnd = Get-Date
$duration = ($verificationEnd - $verificationStart).TotalSeconds

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Verification Results" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$passRate = if ($results.total_checks -gt 0) { 
    [math]::Round(($results.passed_checks / $results.total_checks) * 100, 1) 
} else { 0 }

Write-Host "Duration: $([math]::Round($duration, 1)) seconds" -ForegroundColor White
Write-Host "Total Checks: $($results.total_checks)" -ForegroundColor White
Write-Host "Passed: $($results.passed_checks)" -ForegroundColor Green
Write-Host "Failed: $($results.failed_checks)" -ForegroundColor $(if ($results.failed_checks -gt 0) { "Red" } else { "Gray" })
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 95) { "Green" } elseif ($passRate -ge 80) { "Yellow" } else { "Red" })
Write-Host ""

# Category breakdown
Write-Host "Results by category:" -ForegroundColor Yellow
foreach ($category in $results.categories.Keys | Sort-Object) {
    $catData = $results.categories[$category]
    $catPassRate = if ($catData.checks.Count -gt 0) { 
        [math]::Round(($catData.passed / $catData.checks.Count) * 100, 0) 
    } else { 0 }
    
    $statusColor = if ($catPassRate -eq 100) { "Green" } elseif ($catPassRate -ge 80) { "Yellow" } else { "Red" }
    Write-Host "  $category`: $($catData.passed)/$($catData.checks.Count) ($catPassRate%)" -ForegroundColor $statusColor
}

# Failed checks detail
if ($results.failed_checks -gt 0) {
    Write-Host ""
    Write-Host "Failed checks:" -ForegroundColor Red
    foreach ($category in $results.categories.Keys) {
        foreach ($check in $results.categories[$category].checks) {
            if ($check.status -eq "FAIL") {
                Write-Host "  - [$category] $($check.name)" -ForegroundColor Red
                if ($check.message) {
                    Write-Host "    $($check.message)" -ForegroundColor Gray
                }
            }
        }
    }
}

# Overall status
if ($passRate -ge 95) {
    $results.overall_status = "PASS"
    Write-Host ""
    Write-Host "✅ DEPLOYMENT VERIFICATION PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "BTI DWG QA Pipeline is production-ready!" -ForegroundColor Cyan
} elseif ($passRate -ge 80) {
    $results.overall_status = "WARNING"
    Write-Host ""
    Write-Host "⚠️  DEPLOYMENT VERIFICATION PASSED WITH WARNINGS" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Review failed checks before production use." -ForegroundColor Yellow
} else {
    $results.overall_status = "FAIL"
    Write-Host ""
    Write-Host "❌ DEPLOYMENT VERIFICATION FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host "Fix critical issues before production use." -ForegroundColor Red
}

# Save report
$results.duration_seconds = $duration
$results | ConvertTo-Json -Depth 10 | Out-File $ReportPath -Encoding UTF8

Write-Host ""
Write-Host "Verification report saved: $ReportPath" -ForegroundColor Gray
Write-Host ""

# Next steps
if ($results.overall_status -eq "PASS") {
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Activate auto-start workflow in n8n" -ForegroundColor White
    Write-Host "  2. Place DWG files in C:\bti\input\" -ForegroundColor White
    Write-Host "  3. Monitor Telegram for notifications" -ForegroundColor White
    Write-Host "  4. Check Cloud Logging for detailed logs" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "Required actions:" -ForegroundColor Yellow
    Write-Host "  1. Fix failed checks listed above" -ForegroundColor White
    Write-Host "  2. Re-run verification: .\verify_deployment.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

