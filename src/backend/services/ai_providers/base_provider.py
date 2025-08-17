from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional
from models.homework_models import Question

class AIProvider(ABC):
    """Abstract base class for AI providers"""
    
    def __init__(self, api_key: Optional[str] = None, **kwargs):
        self.api_key = api_key
        self.config = kwargs
        self.is_available = self._check_availability()
    
    @abstractmethod
    def _check_availability(self) -> bool:
        """Check if the provider is available (has API key, etc.)"""
        pass
    
    @abstractmethod
    async def solve_single_question(self, question: Question) -> Question:
        """Solve a single mathematical question"""
        pass
    
    @abstractmethod
    async def generate_overall_explanation(self, solved_questions: List[Question]) -> str:
        """Generate an overall explanation for all solved questions"""
        pass
    
    @property
    @abstractmethod
    def provider_name(self) -> str:
        """Return the name of the provider"""
        pass
    
    @property
    @abstractmethod
    def supported_models(self) -> List[str]:
        """Return list of supported models for this provider"""
        pass
    
    def get_system_prompt(self) -> str:
        """Get the system prompt for mathematical problem solving"""
        return """You are an expert mathematics tutor. Your job is to solve mathematical problems step by step and provide clear explanations that students can understand. 

For multiple choice questions, identify the correct answer and explain why.
For calculation problems, show all work step by step.
Always provide educational explanations that help students learn.

Respond in JSON format with:
{
    "correct_answer": "the correct answer",
    "explanation": "detailed explanation of the solution",
    "steps": ["step 1", "step 2", "step 3", ...]
}"""
    
    def create_question_prompt(self, question: Question) -> str:
        """Create a detailed prompt for solving a specific question"""
        prompt = f"Question {question.question_number}: {question.question_text}\n\n"
        
        if question.options:
            prompt += "Options:\n"
            for i, option in enumerate(question.options, 1):
                prompt += f"{i}. {option}\n"
            prompt += "\n"
        
        prompt += f"Problem Type: {question.problem_type.value}\n\n"
        prompt += "Please solve this step by step and provide a clear explanation."
        
        return prompt
    
    def get_summary_system_prompt(self) -> str:
        """Get system prompt for generating overall explanations"""
        return "You are a mathematics tutor. Provide a brief overall summary of the homework problems that were solved, highlighting the key concepts and skills practiced."
