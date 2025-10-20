# 🚀 BTI DWG QA Pipeline - Deploy NOW!

## Быстрый deployment на Windows Server VM

**Instance**: instance-20251019-062935  
**Zone**: us-central1-f  
**Project**: talkhint  
**External IP**: 104.198.201.212

---

## ⚡ Quick Deploy (20 минут)

### Подключение к VM

```bash
# С локального Mac/Linux
gcloud compute ssh instance-20251019-062935 \
    --zone=us-central1-f \
    --project=talkhint
```

Или через Cloud Console → Compute Engine → SSH

---

## 📋 Deployment Commands (копируйте по порядку)

### Шаг 1: Клонировать репозиторий (2 мин)

```powershell
# На Windows Server VM
cd C:\Users\Administrator

# Клонировать репозиторий
git clone https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git

# Переключиться на ветку с Basmanny template
cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto
git checkout release/DWG-QA-v1

# Перейти в deployment
cd BTI-DWG-QA-pipeline\deployment
```

---

### Шаг 2: Главный deployment (10-15 мин)

```powershell
# Запустить главный deployment скрипт
.\deploy_bti_pipeline.ps1
```

**Что происходит**:
- ✅ Создается структура C:\bti\
- ✅ Копируются все файлы проекта
- ✅ Устанавливается Node.js v20.17.0
- ✅ Устанавливается n8n
- ✅ Устанавливается NSSM
- ✅ Создается n8n Windows Service
- ✅ Устанавливается Google Cloud SDK
- ✅ Загружаются секреты из Secret Manager
- ✅ Запускается n8n service

**Ожидаемый вывод**:
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

✓ Deployment Complete!
```

---

### Шаг 3: Настройка Firewall (2-3 мин)

```powershell
.\setup_firewall.ps1
```

**Что происходит**:
- ✅ Создается GCP firewall rule (allow-n8n-5678)
- ✅ Добавляется network tag (n8n)
- ✅ Создается Windows Firewall rule

**Проверка**:
```
n8n доступен: http://104.198.201.212:5678
```

---

### Шаг 4: Настройка Cloud Logging (3-5 мин)

```powershell
.\setup_logging.ps1
```

**Что происходит**:
- ✅ Устанавливается Google Cloud Ops Agent
- ✅ Создается config.yaml
- ✅ Настраиваются log collectors
- ✅ Включается Serial Port 1

**Проверка**:
```powershell
Get-Service -Name "google-cloud-ops-agent"
# Должно быть: Running
```

---

### Шаг 5: Импорт workflows (1-2 мин)

```powershell
.\import_workflows.ps1
```

**Что происходит**:
- ✅ Импортируется n8n_0_BTI_Watch_Input.json
- ✅ Импортируется n8n_1_BTI_Convert.json
- ✅ Импортируется n8n_2_BTI_Validation.json
- ✅ Импортируется n8n_3_BTI_QTO.json

**Проверка**:
```
Откройте: http://104.198.201.212:5678
Должно быть 4 workflow
```

---

### Шаг 6: Настройка Telegram (2-3 мин)

```powershell
.\setup_telegram.ps1
```

**Что происходит**:
- ✅ Устанавливается Python
- ✅ Устанавливается библиотека requests
- ✅ Создается send_telegram_report.py
- ✅ Отправляется тестовое сообщение

**Проверка**:
```
Должно прийти сообщение в Telegram от @N8Ndwg_bot:
"🚀 BTI DWG QA Pipeline deployment complete!"
```

---

### Шаг 7: Smoke Test (1-2 мин)

```powershell
.\smoke_test.ps1
```

**Что происходит**:
- ✅ Запускается 30+ тестов
- ✅ Проверяются все компоненты
- ✅ Сохраняются результаты

**Ожидаемый результат**:
```
Total Tests: 30
Passed: 30
Failed: 0
Pass Rate: 100%

✓ ALL TESTS PASSED!
```

---

### Шаг 8: Тест Basmanny Template (1-2 мин)

```powershell
.\test_basman_pipeline.ps1
```

**Что происходит**:
- ✅ Проверяется конфигурация templates.json
- ✅ Проверяется шаблон Basmanny
- ✅ Проверяется скрипт применения
- ✅ Создается тестовый DWG
- ✅ Применяется шаблон

**Ожидаемый результат**:
```
Total Tests: 24
Passed: 24
Failed: 0
Pass Rate: 100%

✓ ALL BASMANNY TESTS PASSED!
```

---

## 🎯 Полная команда (для опытных пользователей)

Весь deployment одной последовательностью:

```powershell
cd C:\Users\Administrator

# Clone
git clone https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git
cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto
git checkout release/DWG-QA-v1
cd BTI-DWG-QA-pipeline\deployment

# Deploy (выполнять по порядку!)
.\deploy_bti_pipeline.ps1
.\setup_firewall.ps1
.\setup_logging.ps1
.\import_workflows.ps1
.\setup_telegram.ps1
.\smoke_test.ps1
.\test_basman_pipeline.ps1

# Готово!
```

---

## 🔧 После deployment

### 1. Активировать Auto-Start Workflow

```powershell
# Открыть n8n Web UI
Start-Process "http://localhost:5678"

# Или с внешнего компьютера:
# http://104.198.201.212:5678

# В n8n:
# 1. Открыть workflow: BTI_0_Watch_Input_AutoStart
# 2. Нажать "Activate" (вверху справа)
# 3. Workflow начнет мониторить C:\bti\input\
```

### 2. Настроить пути DWG Converter

В n8n workflows обновить:

```javascript
// BTI_1_DWG_Convert → Setup node
path_to_dwg_converter: "C:\\DDC_CONVERTER_DWG\\datadrivenlibs\\DwgExporter.exe"
```

---

## 🧪 Первый тест

```powershell
# 1. Создать тестовый DWG (или скопировать свой)
Copy-Item "C:\путь\к\вашему\файлу.dwg" "C:\bti\input\test_001.dwg"

# 2. Проверить что auto-start сработал (через 5-10 секунд)
Get-ChildItem C:\bti\output\converted\  # Должен появиться test_001_basman.dwg
Get-ChildItem C:\bti\output\*.xlsx      # Должен появиться test_001_dwg.xlsx
Get-Content C:\bti\output\logs\qa_log.json  # Результаты валидации

# 3. Проверить Telegram
# Должно прийти уведомление от @N8Ndwg_bot

# 4. Проверить Cloud Logging
# https://console.cloud.google.com/logs/query?project=talkhint
# Фильтр: jsonPayload.pipeline_name="BTI-DWG-QA"
```

---

## 📊 Мониторинг

### Проверка сервисов

```powershell
# Статус n8n
Get-Service -Name "n8n"

# Статус Ops Agent
Get-Service -Name "google-cloud-ops-agent"

# n8n logs (через NSSM)
C:\nssm\nssm-2.24\win64\nssm.exe status n8n
```

### Проверка логов

```powershell
# Локальные логи
Get-ChildItem C:\bti\output\logs\

# Cloud Logging (из локального Mac)
gcloud logging read "jsonPayload.pipeline_name=\"BTI-DWG-QA\"" \
    --project=talkhint \
    --limit=20

# Serial Port
gcloud compute instances get-serial-port-output instance-20251019-062935 \
    --zone=us-central1-f \
    --port=1
```

---

## 🆘 Troubleshooting

### Если n8n не запустился:

```powershell
# Проверить статус
Get-Service -Name "n8n" | Format-List *

# Перезапустить
Restart-Service -Name "n8n" -Force

# Проверить логи
C:\nssm\nssm-2.24\win64\nssm.exe status n8n
```

### Если Telegram не работает:

```powershell
# Проверить переменные окружения
[Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
[Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "Machine")

# Если пустые - перезапустить setup_telegram.ps1
.\setup_telegram.ps1
```

### Если workflow не импортировались:

```powershell
# Проверить что n8n запущен
Invoke-WebRequest http://localhost:5678/healthz

# Перезапустить импорт
.\import_workflows.ps1
```

---

## ✅ Успешный deployment checklist

После выполнения всех шагов проверьте:

- [ ] n8n service: Running
- [ ] Ops Agent service: Running
- [ ] n8n Web UI доступен: http://104.198.201.212:5678
- [ ] 4 workflows импортированы
- [ ] Auto-start workflow активирован
- [ ] Telegram тест сообщение получено
- [ ] Шаблон BasmanTitleBlock.dwg в C:\bti\templates\
- [ ] smoke_test.ps1 - 100% pass
- [ ] test_basman_pipeline.ps1 - 100% pass

---

## 🎊 После успешного deployment:

```
✅ BTI DWG QA Pipeline READY!
✅ Basmanny Template ACTIVE!
✅ Auto-Start ENABLED!
✅ Telegram CONFIGURED!
✅ Cloud Logging WORKING!

Просто помещайте DWG файлы в C:\bti\input\
и pipeline обработает их автоматически! 🚀
```

---

**Время deployment**: ~20-30 минут  
**Сложность**: Средняя (все автоматизировано)  
**Статус**: Ready to deploy! ✅

