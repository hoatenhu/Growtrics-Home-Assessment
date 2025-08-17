# Growtrics Home Assessment - Mathematics Homework Solver

A complete full-stack application that uses AI to solve student mathematics homework problems from uploaded images or PDFs. This project demonstrates modern software development practices with a FastAPI backend and Flutter frontend.

## 🚀 Project Overview

This repository contains a mathematics homework solver system that allows students to:
- 📸 Upload homework problems as images (PNG, JPG, JPEG) or PDF files
- 🤖 Get AI-powered solutions with step-by-step explanations
- 📱 Access the service through a beautiful mobile app
- 📊 View and manage homework history

## 📁 Repository Structure

```
├── src/
│   ├── backend/           # Python FastAPI backend service
│   └── frontend/          # Flutter mobile application
├── samples/               # Sample homework files for testing
├── behavioural_questions.md
└── README.md             # This file
```

## 🔧 Technology Stack

### Backend (`src/backend/`)
- **Framework**: FastAPI with Python
- **AI Providers**: Google Gemini, OpenAI GPT-4, Mock provider
- **Database**: Firebase Firestore
- **Image Processing**: OCR with Tesseract, AI Vision processing
- **File Support**: Images (PNG, JPG, JPEG) and PDF files
- **Package Manager**: UV (fast Python package manager)

### Frontend (`src/frontend/`)
- **Framework**: Flutter (cross-platform mobile app)
- **Target Platforms**: iOS, Android, Web
- **Key Features**: Camera integration, file upload, progress tracking
- **UI**: Material Design with custom theming

## 📖 Component Documentation

### Backend Documentation
- **Location**: [`src/backend/README.md`](src/backend/README.md)
- **Contains**: Complete setup instructions, API endpoints, AI provider setup, Firebase configuration, testing instructions
- **Key Features**: Multi-provider AI support, OCR processing, file storage, comprehensive error handling

### Frontend Documentation
- **Location**: [`src/frontend/README.md`](src/frontend/README.md)
- **Contains**: Flutter setup, project structure, UI screenshots, troubleshooting
- **Key Features**: Cross-platform support, camera integration, beautiful UI, offline handling

## 📁 Sample Data

The `samples/` directory contains test homework files:
- **`P5_Maths_2023_SA2_acsprimary.pdf`**: Sample mathematics homework PDF
- **`sample_1.jpg`**: Sample homework image

## 🚀 Getting Started

1. **Backend**: See [`src/backend/README.md`](src/backend/README.md) for complete setup instructions
2. **Frontend**: See [`src/frontend/README.md`](src/frontend/README.md) for Flutter app setup
3. **Testing**: Each component includes comprehensive testing instructions

## 📄 License

This project is part of the Growtrics Home Assessment.

---

## 🗂 Navigation Quick Links

- [Backend API Documentation](src/backend/README.md) - Complete backend setup and API reference
- [Frontend App Documentation](src/frontend/README.md) - Flutter app setup and development guide
- [Sample Files](samples/) - Test homework problems and sample data
- [Backend Source Code](src/backend/) - Python FastAPI implementation
- [Frontend Source Code](src/frontend/) - Flutter mobile application

For questions or issues, refer to the troubleshooting sections in the respective README files or check the comprehensive documentation in each component's directory.
