"""
FastAPI application factory

Creates and configures the FastAPI application with all middleware and routes.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.lifespan import lifespan

def create_app() -> FastAPI:
    """
    Create and configure the FastAPI application
    
    Returns:
        FastAPI: Configured FastAPI application instance
    """
    
    # Create FastAPI app with lifespan management
    app = FastAPI(
        title="Mathematics Homework Solver API",
        description="An AI-powered API to solve student mathematics homework problems from uploaded images or PDFs",
        version="1.0.0",
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan
    )
    
    # Configure CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Configure this properly for production
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    
    # Include route handlers
    from routes.health import router as health_router
    from routes.providers import router as providers_router
    from routes.homework import router as homework_router
    
    app.include_router(health_router, tags=["Health"])
    app.include_router(providers_router, prefix="/ai-providers", tags=["AI Providers"])
    app.include_router(homework_router, prefix="/homework", tags=["Homework"])
    
    # Include legacy upload route (separate from homework prefix for backwards compatibility)
    from routes.homework import upload_router
    app.include_router(upload_router, tags=["Upload"])
    
    return app
