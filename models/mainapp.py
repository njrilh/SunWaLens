from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO

import shutil
import os
from datetime import datetime

# =========================
# INIT APP
# =========================

app = FastAPI()

# =========================
# CORS
# =========================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# LOAD MODEL
# =========================

model_sunda = YOLO("bestsd31.pt")
model_jawa = YOLO("bestjw31.pt")

# =========================
# CONFIG
# =========================

IMGSZ = 224
MIN_CONF = 0.8

# =========================
# FOLDER
# =========================

UPLOAD_FOLDER = "uploads"
ASET_FOLDER = "asetkirim"

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(ASET_FOLDER, exist_ok=True)

# =========================
# API PREDICT
# =========================

@app.post("/predict")
async def predict(file: UploadFile = File(...)):

    # =========================
    # LIMIT FILE
    # =========================

    content = await file.read()

    if len(content) > 200 * 1024:
        return {
            "filename": filename,
            "kategori_terdeteksi":
                "Ukuran file terlalu besar",
            "label":
                "Ukuran file melebihi 200KB",
            "confidence":
                round(0.00, 4),
            "saved_to":
                aset_path
        }

    file.file.seek(0)

    # =========================
    # NAMA FILE
    # =========================

    timestamp = datetime.now().strftime(
        "%Y%m%d_%H%M%S"
    )

    filename = f"{timestamp}_{file.filename}"

    upload_path = os.path.join(
        UPLOAD_FOLDER,
        filename
    )

    with open(upload_path, "wb") as buffer:
        shutil.copyfileobj(
            file.file,
            buffer
        )

    aset_path = os.path.join(
        ASET_FOLDER,
        filename
    )

    shutil.copy(
        upload_path,
        aset_path
    )

    # =========================
    # PREDIKSI SUNDA
    # =========================

    res_sunda = model_sunda(
        upload_path,
        imgsz=IMGSZ,
        verbose=False
    )

    idx_sunda = (
        res_sunda[0]
        .probs
        .top1
    )

    conf_sunda = (
        res_sunda[0]
        .probs
        .top1conf
        .item()
    )

    label_sunda = (
        model_sunda.names[
            idx_sunda
        ]
    )

    # =========================
    # PREDIKSI JAWA
    # =========================

    res_jawa = model_jawa(
        upload_path,
        imgsz=IMGSZ,
        verbose=False
    )

    idx_jawa = (
        res_jawa[0]
        .probs
        .top1
    )

    conf_jawa = (
        res_jawa[0]
        .probs
        .top1conf
        .item()
    )

    label_jawa = (
        model_jawa.names[
            idx_jawa
        ]
    )

    # =========================
    # PILIH CONF TERBESAR
    # =========================

    if conf_sunda > conf_jawa:
        confidence = conf_sunda
        label_final = label_sunda
        kategori = "aksara_sunda"

    else:
        confidence = conf_jawa
        label_final = label_jawa
        kategori = "aksara_jawa"

    # =========================
    # FILTER CONFIDENCE
    # =========================

    if confidence < MIN_CONF:
        return {
            "filename": filename,
            "kategori_terdeteksi":
                "Tidak Diketahui",
            "label":
                "Tidak ada aksara yang dikenali",
            "confidence":
                round(confidence, 4),
            "saved_to":
                aset_path
        }

    # =========================
    # RETURN
    # =========================

    return {
        "filename":
            filename,
        "kategori_terdeteksi":
            kategori,
        "label":
            label_final,
        "confidence":
            round(confidence, 4),
        "saved_to":
            aset_path
    }