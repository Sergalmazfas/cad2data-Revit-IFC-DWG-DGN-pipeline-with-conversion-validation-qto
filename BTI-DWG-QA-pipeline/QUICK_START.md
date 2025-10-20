# 🚀 Quick Start Guide - BTI DWG QA Pipeline

## 5-минутный старт

### Шаг 1: Установите Node.js и n8n
```bash
# Скачайте Node.js с https://nodejs.org/
# После установки запустите:
npx n8n
```

### Шаг 2: Откройте n8n
- Откройте браузер: `http://localhost:5678`
- Создайте аккаунт (локально)

### Шаг 3: Импортируйте workflow
1. В n8n: **Workflows** → **Import from File**
2. Выберите `n8n_1_BTI_Convert.json`
3. Workflow откроется автоматически

### Шаг 4: Настройте пути
Найдите ноду **"Setup - Define DWG Paths"** и измените:

```javascript
// Путь к конвертеру
path_to_dwg_converter: "C:\\DDC_CONVERTER_DWG\\datadrivenlibs\\DwgExporter.exe"

// Путь к вашему DWG файлу
dwg_file_path: "C:\\Projects\\floor_plan.dwg"

// Папка для результатов
output_folder: "C:\\Output"
```

### Шаг 5: Запустите
Нажмите кнопку **"Execute Workflow"** ⚡

---

## Полный цикл обработки

### 1. Конвертация
```bash
# Импортируйте: n8n_1_BTI_Convert.json
# Настройте пути
# Запустите → получите XLSX
```

### 2. Валидация
```bash
# Импортируйте: n8n_2_BTI_Validation.json
# Укажите путь к XLSX файлу
# Запустите → получите JSON отчет
```

### 3. QTO Отчет
```bash
# Импортируйте: n8n_3_BTI_QTO.json
# Укажите путь к XLSX файлу
# Запустите → получите HTML отчет
```

---

## Где скачать конвертер?

### Вариант 1: ODAFileConverter (рекомендуется)
- **Сайт**: https://www.opendesign.com/guestfiles/oda_file_converter
- **Цена**: Бесплатный
- **Платформы**: Windows, Mac, Linux

### Вариант 2: DDC DWG Converter
- **Репозиторий**: [cad2data GitHub](https://github.com/datadrivenconstruction/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto)
- **Папка**: `DDC_CONVERTER_DWG/`
- **Исполняемый файл**: `datadrivenlibs/DwgExporter.exe`

### Вариант 3: LibreDWG
```bash
# Ubuntu/Debian
sudo apt-get install libredwg-dev

# macOS
brew install libredwg
```

---

## Структура результатов

После конвертации получите:

```
Output/
├── floor_plan_dwg.xlsx          # Таблица с данными
├── floor_plan_validation.json   # Результат валидации
└── floor_plan_QTO.html          # Отчет с метриками
```

---

## Типичные проблемы

### ❌ "Converter not found"
**Решение**: Проверьте путь к конвертеру. Убедитесь, что указали файл внутри `datadrivenlibs/`

### ❌ "XLSX file is empty"
**Решение**: 
1. Проверьте версию DWG файла (должна быть совместима)
2. Попробуйте другой конвертер
3. Убедитесь, что DWG файл не поврежден

### ❌ "n8n не запускается"
**Решение**: 
```bash
# Обновите до последней версии
npm install -g n8n@latest

# Или используйте npx
npx n8n@latest
```

---

## Следующие шаги

1. ✅ Настройте правила валидации в `config/validation_rules.json`
2. ✅ Кастомизируйте HTML отчет (измените код в workflow)
3. ✅ Настройте автоматический запуск (Schedule Trigger в n8n)
4. ✅ Интегрируйте с вашей системой (Webhook, API, Database)

---

## 📚 Полная документация

Читайте [README.md](README.md) для детальной информации.

---

## 🆘 Помощь

- **GitHub Issues**: [Создать issue](https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline/issues)
- **Email**: info@datadrivenconstruction.io
- **Website**: https://datadrivenconstruction.io

---

**Удачи! 🎉**

