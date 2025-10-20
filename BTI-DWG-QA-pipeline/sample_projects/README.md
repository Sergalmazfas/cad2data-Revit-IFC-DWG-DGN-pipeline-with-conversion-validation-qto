# Sample Projects

## 📁 Где взять примеры DWG файлов?

Для тестирования BTI DWG QA Pipeline вам потребуются DWG файлы архитектурных чертежей.

### Вариант 1: Используйте примеры из основного репозитория

В основном репозитории [cad2data](https://github.com/datadrivenconstruction/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto) есть папка `Sample_Projects/` с примерами:

```
Sample_Projects/
├── architectural_example-imperial.dwg    # AutoCAD пример (имперские единицы)
└── ... другие файлы
```

Скопируйте `architectural_example-imperial.dwg` в эту папку для тестирования.

---

### Вариант 2: Скачайте бесплатные DWG файлы

#### Источники бесплатных DWG файлов:

1. **Autodesk Sample Files**
   - https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html

2. **CADBlocks.net**
   - https://www.cadblocks.net/
   - Бесплатные блоки и чертежи

3. **CAD Forum**
   - https://www.cadforum.cz/en/dwg-files
   - Коллекция примеров DWG

4. **GrabCAD**
   - https://grabcad.com/
   - Сообщество с CAD файлами

---

### Вариант 3: Создайте свой DWG файл

Используйте бесплатные CAD редакторы:

1. **LibreCAD** (бесплатный, open-source)
   - https://librecad.org/
   - Windows, Mac, Linux

2. **DraftSight Free** (бесплатная версия)
   - https://www.draftsight.com/

3. **Autodesk AutoCAD Web** (онлайн)
   - https://web.autocad.com/

---

## 🧪 Рекомендуемые файлы для тестирования

Для полноценного тестирования BTI pipeline рекомендуем использовать DWG файлы, содержащие:

- ✅ **Слои**: WALLS, WINDOWS, DOORS, ROOMS, DIMENSIONS
- ✅ **Объекты**: Линии, полилинии, блоки
- ✅ **Размеры**: Площади и периметры помещений
- ✅ **Текст**: Названия помещений, номера
- ✅ **Координаты**: Правильная координатная система

---

## 📋 Пример структуры слоев

Хороший тестовый DWG файл должен иметь структуру:

```
Layers:
├── WALLS          (Стены)
├── WINDOWS        (Окна)
├── DOORS          (Двери)
├── ROOMS          (Помещения)
├── DIMENSIONS     (Размерные линии)
├── TEXT           (Текстовые аннотации)
└── FURNITURE      (Мебель, опционально)
```

---

## 🔧 Подготовка ваших DWG файлов

Перед конвертацией рекомендуем:

1. **Очистите чертеж**
   ```
   AutoCAD команда: PURGE
   ```

2. **Проверьте слои**
   - Убедитесь, что слои правильно названы
   - Объекты на правильных слоях

3. **Проверьте единицы измерения**
   ```
   AutoCAD команда: UNITS
   ```

4. **Сохраните в совместимом формате**
   - Рекомендуется: AutoCAD 2018 DWG
   - Или: AutoCAD 2013 DWG (для совместимости)

---

## 💾 Размещение файлов

После получения DWG файлов, разместите их здесь:

```
BTI-DWG-QA-pipeline/
└── sample_projects/
    ├── example_1.dwg
    ├── example_2.dwg
    └── floor_plan.dwg
```

Затем обновите пути в n8n workflows:

```javascript
dwg_file_path: "./sample_projects/example_1.dwg"
```

---

## 📊 Ожидаемые результаты

После конвертации примерных файлов вы должны получить:

### XLSX файл должен содержать:
- Колонки: `Handle`, `Layer`, `EntityType`, `Area`, `Perimeter`, `X`, `Y`
- Строки: каждый объект из DWG

### Валидация должна показать:
- Pass rate > 90%
- Найденные слои
- Ошибки и предупреждения

### QTO отчет должен содержать:
- Общую площадь
- Количество окон и дверей
- Таблицы по слоям

---

## ⚠️ Gitignore

По умолчанию `.gitignore` настроен так, что DWG файлы **не коммитятся** в репозиторий:

```gitignore
*.dwg
*.dxf
```

Это экономит место и соблюдает авторские права. Каждый пользователь должен получить свои тестовые файлы самостоятельно.

---

## 🤝 Вклад

Если у вас есть хорошие примеры DWG файлов (с открытой лицензией), вы можете:

1. Добавить ссылки в этот README
2. Создать Pull Request
3. Поделиться в Issues

---

**Удачного тестирования! 🎉**

