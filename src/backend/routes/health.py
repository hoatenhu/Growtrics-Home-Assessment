"""
Health check endpoints

Simple endpoints to verify the API is running and healthy.
"""

from fastapi import APIRouter
from datetime import datetime

router = APIRouter()

@router.get("/")
async def root():
    """
    Root health check endpoint
    
    Returns a simple message to verify the API is running.
    """
    return {
        "message": "Mathematics Homework Solver API is running!",
        "status": "healthy",
        "timestamp": datetime.now().isoformat()
    }

@router.get("/health")
async def health_check():
    """
    Detailed health check endpoint
    
    Returns more detailed health information.
    """
    return {
        "status": "healthy",
        "service": "Mathematics Homework Solver API",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "checks": {
            "api": "healthy",
            "database": "healthy",  # Could be expanded with actual checks
            "storage": "healthy"     # Could be expanded with actual checks
        }
    }
