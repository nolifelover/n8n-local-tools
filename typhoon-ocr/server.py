from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import os
import uvicorn
from typhoon_ocr import ocr_document
import tempfile
import shutil
import logging
import time
from datetime import datetime

# ตั้งค่า logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Typhoon OCR API")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/process")
async def process_document(
    file: UploadFile = File(...),
    page_num: int = Form(1),
    task_type: str = Form("default")
):
    start_time = time.time()
    logger.info(f"เริ่มประมวลผลไฟล์: {file.filename}")
    logger.info(f"หน้าที่ต้องการประมวลผล: {page_num}")
    logger.info(f"ประเภทงาน: {task_type}")
    
    try:
        # Create a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(file.filename)[1]) as temp_file:
            # Save uploaded file to temporary file
            shutil.copyfileobj(file.file, temp_file)
            temp_file_path = temp_file.name
            logger.info(f"บันทึกไฟล์ชั่วคราวที่: {temp_file_path}")

        # Process the document
        logger.info("เริ่มการประมวลผล OCR")
        result = ocr_document(
            pdf_or_image_path=temp_file_path,
            task_type=task_type,
            page_num=page_num
        )

        # Clean up temporary file
        os.unlink(temp_file_path)
        logger.info("ลบไฟล์ชั่วคราวเรียบร้อย")

        # คำนวณเวลาที่ใช้
        end_time = time.time()
        processing_time = end_time - start_time
        minutes = int(processing_time // 60)
        seconds = int(processing_time % 60)
        
        logger.info(f"ประมวลผลเสร็จสิ้น ใช้เวลา: {minutes} นาที {seconds} วินาที")
        
        return {
            "result": result,
            "processing_time": {
                "minutes": minutes,
                "seconds": seconds,
                "total_seconds": processing_time
            }
        }
    except Exception as e:
        # Clean up temporary file in case of error
        if 'temp_file_path' in locals():
            os.unlink(temp_file_path)
            logger.error(f"เกิดข้อผิดพลาด: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    host = os.getenv("TYPHOON_OCR_HOST", "0.0.0.0")
    port = int(os.getenv("TYPHOON_OCR_PORT", "8000"))
    logger.info(f"เริ่มต้น server ที่ {host}:{port}")
    uvicorn.run(app, host=host, port=port) 