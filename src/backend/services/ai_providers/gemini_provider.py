import google.generativeai as genai
import json
from typing import List, Optional
from .base_provider import AIProvider
from models.homework_models import Question

class GeminiProvider(AIProvider):
    """Google Gemini provider for mathematical problem solving"""
    
    def __init__(self, api_key: Optional[str] = None, model: str = "gemini-pro", **kwargs):
        self.model = model
        super().__init__(api_key, **kwargs)
        if self.is_available:
            genai.configure(api_key=self.api_key)
            self.client = genai.GenerativeModel(self.model)
        else:
            self.client = None
    
    def _check_availability(self) -> bool:
        """Check if Gemini API key is available"""
        return self.api_key is not None and self.api_key.strip() != ""
    
    @property
    def provider_name(self) -> str:
        return "Google Gemini"
    
    @property
    def supported_models(self) -> List[str]:
        return [
            "gemini-pro",
            "gemini-pro-vision",
            "gemini-1.5-pro",
            "gemini-1.5-flash"
        ]
    
    async def solve_single_question(self, question: Question) -> Question:
        """Solve a single mathematical question using Gemini"""
        try:
            if not self.client:
                raise Exception("Gemini client not available")
            
            # Create the full prompt including system instructions
            system_prompt = self.get_system_prompt()
            user_prompt = self.create_question_prompt(question)
            
            full_prompt = f"{system_prompt}\n\n{user_prompt}"
            
            # Generate response
            response = await self._generate_async(full_prompt)
            
            # Parse the AI response
            try:
                # Try to extract JSON from the response
                response_text = response.text
                
                # Sometimes Gemini includes markdown formatting, so let's clean it
                if "```json" in response_text:
                    json_start = response_text.find("```json") + 7
                    json_end = response_text.find("```", json_start)
                    response_text = response_text[json_start:json_end].strip()
                elif "```" in response_text:
                    json_start = response_text.find("```") + 3
                    json_end = response_text.find("```", json_start)
                    response_text = response_text[json_start:json_end].strip()
                
                solution_data = json.loads(response_text)
                
            except json.JSONDecodeError:
                # If JSON parsing fails, try to extract information manually
                solution_data = self._extract_solution_from_text(response.text)
            
            # Update the question with the solution
            question.correct_answer = solution_data.get("correct_answer")
            question.explanation = solution_data.get("explanation")
            question.steps = solution_data.get("steps", [])
            
            return question
            
        except Exception as e:
            print(f"Error solving question with Gemini: {e}")
            question.explanation = f"Error solving this question with Gemini: {str(e)}"
            return question
    
    async def generate_overall_explanation(self, solved_questions: List[Question]) -> str:
        """Generate an overall explanation using Gemini"""
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
            
            system_prompt = self.get_summary_system_prompt()
            user_prompt = f"Please provide a brief overall explanation for this homework assignment:\n\n{summary}"
            
            full_prompt = f"{system_prompt}\n\n{user_prompt}"
            
            response = await self._generate_async(full_prompt)
            return response.text
            
        except Exception as e:
            print(f"Error generating overall explanation with Gemini: {e}")
            return "Overall: This homework covers various mathematical concepts and problem-solving skills."
    
    async def _generate_async(self, prompt: str):
        """Generate response asynchronously using Gemini"""
        import asyncio
        
        # Gemini's Python SDK doesn't have native async support yet,
        # so we'll run it in a thread pool
        loop = asyncio.get_event_loop()
        
        def _generate_sync():
            return self.client.generate_content(
                prompt,
                generation_config=genai.types.GenerationConfig(
                    temperature=0.1,
                    max_output_tokens=1000,
                )
            )
        
        return await loop.run_in_executor(None, _generate_sync)
    
    def _extract_solution_from_text(self, text: str) -> dict:
        """Extract solution information from unstructured text"""
        solution_data = {
            "correct_answer": None,
            "explanation": text,
            "steps": []
        }
        
        # Try to find answer patterns
        lines = text.split('\n')
        for line in lines:
            line = line.strip()
            
            # Look for answer patterns
            if any(keyword in line.lower() for keyword in ['answer:', 'correct answer:', 'solution:']):
                # Extract the answer
                if ':' in line:
                    answer = line.split(':', 1)[1].strip()
                    solution_data["correct_answer"] = answer
            
            # Look for steps (numbered lines)
            if line and (line[0].isdigit() or line.startswith('Step')):
                if solution_data["steps"] is None:
                    solution_data["steps"] = []
                solution_data["steps"].append(line)
        
        return solution_data
