import google.generativeai as genai
import json
from typing import List, Optional
from PIL import Image
import base64
import io
import asyncio
from concurrent.futures import ThreadPoolExecutor
from .base_provider import AIProvider
from models.homework_models import Question
from config.config import settings

class GeminiProvider(AIProvider):
    """Google Gemini provider for mathematical problem solving"""
    
    def __init__(self, api_key: Optional[str] = None, model: Optional[str] = None, **kwargs):
        # Use AI_MODEL from .env file, fallback to gemini-1.5-flash
        self.model = model or settings.AI_MODEL
        
        # Use the same model for vision if it supports it, otherwise use gemini-1.5-flash
        self.vision_model = self.model if self.model in ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-pro-vision"] else "gemini-1.5-flash"
        
        super().__init__(api_key, **kwargs)
        if self.is_available:
            genai.configure(api_key=self.api_key)
            self.client = genai.GenerativeModel(self.model)
            # Create vision model - gemini-1.5-flash supports both text and vision
            self.vision_client = genai.GenerativeModel(self.vision_model)
            print(f"✅ Gemini initialized: Text={self.model}, Vision={self.vision_model}")
        else:
            self.client = None
            self.vision_client = None
    
    def _check_availability(self) -> bool:
        """Check if Gemini API key is available"""
        return self.api_key is not None and self.api_key.strip() != ""
    
    @property
    def provider_name(self) -> str:
        return "Google Gemini"
    
    @property
    def supported_models(self) -> List[str]:
        return [
            "gemini-1.5-flash",  # Default: fastest & supports vision
            "gemini-1.5-pro",   # More capable, slower
            "gemini-pro",       # Original text-only model
            "gemini-pro-vision" # Legacy vision model
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
    
    async def solve_homework_from_image(self, file_path: str) -> List[Question]:
        """Solve homework problems directly from image or PDF using Gemini Vision"""
        try:
            if not self.vision_client:
                raise Exception("Gemini Vision client not available")
            
            # Check if file is PDF or image
            if file_path.lower().endswith('.pdf'):
                print(f"📄 Processing PDF file: {file_path}")
                return await self._solve_from_pdf(file_path)
            else:
                print(f"🖼️ Processing image file: {file_path}")
                return await self._solve_from_image(file_path)
                
        except Exception as e:
            print(f"Error solving homework from file with Gemini Vision: {e}")
            # Return a fallback question
            return [Question(
                question_number=1,
                question_text="Error processing file",
                problem_type="other",
                explanation=f"Unable to process file: {str(e)}",
                steps=["Please check the file format and try again"]
            )]
    
    async def _solve_from_pdf(self, pdf_path: str) -> List[Question]:
        """Process PDF directly using Gemini Vision (no conversion needed)"""
        try:
            print(f"📄 Processing PDF directly with Gemini Vision: {pdf_path}")
            
            # Read PDF file as bytes
            with open(pdf_path, 'rb') as pdf_file:
                pdf_data = pdf_file.read()
            
            # Create prompt for PDF analysis
            prompt = """You are a mathematics teacher analyzing a homework from PDF or Image. Examine EVERY page and find ALL mathematical questions.

IMPORTANT: Respond with VALID JSON only. Do not include any text before or after the JSON.

For each question found, provide:
- question_number: Sequential number starting from 1
- question_text: Complete question exactly as written
- problem_type: one of "multiple_choice", "calculation", "geometry", "algebra", "word_problem", "other"
- options: Array of choices (if multiple choice), or null
- correct_answer: The correct answer
- explanation: Why this answer is correct
- steps: Array of solution steps

JSON format (ensure ALL quotes are properly escaped):
{
  "questions": [
    {
      "question_number": 1,
      "question_text": "Question text here",
      "problem_type": "multiple_choice",
      "options": ["A", "B", "C", "D"],
      "correct_answer": "B",
      "explanation": "Explanation here",
      "steps": ["Step 1", "Step 2", "Step 3"]
    }
  ]
}

Find ALL questions in the PDF. Return valid JSON only."""

            # Generate response with PDF
            response = await self._generate_with_pdf_async(prompt, pdf_data)
            questions = self._parse_questions_response(response.text, "PDF")
            
            print(f"📊 Found {len(questions)} questions in PDF")
            return questions if questions else [self._create_fallback_question("No questions found in PDF")]
            
        except Exception as e:
            print(f"❌ Error processing PDF directly: {e}")
            print("🔄 Trying fallback method with pdf2image...")
            return await self._solve_from_pdf_fallback(pdf_path)
    
    async def _solve_from_pdf_fallback(self, pdf_path: str) -> List[Question]:
        """Fallback: Convert PDF to images and solve using Gemini Vision"""
        try:
            # Import pdf2image here to avoid import errors if not installed
            from pdf2image import convert_from_path
            
            # Convert PDF to images
            loop = asyncio.get_event_loop()
            images = await loop.run_in_executor(
                ThreadPoolExecutor(max_workers=2),
                lambda: convert_from_path(pdf_path, dpi=200)
            )
            
            print(f"📄 Fallback: Converted PDF to {len(images)} pages")
            
            all_questions = []
            question_offset = 0
            
            # Process each page
            for page_num, image in enumerate(images, 1):
                print(f"🔍 Processing page {page_num}/{len(images)}...")
                
                # Create prompt for this page
                prompt = f"""You are a mathematics teacher and problem solver. Please analyze page {page_num} of this homework PDF and:

1. Identify all mathematical problems/questions on this page
2. For each question, provide:
   - Question number (start numbering from {question_offset + 1})
   - Complete question text
   - Problem type (multiple_choice, calculation, geometry, algebra, word_problem)
   - Available options (if it's multiple choice)
   - Correct answer with detailed explanation
   - Step-by-step solution

Please respond in JSON format like this:
{{
  "questions": [
    {{
      "question_number": {question_offset + 1},
      "question_text": "The complete question text...",
      "problem_type": "multiple_choice",
      "options": ["option1", "option2", "option3", "option4"],
      "correct_answer": "option2",
      "explanation": "Detailed explanation of why this is correct...",
      "steps": [
        "Step 1: Identify what the question is asking...",
        "Step 2: Apply the relevant mathematical principle...",
        "Step 3: Calculate the result..."
      ]
    }}
  ]
}}

Be thorough and accurate in your mathematical reasoning."""

                # Generate response for this page
                response = await self._generate_with_image_async(prompt, image)
                page_questions = self._parse_questions_response(response.text, page_num)
                
                # Update question numbering offset
                if page_questions:
                    question_offset = max(q.question_number for q in page_questions)
                    all_questions.extend(page_questions)
                    print(f"✅ Found {len(page_questions)} questions on page {page_num}")
            
            print(f"📊 Total questions found: {len(all_questions)}")
            return all_questions if all_questions else [self._create_fallback_question("No questions found in PDF")]
            
        except ImportError:
            print("❌ pdf2image not available - install with: pip install pdf2image")
            return [self._create_fallback_question("PDF processing requires pdf2image package")]
        except Exception as e:
            print(f"❌ Error in PDF fallback processing: {e}")
            return [self._create_fallback_question(f"PDF processing error: {str(e)}")]
    
    async def _solve_from_image(self, image_path: str) -> List[Question]:
        """Process single image file using Gemini Vision"""
        try:
            # Load and prepare the image
            image = Image.open(image_path)
            
            # Create prompt for homework solving
            prompt = """You are a mathematics teacher and problem solver. Please analyze this homework image and:

1. Identify all mathematical problems/questions in the image
2. For each question, provide:
   - Question number
   - Complete question text
   - Problem type (multiple_choice, calculation, geometry, algebra, word_problem)
   - Available options (if it's multiple choice)
   - Correct answer with detailed explanation
   - Step-by-step solution

Please respond in JSON format like this:
{
  "questions": [
    {
      "question_number": 1,
      "question_text": "The complete question text...",
      "problem_type": "multiple_choice",
      "options": ["option1", "option2", "option3", "option4"],
      "correct_answer": "option2",
      "explanation": "Detailed explanation of why this is correct...",
      "steps": [
        "Step 1: Identify what the question is asking...",
        "Step 2: Apply the relevant mathematical principle...",
        "Step 3: Calculate the result..."
      ]
    }
  ]
}

Be thorough and accurate in your mathematical reasoning."""

            # Generate response with image
            response = await self._generate_with_image_async(prompt, image)
            questions = self._parse_questions_response(response.text, 1)
            
            return questions if questions else [self._create_fallback_question("No questions found in image")]
            
        except Exception as e:
            print(f"❌ Error processing image: {e}")
            return [self._create_fallback_question(f"Image processing error: {str(e)}")]
    
    def _parse_questions_response(self, response_text: str, page_num: int) -> List[Question]:
        """Parse Gemini response into Question objects with robust error handling"""
        try:
            # Clean up markdown formatting
            cleaned_text = self._clean_json_response(response_text)
            
            # Try to parse the JSON
            solution_data = json.loads(cleaned_text)
            
            # Convert to Question objects
            questions = []
            for q_data in solution_data.get("questions", []):
                question = Question(
                    question_number=q_data.get("question_number", len(questions) + 1),
                    question_text=q_data.get("question_text", ""),
                    problem_type=q_data.get("problem_type", "other"),
                    options=q_data.get("options"),
                    correct_answer=q_data.get("correct_answer"),
                    explanation=q_data.get("explanation"),
                    steps=q_data.get("steps", [])
                )
                questions.append(question)
            
            print(f"✅ Successfully parsed {len(questions)} questions from response")
            return questions
            
        except json.JSONDecodeError as e:
            print(f"❌ JSON parsing error on page {page_num}: {e}")
            print(f"📝 Attempting to fix malformed JSON...")
            
            # Try to fix malformed JSON and parse again
            fixed_questions = self._extract_questions_from_malformed_json(response_text)
            if fixed_questions:
                print(f"✅ Recovered {len(fixed_questions)} questions from malformed JSON")
                return fixed_questions
            
            print(f"⚠️ Could not parse JSON, using raw response")
            print(f"Raw response preview: {response_text[:500]}...")
            
            # Return a fallback question with the raw response
            return [Question(
                question_number=1,
                question_text=f"Mathematics problem from page {page_num}",
                problem_type="other",
                explanation=response_text[:2000],  # Show more of the response
                steps=["Analysis provided by AI - JSON parsing failed"]
            )]
    
    def _clean_json_response(self, response_text: str) -> str:
        """Clean up common JSON formatting issues"""
        # Remove markdown formatting
        if "```json" in response_text:
            json_start = response_text.find("```json") + 7
            json_end = response_text.find("```", json_start)
            if json_end == -1:  # No closing ```
                response_text = response_text[json_start:].strip()
            else:
                response_text = response_text[json_start:json_end].strip()
        elif "```" in response_text:
            json_start = response_text.find("```") + 3
            json_end = response_text.find("```", json_start)
            if json_end == -1:  # No closing ```
                response_text = response_text[json_start:].strip()
            else:
                response_text = response_text[json_start:json_end].strip()
        
        # Remove any trailing commas before closing braces/brackets
        import re
        response_text = re.sub(r',(\s*[}\]])', r'\1', response_text)
        
        # Try to fix truncated JSON by adding missing closing braces
        open_braces = response_text.count('{')
        close_braces = response_text.count('}')
        open_brackets = response_text.count('[')
        close_brackets = response_text.count(']')
        
        # Add missing closing characters
        if open_braces > close_braces:
            response_text += '}' * (open_braces - close_braces)
        if open_brackets > close_brackets:
            response_text += ']' * (open_brackets - close_brackets)
        
        return response_text
    
    def _extract_questions_from_malformed_json(self, response_text: str) -> List[Question]:
        """Extract questions from malformed JSON using regex patterns"""
        questions = []
        
        try:
            # Look for question patterns in the text
            import re
            
            # Pattern to find question objects
            question_pattern = r'"question_number":\s*(\d+),\s*"question_text":\s*"([^"]+)"[^}]*"problem_type":\s*"([^"]*)"[^}]*"correct_answer":\s*"([^"]*)"'
            
            matches = re.findall(question_pattern, response_text, re.DOTALL)
            
            for match in matches:
                question_num, question_text, problem_type, correct_answer = match
                
                # Try to extract options if it's multiple choice
                options = None
                if 'multiple_choice' in problem_type:
                    options_pattern = r'"options":\s*\[([^\]]+)\]'
                    options_match = re.search(options_pattern, response_text[response_text.find(question_text):])
                    if options_match:
                        options_text = options_match.group(1)
                        options = [opt.strip().strip('"') for opt in options_text.split(',')]
                
                # Try to extract explanation
                explanation_pattern = r'"explanation":\s*"([^"]+)"'
                explanation_match = re.search(explanation_pattern, response_text[response_text.find(question_text):])
                explanation = explanation_match.group(1) if explanation_match else f"Solved: {correct_answer}"
                
                question = Question(
                    question_number=int(question_num),
                    question_text=question_text,
                    problem_type=problem_type or "other",
                    options=options,
                    correct_answer=correct_answer,
                    explanation=explanation,
                    steps=[f"Answer: {correct_answer}"]
                )
                questions.append(question)
            
            return questions
            
        except Exception as e:
            print(f"❌ Error in regex extraction: {e}")
            return []
    
    def _create_fallback_question(self, error_message: str) -> Question:
        """Create a fallback question for errors"""
        return Question(
            question_number=1,
            question_text="Error processing file",
            problem_type="other",
            explanation=error_message,
            steps=["Please check the file format and try again"]
        )

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
    
    async def _generate_with_image_async(self, prompt: str, image: Image.Image):
        """Generate response asynchronously using Gemini Vision with image"""
        import asyncio
        
        loop = asyncio.get_event_loop()
        
        def _generate_with_image_sync():
            return self.vision_client.generate_content(
                [prompt, image],
                generation_config=genai.types.GenerationConfig(
                    temperature=0.1,
                    max_output_tokens=2000,  # More tokens for detailed solutions
                )
            )
        
        return await loop.run_in_executor(None, _generate_with_image_sync)
    
    async def _generate_with_pdf_async(self, prompt: str, pdf_data: bytes):
        """Generate response asynchronously using Gemini Vision with PDF"""
        import asyncio
        
        loop = asyncio.get_event_loop()
        
        def _generate_with_pdf_sync():
            # Create a file-like object from PDF bytes
            pdf_part = {
                "mime_type": "application/pdf",
                "data": pdf_data
            }
            
            return self.vision_client.generate_content(
                [prompt, pdf_part],
                generation_config=genai.types.GenerationConfig(
                    temperature=0.1,
                    max_output_tokens=8000,  # Increased tokens for complex PDFs with multiple questions
                )
            )
        
        return await loop.run_in_executor(None, _generate_with_pdf_sync)
    
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
