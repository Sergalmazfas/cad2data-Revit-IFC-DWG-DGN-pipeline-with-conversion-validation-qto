# ✅ BTI DWG QA Pipeline - Production Deployment Checklist

## 📋 Pre-Deployment Verification

### ✅ GitHub Repository Status

- [x] Branch: `release/DWG-QA-v1`
- [x] Latest commit: 522ba97
- [x] All files committed and pushed
- [x] Basmanny template (51 KB) uploaded
- [x] Deployment scripts (8 PowerShell scripts)
- [x] n8n workflows (4 workflows)
- [x] Documentation (8 documents, ~70 pages)

### ✅ Google Cloud Prerequisites

- [ ] **GCP Project**: talkhint
- [ ] **VM Instance**: instance-20251019-062935 (running)
- [ ] **Zone**: us-central1-f
- [ ] **OS**: Windows Server 2025 Core
- [ ] **External IP**: 104.198.201.212
- [ ] **IAM Permissions**: 
  - [ ] roles/secretmanager.secretAccessor
  - [ ] roles/logging.logWriter
  - [ ] roles/monitoring.metricWriter

### ✅ Secret Manager Secrets

- [ ] **TELEGRAM_BOT_TOKEN**: Created in Secret Manager
- [ ] **TELEGRAM_CHAT_ID**: Created in Secret Manager
- [ ] Secrets accessible to VM service account

---

## 🚀 Deployment Steps (на Windows VM)

### Step 1: Connect to VM ⏱️ 1 min

```bash
# From your Mac/Linux
gcloud compute ssh instance-20251019-062935 \
    --zone=us-central1-f \
    --project=talkhint
```

**Verification**:
- [ ] Successfully connected to Windows PowerShell

---

### Step 2: Clone Repository ⏱️ 2 min

```powershell
# On Windows VM
cd C:\Users\Administrator

git clone https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git

cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto

git checkout release/DWG-QA-v1

cd BTI-DWG-QA-pipeline\deployment
```

**Verification**:
- [ ] Repository cloned successfully
- [ ] Branch: release/DWG-QA-v1
- [ ] Deployment scripts present (ls *.ps1)
- [ ] Basmanny template present (ls ..\templates\BasmanTitleBlock.dwg)

---

### Step 3: Run ONE-CLICK Deployment ⏱️ 20-30 min

```powershell
.\deploy_all.ps1
```

**Substeps executed automatically**:
1. [ ] Main deployment (Node.js, n8n, NSSM, SDK) - 10-15 min
2. [ ] Firewall configuration (GCP + Windows) - 2-3 min
3. [ ] Cloud Logging setup (Ops Agent) - 3-5 min
4. [ ] Import workflows (4 workflows) - 1-2 min
5. [ ] Telegram integration (Python, script) - 2-3 min
6. [ ] Smoke test (30+ checks) - 1-2 min
7. [ ] Basmanny test (24 checks) - 1-2 min

**Verification**:
- [ ] All 7 steps completed without errors
- [ ] Output shows: "🎉 DEPLOYMENT COMPLETE!"

---

### Step 4: Run Deployment Verification ⏱️ 2 min

```powershell
.\verify_deployment.ps1
```

**Expected output**:
```
Total Checks: 40+
Passed: 40+
Failed: 0
Pass Rate: 100%

✅ DEPLOYMENT VERIFICATION PASSED!
```

**Verification**:
- [ ] Pass rate >= 95%
- [ ] All critical checks passed
- [ ] Report saved: C:\bti\output\logs\deployment_verification_report.json

---

### Step 5: Configure n8n Workflows ⏱️ 5 min

Open n8n Web UI: http://104.198.201.212:5678

**5.1 Activate Auto-Start Workflow**:
- [ ] Open workflow: `BTI_0_Watch_Input_AutoStart`
- [ ] Click "Active" button (top right)
- [ ] Status changes to "Active" ✅

**5.2 Configure DWG Converter Path** (if needed):
- [ ] Open workflow: `BTI_1_DWG_Convert`
- [ ] Edit node: "Setup - Define DWG Paths"
- [ ] Update: `path_to_dwg_converter` to correct path
- [ ] Save workflow

**Verification**:
- [ ] Auto-start workflow is active
- [ ] Converter path configured correctly

---

### Step 6: Run First Test ⏱️ 5 min

```powershell
# Create or copy a test DWG file
Copy-Item "C:\path\to\your\file.dwg" "C:\bti\input\test_001.dwg"

# Wait 15-30 seconds for auto-processing

# Check results
Get-ChildItem C:\bti\output\converted\     # Should have: *_basman.dwg
Get-ChildItem C:\bti\output\*.xlsx         # Should have: *.xlsx
Get-Content C:\bti\output\logs\qa_log.json # Validation results
Get-ChildItem C:\bti\output\*_QTO.html     # QTO report
```

**Verification**:
- [ ] Template applied: `*_basman.dwg` created
- [ ] Conversion: `*.xlsx` created
- [ ] Validation: `qa_log.json` created
- [ ] QTO report: `*_QTO.html` created
- [ ] Telegram notification received from @N8Ndwg_bot

---

## 📊 Post-Deployment Verification

### System Health

```powershell
# Check services
Get-Service -Name "n8n", "google-cloud-ops-agent" | Format-Table -AutoSize
```

**Expected**:
- [ ] n8n: Running
- [ ] google-cloud-ops-agent: Running

### Network Access

```powershell
# Test n8n API
Invoke-WebRequest http://localhost:5678/healthz
```

**Expected**:
- [ ] StatusCode: 200
- [ ] n8n Web UI accessible externally: http://104.198.201.212:5678

### Environment Variables

```powershell
[Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
[Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "Machine")
```

**Expected**:
- [ ] TELEGRAM_BOT_TOKEN: Not empty, length > 20
- [ ] TELEGRAM_CHAT_ID: Not empty

### Cloud Logging

```bash
# From Mac/Linux
gcloud logging read "jsonPayload.pipeline_name=\"BTI-DWG-QA\"" \
    --project=talkhint \
    --limit=10
```

**Expected**:
- [ ] Logs visible in Cloud Logging
- [ ] Entries from BTI pipeline present

### Serial Port

```bash
gcloud compute instances get-serial-port-output instance-20251019-062935 \
    --zone=us-central1-f \
    --port=1 \
    --project=talkhint
```

**Expected**:
- [ ] Serial port output accessible
- [ ] Boot logs visible

---

## 🧪 Functional Testing

### Test 1: Manual Workflow Execution

- [ ] Open n8n Web UI
- [ ] Execute `BTI_1_DWG_Convert` manually
- [ ] Workflow completes successfully
- [ ] Output files created

### Test 2: Auto-Start Trigger

- [ ] Place DWG file in `C:\bti\input\`
- [ ] Auto-start workflow triggers within 10 seconds
- [ ] Pipeline executes all 4 workflows
- [ ] Results appear in output folders

### Test 3: Basmanny Template Application

- [ ] Input: test.dwg
- [ ] Process through pipeline
- [ ] Output: test_basman.dwg created
- [ ] Template configuration applied (check layers, text style)

### Test 4: Validation & QA

- [ ] qa_log.json created
- [ ] Contains validation results
- [ ] Pass/fail status determined
- [ ] Issues logged if any

### Test 5: QTO Report

- [ ] HTML report generated
- [ ] Contains: area, perimeter, counts
- [ ] Grouped by layers and types
- [ ] Opens in browser

### Test 6: Telegram Notification

- [ ] Telegram message received
- [ ] Contains: file name, status, metrics
- [ ] HTML formatting applied
- [ ] @N8Ndwg_bot sends message

### Test 7: Cloud Logging

- [ ] Logs appear in Cloud Logging console
- [ ] JSON logs parsed correctly
- [ ] Text logs collected
- [ ] Pipeline name filter works

---

## 📊 Success Criteria

### Critical (Must Pass)

- ✅ n8n service running
- ✅ Auto-start workflow active
- ✅ Basmanny template file present (51 KB)
- ✅ Secrets configured (Telegram tokens)
- ✅ Firewall rules active
- ✅ Smoke test: 100% pass rate

### Important (Should Pass)

- ✅ Ops Agent collecting logs
- ✅ Serial Port 1 enabled
- ✅ Telegram notifications working
- ✅ QA logs generated
- ✅ QTO reports created

### Optional (Nice to Have)

- ✅ External n8n access working
- ✅ Cloud Logging query filters work
- ✅ Documentation complete

---

## 🎯 Final Sign-Off

### Deployment Team Checklist

- [ ] **Infrastructure**: VM running, services active
- [ ] **Software**: All dependencies installed
- [ ] **Configuration**: templates.json, validation_rules.json configured
- [ ] **Workflows**: 4 workflows imported and tested
- [ ] **Security**: Secrets from Secret Manager, no hardcoded credentials
- [ ] **Monitoring**: Cloud Logging active, Serial Port enabled
- [ ] **Testing**: All smoke tests passed (54/54)
- [ ] **Documentation**: Complete and up-to-date

### Production Readiness

- [ ] **Functionality**: DWG conversion working
- [ ] **Automation**: Auto-start on file detection working
- [ ] **Quality**: Validation rules applied correctly
- [ ] **Reporting**: QTO reports generated successfully
- [ ] **Notifications**: Telegram alerts working
- [ ] **Logging**: All operations logged to Cloud Logging
- [ ] **Template**: Basmanny template loaded and configured

### Approval

- [ ] **Technical Review**: All checks passed
- [ ] **Security Review**: No security issues
- [ ] **Performance Review**: Acceptable performance (<35s per file)
- [ ] **Documentation Review**: Complete documentation

---

## 🎊 Production Approval

**Status**: Ready for Production ✅

**Approved by**: ___________________________

**Date**: ___________________________

**Signature**: ___________________________

---

## 📞 Support Contacts

**GitHub**: https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/tree/release/DWG-QA-v1

**Issues**: https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline/issues

**Email**: info@datadrivenconstruction.io

**Emergency**: Check Cloud Logging for error details

---

**Checklist Version**: 1.0.0  
**Last Updated**: October 20, 2025  
**Next Review**: November 20, 2025

