"""
Service dependencies for the Mathematics Homework Solver API

This module provides singleton instances of all services used throughout the application.
"""

from services.firebase_service import FirebaseService
from services.ocr_service import OCRService
from services.math_solver_service import MathSolverService
from utils.file_utils import FileUtils

# Singleton service instances
# These are created once and reused throughout the application
firebase_service = FirebaseService()
ocr_service = OCRService()
math_solver_service = MathSolverService()
file_utils = FileUtils()

def get_firebase_service() -> FirebaseService:
    """Get the Firebase service instance"""
    return firebase_service

def get_ocr_service() -> OCRService:
    """Get the OCR service instance"""
    return ocr_service

def get_math_solver_service() -> MathSolverService:
    """Get the math solver service instance"""
    return math_solver_service

def get_file_utils() -> FileUtils:
    """Get the file utilities instance"""
    return file_utils
