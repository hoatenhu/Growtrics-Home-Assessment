#!/bin/bash

# Mathematics Homework Solver Backend Startup Script

echo "=== Mathematics Homework Solver Backend ==="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

# Check if UV is installed
if ! command -v uv &> /dev/null; then
    echo "🔧 UV is not installed. Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Check again after installation
    if ! command -v uv &> /dev/null; then
        echo "❌ Failed to install UV. Please install manually:"
        echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
        echo "   Or visit: https://github.com/astral-sh/uv"
        exit 1
    fi
    echo "✅ UV installed successfully!"
fi

# Create UV project environment and install dependencies
echo "📦 Setting up UV environment and installing dependencies..."
uv sync

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  No .env file found. Creating template..."
    cat > .env << EOF
# AI Provider Configuration
AI_PROVIDER=auto
AI_MODEL=

# OpenAI Configuration (optional for development)
OPENAI_API_KEY=your_openai_api_key_here

# Google Gemini Configuration (recommended - 120x cheaper)
GEMINI_API_KEY=your_gemini_api_key_here

# Firebase Configuration (optional for development)
FIREBASE_SERVICE_ACCOUNT_PATH=path/to/firebase-service-account.json
FIREBASE_STORAGE_BUCKET=your-firebase-project.appspot.com

# Application Configuration
DEBUG=True
PORT=8000
HOST=0.0.0.0
EOF
    echo "📝 .env file created. Please edit it with your API keys if needed."
fi

# Check system dependencies
echo "🔍 Checking system dependencies..."

# Check Tesseract
if ! command -v tesseract &> /dev/null; then
    echo "⚠️  Tesseract OCR not found. Please install it:"
    echo "   macOS: brew install tesseract"
    echo "   Ubuntu: sudo apt-get install tesseract-ocr"
    echo "   The app will use mock OCR responses for now."
fi

# Check Poppler (for PDF processing)
if ! command -v pdftoppm &> /dev/null; then
    echo "⚠️  Poppler (PDF processing) not found. Please install it:"
    echo "   macOS: brew install poppler"
    echo "   Ubuntu: sudo apt-get install poppler-utils"
    echo "   PDF processing may not work without this."
fi

echo ""
echo "🚀 Starting FastAPI server..."
echo "📍 API will be available at: http://localhost:8000"
echo "📚 API Documentation: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the FastAPI server using UV
uv run uvicorn main:app --host 0.0.0.0 --port 8000 --reload
