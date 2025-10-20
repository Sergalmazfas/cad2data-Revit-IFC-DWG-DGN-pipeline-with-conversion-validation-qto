#!/bin/bash
# =============================================================================
# BTI DWG QA Pipeline - Migrate from swiftchair to talkhint project
# =============================================================================

set -e

echo "=============================================================================="
echo "  Migrating BTI DWG QA Pipeline to talkhint project"
echo "=============================================================================="
echo ""

PROJECT_DIR="/Users/seregaboss/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto/BTI-DWG-QA-pipeline"

cd "$PROJECT_DIR"

echo "Updating project ID from swiftchair to talkhint..."
echo ""

# Files to update
FILES=(
    "deployment/deploy_all.ps1"
    "deployment/deploy_bti_pipeline.ps1"
    "deployment/setup_firewall.ps1"
    "deployment/setup_logging.ps1"
    "deployment/verify_deployment.ps1"
    "deployment/download_template_from_gcs.ps1"
    "deployment/DEPLOY_NOW.md"
    "deployment/DEPLOYMENT.md"
    "deployment/FINAL_REPORT.md"
    "deployment/README.md"
    "DEPLOY_TO_WINDOWS_VM.md"
    "DEPLOY_COMMANDS.txt"
    "START_HERE.md"
    "PRODUCTION_DEPLOYMENT_CHECKLIST.md"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Updating: $file"
        sed -i '' 's/swiftchair/talkhint/g' "$file"
        echo "  ✓ Updated"
    else
        echo "  ⚠ File not found: $file"
    fi
done

echo ""
echo "=============================================================================="
echo "  Migration Complete!"
echo "=============================================================================="
echo ""
echo "Updated project ID to: talkhint"
echo "Instance: instance-20251019-062935"
echo "Zone: us-central1-f"
echo "External IP: 104.198.201.212"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Commit: git add . && git commit -m 'Migrate to talkhint project'"
echo "  3. Push: git push origin release/DWG-QA-v1"
echo ""

