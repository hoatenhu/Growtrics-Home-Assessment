"""
Application lifespan management

Handles startup and shutdown events for the FastAPI application.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI

from core.dependencies import get_firebase_service, get_math_solver_service

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager
    
    Handles startup and shutdown events for the FastAPI application.
    This replaces the deprecated @app.on_event("startup") and @app.on_event("shutdown") decorators.
    """
    # Startup
    print("🚀 Starting Mathematics Homework Solver API...")
    
    # Initialize Firebase service
    firebase_service = get_firebase_service()
    firebase_service.initialize()
    
    # Show which AI provider is being used
    math_solver_service = get_math_solver_service()
    provider_name = math_solver_service.provider.provider_name
    print(f"🤖 Initialized Math Solver with {provider_name} provider")
    
    print("✅ Application startup complete!")
    
    yield
    
    # Shutdown
    print("🛑 Shutting down Mathematics Homework Solver API...")
    # Add any cleanup logic here if needed
    print("✅ Application shutdown complete!")
