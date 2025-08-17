from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum

class ProblemType(str, Enum):
    MULTIPLE_CHOICE = "multiple_choice"
    WORD_PROBLEM = "word_problem"
    CALCULATION = "calculation"
    GEOMETRY = "geometry"
    ALGEBRA = "algebra"
    OTHER = "other"

class Question(BaseModel):
    question_number: int
    question_text: str
    problem_type: ProblemType
    options: Optional[List[str]] = None  # For multiple choice questions
    correct_answer: Optional[str] = None
    explanation: Optional[str] = None
    steps: Optional[List[str]] = None

class ExtractedContent(BaseModel):
    raw_text: str
    questions: List[Question]
    images_found: int
    confidence_score: float

class Solution(BaseModel):
    problem_id: str
    questions_solved: List[Question]
    overall_explanation: str
    total_questions: int
    solved_at: datetime
    processing_time_seconds: float

class HomeworkProblem(BaseModel):
    id: str
    filename: str
    file_url: str
    upload_timestamp: datetime
    extracted_content: Optional[ExtractedContent] = None
    solution: Optional[Solution] = None
    status: str = "uploaded"  # uploaded, processing, solved, error

class HomeworkUploadResponse(BaseModel):
    problem_id: str
    status: str
    message: str
