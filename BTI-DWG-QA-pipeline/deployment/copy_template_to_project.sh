#!/bin/bash
# =============================================================================
# BTI DWG QA Pipeline - Copy Template to Project
# =============================================================================
# Purpose: Copy Basmanny template from Mac to project
# =============================================================================

set -e

echo "=============================================================================="
echo "  Copy Basmanny Template to Project"
echo "=============================================================================="
echo ""

# Configuration
PROJECT_DIR="/Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline"
TEMPLATES_DIR="$PROJECT_DIR/templates"
CONFIG_FILE="$PROJECT_DIR/config/templates.json"

# Create templates directory
mkdir -p "$TEMPLATES_DIR"

# Search for template files
echo "Searching for template files..."
echo ""

# Common locations on Mac
SEARCH_LOCATIONS=(
    "$HOME/Desktop"
    "$HOME/Downloads"
    "$HOME/Documents"
    "$HOME/Documents/CAD"
    "$HOME/Documents/AutoCAD"
    "$HOME/Documents/Templates"
    "$HOME/Google Drive"
    "$HOME/Dropbox"
    "/Users/Shared"
)

FOUND_FILES=()

for location in "${SEARCH_LOCATIONS[@]}"; do
    if [ -d "$location" ]; then
        echo "Searching in: $location"
        
        # Search for DWG files with relevant names
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                FOUND_FILES+=("$file")
                echo "  ✓ Found: $file"
            fi
        done < <(find "$location" -maxdepth 3 -type f \( -iname "*basman*.dwg" -o -iname "*titleblock*.dwg" -o -iname "*template*.dwg" \) 2>/dev/null)
    fi
done

echo ""

if [ ${#FOUND_FILES[@]} -eq 0 ]; then
    echo "⚠️  No template files found automatically"
    echo ""
    echo "Please specify the template file path manually:"
    echo "  ./copy_template_to_project.sh /path/to/BasmanTitleBlock.dwg"
    echo ""
    echo "Or place the file in one of these locations:"
    for location in "${SEARCH_LOCATIONS[@]}"; do
        echo "  - $location"
    done
    echo ""
    exit 1
fi

# If user specified a file, use it
if [ ! -z "$1" ]; then
    SOURCE_FILE="$1"
    if [ ! -f "$SOURCE_FILE" ]; then
        echo "❌ File not found: $SOURCE_FILE"
        exit 1
    fi
else
    # Use first found file
    SOURCE_FILE="${FOUND_FILES[0]}"
    
    if [ ${#FOUND_FILES[@]} -gt 1 ]; then
        echo "Multiple template files found:"
        for i in "${!FOUND_FILES[@]}"; do
            echo "  $((i+1)). ${FOUND_FILES[$i]}"
        done
        echo ""
        echo "Using: $SOURCE_FILE"
        echo ""
    fi
fi

# Copy file
DEST_FILE="$TEMPLATES_DIR/BasmanTitleBlock.dwg"

echo "Copying template..."
echo "  Source: $SOURCE_FILE"
echo "  Destination: $DEST_FILE"
echo ""

cp "$SOURCE_FILE" "$DEST_FILE"

if [ -f "$DEST_FILE" ]; then
    echo "✓ Template copied successfully!"
    echo ""
    
    # Get file info
    FILE_SIZE=$(du -h "$DEST_FILE" | cut -f1)
    echo "File information:"
    echo "  Location: $DEST_FILE"
    echo "  Size: $FILE_SIZE"
    echo ""
    
    # Update templates.json
    if [ -f "$CONFIG_FILE" ]; then
        echo "Updating templates.json..."
        
        # Backup original
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
        
        # Update path (using Python for JSON manipulation)
        python3 -c "
import json
with open('$CONFIG_FILE', 'r', encoding='utf-8') as f:
    config = json.load(f)
config['templates']['Basmanny']['title_block']['template_file'] = '$DEST_FILE'
with open('$CONFIG_FILE', 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
print('✓ templates.json updated')
"
        echo ""
    fi
    
    # Git add
    cd "$PROJECT_DIR/.."
    git add templates/ config/templates.json
    
    echo "Next steps:"
    echo "  1. Verify the template: open $DEST_FILE"
    echo "  2. Commit changes: git commit -m 'Add Basmanny template file'"
    echo "  3. Push to GitHub: git push origin release/DWG-QA-v1"
    echo ""
    
else
    echo "❌ Failed to copy template"
    exit 1
fi

