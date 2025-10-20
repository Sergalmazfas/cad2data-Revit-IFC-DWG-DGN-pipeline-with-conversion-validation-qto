# BTI DWG QA Pipeline

<p align="center">
  <img src="https://img.shields.io/badge/DWG-Converter-blue?logo=autodesk&logoColor=white" alt="DWG Converter">
  <img src="https://img.shields.io/badge/QA-Validation-green" alt="QA Validation">
  <img src="https://img.shields.io/badge/QTO-Reports-orange" alt="QTO Reports">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License">
</p>

## 📋 Назначение проекта

**BTI DWG QA Pipeline** — это упрощенная контрольная версия пайплайна для автоматизированной обработки DWG файлов архитектурных чертежей с акцентом на валидацию и подсчет объемов работ (QTO) для задач БТИ (Бюро Технической Инвентаризации).

### Что делает проект:

1. **Конвертация DWG → XLSX** — преобразование чертежей в структурированные табличные данные
2. **Валидация данных** — автоматическая проверка на соответствие требованиям БТИ
3. **Генерация отчетов QTO** — подсчет площадей, периметров, количества окон/дверей
4. **Логирование** — отслеживание всех операций для аудита

---

## 🎯 Основные возможности

✅ **DWG-only** — работает только с DWG файлами (без Revit, IFC, DGN)  
✅ **Оффлайн работа** — не требует интернета и лицензий Autodesk  
✅ **Автоматическая валидация** — проверка слоев, объектов, размеров  
✅ **HTML отчеты** — красивые интерактивные отчеты с метриками  
✅ **JSON логи** — структурированное логирование всех операций  
✅ **n8n интеграция** — готовые workflow для автоматизации  

---

## 📁 Структура проекта

```
BTI-DWG-QA-pipeline/
├── n8n_1_BTI_Convert.json          # Workflow: Конвертация DWG → XLSX
├── n8n_2_BTI_Validation.json       # Workflow: Валидация данных
├── n8n_3_BTI_QTO.json              # Workflow: Генерация QTO отчетов
├── config/
│   ├── validation_rules.json       # Правила валидации БТИ
│   ├── converter_settings.json     # Настройки конвертеров
│   └── qa_log_template.json        # Шаблон QA логов
├── scripts/
│   ├── qa_logger.js                # Утилита логирования
│   └── dwg_validator.js            # Валидатор DWG данных
├── sample_projects/                # Примеры DWG файлов
└── README.md                       # Эта документация
```

---

## 🚀 Быстрый старт

### Предварительные требования

1. **Node.js** (версия 18+) — [Скачать](https://nodejs.org/)
2. **n8n** — установка через npm:
   ```bash
   npm install -g n8n
   ```
3. **DWG Конвертер** (один из):
   - **ODAFileConverter** (бесплатный) — [Скачать](https://www.opendesign.com/guestfiles/oda_file_converter)
   - **LibreDWG** (open-source) — [Скачать](https://www.gnu.org/software/libredwg/)
   - **DDC DWG Converter** (из основного проекта)

### Установка

1. **Клонируйте репозиторий или скачайте ZIP**:
   ```bash
   git clone https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline.git
   cd BTI-DWG-QA-pipeline
   ```

2. **Запустите n8n**:
   ```bash
   npx n8n
   ```
   Откройте браузер: `http://localhost:5678`

3. **Импортируйте workflow**:
   - В n8n: **Workflows → Import from File**
   - Выберите `n8n_1_BTI_Convert.json`

4. **Настройте пути** в ноде "Setup - Define DWG Paths":
   ```javascript
   path_to_dwg_converter: "C:\\DDC_CONVERTER_DWG\\datadrivenlibs\\DwgExporter.exe"
   dwg_file_path: "C:\\Sample_Projects\\architectural_example.dwg"
   output_folder: "C:\\Output"
   ```

5. **Запустите workflow** — нажмите **Execute Workflow**

---

## 📖 Использование

### 1️⃣ Конвертация DWG (n8n_1_BTI_Convert.json)

**Назначение**: Конвертирует DWG файлы в XLSX таблицы со структурированными данными.

**Входные данные**:
- DWG файл с архитектурным чертежом

**Выходные данные**:
- XLSX файл с таблицей объектов (слои, типы, координаты, размеры)

**Настройка**:
```javascript
// В ноде "Setup - Define DWG Paths"
path_to_dwg_converter: "путь/к/DwgExporter.exe"
dwg_file_path: "путь/к/вашему/файлу.dwg"
output_folder: "путь/для/сохранения/результатов"
```

**Запуск**:
1. Откройте workflow в n8n
2. Нажмите **Execute Workflow**
3. Проверьте папку `output_folder` — там будет файл `filename_dwg.xlsx`

---

### 2️⃣ Валидация данных (n8n_2_BTI_Validation.json)

**Назначение**: Проверяет DWG данные на соответствие требованиям БТИ.

**Проверки**:
- ✅ Наличие обязательных слоев (WALLS, WINDOWS, DOORS, ROOMS)
- ✅ Валидность типов объектов
- ✅ Корректность расчета площадей и периметров
- ✅ Проверка координатной системы
- ✅ Соответствие именования слоев стандарту

**Входные данные**:
- XLSX файл (результат конвертации)

**Выходные данные**:
- JSON отчет с результатами валидации
- Summary статистика (pass rate, количество ошибок)

**Настройка правил валидации**:

Откройте `config/validation_rules.json` и настройте:
```json
{
  "rules": {
    "required_layers": ["WALLS", "WINDOWS", "DOORS", "ROOMS"],
    "entity_checks": {
      "area_min": 0.1,
      "area_max": 10000
    },
    "quality_thresholds": {
      "min_pass_rate": 90
    }
  }
}
```

---

### 3️⃣ Генерация QTO отчетов (n8n_3_BTI_QTO.json)

**Назначение**: Создает красивые HTML отчеты с подсчетом объемов работ.

**Рассчитываемые метрики**:
- 📐 Общая площадь (м²)
- 📏 Общий периметр (м)
- 🪟 Количество окон
- 🚪 Количество дверей
- 📊 Группировка по слоям
- 📋 Группировка по типам объектов
- 🏠 Таблица помещений с площадями

**Выходные данные**:
- HTML отчет (автоматически открывается в браузере)
- Интерактивные таблицы
- Визуальные метрики

**Пример отчета**:
```
┌─────────────────────────────────────┐
│  BTI Quantity Take-Off Report       │
├─────────────────────────────────────┤
│  Total Area:      1,245.67 m²       │
│  Total Perimeter:   487.23 m        │
│  Windows:          24 units         │
│  Doors:            12 units         │
└─────────────────────────────────────┘

Entities by Layer:
  WALLS:    34 objects, 856.45 m², 234.12 m
  WINDOWS:  24 objects,  45.67 m²,  89.34 m
  DOORS:    12 objects,  23.45 m²,  45.67 m
```

---

## 🔧 Настройка конвертеров

### Вариант 1: ODAFileConverter (рекомендуется)

**Установка**:
1. Скачайте с [официального сайта](https://www.opendesign.com/guestfiles/oda_file_converter)
2. Установите на Windows/Mac/Linux
3. Укажите путь к исполняемому файлу в workflow

**Команда конвертации**:
```bash
ODAFileConverter "input.dwg" "output_folder" ACAD2018 DXF 0 1
```

### Вариант 2: LibreDWG (open-source)

**Установка (Linux/Mac)**:
```bash
# Ubuntu/Debian
sudo apt-get install libredwg-dev

# macOS
brew install libredwg
```

**Команда конвертации**:
```bash
dwg2dxf input.dwg -o output.dxf
```

### Вариант 3: DDC DWG Converter

**Установка**:
1. Скачайте из основного репозитория
2. Разархивируйте `DDC_CONVERTER_DWG/`
3. Путь к конвертеру: `DDC_CONVERTER_DWG/datadrivenlibs/DwgExporter.exe`

**Использование**:
```bash
DwgExporter.exe "input.dwg"
```

---

## 📊 Логирование и QA Report

Все операции автоматически логируются в `logs/` директории.

### Структура логов

```
logs/
├── conversion_2025-10-20.json      # JSON лог конвертаций
├── conversion_2025-10-20.txt       # Текстовый лог (человеко-читаемый)
├── validation_2025-10-20.json      # JSON лог валидации
├── validation_2025-10-20.txt       # Текстовый лог валидации
├── qto_2025-10-20.json             # JSON лог QTO
└── qto_2025-10-20.txt              # Текстовый лог QTO
```

### Пример лога конвертации (TXT)

```
[2025-10-20T14:32:15.123Z] Conversion SUCCESS
  Input: C:\Projects\Basmanny.dwg
  Output: C:\Output\Basmanny_dwg.xlsx
  Notes: All layers extracted successfully

--------------------------------------------------------------------------------
```

### Пример лога валидации (JSON)

```json
{
  "timestamp": "2025-10-20T14:35:42.456Z",
  "type": "validation",
  "input_file": "Basmanny_dwg.xlsx",
  "pass_rate": "94.5%",
  "total_entities": 1247,
  "failed_entities": 69,
  "status": "PASS",
  "issues": [
    "Missing layer information (12)",
    "Area not calculated (34)",
    "Invalid coordinates (23)"
  ]
}
```

---

## 🛠️ Ручные проверки чертежей

После автоматической валидации рекомендуется выполнить **ручные проверки**:

### Чек-лист для БТИ

- [ ] **Архитектурная полнота**
  - Все помещения обозначены
  - Все двери и окна на месте
  - Стены замкнуты

- [ ] **Точность размеров**
  - Размерные линии корректны
  - Площади помещений совпадают с фактическими
  - Масштаб чертежа правильный

- [ ] **Организация слоев**
  - Слои названы по стандарту
  - Объекты на правильных слоях
  - Нет дублирования объектов

- [ ] **Читаемость текста**
  - Все подписи читаемы
  - Шрифты стандартные
  - Размер текста соответствует масштабу

- [ ] **Координатная система**
  - Чертеж привязан к координатам
  - Север/юг обозначены
  - База точки установлена

### Шаблон для ручных проверок

Используйте файл `config/qa_log_template.json`:

```json
{
  "manual_checks": {
    "architectural_drawing_completeness": "✅ PASS",
    "dimension_accuracy": "✅ PASS",
    "layer_organization": "⚠️ WARNINGS",
    "text_readability": "✅ PASS",
    "coordinate_system": "✅ PASS",
    "comments": [
      "Layer 'WINDOWS' содержит объекты из слоя 'DOORS'",
      "Текст на плане этажа слишком мелкий"
    ]
  }
}
```

---

## 🧪 Тестирование

### Быстрый тест

1. **Скачайте пример DWG файла** (или используйте свой)
2. **Запустите все 3 workflow последовательно**:
   - `n8n_1_BTI_Convert.json` → получите XLSX
   - `n8n_2_BTI_Validation.json` → проверьте валидацию
   - `n8n_3_BTI_QTO.json` → сгенерируйте отчет

3. **Проверьте результаты**:
   - XLSX файл должен содержать данные
   - JSON валидация должна показать pass rate > 90%
   - HTML отчет должен открыться в браузере

---

## 🔗 Интеграция с n8n

### Автоматизация полного цикла

Вы можете объединить все 3 workflow в один автоматический пайплайн:

```
DWG файл
   ↓
[Convert] → XLSX
   ↓
[Validate] → Validation JSON
   ↓
[QTO] → HTML Report
   ↓
✅ Готовый отчет
```

### Триггеры для автоматизации

1. **File Watcher** — автоматически запускать при появлении нового DWG
2. **Schedule** — запускать по расписанию (например, каждую ночь)
3. **Webhook** — запускать через API вызов
4. **Email** — получать DWG по email и обрабатывать

---

## 📝 Примеры использования

### Пример 1: Разовая конвертация

```bash
# 1. Конвертация
npx n8n execute --workflow="n8n_1_BTI_Convert.json"

# 2. Проверка результата
ls output/*.xlsx
```

### Пример 2: Batch обработка

```javascript
// В n8n создайте цикл для обработки всех DWG в папке
const dwgFiles = ['project1.dwg', 'project2.dwg', 'project3.dwg'];

for (const file of dwgFiles) {
  // Конвертация
  // Валидация
  // QTO
}
```

### Пример 3: Интеграция с БД

```javascript
// После валидации сохраняйте результаты в БД
const validationResults = $json;

await db.insert('bti_validations', {
  project_name: validationResults.project_name,
  pass_rate: validationResults.pass_rate,
  date: new Date(),
  status: validationResults.status
});
```

---

## ⚙️ Расширенные настройки

### Кастомизация правил валидации

Отредактируйте `config/validation_rules.json`:

```json
{
  "rules": {
    "required_layers": [
      "WALLS",
      "WINDOWS", 
      "DOORS",
      "ROOMS",
      "DIMENSIONS",
      "FURNITURE"  // ← Добавьте свой слой
    ],
    "entity_checks": {
      "area_min": 1.0,      // ← Измените минимальную площадь
      "area_max": 500.0     // ← Измените максимальную площадь
    }
  }
}
```

### Добавление новых проверок

Отредактируйте `scripts/dwg_validator.js`:

```javascript
// Добавьте свою проверку
validateEntity(entity) {
  const issues = [];
  
  // Ваша кастомная проверка
  if (entity.Layer === 'WALLS' && !entity.Thickness) {
    issues.push('Wall missing thickness property');
  }
  
  return { issues, status: issues.length === 0 ? 'PASS' : 'FAIL' };
}
```

---

## 🆘 Troubleshooting

### Проблема: Конвертер не найден

**Решение**: Проверьте путь к конвертеру:
```javascript
// ПРАВИЛЬНО (внутри datadrivenlibs):
"C:\\DDC_CONVERTER_DWG\\datadrivenlibs\\DwgExporter.exe"

// НЕПРАВИЛЬНО:
"C:\\DDC_CONVERTER_DWG\\DwgExporter.exe"
```

### Проблема: XLSX файл пустой

**Решение**: 
1. Проверьте версию DWG файла (должна быть совместима с конвертером)
2. Убедитесь, что DWG файл не поврежден
3. Попробуйте другой конвертер (ODAFileConverter вместо DDC)

### Проблема: Валидация показывает 0% pass rate

**Решение**:
1. Откройте XLSX файл и проверьте названия колонок
2. Убедитесь, что данные загружены
3. Проверьте правила валидации в `validation_rules.json`

### Проблема: HTML отчет не открывается

**Решение**:
1. Проверьте путь сохранения отчета
2. Убедитесь, что у n8n есть права на запись
3. Откройте файл вручную в браузере

---

## 📚 Дополнительные ресурсы

### Документация

- [n8n Documentation](https://docs.n8n.io/)
- [ODA File Converter Guide](https://www.opendesign.com/guestfiles)
- [DWG File Format Specification](https://www.opendesign.com/files/guestdownloads/OpenDesign_Specification_for_.dwg_files.pdf)

### Обучение

- [n8n Quick Start Tutorial](https://youtu.be/HUbEPo-yfeA)
- [DWG to Excel Pipeline Tutorial](https://www.youtube.com/watch?v=jVU7vlMNTO0)

### Сообщество

- [GitHub Issues](https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline/issues)
- [n8n Community](https://community.n8n.io/)

---

## 🤝 Поддержка и контакты

**Вопросы и баги**: [GitHub Issues](https://github.com/datadrivenconstruction/BTI-DWG-QA-pipeline/issues)  
**Email**: info@datadrivenconstruction.io  
**Website**: [datadrivenconstruction.io](https://datadrivenconstruction.io)

---

## 📜 Лицензия

MIT License — свободное использование, модификация и распространение.

---

## 🎯 Roadmap

### v1.1 (планируется)
- [ ] Web UI для управления пайплайном
- [ ] Batch обработка множества DWG файлов
- [ ] Интеграция с PostgreSQL/MongoDB
- [ ] REST API для внешних систем

### v1.2 (планируется)
- [ ] PDF генерация отчетов
- [ ] Email уведомления
- [ ] Telegram бот для мониторинга
- [ ] Docker контейнеризация

---

## ⭐ Благодарности

Этот проект является упрощенной версией [cad2data-Revit-IFC-DWG-DGN-pipeline](https://github.com/datadrivenconstruction/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto).

**Если проект полезен, поставьте ⭐ на GitHub!**

---

<p align="center">
  Made with ❤️ for BTI and construction automation
</p>

