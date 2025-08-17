@echo off
echo === Mathematics Homework Solver Backend ===
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed. Please install Python 3.8 or higher.
    pause
    exit /b 1
)

REM Check if UV is installed
uv --version >nul 2>&1
if errorlevel 1 (
    echo 🔧 UV is not installed. Installing UV...
    powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
    
    REM Check again after installation
    uv --version >nul 2>&1
    if errorlevel 1 (
        echo ❌ Failed to install UV. Please install manually:
        echo    Visit: https://github.com/astral-sh/uv
        pause
        exit /b 1
    )
    echo ✅ UV installed successfully!
)

REM Setup UV environment and install dependencies
echo 📦 Setting up UV environment and installing dependencies...
uv sync

REM Check if .env file exists
if not exist ".env" (
    echo ⚠️  No .env file found. Creating template...
    (
        echo # AI Provider Configuration
        echo AI_PROVIDER=auto
        echo AI_MODEL=
        echo.
        echo # OpenAI Configuration ^(optional for development^)
        echo OPENAI_API_KEY=your_openai_api_key_here
        echo.
        echo # Google Gemini Configuration ^(recommended - 120x cheaper^)
        echo GEMINI_API_KEY=your_gemini_api_key_here
        echo.
        echo # Firebase Configuration ^(optional for development^)
        echo FIREBASE_SERVICE_ACCOUNT_PATH=path/to/firebase-service-account.json
        echo FIREBASE_STORAGE_BUCKET=your-firebase-project.appspot.com
        echo.
        echo # Application Configuration
        echo DEBUG=True
        echo PORT=8000
        echo HOST=0.0.0.0
    ) > .env
    echo 📝 .env file created. Please edit it with your API keys if needed.
)

echo.
echo 🔍 Checking system dependencies...
echo ⚠️  Please ensure Tesseract OCR is installed for image processing
echo ⚠️  Please ensure Poppler is installed for PDF processing
echo    Download from: https://github.com/oschwartz10612/poppler-windows

echo.
echo 🚀 Starting FastAPI server...
echo 📍 API will be available at: http://localhost:8000
echo 📚 API Documentation: http://localhost:8000/docs
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the FastAPI server using UV
uv run uvicorn main:app --host 0.0.0.0 --port 8000 --reload

pause
