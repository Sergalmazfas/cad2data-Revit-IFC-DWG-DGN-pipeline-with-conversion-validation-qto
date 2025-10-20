/**
 * BTI DWG Validator
 * Validates DWG data against BTI requirements
 */

const fs = require('fs');

class DWGValidator {
  constructor(rulesPath = '../config/validation_rules.json') {
    this.rules = JSON.parse(fs.readFileSync(rulesPath, 'utf8'));
  }

  /**
   * Validate single entity
   */
  validateEntity(entity) {
    const issues = [];
    const warnings = [];

    // Check required properties
    if (!entity.Layer || entity.Layer === '') {
      issues.push('Missing layer information');
    }

    if (!entity.EntityType || entity.EntityType === '') {
      issues.push('Missing entity type');
    }

    // Check area bounds
    if (entity.Area !== undefined) {
      const area = parseFloat(entity.Area);
      if (area < this.rules.rules.entity_checks.area_min) {
        warnings.push(`Area too small: ${area} m²`);
      }
      if (area > this.rules.rules.entity_checks.area_max) {
        issues.push(`Area too large: ${area} m²`);
      }
    }

    // Check perimeter bounds
    if (entity.Perimeter !== undefined) {
      const perimeter = parseFloat(entity.Perimeter);
      if (perimeter < this.rules.rules.entity_checks.perimeter_min) {
        warnings.push(`Perimeter too small: ${perimeter} m`);
      }
      if (perimeter > this.rules.rules.entity_checks.perimeter_max) {
        issues.push(`Perimeter too large: ${perimeter} m`);
      }
    }

    // Check coordinates
    if (entity.X !== undefined && entity.Y !== undefined) {
      const x = parseFloat(entity.X);
      const y = parseFloat(entity.Y);
      const cs = this.rules.rules.coordinate_system;
      
      if (x < cs.min_x || x > cs.max_x || y < cs.min_y || y > cs.max_y) {
        warnings.push(`Coordinates out of bounds: (${x}, ${y})`);
      }
    }

    // Layer naming validation
    if (entity.Layer) {
      const pattern = new RegExp(this.rules.rules.layer_naming.pattern);
      if (!pattern.test(entity.Layer)) {
        warnings.push(`Invalid layer name: ${entity.Layer}`);
      }
    }

    return {
      entity_id: entity.Handle || entity.ElementId || 'unknown',
      layer: entity.Layer || 'unknown',
      entity_type: entity.EntityType || 'unknown',
      status: issues.length === 0 ? 'PASS' : 'FAIL',
      issues: issues,
      warnings: warnings,
      issue_count: issues.length,
      warning_count: warnings.length
    };
  }

  /**
   * Validate all entities
   */
  validateAll(entities) {
    const results = {
      total: entities.length,
      passed: 0,
      failed: 0,
      warnings: 0,
      entities: [],
      summary: {}
    };

    for (const entity of entities) {
      const validation = this.validateEntity(entity);
      results.entities.push(validation);
      
      if (validation.status === 'PASS') {
        results.passed++;
      } else {
        results.failed++;
      }
      
      results.warnings += validation.warning_count;
    }

    results.pass_rate = ((results.passed / results.total) * 100).toFixed(2);
    results.summary = this.generateSummary(results);

    return results;
  }

  /**
   * Generate validation summary
   */
  generateSummary(results) {
    const summary = {
      pass_rate: results.pass_rate + '%',
      total_entities: results.total,
      passed_entities: results.passed,
      failed_entities: results.failed,
      total_warnings: results.warnings,
      status: parseFloat(results.pass_rate) >= this.rules.rules.quality_thresholds.min_pass_rate ? 'PASS' : 'FAIL',
      issues_by_type: {},
      warnings_by_type: {}
    };

    // Count issues by type
    for (const entity of results.entities) {
      for (const issue of entity.issues) {
        summary.issues_by_type[issue] = (summary.issues_by_type[issue] || 0) + 1;
      }
      for (const warning of entity.warnings) {
        summary.warnings_by_type[warning] = (summary.warnings_by_type[warning] || 0) + 1;
      }
    }

    return summary;
  }

  /**
   * Check required layers
   */
  checkRequiredLayers(entities) {
    const foundLayers = new Set(entities.map(e => e.Layer).filter(l => l));
    const requiredLayers = this.rules.rules.required_layers;
    const missingLayers = [];

    for (const layer of requiredLayers) {
      if (!foundLayers.has(layer)) {
        missingLayers.push(layer);
      }
    }

    return {
      found_layers: Array.from(foundLayers),
      required_layers: requiredLayers,
      missing_layers: missingLayers,
      status: missingLayers.length === 0 ? 'PASS' : 'FAIL'
    };
  }
}

module.exports = DWGValidator;

// Example usage:
// const validator = new DWGValidator('../config/validation_rules.json');
// const results = validator.validateAll(dwgData);
// console.log(results.summary);

