import os
from typing import Dict, Type, Optional
from .base_provider import AIProvider
from .openai_provider import OpenAIProvider
from .gemini_provider import GeminiProvider
from .mock_provider import MockProvider

class AIProviderFactory:
    """Factory class to create and manage AI providers"""
    
    # Registry of available providers
    _providers: Dict[str, Type[AIProvider]] = {
        "openai": OpenAIProvider,
        "gemini": GeminiProvider,
        "mock": MockProvider
    }
    
    @classmethod
    def get_provider(cls, 
                     provider_name: str = None, 
                     model: str = None, 
                     api_key: str = None,
                     **kwargs) -> AIProvider:
        """
        Get an AI provider instance
        
        Args:
            provider_name: Name of the provider ("openai", "gemini", "mock")
            model: Model name to use
            api_key: API key for the provider
            **kwargs: Additional provider-specific configuration
        
        Returns:
            Configured AIProvider instance
        """
        
        # Auto-detect provider if not specified
        if not provider_name:
            provider_name = cls._auto_detect_provider()
        
        provider_name = provider_name.lower()
        
        if provider_name not in cls._providers:
            available_providers = ", ".join(cls._providers.keys())
            raise ValueError(f"Unknown provider '{provider_name}'. Available providers: {available_providers}")
        
        # Get API key from environment if not provided
        if not api_key:
            api_key = cls._get_api_key_for_provider(provider_name)
        
        # Get default model if not specified
        if not model:
            model = cls._get_default_model(provider_name)
        
        # Create provider instance
        provider_class = cls._providers[provider_name]
        
        try:
            if provider_name == "mock":
                return provider_class(**kwargs)
            else:
                return provider_class(api_key=api_key, model=model, **kwargs)
        except Exception as e:
            print(f"Failed to create {provider_name} provider: {e}")
            print("Falling back to mock provider...")
            return MockProvider(**kwargs)
    
    @classmethod
    def _auto_detect_provider(cls) -> str:
        """Auto-detect which provider to use based on available API keys"""
        
        # Check for API keys in order of preference
        if os.getenv("GEMINI_API_KEY"):
            return "gemini"
        elif os.getenv("GOOGLE_API_KEY"):  # Alternative env var name
            return "gemini"
        elif os.getenv("OPENAI_API_KEY"):
            return "openai"
        else:
            # No API keys found, use mock provider
            return "mock"
    
    @classmethod
    def _get_api_key_for_provider(cls, provider_name: str) -> Optional[str]:
        """Get API key for a specific provider from environment variables"""
        
        env_vars = {
            "openai": ["OPENAI_API_KEY"],
            "gemini": ["GEMINI_API_KEY", "GOOGLE_API_KEY"],
            "mock": []  # Mock provider doesn't need API key
        }
        
        if provider_name not in env_vars:
            return None
        
        for env_var in env_vars[provider_name]:
            api_key = os.getenv(env_var)
            if api_key:
                return api_key
        
        return None
    
    @classmethod
    def _get_default_model(cls, provider_name: str) -> str:
        """Get default model for a provider"""
        
        defaults = {
            "openai": "gpt-4",
            "gemini": "gemini-pro", 
            "mock": "mock-model-v1"
        }
        
        return defaults.get(provider_name, "default")
    
    @classmethod
    def list_available_providers(cls) -> Dict[str, Dict]:
        """List all available providers and their status"""
        
        providers_info = {}
        
        for name, provider_class in cls._providers.items():
            api_key = cls._get_api_key_for_provider(name)
            
            # Create a temporary instance to check availability
            try:
                if name == "mock":
                    instance = provider_class()
                else:
                    instance = provider_class(api_key=api_key)
                
                providers_info[name] = {
                    "name": instance.provider_name,
                    "available": instance.is_available,
                    "models": instance.supported_models,
                    "has_api_key": api_key is not None
                }
            except Exception as e:
                providers_info[name] = {
                    "name": name.title(),
                    "available": False,
                    "models": [],
                    "has_api_key": api_key is not None,
                    "error": str(e)
                }
        
        return providers_info
    
    @classmethod
    def register_provider(cls, name: str, provider_class: Type[AIProvider]):
        """Register a new custom provider"""
        cls._providers[name.lower()] = provider_class
