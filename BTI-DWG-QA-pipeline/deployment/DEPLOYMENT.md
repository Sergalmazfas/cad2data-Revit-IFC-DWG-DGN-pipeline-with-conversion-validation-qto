# BTI DWG QA Pipeline - Deployment Guide

## 📋 Overview

Complete deployment guide for BTI DWG QA Pipeline on **Windows Server 2025 Core** running on **Google Compute Engine**.

**Target Instance:**
- Name: `instance-20251019-062935`
- Machine Type: `n2-standard-2`
- OS: Windows Server 2025 Core
- Zone: `us-central1-f`
- Project: `swiftchair`

---

## 🎯 What Will Be Deployed

| Component | Description | Port/Path |
|-----------|-------------|-----------|
| **n8n** | Workflow automation | Port 5678 |
| **Node.js** | Runtime environment | - |
| **Google Cloud SDK** | gcloud CLI | - |
| **Google Cloud Ops Agent** | Log collection | - |
| **Telegram Bot** | Notifications via @N8Ndwg_bot | - |
| **BTI Workflows** | 3 n8n workflows (Convert, Validate, QTO) | C:\bti\workflows |
| **Scripts** | Python & JavaScript utilities | C:\bti\scripts |

---

## 📁 Directory Structure

```
C:\bti\
├── input\                      # Input DWG files
├── output\                     # Output XLSX, JSON, HTML
│   └── logs\                   # QA logs (JSON, TXT)
├── scripts\                    # Automation scripts
│   ├── qa_logger.js
│   ├── dwg_validator.js
│   └── send_telegram_report.py
├── config\                     # Configuration files
│   ├── validation_rules.json
│   ├── converter_settings.json
│   └── qa_log_template.json
├── workflows\                  # n8n workflows
│   ├── n8n_1_BTI_Convert.json
│   ├── n8n_2_BTI_Validation.json
│   └── n8n_3_BTI_QTO.json
└── temp\                       # Temporary files
```

---

## ⚙️ Prerequisites

### 1. Google Cloud Permissions

Ensure your service account has these IAM roles:

```bash
# Required roles
roles/secretmanager.secretAccessor     # Read secrets
roles/logging.logWriter                # Write logs
roles/monitoring.metricWriter          # Write metrics
roles/compute.instanceAdmin            # Manage instance
```

### 2. Secret Manager Secrets

Create these secrets in Google Secret Manager:

```bash
# Create TELEGRAM_BOT_TOKEN
echo "YOUR_BOT_TOKEN" | gcloud secrets create TELEGRAM_BOT_TOKEN \
    --data-file=- \
    --replication-policy="automatic"

# Create TELEGRAM_CHAT_ID
echo "YOUR_CHAT_ID" | gcloud secrets create TELEGRAM_CHAT_ID \
    --data-file=- \
    --replication-policy="automatic"
```

### 3. Clone Repository

```powershell
# On the Windows VM
cd C:\Users\Administrator
git clone https://github.com/datadrivenconstruction/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git
```

---

## 🚀 Deployment Steps

### Step 1: Main Deployment (10-15 minutes)

```powershell
# Navigate to deployment scripts
cd C:\Users\Administrator\cad2data-*\BTI-DWG-QA-pipeline\deployment

# Run main deployment script
.\deploy_bti_pipeline.ps1
```

**What it does:**
- ✅ Creates directory structure
- ✅ Copies project files
- ✅ Installs Node.js LTS (v20.17.0)
- ✅ Installs n8n globally
- ✅ Installs NSSM (service manager)
- ✅ Creates n8n Windows Service
- ✅ Installs Google Cloud SDK
- ✅ Retrieves secrets from Secret Manager
- ✅ Starts n8n service

**Output:**
```
[1/9] Creating directory structure...
[2/9] Copying project files...
[3/9] Installing Node.js...
[4/9] Installing n8n...
[5/9] Installing NSSM...
[6/9] Creating n8n Windows Service...
[7/9] Configuring Google Cloud SDK...
[8/9] Retrieving secrets...
[9/9] Starting n8n service...

Deployment Complete!
```

---

### Step 2: Configure Firewall (2-3 minutes)

```powershell
.\setup_firewall.ps1
```

**What it does:**
- ✅ Creates GCP firewall rule (`allow-n8n-5678`)
- ✅ Adds network tag to instance (`n8n`)
- ✅ Creates Windows Firewall rule

**Output:**
```
[1/3] Creating GCP firewall rule...
[2/3] Adding network tag to instance...
[3/3] Creating Windows Firewall rule...

n8n is now accessible at:
  External: http://104.198.201.212:5678
```

---

### Step 3: Configure Cloud Logging (3-5 minutes)

```powershell
.\setup_logging.ps1
```

**What it does:**
- ✅ Installs Google Cloud Ops Agent
- ✅ Creates Ops Agent configuration (YAML)
- ✅ Configures log collectors for:
  - `C:\bti\output\logs\*.json`
  - `C:\bti\output\logs\*.txt`
  - Windows Event Logs
- ✅ Restarts Ops Agent service
- ✅ Enables Serial Port 1

**Output:**
```
[1/4] Installing Google Cloud Ops Agent...
[2/4] Creating Ops Agent configuration...
[3/4] Restarting Ops Agent...
[4/4] Enabling Serial Port 1...

View logs at:
  https://console.cloud.google.com/logs/query?project=swiftchair
```

---

### Step 4: Import n8n Workflows (1-2 minutes)

```powershell
.\import_workflows.ps1
```

**What it does:**
- ✅ Waits for n8n to be ready
- ✅ Imports 3 workflows via REST API:
  - `n8n_1_BTI_Convert.json`
  - `n8n_2_BTI_Validation.json`
  - `n8n_3_BTI_QTO.json`

**Output:**
```
[0/3] Waiting for n8n to be ready...
[1/3] Importing n8n_1_BTI_Convert.json...
  ✓ Imported: BTI_1_DWG_Convert (ID: 1)
[2/3] Importing n8n_2_BTI_Validation.json...
  ✓ Imported: BTI_2_DWG_Validation (ID: 2)
[3/3] Importing n8n_3_BTI_QTO.json...
  ✓ Imported: BTI_3_DWG_QTO (ID: 3)

Import Summary:
  ✓ Imported: 3 workflows
```

---

### Step 5: Setup Telegram Integration (2-3 minutes)

```powershell
.\setup_telegram.ps1
```

**What it does:**
- ✅ Installs Python (if not installed)
- ✅ Installs `requests` library
- ✅ Creates Telegram notification script
- ✅ Sends test message to @N8Ndwg_bot

**Output:**
```
[1/3] Checking Python installation...
[2/3] Installing Python requests library...
[3/3] Creating Telegram notification script...

Testing Telegram configuration...
  ✓ Test message sent successfully!
```

---

### Step 6: Run Smoke Test (1-2 minutes)

```powershell
.\smoke_test.ps1
```

**What it does:**
- ✅ Tests directory structure (7 tests)
- ✅ Tests required files (5 tests)
- ✅ Tests software installation (5 tests)
- ✅ Tests Windows services (4 tests)
- ✅ Tests environment variables (2 tests)
- ✅ Tests network connectivity (3 tests)
- ✅ Tests firewall rules (2 tests)
- ✅ Tests Cloud Logging (1 test)
- ✅ Tests n8n workflows (1 test)

**Output:**
```
==============================================================================
  Smoke Test Results
==============================================================================

Total Tests: 30
Passed: 30
Failed: 0
Pass Rate: 100%

✓ ALL TESTS PASSED!

BTI DWG QA Pipeline is ready to use!
```

---

## 🔧 Configuration

### Update DWG Converter Path

After deployment, update the DWG converter path in n8n workflows:

1. Open n8n Web UI: `http://104.198.201.212:5678`
2. Open workflow: `BTI_1_DWG_Convert`
3. Edit node: `Setup - Define DWG Paths`
4. Update:
   ```javascript
   path_to_dwg_converter: "C:\\DDC_CONVERTER_DWG\\datadrivenlibs\\DwgExporter.exe"
   ```
5. Save workflow

### Update Validation Rules

Edit `C:\bti\config\validation_rules.json`:

```json
{
  "rules": {
    "required_layers": ["WALLS", "WINDOWS", "DOORS", "ROOMS"],
    "entity_checks": {
      "area_min": 0.1,
      "area_max": 10000
    }
  }
}
```

---

## 📊 Usage

### Manual Workflow Execution

1. Place DWG file in `C:\bti\input\`
2. Open n8n: `http://104.198.201.212:5678`
3. Execute workflows in order:
   - `BTI_1_DWG_Convert` → generates XLSX
   - `BTI_2_BTI_Validation` → validates data, sends Telegram
   - `BTI_3_BTI_QTO` → generates HTML report

### API Workflow Execution

```powershell
# Trigger workflow via API
$workflowId = "1"  # BTI_1_DWG_Convert
$apiUrl = "http://localhost:5678/webhook/$workflowId"

Invoke-RestMethod -Uri $apiUrl -Method POST -Body @{
    dwg_file = "C:\bti\input\test.dwg"
} -ContentType "application/json"
```

---

## 📋 Monitoring

### View Cloud Logs

```bash
# View all BTI logs
gcloud logging read "jsonPayload.pipeline_name=\"BTI-DWG-QA\"" \
    --project=swiftchair \
    --limit=50

# View conversion logs
gcloud logging read "jsonPayload.type=\"conversion\"" \
    --project=swiftchair \
    --limit=20

# View validation logs
gcloud logging read "jsonPayload.type=\"validation\"" \
    --project=swiftchair \
    --limit=20
```

### Cloud Logging Web UI

https://console.cloud.google.com/logs/query?project=swiftchair

**Query examples:**
```
resource.type="gce_instance"
jsonPayload.pipeline_name="BTI-DWG-QA"
```

### Serial Port Console

```bash
# View serial port output
gcloud compute instances get-serial-port-output instance-20251019-062935 \
    --zone=us-central1-f \
    --port=1
```

### Check n8n Service Status

```powershell
# Service status
Get-Service -Name "n8n"

# Service logs (via NSSM)
C:\nssm\nssm-2.24\win64\nssm.exe status n8n
```

---

## 🆘 Troubleshooting

### n8n Service Not Starting

```powershell
# Check service status
Get-Service -Name "n8n" | Format-List *

# Restart service
Restart-Service -Name "n8n" -Force

# View service logs
C:\nssm\nssm-2.24\win64\nssm.exe status n8n
```

### Telegram Not Sending Messages

```powershell
# Check environment variables
[Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
[Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "Machine")

# Test manually
python C:\bti\scripts\send_telegram_report.py
```

### Secrets Not Accessible

```bash
# Check IAM permissions
gcloud projects get-iam-policy swiftchair \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:*"

# Grant secretAccessor role
gcloud projects add-iam-policy-binding swiftchair \
    --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
    --role="roles/secretmanager.secretAccessor"
```

### Firewall Blocking n8n

```powershell
# Check Windows Firewall
Get-NetFirewallRule -DisplayName "n8n BTI Pipeline"

# Check GCP firewall
gcloud compute firewall-rules list --filter="name=allow-n8n-5678"

# Re-run firewall setup
.\setup_firewall.ps1
```

### Logs Not Appearing in Cloud Logging

```powershell
# Check Ops Agent status
Get-Service -Name "google-cloud-ops-agent"

# Restart Ops Agent
Restart-Service -Name "google-cloud-ops-agent" -Force

# Check config
Get-Content "C:\ProgramData\Google\Cloud Operations\Ops Agent\config\config.yaml"
```

---

## 🔄 Updates and Maintenance

### Update n8n

```powershell
# Stop service
Stop-Service -Name "n8n"

# Update n8n
npm update -g n8n

# Start service
Start-Service -Name "n8n"
```

### Update Workflows

```powershell
# Re-import workflows
.\import_workflows.ps1
```

### Backup Configuration

```powershell
# Backup BTI directory
Compress-Archive -Path "C:\bti" -DestinationPath "C:\bti_backup_$(Get-Date -Format 'yyyyMMdd').zip"
```

---

## 🧹 Uninstall

```powershell
# Stop and remove n8n service
C:\nssm\nssm-2.24\win64\nssm.exe stop n8n
C:\nssm\nssm-2.24\win64\nssm.exe remove n8n confirm

# Stop Ops Agent
Stop-Service -Name "google-cloud-ops-agent"

# Remove firewall rules
gcloud compute firewall-rules delete allow-n8n-5678 --quiet

# Remove directories
Remove-Item -Path "C:\bti" -Recurse -Force
Remove-Item -Path "C:\nssm" -Recurse -Force
```

---

## 📞 Support

**GitHub**: https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline  
**Issues**: https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline/issues  
**Email**: info@datadrivenconstruction.io

---

## 📜 License

MIT License - See [LICENSE](../LICENSE) for details

---

**Deployment Version**: 1.0.0  
**Last Updated**: October 20, 2025

