# =============================================================================
# BTI DWG QA Pipeline - Download Template from Google Cloud Storage
# =============================================================================
# Purpose: Download Basmanny template DWG from Google Cloud Storage
# =============================================================================

param(
    [string]$ProjectId = "swiftchair",
    [string]$BucketName = "",
    [string]$TemplateFileName = "BasmanTitleBlock.dwg",
    [string]$DestinationPath = "C:\bti\templates"
)

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  Download Basmanny Template from Google Cloud Storage" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Configuration
# =============================================================================

if ([string]::IsNullOrEmpty($BucketName)) {
    Write-Host "Searching for buckets in project: $ProjectId" -ForegroundColor Yellow
    
    # List all buckets
    $buckets = gcloud storage ls --project=$ProjectId 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Available buckets:" -ForegroundColor Green
        $buckets | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
        Write-Host ""
        
        # Try common bucket names
        $commonNames = @(
            "gs://$ProjectId-templates",
            "gs://$ProjectId-dwg-templates",
            "gs://$ProjectId-bti",
            "gs://bti-templates",
            "gs://dwg-templates"
        )
        
        foreach ($bucketPath in $commonNames) {
            Write-Host "Checking: $bucketPath" -ForegroundColor Gray
            $files = gcloud storage ls $bucketPath 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  Found bucket: $bucketPath" -ForegroundColor Green
                $BucketName = $bucketPath
                break
            }
        }
    }
}

if ([string]::IsNullOrEmpty($BucketName)) {
    Write-Host "ERROR: Bucket not specified and auto-detection failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please specify bucket manually:" -ForegroundColor Yellow
    Write-Host "  .\download_template_from_gcs.ps1 -BucketName 'gs://your-bucket-name'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or create a bucket:" -ForegroundColor Yellow
    Write-Host "  gcloud storage buckets create gs://$ProjectId-templates --location=us-central1" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# =============================================================================
# Search for Template File
# =============================================================================

Write-Host "Searching for template files in: $BucketName" -ForegroundColor Yellow
Write-Host ""

# List all files in bucket
$allFiles = gcloud storage ls "$BucketName/**" --recursive 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to list files in bucket: $BucketName" -ForegroundColor Red
    Write-Host "Make sure the bucket exists and you have access" -ForegroundColor Yellow
    exit 1
}

# Search for template files
$templateFiles = $allFiles | Where-Object { 
    $_ -match "basman|Basman|template|Template|titleblock|TitleBlock" -and $_ -match "\.dwg$" 
}

if ($templateFiles.Count -eq 0) {
    Write-Host "WARNING: No template files found matching pattern" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "All DWG files in bucket:" -ForegroundColor Yellow
    $dwgFiles = $allFiles | Where-Object { $_ -match "\.dwg$" }
    if ($dwgFiles.Count -gt 0) {
        $dwgFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    } else {
        Write-Host "  (No DWG files found)" -ForegroundColor Gray
    }
    Write-Host ""
    
    Write-Host "To upload a template file:" -ForegroundColor Yellow
    Write-Host "  gcloud storage cp C:\path\to\BasmanTitleBlock.dwg $BucketName/templates/" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "Found template files:" -ForegroundColor Green
$templateFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
Write-Host ""

# =============================================================================
# Select and Download Template
# =============================================================================

# Use first matching file
$sourceFile = $templateFiles[0]

Write-Host "Downloading: $sourceFile" -ForegroundColor Yellow
Write-Host "Destination: $DestinationPath" -ForegroundColor Gray
Write-Host ""

# Create destination directory
if (-not (Test-Path $DestinationPath)) {
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    Write-Host "Created directory: $DestinationPath" -ForegroundColor Green
}

# Download file
$destinationFile = Join-Path $DestinationPath $TemplateFileName

try {
    gcloud storage cp $sourceFile $destinationFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Template downloaded successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "File location: $destinationFile" -ForegroundColor Cyan
        Write-Host "File size: $((Get-Item $destinationFile).Length / 1KB) KB" -ForegroundColor Gray
        Write-Host ""
        
        # Update templates.json to point to downloaded file
        $configFile = "C:\bti\config\templates.json"
        if (Test-Path $configFile) {
            Write-Host "Updating templates.json..." -ForegroundColor Yellow
            
            $config = Get-Content $configFile -Raw | ConvertFrom-Json
            $config.templates.Basmanny.title_block.template_file = $destinationFile
            
            $config | ConvertTo-Json -Depth 10 | Set-Content $configFile -Encoding UTF8
            
            Write-Host "✓ templates.json updated" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  1. Verify the template file opens in AutoCAD" -ForegroundColor White
        Write-Host "  2. Run test: .\test_basman_pipeline.ps1" -ForegroundColor White
        Write-Host "  3. Process DWG files with template" -ForegroundColor White
        Write-Host ""
        
        exit 0
    } else {
        throw "gcloud storage cp failed"
    }
} catch {
    Write-Host "✗ Failed to download template" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}

