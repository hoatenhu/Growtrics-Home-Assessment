import openai
import json
from typing import List, Optional
from .base_provider import AIProvider
from models.homework_models import Question

class OpenAIProvider(AIProvider):
    """OpenAI GPT provider for mathematical problem solving"""
    
    def __init__(self, api_key: Optional[str] = None, model: str = "gpt-4", **kwargs):
        self.model = model
        super().__init__(api_key, **kwargs)
        if self.is_available:
            self.client = openai.AsyncOpenAI(api_key=self.api_key)
        else:
            self.client = None
    
    def _check_availability(self) -> bool:
        """Check if OpenAI API key is available"""
        return self.api_key is not None and self.api_key.strip() != ""
    
    @property
    def provider_name(self) -> str:
        return "OpenAI"
    
    @property
    def supported_models(self) -> List[str]:
        return [
            "gpt-4",
            "gpt-4-turbo",
            "gpt-4-turbo-preview", 
            "gpt-3.5-turbo",
            "gpt-3.5-turbo-16k"
        ]
    
    async def solve_single_question(self, question: Question) -> Question:
        """Solve a single mathematical question using OpenAI"""
        try:
            if not self.client:
                raise Exception("OpenAI client not available")
            
            prompt = self.create_question_prompt(question)
            
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": self.get_system_prompt()
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.1,
                max_tokens=1000
            )
            
            # Parse the AI response
            response_text = response.choices[0].message.content
            solution_data = json.loads(response_text)
            
            # Update the question with the solution
            question.correct_answer = solution_data.get("correct_answer")
            question.explanation = solution_data.get("explanation")
            question.steps = solution_data.get("steps", [])
            
            return question
            
        except Exception as e:
            print(f"Error solving question with OpenAI: {e}")
            question.explanation = f"Error solving this question with OpenAI: {str(e)}"
            return question
    
    async def generate_overall_explanation(self, solved_questions: List[Question]) -> str:
        """Generate an overall explanation using OpenAI"""
        try:
            if not self.client:
                return "Overall: These problems test various mathematical concepts including number representation, percentages, and basic arithmetic."
            
            # Create summary of all questions
            summary = "Questions solved:\n"
            for q in solved_questions:
                summary += f"Q{q.question_number}: {q.question_text[:100]}...\n"
                if q.correct_answer:
                    summary += f"Answer: {q.correct_answer}\n"
                summary += "\n"
            
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": self.get_summary_system_prompt()
                    },
                    {
                        "role": "user",
                        "content": f"Please provide a brief overall explanation for this homework assignment:\n\n{summary}"
                    }
                ],
                temperature=0.1,
                max_tokens=500
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            print(f"Error generating overall explanation with OpenAI: {e}")
            return "Overall: This homework covers various mathematical concepts and problem-solving skills."
