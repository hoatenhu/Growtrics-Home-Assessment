import os
from typing import List, Dict, Any, Optional
import asyncio
from datetime import datetime
import time

from models.homework_models import ExtractedContent, Solution, Question, ProblemType
from services.ai_providers.provider_factory import AIProviderFactory
from services.ai_providers.base_provider import AIProvider
from config.config import settings

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
        # Use centralized configuration with Gemini as default
        if not provider_name:
            provider_name = settings.AI_PROVIDER
        
        if not model:
            model = settings.AI_MODEL
        
        if not api_key:
            # Try to get API key for the specific provider
            if provider_name == "openai":
                api_key = settings.OPENAI_API_KEY
            elif provider_name == "gemini":
                api_key = settings.GEMINI_API_KEY
        
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
    
    async def solve_problems_from_image(self, image_path: str) -> Solution:
        """Solve mathematical problems directly from image using AI vision (bypasses OCR)"""
        start_time = time.time()
        
        try:
            print(f"🔍 Analyzing image directly with {self.provider.provider_name}...")
            
            # Check if provider supports image processing
            if hasattr(self.provider, 'solve_homework_from_image'):
                solved_questions = await self.provider.solve_homework_from_image(image_path)
                
                # Generate overall explanation
                overall_explanation = await self.provider.generate_overall_explanation(solved_questions)
                
                processing_time = time.time() - start_time
                print(f"✅ Solved {len(solved_questions)} questions in {processing_time:.2f}s using AI Vision")
                
                return Solution(
                    problem_id="",  # This will be set by the caller
                    questions_solved=solved_questions,
                    overall_explanation=overall_explanation,
                    total_questions=len(solved_questions),
                    solved_at=datetime.now(),
                    processing_time_seconds=processing_time
                )
            else:
                # Fallback: Provider doesn't support image processing
                print(f"⚠️  {self.provider.provider_name} doesn't support direct image processing")
                print("📝 Falling back to OCR-based approach...")
                
                # Create mock extracted content and use regular solving
                from services.ocr_service import OCRService
                ocr_service = OCRService()
                extracted_content = await ocr_service.extract_content(image_path)
                return await self.solve_problems(extracted_content)
                
        except Exception as e:
            print(f"❌ Error solving problems from image: {e}")
            # Create a fallback solution
            processing_time = time.time() - start_time
            return Solution(
                problem_id="",
                questions_solved=[Question(
                    question_number=1,
                    question_text="Error processing image",
                    problem_type=ProblemType.OTHER,
                    explanation=f"Unable to process image: {str(e)}",
                    steps=["Please check the image format and try again"]
                )],
                overall_explanation=f"Unable to process homework image due to error: {str(e)}",
                total_questions=1,
                solved_at=datetime.now(),
                processing_time_seconds=processing_time
            )
    
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
