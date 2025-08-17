# 📦 Dependencies Installation Guide

Complete guide for installing and managing dependencies for the Mathematics Homework Solver.

## 🚀 Quick Start

### Method 1: UV (Recommended - Fast & Modern)

```bash
# Install UV if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Navigate to backend directory
cd src/backend

# Install all dependencies (creates virtual environment automatically)
uv sync

# Start the application
uv run uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Method 2: Traditional pip (Backup method)

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the application
python main.py
```

## 📋 Core Dependencies

### **Updated Package Versions (2024)**

| Package | Version | Purpose |
|---------|---------|---------|
| **fastapi** | ≥0.116.1 | Web framework |
| **uvicorn** | ≥0.35.0 | ASGI server |
| **google-generativeai** | ≥0.8.5 | Gemini AI integration |
| **openai** | ≥1.99.0 | OpenAI GPT integration |
| **firebase-admin** | ≥7.1.0 | Firebase services |
| **pydantic** | ≥2.11.0 | Data validation |
| **python-dotenv** | ≥1.1.0 | Environment variables |
| **pytesseract** | ≥0.3.13 | OCR text extraction |
| **opencv-python** | ≥4.11.0 | Image processing |
| **Pillow** | ≥11.3.0 | Image manipulation |
| **numpy** | ≥2.3.0 | Numerical computing |
| **pdf2image** | ≥1.17.0 | PDF processing |

### **Development Dependencies**

| Package | Version | Purpose |
|---------|---------|---------|
| **pytest** | ≥8.4.0 | Testing framework |
| **black** | ≥25.1.0 | Code formatting |
| **mypy** | ≥1.17.0 | Type checking |
| **flake8** | ≥7.3.0 | Linting |

## 🛠️ System Dependencies

### **Required System Packages**

#### **For OCR (Tesseract)**

**macOS:**
```bash
brew install tesseract
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install tesseract-ocr tesseract-ocr-eng
```

**Windows:**
1. Download from: https://github.com/UB-Mannheim/tesseract/wiki
2. Add to PATH: `C:\Program Files\Tesseract-OCR`

#### **For PDF Processing (Poppler)**

**macOS:**
```bash
brew install poppler
```

**Ubuntu/Debian:**
```bash
sudo apt-get install poppler-utils
```

**Windows:**
1. Download from: https://github.com/oschwartz10612/poppler-windows
2. Extract and add to PATH

### **Python Version Requirements**

- **Minimum:** Python 3.9+
- **Recommended:** Python 3.11+ or 3.12+
- **Maximum:** Python 3.12 (tested)

## 🔧 Installation Troubleshooting

### **Common Issues & Solutions**

#### **1. ModuleNotFoundError: No module named 'config'**

**Problem:** Python can't find local modules
**Solution:**
```bash
# Make sure you're in the backend directory
cd src/backend

# Use UV to run with proper path
uv run python -c "from config.config import settings; print(settings.AI_PROVIDER)"

# Or set PYTHONPATH (traditional pip)
export PYTHONPATH=.
python -c "from config.config import settings; print(settings.AI_PROVIDER)"
```

#### **2. Google Generative AI Import Error**

**Problem:** `ImportError: cannot import name 'genai'`
**Solution:**
```bash
# Update to latest version
uv add google-generativeai --upgrade

# Or with pip
pip install google-generativeai --upgrade
```

#### **3. OpenCV Import Error**

**Problem:** `ImportError: No module named 'cv2'`
**Solution:**
```bash
# Try different OpenCV package
uv remove opencv-python
uv add opencv-python-headless

# Or with pip
pip uninstall opencv-python
pip install opencv-python-headless
```

#### **4. Tesseract Not Found**

**Problem:** `TesseractNotFoundError`
**Solution:**
```bash
# macOS
brew install tesseract

# Linux
sudo apt-get install tesseract-ocr

# Check installation
tesseract --version

# Set path in .env if needed
echo "TESSERACT_CMD=/usr/local/bin/tesseract" >> .env
```

#### **5. Firebase Admin Error**

**Problem:** `ValueError: Illegal Firebase credential provided`
**Solution:**
```bash
# This is expected in development mode
# For production, set up proper Firebase credentials:
echo "FIREBASE_SERVICE_ACCOUNT_PATH=path/to/service-account.json" >> .env
```

#### **6. PDF Processing Error**

**Problem:** `pdf2image.exceptions.PDFInfoNotInstalledError`
**Solution:**
```bash
# Install poppler
# macOS:
brew install poppler

# Linux:
sudo apt-get install poppler-utils
```

### **Version Conflicts**

#### **Numpy Compatibility Issues**
```bash
# If you get numpy version conflicts
uv remove numpy
uv add "numpy>=2.0.0,<3.0.0"
```

#### **Pydantic V1 vs V2**
```bash
# Ensure Pydantic V2
uv add "pydantic>=2.11.0"
```

## 🧪 Verification Commands

### **Check All Dependencies**

```bash
# With UV
uv pip list

# Check specific packages
uv pip show fastapi google-generativeai openai

# With pip
pip list
pip show fastapi google-generativeai openai
```

### **Test Core Functionality**

```bash
# Test AI provider setup
uv run python -c "
from services.ai_providers.provider_factory import AIProviderFactory
providers = AIProviderFactory.list_available_providers()
print('Available providers:', list(providers.keys()))
"

# Test config loading
uv run python -c "
from config.config import settings
print('AI Provider:', settings.AI_PROVIDER)
print('Gemini Key available:', bool(settings.GEMINI_API_KEY))
"

# Test FastAPI
uv run python -c "
from main import app
print('FastAPI app created successfully')
print(f'Routes: {len(app.routes)}')
"
```

### **System Dependencies Check**

```bash
# Check Tesseract
tesseract --version

# Check Python version
python --version

# Check UV version
uv --version

# Check Poppler (for PDF)
pdftoppm -h || echo "Poppler not installed"
```

## 🔄 Update Dependencies

### **Update All Packages**

```bash
# With UV (recommended)
uv sync --upgrade

# With pip
pip install -r requirements.txt --upgrade
```

### **Update Specific Package**

```bash
# With UV
uv add fastapi --upgrade
uv add google-generativeai --upgrade

# With pip
pip install fastapi --upgrade
pip install google-generativeai --upgrade
```

### **Lock Dependencies**

```bash
# UV automatically creates uv.lock
uv lock

# For pip users, create requirements-lock.txt
pip freeze > requirements-lock.txt
```

## 🐳 Docker Alternative

If you're having persistent dependency issues, use Docker:

```dockerfile
# Dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```bash
# Build and run
docker build -t homework-solver .
docker run -p 8000:8000 homework-solver
```

## 📊 Dependency Status Check

Run this command to check your installation:

```bash
uv run python -c "
import sys
print(f'Python: {sys.version}')

try:
    import fastapi; print(f'✅ FastAPI: {fastapi.__version__}')
except ImportError: print('❌ FastAPI: Not installed')

try:
    import google.generativeai; print(f'✅ Google Generative AI: {google.generativeai.__version__}')
except ImportError: print('❌ Google Generative AI: Not installed')

try:
    import openai; print(f'✅ OpenAI: {openai.__version__}')
except ImportError: print('❌ OpenAI: Not installed')

try:
    import cv2; print(f'✅ OpenCV: {cv2.__version__}')
except ImportError: print('❌ OpenCV: Not installed')

try:
    import pytesseract; print(f'✅ PyTesseract: {pytesseract.__version__}')
except ImportError: print('❌ PyTesseract: Not installed')

print('\\n🔧 System Dependencies:')
import subprocess
try:
    result = subprocess.run(['tesseract', '--version'], capture_output=True, text=True)
    print(f'✅ Tesseract: Available')
except FileNotFoundError:
    print('❌ Tesseract: Not found in PATH')

try:
    result = subprocess.run(['pdftoppm', '-h'], capture_output=True, text=True)
    print(f'✅ Poppler: Available')
except FileNotFoundError:
    print('❌ Poppler: Not found in PATH')
"
```

## 🆘 Getting Help

If you're still having issues:

1. **Check the terminal output** for specific error messages
2. **Run the verification commands** above
3. **Check your Python version** (`python --version`)
4. **Ensure you're in the correct directory** (`src/backend`)
5. **Try the Docker approach** if all else fails

## 📝 Development Workflow

```bash
# Daily development setup
cd src/backend
uv sync                    # Ensure dependencies are up to date
uv run python main.py      # Start development server

# Adding new dependencies
uv add package-name        # Add production dependency
uv add --dev package-name  # Add development dependency

# Testing
uv run pytest             # Run tests
uv run black .             # Format code
uv run mypy .              # Type checking
```

Your dependencies should now be properly configured and installed! 🎉
