import os
from typing import List, Dict, Any, Optional
import asyncio
from datetime import datetime
import time

from models.homework_models import ExtractedContent, Solution, Question, ProblemType
from services.ai_providers.provider_factory import AIProviderFactory
from services.ai_providers.base_provider import AIProvider

class MathSolverService:
    def __init__(self, 
                 provider_name: Optional[str] = None, 
                 model: Optional[str] = None,
                 api_key: Optional[str] = None):
        """
        Initialize Math Solver Service with configurable AI provider
        
        Args:
            provider_name: AI provider to use ("openai", "gemini", "mock")
            model: Specific model to use
            api_key: API key for the provider
        """
        # Get provider from environment or use auto-detection
        if not provider_name:
            provider_name = os.getenv("AI_PROVIDER", "auto")
        
        if not model:
            model = os.getenv("AI_MODEL")
        
        if not api_key:
            # Try to get API key for the specific provider
            if provider_name == "openai":
                api_key = os.getenv("OPENAI_API_KEY")
            elif provider_name == "gemini":
                api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
        
        # Create the AI provider
        self.provider = AIProviderFactory.get_provider(
            provider_name=provider_name if provider_name != "auto" else None,
            model=model,
            api_key=api_key
        )
        
        print(f"Initialized Math Solver with {self.provider.provider_name} provider")
    
    async def solve_problems(self, extracted_content: ExtractedContent) -> Solution:
        """Solve mathematical problems using AI provider"""
        start_time = time.time()
        
        try:
            solved_questions = []
            
            for question in extracted_content.questions:
                solved_question = await self.provider.solve_single_question(question)
                solved_questions.append(solved_question)
            
            # Generate overall explanation
            overall_explanation = await self.provider.generate_overall_explanation(solved_questions)
            
            processing_time = time.time() - start_time
            
            return Solution(
                problem_id="",  # This will be set by the caller
                questions_solved=solved_questions,
                overall_explanation=overall_explanation,
                total_questions=len(solved_questions),
                solved_at=datetime.now(),
                processing_time_seconds=processing_time
            )
            
        except Exception as e:
            print(f"Error solving problems with {self.provider.provider_name}: {e}")
            # Create a basic fallback solution
            return self._create_fallback_solution(extracted_content, start_time)
    
    def get_provider_info(self) -> Dict[str, Any]:
        """Get information about the current AI provider"""
        return {
            "provider_name": self.provider.provider_name,
            "is_available": self.provider.is_available,
            "supported_models": self.provider.supported_models
        }
    
    def _create_fallback_solution(self, extracted_content: ExtractedContent, start_time: float) -> Solution:
        """Create a basic fallback solution when AI provider fails"""
        solved_questions = []
        
        for question in extracted_content.questions:
            # Create a basic response indicating an error occurred
            question.correct_answer = "Unable to solve - AI provider error"
            question.explanation = f"There was an error processing this question with the {self.provider.provider_name} provider. Please try again or check your API configuration."
            question.steps = [
                "Error occurred during AI processing",
                "Check API key configuration",
                "Verify provider availability",
                "Contact support if issue persists"
            ]
            solved_questions.append(question)
        
        processing_time = time.time() - start_time
        
        return Solution(
            problem_id="",
            questions_solved=solved_questions,
            overall_explanation=f"Unable to process homework due to {self.provider.provider_name} provider error. Please check your configuration and try again.",
            total_questions=len(solved_questions),
            solved_at=datetime.now(),
            processing_time_seconds=processing_time
        )
