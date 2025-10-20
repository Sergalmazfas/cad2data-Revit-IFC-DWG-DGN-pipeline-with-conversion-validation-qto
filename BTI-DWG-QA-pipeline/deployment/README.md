# BTI DWG QA Pipeline - Deployment Scripts

## 📦 Quick Start

Deploy the entire BTI DWG QA Pipeline on Windows Server VM in **5 simple steps**:

```powershell
# Step 1: Main deployment (10-15 min)
.\deploy_bti_pipeline.ps1

# Step 2: Configure firewall (2-3 min)
.\setup_firewall.ps1

# Step 3: Setup Cloud Logging (3-5 min)
.\setup_logging.ps1

# Step 4: Import workflows (1-2 min)
.\import_workflows.ps1

# Step 5: Setup Telegram bot (2-3 min)
.\setup_telegram.ps1

# Step 6: Run smoke test (1-2 min)
.\smoke_test.ps1
```

**Total time**: ~20-30 minutes for complete deployment

---

## 📄 Available Scripts

| Script | Purpose | Duration | Dependencies |
|--------|---------|----------|--------------|
| `deploy_bti_pipeline.ps1` | Main deployment (Node.js, n8n, SDK, secrets) | 10-15 min | None |
| `setup_firewall.ps1` | Configure GCP + Windows firewall for n8n | 2-3 min | gcloud |
| `setup_logging.ps1` | Install Ops Agent + configure log collection | 3-5 min | gcloud |
| `import_workflows.ps1` | Import 3 n8n workflows via REST API | 1-2 min | n8n running |
| `setup_telegram.ps1` | Setup Telegram bot notifications | 2-3 min | Python |
| `smoke_test.ps1` | End-to-end system test (30+ checks) | 1-2 min | All above |

---

## 🎯 What Gets Deployed

### Software Components
- ✅ **Node.js** v20.17.0 LTS
- ✅ **n8n** (latest) - workflow automation
- ✅ **NSSM** 2.24 - Windows service manager
- ✅ **Google Cloud SDK** - gcloud CLI
- ✅ **Google Cloud Ops Agent** - log collector
- ✅ **Python** 3.12 - for Telegram bot

### Windows Services
- ✅ **n8n** - runs on port 5678
- ✅ **google-cloud-ops-agent** - log collection

### BTI Components
- ✅ 3 n8n workflows (Convert, Validation, QTO)
- ✅ 2 JavaScript utilities (logger, validator)
- ✅ 1 Python script (Telegram notifications)
- ✅ 3 config files (rules, settings, template)

### Cloud Configuration
- ✅ GCP firewall rule: `allow-n8n-5678`
- ✅ Network tag: `n8n`
- ✅ Secret Manager integration
- ✅ Cloud Logging pipelines
- ✅ Serial Port 1 enabled

---

## 📋 Prerequisites

### Google Cloud
- **Project**: `talkhint`
- **Instance**: `instance-20251019-062935`
- **Zone**: `us-central1-f`
- **OS**: Windows Server 2025 Core

### IAM Permissions
```bash
roles/secretmanager.secretAccessor     # Read secrets
roles/logging.logWriter                # Write logs
roles/monitoring.metricWriter          # Write metrics
roles/compute.instanceAdmin            # Manage instance
```

### Secrets in Secret Manager
```bash
gcloud secrets create TELEGRAM_BOT_TOKEN --data-file=-
gcloud secrets create TELEGRAM_CHAT_ID --data-file=-
```

### Repository Cloned
```powershell
cd C:\Users\Administrator
git clone https://github.com/datadrivenconstruction/cad2data-*.git
```

---

## 🚀 Deployment Process

### 1. Main Deployment

```powershell
.\deploy_bti_pipeline.ps1

# Optional parameters:
.\deploy_bti_pipeline.ps1 `
    -ProjectId "talkhint" `
    -Zone "us-central1-f" `
    -InstanceName "instance-20251019-062935" `
    -RepoPath "C:\Users\Administrator\cad2data-*"
```

**Actions**:
1. Creates `C:\bti\` directory structure
2. Copies project files from repository
3. Installs Node.js v20.17.0
4. Installs n8n globally
5. Installs NSSM for Windows Service
6. Creates n8n service (auto-start)
7. Installs Google Cloud SDK
8. Retrieves secrets from Secret Manager
9. Starts n8n service

**Output**: n8n running on http://localhost:5678

---

### 2. Firewall Configuration

```powershell
.\setup_firewall.ps1
```

**Actions**:
1. Creates GCP VPC firewall rule (`allow-n8n-5678`)
2. Adds network tag `n8n` to instance
3. Creates Windows Firewall inbound rule

**Output**: n8n accessible at http://EXTERNAL_IP:5678

---

### 3. Cloud Logging Setup

```powershell
.\setup_logging.ps1
```

**Actions**:
1. Installs Google Cloud Ops Agent
2. Creates `config.yaml` for log collection:
   - `C:\bti\output\logs\*.json`
   - `C:\bti\output\logs\*.txt`
   - Windows Event Logs (Application, System)
3. Restarts Ops Agent service
4. Enables Serial Port 1

**Output**: Logs visible in Cloud Logging console

---

### 4. Import Workflows

```powershell
.\import_workflows.ps1
```

**Actions**:
1. Waits for n8n to be ready
2. Imports workflows via REST API:
   - `n8n_1_BTI_Convert.json`
   - `n8n_2_BTI_Validation.json`
   - `n8n_3_BTI_QTO.json`

**Output**: 3 workflows available in n8n

---

### 5. Telegram Integration

```powershell
.\setup_telegram.ps1
```

**Actions**:
1. Installs Python 3.12 (if needed)
2. Installs `requests` library
3. Creates `send_telegram_report.py` script
4. Sends test message to @N8Ndwg_bot

**Output**: Telegram bot ready for notifications

---

### 6. Smoke Test

```powershell
.\smoke_test.ps1
```

**Actions**:
- Tests 30+ components:
  - Directory structure (7 tests)
  - Required files (5 tests)
  - Software installation (5 tests)
  - Windows services (4 tests)
  - Environment variables (2 tests)
  - Network connectivity (3 tests)
  - Firewall rules (2 tests)
  - Cloud Logging (1 test)
  - n8n workflows (1 test)

**Output**: Pass/Fail report with 100% pass rate expected

---

## 🔧 Post-Deployment Configuration

### Update DWG Converter Path

1. Open n8n: http://EXTERNAL_IP:5678
2. Edit workflow: `BTI_1_DWG_Convert`
3. Update node: `Setup - Define DWG Paths`
4. Set: `path_to_dwg_converter = "C:\\DDC_CONVERTER_DWG\\datadrivenlibs\\DwgExporter.exe"`

### Test Workflows

1. Place test DWG in `C:\bti\input\test.dwg`
2. Execute `BTI_1_DWG_Convert` → XLSX created
3. Execute `BTI_2_BTI_Validation` → JSON report + Telegram
4. Execute `BTI_3_BTI_QTO` → HTML report

---

## 📊 Monitoring

### Service Status
```powershell
Get-Service -Name "n8n"
Get-Service -Name "google-cloud-ops-agent"
```

### View Logs
```bash
# Cloud Logging
gcloud logging read "jsonPayload.pipeline_name=\"BTI-DWG-QA\"" --limit=50

# Serial Port
gcloud compute instances get-serial-port-output instance-20251019-062935 --zone=us-central1-f --port=1
```

### n8n Web UI
- http://localhost:5678 (internal)
- http://104.198.201.212:5678 (external)

---

## 🆘 Troubleshooting

### Script Execution Policy

If scripts are blocked:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### n8n Service Not Starting
```powershell
# Check logs
C:\nssm\nssm-2.24\win64\nssm.exe status n8n

# Restart
Restart-Service -Name "n8n" -Force
```

### Secrets Not Found
```bash
# Check secrets exist
gcloud secrets list

# Grant access
gcloud projects add-iam-policy-binding talkhint \
    --member="serviceAccount:SA_EMAIL" \
    --role="roles/secretmanager.secretAccessor"
```

### Firewall Issues
```powershell
# Re-run firewall setup
.\setup_firewall.ps1

# Check Windows Firewall
Get-NetFirewallRule -DisplayName "n8n BTI Pipeline"
```

---

## 🔄 Updates

### Update n8n
```powershell
Stop-Service -Name "n8n"
npm update -g n8n
Start-Service -Name "n8n"
```

### Re-import Workflows
```powershell
.\import_workflows.ps1
```

### Update Secrets
```bash
echo "NEW_TOKEN" | gcloud secrets versions add TELEGRAM_BOT_TOKEN --data-file=-

# Restart n8n to reload env vars
Restart-Service -Name "n8n"
```

---

## 📞 Support

**Full Documentation**: [DEPLOYMENT.md](DEPLOYMENT.md)  
**GitHub Issues**: https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline/issues  
**Email**: info@datadrivenconstruction.io

---

## 📜 License

MIT License - See [../LICENSE](../LICENSE)

---

**Version**: 1.0.0  
**Last Updated**: October 20, 2025

