# 📋 Инструкция: Копирование шаблона Басманная

## 🎯 Файл найден на Desktop:

**Имя файла**: `Чертеж Басманная Новая обмерный план.dwg`

---

## ✅ Способ 1: Копирование через Finder (рекомендуется)

### Шаги:

1. **Откройте Finder**
2. **Перейдите на Desktop** (⌘ + Shift + D)
3. **Найдите файл**: `Чертеж Басманная Новая обмерный план.dwg`
4. **Скопируйте файл** (⌘ + C)
5. **Перейдите в папку проекта**:
   ```
   /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/
   ```
6. **Вставьте файл** (⌘ + V)
7. **Переименуйте** в `BasmanTitleBlock.dwg`

---

## ✅ Способ 2: Через Terminal (с правами доступа)

```bash
# 1. Дать Terminal доступ к Desktop
# System Preferences → Security & Privacy → Privacy → Files and Folders
# Включить доступ для Terminal к Desktop

# 2. После этого выполнить:
cp ~/Desktop/"Чертеж Басманная Новая обмерный план.dwg" \
   /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/BasmanTitleBlock.dwg
```

---

## ✅ Способ 3: Переместить файл в доступное место

```bash
# 1. Скопируйте файл с Desktop в Downloads (через Finder)

# 2. Затем выполните:
cp ~/Downloads/"Чертеж Басманная Новая обмерный план.dwg" \
   /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/BasmanTitleBlock.dwg
```

---

## ✅ Способ 4: Перетащить файл в проект

1. **Откройте две окна Finder**
2. **Первое окно**: Desktop с файлом
3. **Второе окно**: 
   ```
   /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/
   ```
4. **Перетащите файл** из первого окна во второе (удерживая Option для копирования)
5. **Переименуйте** в `BasmanTitleBlock.dwg`

---

## 📝 После копирования:

### 1. Обновить конфигурацию:

```bash
cd /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline

# Обновить templates.json
python3 << 'EOF'
import json
config_file = 'config/templates.json'
with open(config_file, 'r', encoding='utf-8') as f:
    config = json.load(f)
config['templates']['Basmanny']['title_block']['template_file'] = 'templates/BasmanTitleBlock.dwg'
with open(config_file, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
print('✓ Configuration updated')
EOF
```

### 2. Проверить файл:

```bash
ls -lh /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/BasmanTitleBlock.dwg
```

### 3. Добавить в Git:

```bash
cd /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto

git add BTI-DWG-QA-pipeline/templates/
git add BTI-DWG-QA-pipeline/config/templates.json

git commit -m "Add Basmanny district template DWG file"
git push origin release/DWG-QA-v1
```

---

## ✅ Быстрая команда (если доступ есть):

```bash
# Одной командой (после предоставления доступа):
mkdir -p /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates && \
cp ~/Desktop/"Чертеж Басманная Новая обмерный план.dwg" \
   /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/BasmanTitleBlock.dwg && \
echo "✓ Template copied!" && \
ls -lh /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/
```

---

## 🎯 Итог:

**Файл на Desktop**: `Чертеж Басманная Новая обмерный план.dwg`  
**Целевая папка**: `BTI-DWG-QA-pipeline/templates/`  
**Целевое имя**: `BasmanTitleBlock.dwg`

**Рекомендация**: Используйте **Способ 1 (Finder)** - самый простой и надежный! 🎉

