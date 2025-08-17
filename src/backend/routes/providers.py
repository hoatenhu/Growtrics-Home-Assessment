"""
AI Provider management endpoints

Endpoints for managing and monitoring AI providers (OpenAI, Gemini, etc.)
"""

from fastapi import APIRouter, HTTPException
from typing import Dict, Any

from services.ai_providers.provider_factory import AIProviderFactory
from core.dependencies import get_math_solver_service

router = APIRouter()

@router.get("")
async def get_ai_providers() -> Dict[str, Any]:
    """
    Get information about all available AI providers
    
    Returns information about all configured AI providers including:
    - Which providers are available
    - Current provider being used
    - Provider capabilities and models
    """
    try:
        math_solver_service = get_math_solver_service()
        providers_info = AIProviderFactory.list_available_providers()
        
        return {
            "available_providers": providers_info,
            "current_provider": math_solver_service.get_provider_info()
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Error getting provider info: {str(e)}"
        )

@router.get("/current")
async def get_current_provider() -> Dict[str, Any]:
    """
    Get information about the currently active AI provider
    
    Returns details about the provider currently being used for solving
    mathematical problems.
    """
    try:
        math_solver_service = get_math_solver_service()
        return math_solver_service.get_provider_info()
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Error getting current provider: {str(e)}"
        )

@router.get("/status")
async def get_providers_status() -> Dict[str, Any]:
    """
    Get detailed status of all AI providers
    
    Returns comprehensive status information including availability,
    API key status, and any error messages.
    """
    try:
        math_solver_service = get_math_solver_service()
        providers_info = AIProviderFactory.list_available_providers()
        current_provider = math_solver_service.get_provider_info()
        
        # Count available providers
        available_count = sum(1 for p in providers_info.values() if p.get('available', False))
        total_count = len(providers_info)
        
        return {
            "summary": {
                "total_providers": total_count,
                "available_providers": available_count,
                "current_provider": current_provider.get("provider_name", "unknown")
            },
            "providers": providers_info,
            "current": current_provider
        }
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Error getting provider status: {str(e)}"
        )
