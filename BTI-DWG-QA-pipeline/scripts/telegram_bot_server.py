#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BTI DWG QA Pipeline - Telegram Bot Server
Receives DWG files from users via Telegram and triggers processing
"""

import os
import sys
import json
import logging
import asyncio
import requests
from pathlib import Path
from datetime import datetime

try:
    from aiogram import Bot, Dispatcher, types
    from aiogram.filters import Command
    from aiogram.types import FSInputFile
    from aiogram import F
except ImportError:
    print("ERROR: aiogram not installed. Run: pip install aiogram")
    sys.exit(1)

# =============================================================================
# Configuration
# =============================================================================

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
UPLOAD_PATH = Path(r"C:\bti\input")
OUTPUT_PATH = Path(r"C:\bti\output")
CONVERTED_PATH = OUTPUT_PATH / "converted"
QA_LOG_PATH = OUTPUT_PATH / "logs" / "qa_log.json"
N8N_WEBHOOK_URL = "http://localhost:5678/webhook/bti_telegram_trigger"
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50 MB

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(r"C:\bti\output\logs\telegram_bot.log", encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Validate token
if not TOKEN:
    logger.error("TELEGRAM_BOT_TOKEN environment variable not set!")
    sys.exit(1)

# Create bot and dispatcher
bot = Bot(token=TOKEN)
dp = Dispatcher()

# Storage for user files (track processing status)
user_files = {}

# =============================================================================
# Helper Functions
# =============================================================================

def save_user_file_info(user_id, chat_id, file_name):
    """Save user file information for later retrieval"""
    info_file = OUTPUT_PATH / "logs" / "user_files.json"
    info_file.parent.mkdir(parents=True, exist_ok=True)
    
    user_data = {}
    if info_file.exists():
        try:
            with open(info_file, 'r', encoding='utf-8') as f:
                user_data = json.load(f)
        except:
            user_data = {}
    
    user_data[file_name] = {
        "user_id": user_id,
        "chat_id": chat_id,
        "upload_time": datetime.now().isoformat(),
        "status": "processing"
    }
    
    with open(info_file, 'w', encoding='utf-8') as f:
        json.dump(user_data, f, indent=2)

def get_user_info_by_file(file_name):
    """Get user info for a processed file"""
    info_file = OUTPUT_PATH / "logs" / "user_files.json"
    
    if info_file.exists():
        try:
            with open(info_file, 'r', encoding='utf-8') as f:
                user_data = json.load(f)
            return user_data.get(file_name)
        except:
            return None
    return None

# =============================================================================
# Command Handlers
# =============================================================================

@dp.message(Command("start"))
async def cmd_start(message: types.Message):
    """Handle /start command"""
    welcome_text = """
🏗️ <b>BTI DWG QA Pipeline Bot</b>

Я обрабатываю DWG-файлы через шаблон <b>Басманный</b>.

<b>Что я делаю:</b>
✅ Применяю шаблон Басманный
✅ Конвертирую в структурированные данные
✅ Проверяю качество (QA)
✅ Генерирую отчет QTO
✅ Отправляю результаты обратно

<b>Как использовать:</b>
1. Отправьте мне .dwg файл
2. Подождите 30-60 секунд
3. Получите результаты

<b>Команды:</b>
/help - Справка
/status - Статус обработки

📊 Максимальный размер файла: 50 МБ
"""
    
    await message.answer(welcome_text, parse_mode="HTML")
    logger.info(f"User {message.from_user.id} started bot")

@dp.message(Command("help"))
async def cmd_help(message: types.Message):
    """Handle /help command"""
    help_text = """
<b>📋 Справка BTI DWG QA Bot</b>

<b>Поддерживаемые форматы:</b>
• .dwg (AutoCAD)

<b>Что происходит с вашим файлом:</b>
1. Загрузка на сервер
2. Применение шаблона Басманный
3. Конвертация DWG → XLSX
4. Валидация данных (слои, площади, координаты)
5. Генерация QTO отчета
6. Отправка результатов вам

<b>Результаты:</b>
• DWG файл с шаблоном Басманный
• QA отчет (JSON)
• QTO отчет (HTML)

<b>Время обработки:</b>
15-60 секунд (зависит от размера файла)

<b>Ограничения:</b>
• Максимальный размер: 50 МБ
• Только .dwg файлы
• Обработка по очереди

<b>Поддержка:</b>
info@datadrivenconstruction.io
"""
    
    await message.answer(help_text, parse_mode="HTML")

@dp.message(Command("status"))
async def cmd_status(message: types.Message):
    """Handle /status command"""
    try:
        # Check n8n status
        response = requests.get("http://localhost:5678/healthz", timeout=5)
        n8n_status = "✅ Работает" if response.status_code == 200 else "❌ Не отвечает"
    except:
        n8n_status = "❌ Недоступен"
    
    # Count files in processing
    files_in_queue = len(list(UPLOAD_PATH.glob("*.dwg"))) if UPLOAD_PATH.exists() else 0
    
    status_text = f"""
<b>📊 Статус системы BTI DWG QA Pipeline</b>

<b>Сервисы:</b>
• n8n Pipeline: {n8n_status}
• Telegram Bot: ✅ Работает
• Template Basmanny: ✅ Активен

<b>Очередь:</b>
• Файлов в обработке: {files_in_queue}

<b>Версия:</b>
• v1.0.0-basman

Время: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
    
    await message.answer(status_text, parse_mode="HTML")

# =============================================================================
# Document Handler (DWG Upload)
# =============================================================================

@dp.message(F.document)
async def handle_document(message: types.Message):
    """Handle document uploads (DWG files)"""
    
    user_id = message.from_user.id
    chat_id = message.chat.id
    doc = message.document
    
    logger.info(f"Received file from user {user_id}: {doc.file_name}")
    
    # Check file extension
    if not doc.file_name.lower().endswith(".dwg"):
        await message.answer(
            "⚠️ <b>Неподдерживаемый формат</b>\n\n"
            "Пожалуйста, отправьте файл в формате <b>.dwg</b> (AutoCAD)",
            parse_mode="HTML"
        )
        return
    
    # Check file size
    if doc.file_size > MAX_FILE_SIZE:
        size_mb = doc.file_size / (1024 * 1024)
        await message.answer(
            f"⚠️ <b>Файл слишком большой</b>\n\n"
            f"Размер: {size_mb:.1f} МБ\n"
            f"Максимум: {MAX_FILE_SIZE / (1024 * 1024):.0f} МБ\n\n"
            f"Пожалуйста, уменьшите размер файла или разделите на части.",
            parse_mode="HTML"
        )
        return
    
    # Send processing message
    processing_msg = await message.answer(
        "🔄 <b>Обработка начата...</b>\n\n"
        f"Файл: <code>{doc.file_name}</code>\n"
        f"Размер: {doc.file_size / 1024:.1f} КБ\n\n"
        "⏳ Применяю шаблон Басманный...",
        parse_mode="HTML"
    )
    
    try:
        # Download file
        file_info = await bot.get_file(doc.file_id)
        file_url = f"https://api.telegram.org/file/bot{TOKEN}/{file_info.file_path}"
        
        # Create upload directory
        UPLOAD_PATH.mkdir(parents=True, exist_ok=True)
        
        # Download file content
        response = requests.get(file_url, timeout=30)
        response.raise_for_status()
        
        # Save file locally
        local_path = UPLOAD_PATH / doc.file_name
        local_path.write_bytes(response.content)
        
        logger.info(f"File saved: {local_path}")
        
        # Save user info for later
        save_user_file_info(user_id, chat_id, doc.file_name)
        
        # Update message
        await processing_msg.edit_text(
            "✅ <b>Файл получен!</b>\n\n"
            f"Файл: <code>{doc.file_name}</code>\n"
            f"Сохранен в: <code>C:\\bti\\input\\</code>\n\n"
            "🔄 Запускаю обработку через n8n...\n"
            "⏱️ Ожидайте ~30-60 секунд",
            parse_mode="HTML"
        )
        
        # Trigger n8n webhook
        try:
            webhook_data = {
                "file_name": doc.file_name,
                "chat_id": chat_id,
                "user_id": user_id,
                "file_size": doc.file_size,
                "timestamp": datetime.now().isoformat()
            }
            
            webhook_response = requests.post(
                N8N_WEBHOOK_URL,
                json=webhook_data,
                timeout=10
            )
            
            if webhook_response.status_code == 200:
                logger.info(f"n8n webhook triggered for {doc.file_name}")
            else:
                logger.warning(f"n8n webhook returned status {webhook_response.status_code}")
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to trigger n8n webhook: {e}")
            # File will still be processed by auto-start workflow
            await processing_msg.edit_text(
                "✅ <b>Файл загружен!</b>\n\n"
                "Обработка начнется автоматически через File Watcher.\n"
                "Результаты придут в течение 1-2 минут.",
                parse_mode="HTML"
            )
        
    except Exception as e:
        logger.error(f"Error processing file: {e}")
        await processing_msg.edit_text(
            "❌ <b>Ошибка при загрузке файла</b>\n\n"
            f"Детали: {str(e)}\n\n"
            "Попробуйте еще раз или обратитесь в поддержку.",
            parse_mode="HTML"
        )

# =============================================================================
# Result Notification Function (called by n8n)
# =============================================================================

async def send_results_to_user(chat_id, file_name, status, qa_log=None):
    """
    Send processing results back to user
    Called by n8n workflow after processing completes
    """
    try:
        if status == "success":
            # Prepare success message
            message_text = f"""
✅ <b>Обработка завершена успешно!</b>

📁 <b>Файл:</b> <code>{file_name}</code>
🏗️ <b>Шаблон:</b> Басманный (применен)
"""
            
            # Add QA results if available
            if qa_log:
                pass_rate = qa_log.get("validation", {}).get("pass_rate", 0)
                status_emoji = "✅" if pass_rate >= 90 else "⚠️"
                
                message_text += f"""
<b>Валидация:</b> {status_emoji}
• Pass Rate: {pass_rate}%
• Слоев проверено: {len(qa_log.get("validation", {}).get("layer_check", {}).get("found_layers", []))}

<b>QTO Метрики:</b>
• Площадь: {qa_log.get("qto_metrics", {}).get("total_area_m2", 0):.2f} м²
• Окон: {qa_log.get("qto_metrics", {}).get("windows_count", 0)}
• Дверей: {qa_log.get("qto_metrics", {}).get("doors_count", 0)}
"""
            
            await bot.send_message(chat_id, message_text, parse_mode="HTML")
            
            # Send processed DWG file with Basmanny template
            basman_file = CONVERTED_PATH / f"{Path(file_name).stem}_basman.dwg"
            if basman_file.exists():
                file_to_send = FSInputFile(str(basman_file))
                await bot.send_document(
                    chat_id,
                    file_to_send,
                    caption="📎 DWG с шаблоном Басманный"
                )
                logger.info(f"Sent Basmanny DWG to chat {chat_id}")
            
            # Send QA log as JSON file
            if QA_LOG_PATH.exists():
                qa_file = FSInputFile(str(QA_LOG_PATH))
                await bot.send_document(
                    chat_id,
                    qa_file,
                    caption="📊 QA отчет (JSON)"
                )
                logger.info(f"Sent QA log to chat {chat_id}")
            
            # Send QTO HTML report
            qto_html = OUTPUT_PATH / f"{Path(file_name).stem}_QTO.html"
            if qto_html.exists():
                qto_file = FSInputFile(str(qto_html))
                await bot.send_document(
                    chat_id,
                    qto_file,
                    caption="📈 QTO отчет (HTML)"
                )
                logger.info(f"Sent QTO report to chat {chat_id}")
                
        else:
            # Error message
            error_text = f"""
❌ <b>Ошибка при обработке файла</b>

📁 <b>Файл:</b> <code>{file_name}</code>

Проверьте:
• Файл не поврежден
• Формат совместим с конвертером
• Размер файла допустимый

Попробуйте еще раз или обратитесь в поддержку.
"""
            await bot.send_message(chat_id, error_text, parse_mode="HTML")
            logger.error(f"Processing failed for {file_name}")
            
    except Exception as e:
        logger.error(f"Error sending results: {e}")

# =============================================================================
# Text Message Handler
# =============================================================================

@dp.message(F.text)
async def handle_text(message: types.Message):
    """Handle text messages"""
    await message.answer(
        "👋 Отправьте мне <b>.dwg файл</b> для обработки\n\n"
        "Или используйте команды:\n"
        "/help - Справка\n"
        "/status - Статус системы",
        parse_mode="HTML"
    )

# =============================================================================
# Main Function
# =============================================================================

async def main():
    """Main bot function"""
    logger.info("=" * 80)
    logger.info("BTI DWG QA Pipeline - Telegram Bot Server Starting")
    logger.info("=" * 80)
    logger.info(f"Bot token: {TOKEN[:10]}...{TOKEN[-10:]}")
    logger.info(f"Upload path: {UPLOAD_PATH}")
    logger.info(f"Output path: {OUTPUT_PATH}")
    logger.info(f"Max file size: {MAX_FILE_SIZE / (1024*1024):.0f} MB")
    logger.info(f"n8n webhook: {N8N_WEBHOOK_URL}")
    logger.info("=" * 80)
    
    # Create directories
    UPLOAD_PATH.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.mkdir(parents=True, exist_ok=True)
    CONVERTED_PATH.mkdir(parents=True, exist_ok=True)
    
    # Start polling
    logger.info("Starting bot polling...")
    await dp.start_polling(bot, skip_updates=True)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Bot stopped by user")
    except Exception as e:
        logger.error(f"Bot crashed: {e}")
        sys.exit(1)

