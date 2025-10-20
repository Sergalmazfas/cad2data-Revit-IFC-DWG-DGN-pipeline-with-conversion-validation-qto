# 🎯 START HERE - BTI DWG QA Pipeline Deployment

## ⚡ 3 простых шага для deployment:

---

## 📍 ШАГ 1: Подключитесь к Windows VM

### С вашего Mac:
```bash
gcloud compute ssh instance-20251019-062935 \
    --zone=us-central1-f \
    --project=talkhint
```

### Или через браузер:
https://console.cloud.google.com/compute/instances?project=talkhint

Нажмите **SSH** напротив instance-20251019-062935

---

## 📥 ШАГ 2: Скопируйте эти команды в PowerShell на VM

```powershell
cd C:\Users\Administrator
git clone https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git
cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto
git checkout release/DWG-QA-v1
cd BTI-DWG-QA-pipeline\deployment
```

---

## 🚀 ШАГ 3: Запустите ONE-CLICK deployment

```powershell
.\deploy_all.ps1
```

**Время**: 20-30 минут  
**Всё автоматически**: Да ✅

---

## ✅ После deployment

1. **Откройте n8n**: http://104.198.201.212:5678

2. **Активируйте auto-start**:
   - Workflow: `BTI_0_Watch_Input_AutoStart`
   - Кнопка: **"Active"** ✅

3. **Поместите DWG файл**:
   ```powershell
   Copy-Item "C:\ваш\файл.dwg" "C:\bti\input\"
   ```

4. **Проверьте результаты** (через 15-30 секунд):
   - `C:\bti\output\converted\*_basman.dwg` ✅
   - `C:\bti\output\*.xlsx` ✅
   - `C:\bti\output\logs\qa_log.json` ✅
   - Telegram уведомление ✅

---

## 🎊 ГОТОВО!

Pipeline работает автоматически! 🚀

**Документация**: 
- `DEPLOY_TO_WINDOWS_VM.md` - Полная инструкция
- `deployment/FINAL_REPORT.md` - Финальный отчет
- `deployment/DEPLOY_NOW.md` - Deploy guide

**GitHub**: https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/tree/release/DWG-QA-v1

