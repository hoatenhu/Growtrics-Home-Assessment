#!/usr/bin/env python3
"""
Test script for AI providers in the Mathematics Homework Solver
"""

import asyncio
import os
import sys
from typing import Dict, Any

# Add the current directory to the Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from services.ai_providers.provider_factory import AIProviderFactory
from services.ai_providers.openai_provider import OpenAIProvider
from services.ai_providers.gemini_provider import GeminiProvider
from services.ai_providers.mock_provider import MockProvider
from models.homework_models import Question, ProblemType

def print_header(title: str):
    """Print a formatted header"""
    print("\n" + "="*60)
    print(f" {title}")
    print("="*60)

def print_provider_info(provider_name: str, info: Dict[str, Any]):
    """Print provider information in a formatted way"""
    print(f"\n📊 {provider_name.upper()} Provider:")
    print(f"   Name: {info.get('name', 'Unknown')}")
    print(f"   Available: {'✅' if info.get('available') else '❌'}")
    print(f"   Has API Key: {'✅' if info.get('has_api_key') else '❌'}")
    print(f"   Models: {', '.join(info.get('models', []))}")
    if 'error' in info:
        print(f"   Error: {info['error']}")

async def test_provider(provider, provider_name: str):
    """Test a specific provider with sample questions"""
    print(f"\n🧪 Testing {provider_name} Provider...")
    
    # Create sample questions
    sample_questions = [
        Question(
            question_number=1,
            question_text="Which one of the following is sixty-three thousand and forty in numerals?",
            problem_type=ProblemType.MULTIPLE_CHOICE,
            options=["6340", "63 040", "63 400", "630 040"]
        ),
        Question(
            question_number=2,
            question_text="Calculate: 456 + 789 = ?",
            problem_type=ProblemType.CALCULATION
        )
    ]
    
    results = []
    
    try:
        for question in sample_questions:
            print(f"   Solving Q{question.question_number}: {question.question_text[:50]}...")
            solved_question = await provider.solve_single_question(question)
            results.append(solved_question)
            
            if solved_question.correct_answer:
                print(f"   ✅ Answer: {solved_question.correct_answer}")
            else:
                print(f"   ❌ No answer provided")
        
        # Test overall explanation
        print("   Generating overall explanation...")
        explanation = await provider.generate_overall_explanation(results)
        print(f"   📝 Explanation: {explanation[:100]}...")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error testing {provider_name}: {e}")
        return False

async def test_factory():
    """Test the provider factory"""
    print_header("Testing Provider Factory")
    
    # Test auto-detection
    print("🔍 Testing auto-detection...")
    auto_provider = AIProviderFactory.get_provider()
    print(f"   Auto-detected provider: {auto_provider.provider_name}")
    
    # Test specific providers
    providers_to_test = ["mock", "openai", "gemini"]
    
    for provider_name in providers_to_test:
        try:
            print(f"\n🏭 Creating {provider_name} provider...")
            provider = AIProviderFactory.get_provider(provider_name=provider_name)
            print(f"   ✅ Created: {provider.provider_name}")
            print(f"   Available: {'✅' if provider.is_available else '❌'}")
        except Exception as e:
            print(f"   ❌ Failed to create {provider_name}: {e}")

async def run_comprehensive_test():
    """Run comprehensive tests of the provider system"""
    print_header("Mathematics Homework Solver - AI Provider Test Suite")
    
    # List all available providers
    print_header("Available Providers")
    providers_info = AIProviderFactory.list_available_providers()
    
    for provider_name, info in providers_info.items():
        print_provider_info(provider_name, info)
    
    # Test factory
    await test_factory()
    
    # Test each provider that's available
    print_header("Provider Testing")
    
    for provider_name in ["mock", "openai", "gemini"]:
        try:
            provider = AIProviderFactory.get_provider(provider_name=provider_name)
            if provider.is_available or provider_name == "mock":
                success = await test_provider(provider, provider_name)
                if success:
                    print(f"   ✅ {provider_name} test completed successfully")
                else:
                    print(f"   ❌ {provider_name} test failed")
            else:
                print(f"   ⏭️  Skipping {provider_name} (not available)")
        except Exception as e:
            print(f"   ❌ Failed to test {provider_name}: {e}")

def check_environment():
    """Check environment variables and configuration"""
    print_header("Environment Check")
    
    env_vars = [
        ("AI_PROVIDER", "AI Provider Selection"),
        ("AI_MODEL", "AI Model Selection"),
        ("OPENAI_API_KEY", "OpenAI API Key"),
        ("GEMINI_API_KEY", "Gemini API Key"),
        ("GOOGLE_API_KEY", "Google API Key (alternative)")
    ]
    
    for env_var, description in env_vars:
        value = os.getenv(env_var)
        if value:
            if "key" in env_var.lower():
                display_value = f"{value[:8]}..." if len(value) > 8 else value
            else:
                display_value = value
            print(f"   ✅ {description}: {display_value}")
        else:
            print(f"   ❌ {description}: Not set")

def print_usage_instructions():
    """Print usage instructions"""
    print_header("Usage Instructions")
    
    print("""
🚀 To use different AI providers:

1. Environment Variables:
   export AI_PROVIDER=gemini          # Use Gemini
   export AI_PROVIDER=openai          # Use OpenAI
   export AI_PROVIDER=mock            # Use Mock (for testing)
   export AI_PROVIDER=auto            # Auto-detect (default)

2. API Keys:
   export GEMINI_API_KEY=your_key     # For Gemini
   export OPENAI_API_KEY=your_key     # For OpenAI

3. Models (optional):
   export AI_MODEL=gemini-pro         # Specific Gemini model
   export AI_MODEL=gpt-4              # Specific OpenAI model

4. In your .env file:
   AI_PROVIDER=gemini
   GEMINI_API_KEY=your_gemini_api_key_here
   AI_MODEL=gemini-pro

5. Test the API:
   GET /ai-providers                  # List all providers
   GET /ai-providers/current          # Current provider info
   POST /solve-homework/{id}          # Solve with current provider
""")

async def main():
    """Main test function"""
    check_environment()
    await run_comprehensive_test()
    print_usage_instructions()
    
    print_header("Test Complete")
    print("✅ Provider system test completed!")
    print("🚀 Ready to solve mathematics homework with multiple AI providers!")

if __name__ == "__main__":
    asyncio.run(main())
