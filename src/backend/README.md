# Mathematics Homework Solver Backend

A FastAPI + Firebase backend service that uses AI to solve student mathematics homework problems from uploaded images or PDFs.

## Features

- 📸 **Image/PDF Upload**: Upload homework problems as images (PNG, JPG, JPEG) or PDF files
- 🔍 **OCR Text Extraction**: Extract text and mathematical content from images using Tesseract OCR
- 🤖 **Multi-AI Provider Support**: Choose between OpenAI GPT-4, Google Gemini, or mock providers
- 🔄 **Easy Provider Switching**: Switch between AI providers with simple configuration
- 📊 **Multiple Problem Types**: Supports multiple choice, word problems, calculations, geometry, and algebra
- ☁️ **Firebase Integration**: Store files and homework data in Firebase
- 📝 **Detailed Solutions**: Get step-by-step solutions with explanations
- 💰 **Cost Optimization**: Use Gemini for 120x cheaper AI processing than OpenAI

## Architecture

```
├── main.py                     # FastAPI application entry point
├── models/
│   └── homework_models.py      # Pydantic models for data structures
├── services/
│   ├── firebase_service.py     # Firebase Storage and Firestore integration
│   ├── ocr_service.py         # OCR text extraction from images/PDFs
│   └── math_solver_service.py  # AI-powered math problem solving
├── utils/
│   └── file_utils.py          # File handling utilities
├── config.py                  # Configuration settings
├── requirements.txt           # Python dependencies
├── test_api.py               # API testing script
└── README.md                 # This file
```

## Setup Instructions

### 1. Install UV and Dependencies

UV is a fast Python package manager that replaces pip and virtualenv.

```bash
# Install UV (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Navigate to backend directory
cd src/backend

# Install all dependencies (creates virtual environment automatically)
uv sync
```

### 2. Install System Dependencies

**For OCR (Tesseract):**

**macOS:**
```bash
brew install tesseract
```

**Ubuntu/Debian:**
```bash
sudo apt-get install tesseract-ocr
```

**Windows:**
Download from: https://github.com/UB-Mannheim/tesseract/wiki

**For PDF processing:**
```bash
# macOS
brew install poppler

# Ubuntu/Debian
sudo apt-get install poppler-utils

# Windows - download poppler binaries
```

### 3. Environment Configuration

Create a `.env` file in the backend directory:

```env
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Firebase Configuration (optional for development)
FIREBASE_SERVICE_ACCOUNT_PATH=path/to/firebase-service-account.json
FIREBASE_STORAGE_BUCKET=your-firebase-project.appspot.com

# Application Configuration
DEBUG=True
PORT=8000
HOST=0.0.0.0
```

### 4. Firebase Setup (Optional)

For production deployment:

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Firestore Database and Storage
3. Generate a service account key
4. Download the JSON key file and set `FIREBASE_SERVICE_ACCOUNT_PATH`

**Note**: The application includes mock implementations for development, so Firebase setup is optional for testing.

### 5. AI Provider Setup

The system supports multiple AI providers. Choose one:

#### Option A: Google Gemini (Recommended - 120x cheaper!)
1. Get an API key from https://makersuite.google.com/app/apikey
2. Set environment variables:
   ```env
   AI_PROVIDER=gemini
   GEMINI_API_KEY=your_gemini_api_key_here
   AI_MODEL=gemini-pro
   ```

#### Option B: OpenAI
1. Get an API key from https://platform.openai.com
2. Set environment variables:
   ```env
   AI_PROVIDER=openai
   OPENAI_API_KEY=your_openai_api_key_here
   AI_MODEL=gpt-4
   ```

#### Option C: Auto-Detection
Don't set `AI_PROVIDER` and the system will automatically detect which provider to use based on available API keys.

**Note**: The application includes mock responses for development if no API keys are provided.

## Running the Application

### Development Server

```bash
cd src/backend

# Using the startup script (recommended)
./start.sh  # macOS/Linux
# or
start.bat   # Windows

# Or run directly with UV
uv run python main.py

# Or using uvicorn with UV
uv run uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at: http://localhost:8000

### API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### 0. AI Provider Information
```http
GET /ai-providers
```

**Response:**
```json
{
  "available_providers": {
    "openai": {"name": "OpenAI", "available": true, "models": ["gpt-4"]},
    "gemini": {"name": "Google Gemini", "available": true, "models": ["gemini-pro"]}
  },
  "current_provider": {
    "provider_name": "Google Gemini",
    "is_available": true,
    "supported_models": ["gemini-pro"]
  }
}
```

```http
GET /ai-providers/current
```

### 1. Upload Homework
```http
POST /upload-homework
Content-Type: multipart/form-data

Body: file (image or PDF)
```

**Response:**
```json
{
  "problem_id": "uuid-string",
  "status": "uploaded",
  "message": "Homework uploaded successfully"
}
```

### 2. Solve Homework
```http
POST /solve-homework/{problem_id}
```

**Response:**
```json
{
  "problem_id": "uuid-string",
  "questions_solved": [
    {
      "question_number": 1,
      "question_text": "Which one of the following is sixty-three thousand and forty in numerals?",
      "problem_type": "multiple_choice",
      "options": ["6340", "63 040", "63 400", "630 040"],
      "correct_answer": "63 040",
      "explanation": "Sixty-three thousand and forty is written as 63,040...",
      "steps": ["Step 1...", "Step 2..."]
    }
  ],
  "overall_explanation": "This homework focuses on...",
  "total_questions": 2,
  "solved_at": "2024-01-15T10:30:00",
  "processing_time_seconds": 3.5
}
```

### 3. Get Homework Details
```http
GET /homework/{problem_id}
```

### 4. List Homework Problems
```http
GET /homework?limit=10&offset=0
```

## Testing

### Test API Endpoints

Run the test script to verify all endpoints:

```bash
uv run python test_api.py
```

Make sure to place a test image file named `test_homework.png` in the backend directory.

### Test AI Providers

Test the multi-provider system:

```bash
uv run python test_providers.py
```

This will:
- Check your environment configuration
- List all available AI providers
- Test each provider with sample math problems
- Show provider performance and availability
- Display usage instructions

### Test Specific Provider

```bash
# Test with Gemini
export AI_PROVIDER=gemini
export GEMINI_API_KEY=your_key
uv run python test_providers.py

# Test with OpenAI  
export AI_PROVIDER=openai
export OPENAI_API_KEY=your_key
uv run python test_providers.py
```

### UV Test Runner

Use the comprehensive UV test runner:

```bash
uv run python scripts/test_with_uv.py
```

This runs all tests, linting, and type checking in one command.

## Sample Test Data

Based on the provided sample questions, the system can handle:

1. **Number Representation**: "Which one of the following is sixty-three thousand and forty in numerals?"
2. **Percentage Calculations**: "What percentage of the figure is shaded?" (with visual diagrams)
3. **Multiple Choice Questions**: With options (1), (2), (3), (4)

## Error Handling

The API includes comprehensive error handling:

- **400**: Invalid file type or malformed request
- **404**: Homework problem not found
- **500**: Internal server errors

## Development Notes

- Mock implementations are provided for development without external dependencies
- The OCR service includes image preprocessing for better text extraction
- The AI solver provides step-by-step solutions with educational explanations
- File uploads are temporarily stored and cleaned up automatically

## Production Deployment

For production deployment:

1. Set up proper Firebase project and authentication
2. Configure CORS settings for your frontend domain
3. Set up proper environment variables
4. Use a production ASGI server like Gunicorn
5. Set up proper logging and monitoring

## Troubleshooting

**Common Issues:**

1. **Tesseract not found**: Install Tesseract and ensure it's in your PATH
2. **PDF processing errors**: Install poppler utilities
3. **Firebase errors**: Check service account configuration
4. **OpenAI errors**: Verify API key and quota

**Debug Mode:**

Set `DEBUG=True` in environment to see detailed error messages and mock responses.

## UV Package Management

This project uses UV for fast and reliable dependency management.

### Key UV Commands

```bash
# Install dependencies and create virtual environment
uv sync

# Add a new dependency
uv add fastapi

# Add a development dependency
uv add --dev pytest

# Remove a dependency
uv remove package-name

# Run a command in the UV environment
uv run python script.py

# Show installed packages
uv pip list

# Update all dependencies
uv sync --upgrade

# Lock dependencies (create uv.lock)
uv lock

# Install from lock file
uv sync --frozen
```

### UV vs Traditional Python Tools

| Task | Traditional | UV |
|------|------------|-----|
| Create venv | `python -m venv venv` | Automatic with `uv sync` |
| Activate venv | `source venv/bin/activate` | Not needed |
| Install deps | `pip install -r requirements.txt` | `uv sync` |
| Run script | `python script.py` | `uv run python script.py` |
| Add dependency | Edit requirements.txt + pip install | `uv add package` |

### Benefits of UV

- ⚡ **10-100x faster** than pip
- 🔒 **Automatic lock files** for reproducible builds
- 🚀 **Automatic virtual environment** management
- 🎯 **Better dependency resolution** than pip
- 📦 **Built-in project management** features
