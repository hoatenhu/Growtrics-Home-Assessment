from typing import List
from .base_provider import AIProvider
from models.homework_models import Question

class MockProvider(AIProvider):
    """Mock AI provider for development and testing"""
    
    def __init__(self, **kwargs):
        super().__init__(api_key="mock_key", **kwargs)
    
    def _check_availability(self) -> bool:
        """Mock provider is always available"""
        return True
    
    @property
    def provider_name(self) -> str:
        return "Mock Provider"
    
    @property
    def supported_models(self) -> List[str]:
        return ["mock-model-v1", "mock-model-v2"]
    
    async def solve_single_question(self, question: Question) -> Question:
        """Provide mock solutions for testing"""
        if question.question_number == 1:
            # Mock solution for number representation question
            question.correct_answer = "63 040"
            question.explanation = "Sixty-three thousand and forty is written as 63,040. The word 'thousand' indicates we need 63 in the thousands place, and 'forty' means 40 in the ones/tens place."
            question.steps = [
                "Identify 'sixty-three thousand' = 63,000",
                "Identify 'forty' = 40", 
                "Combine: 63,000 + 40 = 63,040",
                "Check the options to find 63 040"
            ]
        elif question.question_number == 2:
            # Mock solution for percentage question
            question.correct_answer = "35%"
            question.explanation = "Looking at the figure with 20 identical rectangles, I need to count the shaded rectangles. There appear to be 7 shaded rectangles out of 20 total. 7/20 = 0.35 = 35%."
            question.steps = [
                "Count total rectangles: 20",
                "Count shaded rectangles: 7",
                "Calculate percentage: 7 ÷ 20 = 0.35",
                "Convert to percentage: 0.35 × 100% = 35%"
            ]
        elif "calculate" in question.question_text.lower() or "+" in question.question_text:
            # Mock solution for calculation problems
            question.correct_answer = "1245"
            question.explanation = "This is a basic addition problem. Adding the numbers step by step."
            question.steps = [
                "Set up the addition problem",
                "Add ones place: 6 + 9 = 15, write 5 carry 1",
                "Add tens place: 5 + 8 + 1 = 14, write 4 carry 1", 
                "Add hundreds place: 4 + 7 + 1 = 12, write 2 carry 1",
                "Result: 1245"
            ]
        elif "area" in question.question_text.lower():
            # Mock solution for area problems
            question.correct_answer = "96 cm²"
            question.explanation = "To find the area of a rectangle, multiply length by width."
            question.steps = [
                "Identify the formula: Area = length × width",
                "Substitute values: Area = 12 cm × 8 cm",
                "Calculate: 12 × 8 = 96",
                "Add units: 96 cm²"
            ]
        elif "apple" in question.question_text.lower():
            # Mock solution for word problems
            question.correct_answer = "8 apples"
            question.explanation = "This is a subtraction word problem. John starts with 15 apples and gives away 7."
            question.steps = [
                "Identify what we know: John has 15 apples initially",
                "Identify what happens: He gives away 7 apples",
                "Set up subtraction: 15 - 7",
                "Calculate: 15 - 7 = 8 apples remaining"
            ]
        else:
            # Generic mock solution
            question.correct_answer = "Answer depends on the specific problem"
            question.explanation = f"This is a mock solution for question {question.question_number}. In a real scenario, an AI would analyze the mathematical content and provide a detailed step-by-step solution."
            question.steps = [
                "Step 1: Analyze the problem",
                "Step 2: Identify the mathematical concept",
                "Step 3: Apply the appropriate method",
                "Step 4: Calculate the result"
            ]
        
        return question
    
    async def generate_overall_explanation(self, solved_questions: List[Question]) -> str:
        """Generate mock overall explanation"""
        problem_types = set()
        for q in solved_questions:
            if q.problem_type:
                problem_types.add(q.problem_type.value)
        
        explanation = f"This homework assignment covers {len(solved_questions)} questions focusing on "
        
        if problem_types:
            explanation += f"{', '.join(problem_types)} concepts. "
        else:
            explanation += "various mathematical concepts. "
        
        explanation += "These problems help students practice fundamental mathematical skills including number recognition, basic arithmetic, percentage calculations, and problem-solving strategies. Each solution provides step-by-step guidance to help students understand the underlying mathematical principles."
        
        return explanation
