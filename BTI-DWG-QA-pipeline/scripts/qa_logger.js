/**
 * BTI DWG QA Logger
 * Utility for logging conversion and validation results
 */

const fs = require('fs');
const path = require('path');

class QALogger {
  constructor(logDir = './logs') {
    this.logDir = logDir;
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
  }

  /**
   * Log conversion result
   */
  logConversion(dwgFile, status, outputFile, notes = '') {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      type: 'conversion',
      input_file: dwgFile,
      status: status, // 'success' or 'failed'
      output_file: outputFile,
      notes: notes
    };

    this.writeLog(logEntry, 'conversion');
    this.writeTextLog(logEntry, 'conversion');
  }

  /**
   * Log validation result
   */
  logValidation(xlsxFile, passRate, totalEntities, failedEntities, issues = []) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      type: 'validation',
      input_file: xlsxFile,
      pass_rate: passRate,
      total_entities: totalEntities,
      failed_entities: failedEntities,
      issues: issues,
      status: passRate >= 90 ? 'PASS' : 'FAIL'
    };

    this.writeLog(logEntry, 'validation');
    this.writeTextLog(logEntry, 'validation');
  }

  /**
   * Log QTO generation
   */
  logQTO(xlsxFile, metrics, reportPath) {
    const timestamp = new Date().toISOString();
    const logEntry = {
      timestamp,
      type: 'qto',
      input_file: xlsxFile,
      metrics: metrics,
      report_path: reportPath,
      status: 'success'
    };

    this.writeLog(logEntry, 'qto');
    this.writeTextLog(logEntry, 'qto');
  }

  /**
   * Write JSON log
   */
  writeLog(entry, type) {
    const date = new Date().toISOString().split('T')[0];
    const logFile = path.join(this.logDir, `${type}_${date}.json`);
    
    let logs = [];
    if (fs.existsSync(logFile)) {
      const content = fs.readFileSync(logFile, 'utf8');
      logs = JSON.parse(content);
    }
    
    logs.push(entry);
    fs.writeFileSync(logFile, JSON.stringify(logs, null, 2));
  }

  /**
   * Write text log (human-readable)
   */
  writeTextLog(entry, type) {
    const date = new Date().toISOString().split('T')[0];
    const logFile = path.join(this.logDir, `${type}_${date}.txt`);
    
    let logText = '';
    
    switch (type) {
      case 'conversion':
        logText = `[${entry.timestamp}] Conversion ${entry.status.toUpperCase()}\n`;
        logText += `  Input: ${entry.input_file}\n`;
        logText += `  Output: ${entry.output_file}\n`;
        if (entry.notes) logText += `  Notes: ${entry.notes}\n`;
        break;
        
      case 'validation':
        logText = `[${entry.timestamp}] Validation ${entry.status}\n`;
        logText += `  File: ${entry.input_file}\n`;
        logText += `  Pass Rate: ${entry.pass_rate}%\n`;
        logText += `  Entities: ${entry.total_entities} total, ${entry.failed_entities} failed\n`;
        if (entry.issues.length > 0) {
          logText += `  Issues:\n`;
          entry.issues.forEach(issue => {
            logText += `    - ${issue}\n`;
          });
        }
        break;
        
      case 'qto':
        logText = `[${entry.timestamp}] QTO Generated\n`;
        logText += `  Input: ${entry.input_file}\n`;
        logText += `  Report: ${entry.report_path}\n`;
        logText += `  Total Area: ${entry.metrics.total_area} m²\n`;
        logText += `  Total Perimeter: ${entry.metrics.total_perimeter} m\n`;
        break;
    }
    
    logText += '\n' + '-'.repeat(80) + '\n\n';
    
    fs.appendFileSync(logFile, logText);
  }

  /**
   * Get today's logs
   */
  getTodayLogs(type) {
    const date = new Date().toISOString().split('T')[0];
    const logFile = path.join(this.logDir, `${type}_${date}.json`);
    
    if (fs.existsSync(logFile)) {
      const content = fs.readFileSync(logFile, 'utf8');
      return JSON.parse(content);
    }
    
    return [];
  }
}

module.exports = QALogger;

// Example usage:
// const logger = new QALogger('./logs');
// logger.logConversion('project.dwg', 'success', 'project_dwg.xlsx', 'All layers extracted');

