#!/bin/bash
# Команды для копирования шаблона Басманная с Desktop

echo "========================================================================"
echo "  Копирование шаблона Басманная в проект"
echo "========================================================================"
echo ""

# 1. Создать папку templates
echo "1. Создаем папку templates..."
mkdir -p /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates
echo "✓ Папка создана"
echo ""

# 2. Копировать файл с Desktop
echo "2. Копируем файл с Desktop..."
cp ~/Desktop/"Чертеж Басманная Новая обмерный план.dwg" \
   /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/BasmanTitleBlock.dwg

if [ $? -eq 0 ]; then
    echo "✓ Файл скопирован успешно!"
else
    echo "⚠️  Ошибка копирования. Возможно нужно дать доступ Terminal к Desktop"
    echo ""
    echo "Альтернативный способ:"
    echo "1. Откройте Finder"
    echo "2. Скопируйте файл 'Чертеж Басманная Новая обмерный план.dwg' с Desktop"
    echo "3. Вставьте в папку: BTI-DWG-QA-pipeline/templates/"
    echo "4. Переименуйте в: BasmanTitleBlock.dwg"
    exit 1
fi
echo ""

# 3. Проверить файл
echo "3. Проверяем файл..."
ls -lh /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/BasmanTitleBlock.dwg
echo ""

# 4. Обновить конфигурацию
echo "4. Обновляем конфигурацию templates.json..."
cd /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline

python3 << 'EOF'
import json
try:
    with open('config/templates.json', 'r', encoding='utf-8') as f:
        config = json.load(f)
    config['templates']['Basmanny']['title_block']['template_file'] = 'templates/BasmanTitleBlock.dwg'
    with open('config/templates.json', 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    print('✓ Конфигурация обновлена!')
except Exception as e:
    print(f'⚠️  Ошибка: {e}')
EOF
echo ""

# 5. Добавить в Git
echo "5. Добавляем в Git..."
cd /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto
git add BTI-DWG-QA-pipeline/templates/
git add BTI-DWG-QA-pipeline/config/templates.json
echo "✓ Файлы добавлены в Git"
echo ""

# 6. Commit
echo "6. Создаем commit..."
git commit -m "Add Basmanny district template DWG file from Desktop"
echo ""

# 7. Push
echo "7. Отправляем на GitHub..."
git push origin release/DWG-QA-v1
echo ""

echo "========================================================================"
echo "  ✅ ГОТОВО!"
echo "========================================================================"
echo ""
echo "Шаблон Басманная успешно добавлен в проект!"
echo ""
echo "Файл: BTI-DWG-QA-pipeline/templates/BasmanTitleBlock.dwg"
echo "Размер: $(du -h /Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline/templates/BasmanTitleBlock.dwg 2>/dev/null | cut -f1 || echo 'неизвестно')"
echo ""

