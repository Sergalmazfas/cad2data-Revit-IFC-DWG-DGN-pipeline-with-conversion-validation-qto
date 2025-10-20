#!/bin/bash
# =============================================================================
# BTI DWG QA Pipeline - Remote Deployment from Cloud Shell
# =============================================================================
# Execute this from Cloud Shell to deploy on Windows VM remotely
# =============================================================================

set -e

PROJECT_ID="talkhint"
ZONE="us-central1-f"
INSTANCE="instance-20251019-062935"

echo "=============================================================================="
echo "  BTI DWG QA Pipeline - Remote Deployment"
echo "=============================================================================="
echo ""
echo "Project: $PROJECT_ID"
echo "Zone: $ZONE"
echo "Instance: $INSTANCE"
echo ""

# Create PowerShell deployment script
cat > /tmp/deploy_bti.ps1 << 'EOFPS1'
# BTI DWG QA Pipeline - Remote Deployment Script
Write-Host "Starting BTI DWG QA Pipeline deployment..." -ForegroundColor Cyan

cd C:\Users\Administrator

# Clone repository
if (Test-Path "cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto") {
    cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto
    git pull origin release/DWG-QA-v1
} else {
    git clone https://github.com/Sergalmazfas/cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto.git
    cd cad2data-Revit-IFC-DWG-DGN-pipeline-with-conversion-validation-qto
}

git checkout release/DWG-QA-v1
cd BTI-DWG-QA-pipeline\deployment

# Run deployment
.\deploy_all.ps1 -ProjectId "talkhint" -Zone "us-central1-f" -InstanceName "instance-20251019-062935"

Write-Host "Deployment initiated!" -ForegroundColor Green
EOFPS1

echo "Uploading deployment script to VM..."
gcloud compute scp /tmp/deploy_bti.ps1 $INSTANCE:C:\\deploy_bti.ps1 \
    --zone=$ZONE \
    --project=$PROJECT_ID \
    --tunnel-through-iap

echo ""
echo "Executing deployment on VM..."
echo "This will take 30-40 minutes..."
echo ""

gcloud compute instances run-script $INSTANCE \
    --zone=$ZONE \
    --project=$PROJECT_ID \
    --script-file=/tmp/deploy_bti.ps1

echo ""
echo "=============================================================================="
echo "  Remote Deployment Complete!"
echo "=============================================================================="
echo ""
echo "Check deployment status:"
echo "  n8n UI: http://104.198.201.212:5678"
echo ""

