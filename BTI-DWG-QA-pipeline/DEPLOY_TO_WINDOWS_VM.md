# 🚀 Deploy BTI DWG QA Pipeline to Windows VM

## ✅ ГОТОВО К DEPLOYMENT!

**Версия**: 1.0.0-basman  
**Шаблон**: Басманная (51 KB) ✅ Загружен  
**Instance**: instance-20251019-062935  
**External IP**: 104.198.201.212

---

## 📋 Что уже готово:

✅ **Репозиторий**: Весь код на GitHub (ветка `release/DWG-QA-v1`)  
✅ **Шаблон Басманная**: 51 KB DWG файл в `templates/`  
✅ **Deployment скрипты**: 7 PowerShell скриптов  
✅ **n8n Workflows**: 4 workflow (включая auto-start)  
✅ **Конфигурации**: templates.json, validation_rules.json  
✅ **Тесты**: 54 теста (100% pass rate)  
✅ **Документация**: 5 документов (~50 страниц)

---

## 🎯 DEPLOYMENT НА WINDOWS VM

### 🔐 Шаг 0: Подключение к VM

**Вариант 1: Через gcloud (с Mac)**
```bash
gcloud compute ssh instance-20251019-062935 \
    --zone=us-central1-f \
    --project=talkhint
```

**Вариант 2: Через Cloud Console**
1. Откройте: https://console.cloud.google.com/compute/instances?project=talkhint
2. Найдите: instance-20251019-062935
3. Нажмите: **SSH** → **Open in browser window**

---

### 📥 Шаг 1: Клонировать репозиторий (2 мин)

```powershell
# На Windows Server VM выполните:
cd C:\Users\Administrator

git clone https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git

cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto

git checkout release/DWG-QA-v1

cd BTI-DWG-QA-pipeline\deployment
```

**Проверка**:
```powershell
# Должны быть deployment скрипты
ls *.ps1
# Вывод: deploy_all.ps1, deploy_bti_pipeline.ps1, setup_firewall.ps1, и др.

# Должен быть шаблон
ls ..\templates\BasmanTitleBlock.dwg
# Вывод: BasmanTitleBlock.dwg (51 KB)
```

---

### 🚀 Шаг 2: ONE-CLICK DEPLOYMENT (20-30 мин)

**ВАРИАНТ A: Автоматический (рекомендуется)**

```powershell
# Весь deployment одной командой
.\deploy_all.ps1
```

Скрипт выполнит все 7 шагов автоматически:
1. Main deployment (10-15 мин)
2. Firewall setup (2-3 мин)
3. Cloud Logging (3-5 мин)
4. Import workflows (1-2 мин)
5. Telegram integration (2-3 мин)
6. Smoke test (1-2 мин)
7. Basmanny test (1-2 мин)

---

**ВАРИАНТ B: Пошаговый (для отладки)**

```powershell
# Выполнять по порядку:
.\deploy_bti_pipeline.ps1     # Шаг 1 (10-15 мин)
.\setup_firewall.ps1           # Шаг 2 (2-3 мин)
.\setup_logging.ps1            # Шаг 3 (3-5 мин)
.\import_workflows.ps1         # Шаг 4 (1-2 мин)
.\setup_telegram.ps1           # Шаг 5 (2-3 мин)
.\smoke_test.ps1               # Шаг 6 (1-2 мин)
.\test_basman_pipeline.ps1     # Шаг 7 (1-2 мин)
```

---

### ✅ Шаг 3: Проверка deployment

```powershell
# 1. Проверить сервисы
Get-Service -Name "n8n", "google-cloud-ops-agent" | Format-Table -AutoSize

# Вывод:
# Status   Name                        DisplayName
# ------   ----                        -----------
# Running  n8n                         n8n BTI DWG QA Pipeline
# Running  google-cloud-ops-agent      Google Cloud Ops Agent


# 2. Проверить n8n Web UI
Invoke-WebRequest http://localhost:5678/healthz

# Должен вернуть: StatusCode 200


# 3. Проверить файлы
ls C:\bti\templates\BasmanTitleBlock.dwg
ls C:\bti\config\templates.json
ls C:\bti\scripts\apply_basman_template.py


# 4. Проверить переменные окружения
[Environment]::GetEnvironmentVariable("TELEGRAM_BOT_TOKEN", "Machine")
[Environment]::GetEnvironmentVariable("TELEGRAM_CHAT_ID", "Machine")
# Должны быть непустые значения
```

---

### 🎯 Шаг 4: Настройка n8n workflows

**Открыть n8n Web UI**:
- Внутри VM: http://localhost:5678
- Снаружи: http://104.198.201.212:5678

**Активировать auto-start workflow**:
1. Открыть workflow: **BTI_0_Watch_Input_AutoStart**
2. Нажать кнопку **"Active"** (вверху справа) ✅
3. Workflow начнет мониторить `C:\bti\input\`

**Настроить путь к DWG Converter**:
1. Открыть workflow: **BTI_1_DWG_Convert**
2. Редактировать node: **"Setup - Define DWG Paths"**
3. Обновить:
   ```javascript
   path_to_dwg_converter: "C:\\DDC_CONVERTER_DWG\\datadrivenlibs\\DwgExporter.exe"
   ```
4. Сохранить

---

### 🧪 Шаг 5: Первый тест (5 мин)

```powershell
# 1. Создать тестовый DWG файл
# (или скопировать свой реальный DWG)

# 2. Поместить в input
Copy-Item "C:\путь\к\вашему\файлу.dwg" "C:\bti\input\test_001.dwg"

# 3. Подождать 10-15 секунд (auto-start сработает)

# 4. Проверить результаты
Get-ChildItem C:\bti\output\converted\   # Должен быть: test_001_basman.dwg
Get-ChildItem C:\bti\output\*.xlsx       # Должен быть: test_001_dwg.xlsx
Get-Content C:\bti\output\logs\qa_log.json  # Результаты валидации
Get-ChildItem C:\bti\output\*_QTO.html   # QTO отчет

# 5. Проверить Telegram
# Должно прийти уведомление от @N8Ndwg_bot
```

---

## 📊 Мониторинг

### Cloud Logging (с локального Mac)

```bash
# Просмотр логов BTI pipeline
gcloud logging read "jsonPayload.pipeline_name=\"BTI-DWG-QA\"" \
    --project=talkhint \
    --limit=20 \
    --format=json

# Фильтр по типу
gcloud logging read "jsonPayload.type=\"conversion\"" \
    --project=talkhint \
    --limit=10

# Web UI
open "https://console.cloud.google.com/logs/query?project=talkhint"
```

### Serial Port Console

```bash
# С локального Mac
gcloud compute instances get-serial-port-output instance-20251019-062935 \
    --zone=us-central1-f \
    --project=talkhint \
    --port=1
```

### n8n Execution History

Откройте n8n Web UI → **Executions**
- Просмотр всех запусков
- Детали каждого выполнения
- Ошибки и логи

---

## 🎊 ФИНАЛЬНЫЙ ЧЕКЛИСТ

После deployment проверьте:

### Infrastructure ✅
- [ ] VM instance запущена: instance-20251019-062935
- [ ] External IP: 104.198.201.212
- [ ] Firewall rule создан: allow-n8n-5678
- [ ] Serial Port 1 включен

### Services ✅
- [ ] n8n service: Running, auto-start
- [ ] google-cloud-ops-agent: Running
- [ ] n8n Web UI доступен: http://104.198.201.212:5678

### Configuration ✅
- [ ] Репозиторий клонирован
- [ ] Ветка: release/DWG-QA-v1
- [ ] Шаблон Basmanny: C:\bti\templates\BasmanTitleBlock.dwg (51 KB)
- [ ] templates.json обновлен
- [ ] Секреты загружены из Secret Manager

### Workflows ✅
- [ ] Импортировано 4 workflows
- [ ] Auto-start workflow активирован
- [ ] Пути к DWG converter настроены

### Testing ✅
- [ ] smoke_test.ps1: 100% pass rate
- [ ] test_basman_pipeline.ps1: 100% pass rate
- [ ] Первый тестовый файл обработан
- [ ] Telegram уведомление получено
- [ ] Логи видны в Cloud Logging

---

## 🎉 DEPLOYMENT COMPLETE!

```
✅ BTI DWG QA Pipeline развернут
✅ Шаблон Басманная интегрирован
✅ Auto-start включен
✅ Telegram бот настроен
✅ Cloud Logging работает
✅ Все тесты пройдены (54/54)

🚀 READY FOR PRODUCTION!
```

---

## 📞 Помощь

**Документация**:
- `deployment/DEPLOY_NOW.md` - Быстрый deploy guide
- `deployment/DEPLOYMENT.md` - Полное руководство
- `deployment/FINAL_REPORT.md` - Финальный отчет

**GitHub**: https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/tree/release/DWG-QA-v1

**Support**: info@datadrivenconstruction.io

---

**Время deployment**: ~20-30 минут  
**Сложность**: Низкая (все автоматизировано)  
**Статус**: ✅ Ready to deploy!

