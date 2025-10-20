# Changelog

All notable changes to the BTI DWG QA Pipeline project will be documented in this file.

## [1.0.0] - 2025-10-20

### Added - Initial Release (Baseline)

#### Core Functionality
- **DWG to XLSX Converter** (n8n_1_BTI_Convert.json)
  - Convert AutoCAD DWG files to structured Excel format
  - Support for ODAFileConverter, LibreDWG, and DDC DWG Converter
  - Automatic output path generation

- **Validation Pipeline** (n8n_2_BTI_Validation.json)
  - Validate DWG data against BTI requirements
  - Check required layers (WALLS, WINDOWS, DOORS, ROOMS, DIMENSIONS)
  - Entity validation (area bounds, perimeter, coordinates)
  - Layer naming pattern validation
  - Pass/fail status with detailed issue reporting
  - Summary statistics generation

- **QTO Report Generator** (n8n_3_BTI_QTO.json)
  - Calculate total area and perimeter
  - Count windows and doors
  - Group entities by layer and type
  - Generate beautiful HTML reports
  - Room-by-room breakdown

#### Configuration
- **validation_rules.json** - BTI-specific validation rules
- **converter_settings.json** - DWG converter configuration
- **qa_log_template.json** - QA report template

#### Scripts
- **qa_logger.js** - Logging utility for conversion, validation, and QTO operations
- **dwg_validator.js** - Validation engine for DWG data

#### Documentation
- Comprehensive README.md with quick start guide
- Converter setup instructions (ODAFileConverter, LibreDWG, DDC)
- Validation rules customization guide
- Manual QA checklist for BTI requirements
- Troubleshooting section

### Features
- ✅ Offline operation (no internet required)
- ✅ No Autodesk licenses needed
- ✅ Structured JSON logging
- ✅ HTML report generation with charts
- ✅ n8n workflow automation
- ✅ Customizable validation rules
- ✅ Batch processing support

### Excluded from v1.0
- ❌ Revit support (removed)
- ❌ IFC support (removed)
- ❌ DGN support (removed)
- ❌ AI/LLM features (removed)
- ❌ Carbon footprint analysis (removed)
- ❌ Price estimation (removed)

### Technical Details
- **Project Type**: n8n workflow automation
- **Primary Format**: DWG (AutoCAD)
- **Output Formats**: XLSX, JSON, HTML
- **License**: MIT
- **Node.js**: 18+ required

---

## Roadmap

### v1.1 (Planned)
- Web UI for pipeline management
- Batch processing multiple DWG files
- PostgreSQL/MongoDB integration
- REST API endpoints

### v1.2 (Planned)
- PDF report generation
- Email notifications
- Telegram bot monitoring
- Docker containerization

---

**Release Date**: October 20, 2025  
**Git Branch**: release/DWG-QA-v1  
**Status**: Production-ready baseline

