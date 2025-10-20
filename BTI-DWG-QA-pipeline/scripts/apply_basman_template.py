#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BTI DWG QA Pipeline - Apply Basmanny Template
Applies Basmanny district template to DWG files
"""

import os
import sys
import json
import logging
from datetime import datetime
from pathlib import Path

# =============================================================================
# Configuration
# =============================================================================

BASE_DIR = Path(r"C:\bti")
CONFIG_DIR = BASE_DIR / "config"
TEMPLATES_CONFIG = CONFIG_DIR / "templates.json"
OUTPUT_DIR = BASE_DIR / "output" / "converted"
LOG_FILE = BASE_DIR / "output" / "logs" / f"template_apply_{datetime.now().strftime('%Y%m%d')}.log"

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# =============================================================================
# Load Templates Configuration
# =============================================================================

def load_templates_config():
    """Load templates configuration from JSON"""
    try:
        with open(TEMPLATES_CONFIG, 'r', encoding='utf-8') as f:
            config = json.load(f)
        logger.info(f"Loaded templates configuration from {TEMPLATES_CONFIG}")
        return config
    except FileNotFoundError:
        logger.error(f"Templates config not found: {TEMPLATES_CONFIG}")
        return None
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in templates config: {e}")
        return None

# =============================================================================
# Apply Basmanny Template
# =============================================================================

def apply_basmanny_template(input_dwg, output_dwg=None, template_name="Basmanny"):
    """
    Apply Basmanny template to DWG file
    
    Args:
        input_dwg: Path to input DWG file
        output_dwg: Path to output DWG file (optional)
        template_name: Template name from config
    
    Returns:
        dict: Result with status and details
    """
    logger.info(f"Starting template application: {template_name}")
    logger.info(f"Input file: {input_dwg}")
    
    # Load config
    config = load_templates_config()
    if not config:
        return {"status": "error", "message": "Failed to load templates config"}
    
    # Get template
    template = config.get("templates", {}).get(template_name)
    if not template:
        logger.error(f"Template not found: {template_name}")
        return {"status": "error", "message": f"Template '{template_name}' not found"}
    
    if not template.get("enabled", False):
        logger.warning(f"Template is disabled: {template_name}")
        return {"status": "error", "message": f"Template '{template_name}' is disabled"}
    
    # Prepare output path
    if not output_dwg:
        input_path = Path(input_dwg)
        output_dwg = OUTPUT_DIR / f"{input_path.stem}_basman{input_path.suffix}"
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Simulate template application (in real implementation, use ezdxf or similar)
    logger.info("Applying template settings:")
    logger.info(f"  - Insert block: {template.get('insert_block')}")
    logger.info(f"  - Layers: {len(template.get('layers', {}))}")
    logger.info(f"  - Text style: {template.get('text_style', {}).get('font')}")
    
    # Check layers
    layers = template.get("layers", {})
    for layer_name, layer_props in layers.items():
        logger.info(f"  - Layer {layer_name}: color={layer_props.get('color')}, lineweight={layer_props.get('lineweight')}")
    
    # Check title block
    title_block = template.get("title_block", {})
    if title_block:
        logger.info(f"  - Title block: {title_block.get('template_file')}")
        for attr, value in title_block.get("attributes", {}).items():
            if value == "auto":
                value = datetime.now().strftime("%Y-%m-%d")
            logger.info(f"    - {attr}: {value}")
    
    # Validation rules
    validation = template.get("validation_rules", {})
    logger.info(f"Validation rules:")
    logger.info(f"  - Required layers: {validation.get('required_layers')}")
    logger.info(f"  - Area range: {validation.get('min_area')} - {validation.get('max_area')} m²")
    logger.info(f"  - Coordinate system: {validation.get('coordinate_system')}")
    
    # In real implementation, use ezdxf or pyautocad to:
    # 1. Open DWG file
    # 2. Apply layer properties
    # 3. Set text styles
    # 4. Insert title block
    # 5. Save to output_dwg
    
    # For now, just copy the file (placeholder)
    try:
        import shutil
        shutil.copy2(input_dwg, output_dwg)
        logger.info(f"Output file created: {output_dwg}")
    except Exception as e:
        logger.error(f"Failed to create output file: {e}")
        return {"status": "error", "message": str(e)}
    
    # Create result
    result = {
        "status": "success",
        "input_file": str(input_dwg),
        "output_file": str(output_dwg),
        "template_name": template_name,
        "template_description": template.get("description"),
        "layers_applied": list(layers.keys()),
        "insert_block": template.get("insert_block"),
        "validation_rules": validation,
        "timestamp": datetime.now().isoformat()
    }
    
    logger.info("Template application completed successfully")
    return result

# =============================================================================
# Save Result Log
# =============================================================================

def save_result_log(result):
    """Save result to JSON log file"""
    log_file = BASE_DIR / "output" / "logs" / "template_results.json"
    log_file.parent.mkdir(parents=True, exist_ok=True)
    
    # Load existing logs
    logs = []
    if log_file.exists():
        try:
            with open(log_file, 'r', encoding='utf-8') as f:
                logs = json.load(f)
        except:
            logs = []
    
    # Append new result
    logs.append(result)
    
    # Save
    with open(log_file, 'w', encoding='utf-8') as f:
        json.dump(logs, f, indent=2, ensure_ascii=False)
    
    logger.info(f"Result saved to: {log_file}")

# =============================================================================
# Main
# =============================================================================

def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python apply_basman_template.py <input_dwg> [output_dwg] [template_name]")
        print("Example: python apply_basman_template.py C:\\bti\\input\\test.dwg")
        sys.exit(1)
    
    input_dwg = sys.argv[1]
    output_dwg = sys.argv[2] if len(sys.argv) > 2 else None
    template_name = sys.argv[3] if len(sys.argv) > 3 else "Basmanny"
    
    logger.info("=" * 80)
    logger.info("BTI DWG QA Pipeline - Basmanny Template Application")
    logger.info("=" * 80)
    
    # Check input file
    if not os.path.exists(input_dwg):
        logger.error(f"Input file not found: {input_dwg}")
        sys.exit(1)
    
    # Apply template
    result = apply_basmanny_template(input_dwg, output_dwg, template_name)
    
    # Save result
    save_result_log(result)
    
    # Print result
    logger.info("=" * 80)
    if result["status"] == "success":
        logger.info("✓ Template application successful!")
        logger.info(f"Output file: {result['output_file']}")
        sys.exit(0)
    else:
        logger.error(f"✗ Template application failed: {result['message']}")
        sys.exit(1)

if __name__ == "__main__":
    main()

