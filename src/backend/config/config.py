import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Settings:
    # AI Provider Configuration
    AI_PROVIDER = os.getenv("AI_PROVIDER", "gemini")  # Default: "gemini" (120x cheaper than OpenAI)
    AI_MODEL = os.getenv("AI_MODEL", "gemini-pro")  # Default model for Gemini
    
    # OpenAI Configuration
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
    
    # Google Gemini Configuration
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
    
    # Firebase Configuration
    FIREBASE_SERVICE_ACCOUNT_PATH = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH")
    FIREBASE_STORAGE_BUCKET = os.getenv("FIREBASE_STORAGE_BUCKET", "growtrics-homework-solver.appspot.com")
    
    # Application Configuration
    DEBUG = os.getenv("DEBUG", "True").lower() == "true"
    PORT = int(os.getenv("PORT", 8000))
    HOST = os.getenv("HOST", "0.0.0.0")
    
    # Tesseract Configuration
    TESSERACT_CMD = os.getenv("TESSERACT_CMD", "/usr/bin/tesseract")
    
    # File Upload Configuration
    MAX_FILE_SIZE = int(os.getenv("MAX_FILE_SIZE", 10 * 1024 * 1024))  # 10MB default
    TEMP_DIR = os.getenv("TEMP_DIR", "/tmp")

settings = Settings()
