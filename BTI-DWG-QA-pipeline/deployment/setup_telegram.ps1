# =============================================================================
# BTI DWG QA Pipeline - Telegram Bot Integration
# =============================================================================
# Purpose: Create Python script for Telegram notifications
# =============================================================================

param(
    [string]$ScriptsPath = "C:\bti\scripts"
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Telegram Bot Integration for BTI DWG QA Pipeline" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# 1. Check Python Installation
# =============================================================================

Write-Host "[1/3] Checking Python installation..." -ForegroundColor Yellow

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "  Python not found. Installing Python..." -ForegroundColor Gray
    
    # Download Python installer
    $pythonInstaller = "C:\bti\temp\python-installer.exe"
    Invoke-WebRequest `
        -Uri "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe" `
        -OutFile $pythonInstaller `
        -UseBasicParsing
    
    # Install Python (silent, add to PATH)
    Start-Process $pythonInstaller `
        -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" `
        -Wait -NoNewWindow
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    Write-Host "  Python installed" -ForegroundColor Green
} else {
    $pythonVersion = python --version
    Write-Host "  Python already installed: $pythonVersion" -ForegroundColor Gray
}

# =============================================================================
# 2. Install requests library
# =============================================================================

Write-Host "[2/3] Installing Python requests library..." -ForegroundColor Yellow

try {
    python -m pip install --quiet --upgrade requests
    Write-Host "  requests library installed" -ForegroundColor Green
} catch {
    Write-Host "  WARNING: Failed to install requests library" -ForegroundColor Yellow
}

# =============================================================================
# 3. Create Telegram Notification Script
# =============================================================================

Write-Host "[3/3] Creating Telegram notification script..." -ForegroundColor Yellow

$telegramScript = @"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BTI DWG QA Pipeline - Telegram Notification Script
Sends QA validation reports to Telegram via bot
"""

import os
import json
import sys
from datetime import datetime

try:
    import requests
except ImportError:
    print("ERROR: requests library not installed. Run: pip install requests")
    sys.exit(1)

# =============================================================================
# Configuration from Environment Variables
# =============================================================================

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")
LOG_FILE = r"C:\bti\output\logs\qa_log.json"

if not TOKEN:
    print("ERROR: TELEGRAM_BOT_TOKEN environment variable not set")
    sys.exit(1)

if not CHAT_ID:
    print("ERROR: TELEGRAM_CHAT_ID environment variable not set")
    sys.exit(1)

# =============================================================================
# Read QA Log
# =============================================================================

def read_qa_log():
    """Read the latest QA log file"""
    try:
        with open(LOG_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data
    except FileNotFoundError:
        print(f"ERROR: Log file not found: {LOG_FILE}")
        return None
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in log file: {e}")
        return None

# =============================================================================
# Format Report Message
# =============================================================================

def format_report(data):
    """Format QA data into Telegram message"""
    
    # Extract data
    project_info = data.get("project_info", {})
    conversion = data.get("conversion", {})
    validation = data.get("validation", {})
    qto_metrics = data.get("qto_metrics", {})
    final_status = data.get("final_status", "unknown")
    
    # Status emoji
    status_emoji = {
        "success": "✅",
        "failed": "❌",
        "warning": "⚠️",
        "in_progress": "🔄",
        "pending": "⏳"
    }
    
    conv_emoji = status_emoji.get(conversion.get("status", "pending"), "❓")
    val_emoji = status_emoji.get(validation.get("status", "pending"), "❓")
    
    # Build message
    message_parts = [
        "📋 <b>BTI DWG QA REPORT</b>",
        "",
        f"<b>Project:</b> {project_info.get('project_name', 'Unknown')}",
        f"<b>File:</b> <code>{project_info.get('dwg_file', 'N/A')}</code>",
        "",
        f"<b>CONVERSION</b> {conv_emoji}",
        f"• Status: {conversion.get('status', 'pending')}",
        f"• Output: {conversion.get('output_file', 'N/A')}",
    ]
    
    if conversion.get("notes"):
        for note in conversion["notes"]:
            message_parts.append(f"• Note: {note}")
    
    message_parts.extend([
        "",
        f"<b>VALIDATION</b> {val_emoji}",
        f"• Pass Rate: {validation.get('pass_rate', 0)}%",
        f"• Total Entities: {validation.get('total_entities', 0)}",
        f"• Failed: {validation.get('failed_entities', 0)}",
        f"• Warnings: {validation.get('warnings_count', 0)}",
    ])
    
    # Issues
    issues = validation.get("issues", [])
    if issues:
        message_parts.append("")
        message_parts.append("<b>Issues:</b>")
        for issue in issues[:5]:  # Show only first 5
            message_parts.append(f"  • {issue}")
        if len(issues) > 5:
            message_parts.append(f"  ... and {len(issues) - 5} more")
    
    # QTO Metrics
    if qto_metrics:
        message_parts.extend([
            "",
            f"<b>QTO METRICS</b> 📊",
            f"• Area: {qto_metrics.get('total_area_m2', 0):.2f} m²",
            f"• Perimeter: {qto_metrics.get('total_perimeter_m', 0):.2f} m",
            f"• Windows: {qto_metrics.get('windows_count', 0)}",
            f"• Doors: {qto_metrics.get('doors_count', 0)}",
        ])
    
    # Final status
    final_emoji = status_emoji.get(final_status, "❓")
    message_parts.extend([
        "",
        f"<b>Final Status:</b> {final_status.upper()} {final_emoji}",
        f"<b>Time:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
    ])
    
    return "\n".join(message_parts)

# =============================================================================
# Send to Telegram
# =============================================================================

def send_telegram_message(text):
    """Send message to Telegram via bot API"""
    url = f"https://api.telegram.org/bot{TOKEN}/sendMessage"
    
    payload = {
        "chat_id": CHAT_ID,
        "text": text,
        "parse_mode": "HTML",
        "disable_web_page_preview": True
    }
    
    try:
        response = requests.post(url, json=payload, timeout=10)
        response.raise_for_status()
        
        result = response.json()
        if result.get("ok"):
            print("✓ Message sent successfully to Telegram")
            return True
        else:
            print(f"✗ Telegram API error: {result.get('description', 'Unknown error')}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"✗ Failed to send message: {e}")
        return False

# =============================================================================
# Main
# =============================================================================

def main():
    print("BTI DWG QA Pipeline - Telegram Notification")
    print("=" * 60)
    
    # Read log
    print(f"Reading log file: {LOG_FILE}")
    data = read_qa_log()
    if not data:
        sys.exit(1)
    
    # Format message
    print("Formatting report...")
    message = format_report(data)
    
    # Send to Telegram
    print(f"Sending to Telegram chat: {CHAT_ID}")
    success = send_telegram_message(message)
    
    if success:
        print("Report sent successfully!")
        sys.exit(0)
    else:
        print("Failed to send report")
        sys.exit(1)

if __name__ == "__main__":
    main()
"@

# Write script
$telegramScriptPath = Join-Path $ScriptsPath "send_telegram_report.py"
$telegramScript | Out-File -FilePath $telegramScriptPath -Encoding utf8 -Force

Write-Host "  Created: $telegramScriptPath" -ForegroundColor Green

# =============================================================================
# 4. Test Script (if secrets are available)
# =============================================================================

Write-Host ""
Write-Host "Testing Telegram configuration..." -ForegroundColor Yellow

$token = [Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
$chatId = [Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "Machine")

if ($token -and $chatId) {
    Write-Host "  ✓ TELEGRAM_BOT_TOKEN: configured" -ForegroundColor Green
    Write-Host "  ✓ TELEGRAM_CHAT_ID: configured" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "  Sending test message..." -ForegroundColor Gray
    
    # Send test message
    $testMessage = @{
        chat_id = $chatId
        text = "🚀 BTI DWG QA Pipeline deployment complete!`n`nTelegram notifications are now active.`n`nTime: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod `
            -Uri "https://api.telegram.org/bot$token/sendMessage" `
            -Method POST `
            -ContentType "application/json; charset=utf-8" `
            -Body $testMessage
        
        if ($response.ok) {
            Write-Host "  ✓ Test message sent successfully!" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ✗ Failed to send test message" -ForegroundColor Yellow
        Write-Host "    Check bot token and chat ID" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ Environment variables not set" -ForegroundColor Yellow
    Write-Host "    Run setup_secrets.ps1 first" -ForegroundColor Gray
}

# =============================================================================
# Summary
# =============================================================================

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Telegram Integration Complete!" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files created:" -ForegroundColor Yellow
Write-Host "  ✓ $telegramScriptPath" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  python $telegramScriptPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Integration:" -ForegroundColor Yellow
Write-Host "  Add to n8n workflow:" -ForegroundColor White
Write-Host "  Execute Command node → python $telegramScriptPath" -ForegroundColor Gray
Write-Host ""

