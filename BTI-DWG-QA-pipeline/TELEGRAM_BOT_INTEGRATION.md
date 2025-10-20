# 📱 BTI DWG QA Pipeline - Telegram Bot Integration

## 🎯 Overview

Пользователи могут отправлять DWG файлы напрямую в Telegram бот **@N8Ndwg_bot**, и получать обработанные результаты с примененным шаблоном Басманный, QA отчетом и QTO метриками.

---

## ✨ Features

✅ **Upload DWG via Telegram** - Просто отправьте файл боту  
✅ **Auto-Processing** - Автоматическая обработка через n8n pipeline  
✅ **Basmanny Template** - Автоматическое применение шаблона  
✅ **QA Validation** - Проверка качества данных  
✅ **QTO Reports** - Подсчет объемов работ  
✅ **Results via Telegram** - Результаты возвращаются пользователю  
✅ **Cloud Logging** - Все операции логируются  

---

## 🏗️ Architecture

```
User (Telegram)
    ↓
    📤 Uploads .dwg file
    ↓
@N8Ndwg_bot (Telegram Bot Server)
    ↓
    💾 Saves to C:\bti\input\
    ↓
    🔔 Triggers n8n webhook
    ↓
n8n Pipeline
    ├─ BTI_1_Convert (DWG → XLSX)
    ├─ BTI_2_Validation (QA checks)
    └─ BTI_3_QTO (Reports)
    ↓
    📊 Results prepared
    ↓
@N8Ndwg_bot
    ↓
    📨 Sends back to user:
       - DWG with Basmanny template
       - QA log (JSON)
       - QTO report (HTML)
    ↓
User receives results ✅
```

---

## 🚀 Installation

### Step 1: Install Bot Service (5-10 min)

```powershell
cd C:\Users\Administrator\cad2data-*\BTI-DWG-QA-pipeline\deployment

# Install Telegram bot as Windows Service
.\setup_telegram_bot_service.ps1
```

**What it does**:
- ✅ Installs Python 3.12 (if needed)
- ✅ Installs aiogram library
- ✅ Creates Windows Service: N8NdwgBot
- ✅ Configures auto-start
- ✅ Starts the service

### Step 2: Import Telegram Webhook Workflow (2 min)

```powershell
# Import the webhook workflow to n8n
.\import_workflows.ps1
```

**Or manually**:
1. Open n8n: http://localhost:5678
2. Workflows → Import from File
3. Select: `n8n_4_BTI_Telegram_Webhook.json`
4. Save workflow

### Step 3: Activate Webhook Workflow

In n8n Web UI:
1. Open workflow: **BTI_4_Telegram_Webhook**
2. Click **"Active"** button ✅
3. Note the webhook URL: `http://localhost:5678/webhook/bti_telegram_trigger`

---

## 📖 Usage

### For Users (Telegram)

1. **Open Telegram** and find **@N8Ndwg_bot**

2. **Send /start** to begin
   ```
   Bot responds with welcome message and instructions
   ```

3. **Upload .dwg file**
   - Just send the file as attachment
   - Max size: 50 MB
   - Only .dwg format accepted

4. **Wait 30-60 seconds** for processing

5. **Receive results**:
   - ✅ DWG file with Basmanny template applied
   - ✅ QA validation report (JSON)
   - ✅ QTO report (HTML)

### Commands

| Command | Description |
|---------|-------------|
| `/start` | Welcome message and instructions |
| `/help` | Detailed help and limitations |
| `/status` | System status and queue info |

---

## 🔧 Configuration

### Bot Settings

Located in: `scripts/telegram_bot_server.py`

```python
UPLOAD_PATH = r"C:\bti\input"           # Where files are saved
OUTPUT_PATH = r"C:\bti\output"          # Where results are generated
MAX_FILE_SIZE = 50 * 1024 * 1024        # 50 MB limit
N8N_WEBHOOK_URL = "http://localhost:5678/webhook/bti_telegram_trigger"
```

### Security & Limits

```python
# File type validation
if not doc.file_name.lower().endswith(".dwg"):
    # Reject non-DWG files

# File size validation
if doc.file_size > MAX_FILE_SIZE:
    # Reject files > 50 MB

# Rate limiting (future enhancement)
# Implement per-user rate limiting
```

---

## 🧪 Testing

### Quick Test

```powershell
# Run automated tests
.\test_telegram_bot.ps1
```

**Expected output**:
```
Total Tests: 17
Passed: 17
Failed: 0
Pass Rate: 100%

✅ Telegram Bot Integration: READY!
```

### Manual Test

1. **Send /start to @N8Ndwg_bot**
   - Should receive welcome message

2. **Send /status**
   - Should show system status

3. **Upload a small DWG file**
   - Should receive "File received" message
   - Wait 30-60 seconds
   - Should receive 3 files: DWG + JSON + HTML

4. **Check logs**:
   ```powershell
   Get-Content C:\bti\output\logs\telegram_bot.log -Tail 20
   Get-Content C:\bti\output\logs\telegram_triggers.json
   ```

---

## 📊 Monitoring

### Bot Service Status

```powershell
# Check service
Get-Service -Name N8NdwgBot

# View logs
Get-Content C:\bti\output\logs\telegram_bot.log -Tail 50 -Wait

# Restart if needed
Restart-Service -Name N8NdwgBot
```

### Telegram Triggers Log

```powershell
# View all Telegram uploads
Get-Content C:\bti\output\logs\telegram_triggers.json | ConvertFrom-Json
```

### Cloud Logging

```bash
# From Mac/Linux
gcloud logging read "jsonPayload.type=\"telegram_upload\"" \
    --project=swiftchair \
    --limit=20
```

---

## 🔄 Processing Flow

### User Perspective

```
1. User uploads DWG to @N8Ndwg_bot
   ↓
2. Bot replies: "✅ File received! Processing..."
   ↓
3. [Wait 30-60 seconds]
   ↓
4. Bot sends:
   📎 project_basman.dwg (with template)
   📊 qa_log.json (validation results)
   📈 project_QTO.html (metrics report)
   ↓
5. User downloads and reviews results ✅
```

### System Perspective

```
1. Telegram → Bot receives file
   ↓
2. Bot saves to C:\bti\input\
   ↓
3. Bot triggers n8n webhook
   ↓
4. n8n processes:
   - Apply Basmanny template
   - Convert DWG → XLSX
   - Validate data
   - Generate QTO
   ↓
5. n8n notifies bot
   ↓
6. Bot sends results to user
   ↓
7. All logged to Cloud Logging ✅
```

---

## 🛠️ Troubleshooting

### Bot Not Responding

```powershell
# Check service status
Get-Service -Name N8NdwgBot

# Check logs for errors
Get-Content C:\bti\output\logs\telegram_bot_stderr.log -Tail 20

# Restart service
Restart-Service -Name N8NdwgBot -Force
```

### Files Not Processing

```powershell
# Check if file was saved
Get-ChildItem C:\bti\input\

# Check n8n auto-start workflow
# Open n8n → BTI_0_Watch_Input_AutoStart
# Ensure it's "Active"

# Check n8n execution history
# Open n8n → Executions
```

### Bot Not Sending Results

```powershell
# Check if results were generated
Get-ChildItem C:\bti\output\converted\
Get-ChildItem C:\bti\output\*.xlsx
Get-ChildItem C:\bti\output\*.html

# Check Telegram token
[Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")

# Test bot manually
python C:\bti\scripts\telegram_bot_server.py
```

### Webhook Not Triggering

```powershell
# Test webhook endpoint
Invoke-RestMethod -Uri "http://localhost:5678/webhook/bti_telegram_trigger" `
    -Method POST `
    -ContentType "application/json" `
    -Body (@{file_name="test.dwg"; chat_id="123"} | ConvertTo-Json)

# Check n8n webhook workflow is active
# n8n UI → BTI_4_Telegram_Webhook → Active: Yes
```

---

## 🔐 Security

### Secrets Management
- ✅ TELEGRAM_BOT_TOKEN from Google Secret Manager
- ✅ No tokens hardcoded in scripts
- ✅ Environment variables only

### File Validation
- ✅ Only .dwg files accepted
- ✅ File size limit: 50 MB
- ✅ File type verification

### User Tracking
- ✅ User ID logged for each upload
- ✅ Chat ID saved for result delivery
- ✅ All operations logged to Cloud Logging

---

## 📈 Scaling

### Current Capacity
- **Sequential Processing**: One file at a time
- **Throughput**: ~100-200 files/day
- **Concurrent Users**: Unlimited (queued)

### Future Enhancements
- [ ] Parallel processing (multiple files simultaneously)
- [ ] Priority queue for urgent requests
- [ ] User quotas and rate limiting
- [ ] Batch processing support

---

## 📞 Support

**Bot Issues**: Check service logs and restart if needed  
**Processing Issues**: Review n8n execution history  
**Results Issues**: Check output directories

**Email**: info@datadrivenconstruction.io  
**GitHub**: https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline

---

## ✅ Quick Start Checklist

After installation:

- [ ] Bot service running: `Get-Service N8NdwgBot`
- [ ] n8n webhook workflow active
- [ ] Environment variables configured
- [ ] Test /start command in Telegram
- [ ] Upload test DWG file
- [ ] Receive results (3 files)
- [ ] Logs appearing in Cloud Logging

---

**Version**: 1.0.0-basman  
**Bot**: @N8Ndwg_bot  
**Status**: Production Ready ✅

