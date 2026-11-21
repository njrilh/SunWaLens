# SunWaLens 🌿

**AI-Powered Javanese and Sundanese Script Recognition Application**

SunWaLens is a mobile application designed to recognize traditional Javanese and Sundanese scripts using computer vision and deep learning.

The application integrates a Flutter mobile interface with a YOLO-based classification model through a FastAPI backend.

## ✨ Features

- Image input through camera and gallery.
- Image cropping before prediction.
- AI-based Javanese and Sundanese script recognition.
- Classification of unknown or unrecognized scripts.
- Prediction confidence display.
- Recognition history.
- Integrated learning support for traditional scripts.

## 🛠️ Tech Stack

- **Mobile:** Flutter, Dart
- **Backend:** Python, FastAPI
- **AI Model:** YOLO
- **Computer Vision:** OpenCV / image processing
- **Communication:** REST API

## 🏗️ System Architecture

```text
Flutter Application
       |
       v
Image Selection / Camera
       |
       v
Image Preprocessing
       |
       v
FastAPI Backend
       |
       v
YOLO Classification
       |
       v
Prediction Result
       |
       v
Flutter Interface
```

## 🚀 Getting Started

### Mobile Application

```bash
cd SunWaLensApp
flutter pub get
flutter run
```

### Backend

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the API:

```bash
uvicorn mainapp:app --host 0.0.0.0 --port 8000
```

> Adjust the entry-point and model paths according to the actual backend structure.

## 📂 Project Structure

```text
SunWaLens/
├── SunWaLensApp/
├── models/
└── datasets.zip
```

## 🎯 Project Goals

- Preserve and introduce traditional Indonesian scripts through technology.
- Explore practical applications of deep learning in cultural heritage.
- Develop an accessible mobile-based script recognition system.

## 👨‍💻 Author

Developed by **Nazril Hidayatulloh**.

---

*An exploration of AI and mobile technology for Indonesian cultural heritage.*
