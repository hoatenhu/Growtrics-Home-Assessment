import cv2
import numpy as np
from PIL import Image
import pytesseract
import re
from typing import List, Tuple
import os
from pdf2image import convert_from_path
import asyncio
from concurrent.futures import ThreadPoolExecutor

from models.homework_models import ExtractedContent, Question, ProblemType

class OCRService:
    def __init__(self):
        self.executor = ThreadPoolExecutor(max_workers=2)
        # Configure tesseract path if needed (especially on Windows)
        # pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
    
    async def extract_content(self, file_path: str) -> ExtractedContent:
        """Extract text and mathematical content from image or PDF"""
        try:
            if file_path.endswith('.pdf'):
                return await self._extract_from_pdf(file_path)
            else:
                return await self._extract_from_image(file_path)
                
        except Exception as e:
            print(f"Error in OCR extraction: {e}")
            # Return mock content for development
            return self._create_mock_content()
    
    async def _extract_from_pdf(self, pdf_path: str) -> ExtractedContent:
        """Extract content from PDF file"""
        try:
            loop = asyncio.get_event_loop()
            
            # Convert PDF to images
            images = await loop.run_in_executor(
                self.executor,
                lambda: convert_from_path(pdf_path, dpi=200)
            )
            
            all_text = ""
            total_images = len(images)
            
            for i, image in enumerate(images):
                # Process each page
                page_text = await self._process_image(image)
                all_text += f"Page {i+1}:\n{page_text}\n\n"
            
            # Parse questions from extracted text
            questions = self._parse_questions(all_text)
            
            return ExtractedContent(
                raw_text=all_text,
                questions=questions,
                images_found=total_images,
                confidence_score=0.85  # Estimate confidence
            )
            
        except Exception as e:
            print(f"Error extracting from PDF: {e}")
            return self._create_mock_content()
    
    async def _extract_from_image(self, image_path: str) -> ExtractedContent:
        """Extract content from single image file"""
        try:
            # Load and preprocess image
            image = Image.open(image_path)
            processed_text = await self._process_image(image)
            
            # Parse questions from extracted text
            questions = self._parse_questions(processed_text)
            
            return ExtractedContent(
                raw_text=processed_text,
                questions=questions,
                images_found=1,
                confidence_score=0.80
            )
            
        except Exception as e:
            print(f"Error extracting from image: {e}")
            return self._create_mock_content()
    
    async def _process_image(self, image: Image.Image) -> str:
        """Process a single image and extract text using OCR"""
        try:
            loop = asyncio.get_event_loop()
            
            # Convert PIL image to OpenCV format for preprocessing
            opencv_image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
            
            # Preprocess image for better OCR results
            processed_image = await loop.run_in_executor(
                self.executor,
                self._preprocess_image,
                opencv_image
            )
            
            # Convert back to PIL Image
            pil_image = Image.fromarray(processed_image)
            
            # Extract text using Tesseract with math-friendly configuration
            text = await loop.run_in_executor(
                self.executor,
                lambda: pytesseract.image_to_string(
                    pil_image,
                    config='--psm 6 -c tessedit_char_whitelist=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()[]{}+-*/=.,?!:; \n'
                )
            )
            
            return text.strip()
            
        except Exception as e:
            print(f"Error processing image: {e}")
            return "Error processing image"
    
    def _preprocess_image(self, image: np.ndarray) -> np.ndarray:
        """Preprocess image to improve OCR accuracy"""
        # Convert to grayscale
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # Apply denoising
        denoised = cv2.fastNlMeansDenoising(gray)
        
        # Apply adaptive thresholding
        thresh = cv2.adaptiveThreshold(
            denoised, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2
        )
        
        # Apply morphological operations to clean up the image
        kernel = np.ones((1, 1), np.uint8)
        cleaned = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
        
        return cleaned
    
    def _parse_questions(self, text: str) -> List[Question]:
        """Parse questions from extracted text"""
        questions = []
        
        # Split text into lines and process
        lines = [line.strip() for line in text.split('\n') if line.strip()]
        
        current_question = None
        current_options = []
        question_number = 0
        
        for line in lines:
            # Check if line starts with a number (potential question)
            question_match = re.match(r'^(\d+)\.?\s*(.+)', line)
            if question_match:
                # Save previous question if exists
                if current_question:
                    questions.append(self._create_question(
                        question_number, current_question, current_options
                    ))
                
                # Start new question
                question_number = int(question_match.group(1))
                current_question = question_match.group(2)
                current_options = []
            
            # Check if line is an option (1), (2), (3), (4) or (A), (B), (C), (D)
            option_match = re.match(r'^\(([1-4A-Da-d])\)\s*(.+)', line)
            if option_match and current_question:
                current_options.append(option_match.group(2))
            
            # If not a question start or option, might be continuation of question
            elif current_question and not option_match:
                current_question += " " + line
        
        # Don't forget the last question
        if current_question:
            questions.append(self._create_question(
                question_number, current_question, current_options
            ))
        
        return questions
    
    def _create_question(self, number: int, text: str, options: List[str]) -> Question:
        """Create a Question object from parsed data"""
        # Determine problem type based on content
        problem_type = self._determine_problem_type(text, options)
        
        return Question(
            question_number=number,
            question_text=text,
            problem_type=problem_type,
            options=options if options else None
        )
    
    def _determine_problem_type(self, text: str, options: List[str]) -> ProblemType:
        """Determine the type of mathematical problem"""
        text_lower = text.lower()
        
        if options:
            return ProblemType.MULTIPLE_CHOICE
        elif any(word in text_lower for word in ['percent', 'percentage', '%']):
            return ProblemType.CALCULATION
        elif any(word in text_lower for word in ['rectangle', 'square', 'circle', 'triangle', 'area', 'perimeter']):
            return ProblemType.GEOMETRY
        elif any(word in text_lower for word in ['solve', 'equation', 'x', 'y', 'variable']):
            return ProblemType.ALGEBRA
        elif any(word in text_lower for word in ['word', 'story', 'john', 'mary', 'total', 'altogether']):
            return ProblemType.WORD_PROBLEM
        else:
            return ProblemType.OTHER
    
    def _create_mock_content(self) -> ExtractedContent:
        """Create mock content for development/testing"""
        mock_questions = [
            Question(
                question_number=1,
                question_text="Which one of the following is sixty-three thousand and forty in numerals?",
                problem_type=ProblemType.MULTIPLE_CHOICE,
                options=["6340", "63 040", "63 400", "630 040"]
            ),
            Question(
                question_number=2,
                question_text="The figure below is made up of 20 identical small rectangles. What percentage of the figure is shaded?",
                problem_type=ProblemType.MULTIPLE_CHOICE,
                options=["35%", "20%", "3%", "7%"]
            )
        ]
        
        return ExtractedContent(
            raw_text="Mock extracted text from homework image",
            questions=mock_questions,
            images_found=1,
            confidence_score=0.90
        )
