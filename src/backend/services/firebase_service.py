import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter
import uuid
import os
import shutil
import aiofiles
from datetime import datetime
from typing import List, Optional
import asyncio
from concurrent.futures import ThreadPoolExecutor
from dotenv import load_dotenv

from models.homework_models import HomeworkProblem, Solution, ExtractedContent

# Load environment variables
load_dotenv()

class FirebaseService:
    def __init__(self):
        self.db = None
        self.executor = ThreadPoolExecutor(max_workers=4)
        # Local file storage configuration
        self.uploads_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
        self._ensure_uploads_dir()
    
    def _ensure_uploads_dir(self):
        """Ensure uploads directory exists"""
        try:
            os.makedirs(self.uploads_dir, exist_ok=True)
            print(f"✅ Local uploads directory ready: {self.uploads_dir}")
        except Exception as e:
            print(f"❌ Error creating uploads directory: {e}")
    
    def initialize(self):
        """Initialize Firebase Admin SDK (Firestore only)"""
        try:
            # Initialize Firebase Admin for Firestore only
            if not firebase_admin._apps:
                if os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH"):
                    cred = credentials.Certificate(os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH"))
                    firebase_admin.initialize_app(cred)
                else:
                    # For local development without service account
                    firebase_admin.initialize_app()
            
            self.db = firestore.client()
            print("✅ Firebase Firestore connected successfully")
            
        except Exception as e:
            print(f"Firebase initialization error: {e}")
            print("⚠️  Running with mock Firestore for development")
            self.db = None
    
    async def save_file(self, temp_file_path: str, original_filename: str) -> str:
        """Save file to local uploads directory and return the local file path"""
        try:
            # Generate unique filename to prevent conflicts
            file_extension = os.path.splitext(original_filename)[1]
            unique_filename = f"{uuid.uuid4()}{file_extension}"
            
            # Create permanent file path in uploads directory
            permanent_file_path = os.path.join(self.uploads_dir, unique_filename)
            
            # Copy file from temp location to permanent location
            loop = asyncio.get_event_loop()
            await loop.run_in_executor(
                self.executor,
                lambda: shutil.copy2(temp_file_path, permanent_file_path)
            )
            
            print(f"✅ File saved locally: {permanent_file_path}")
            return permanent_file_path
            
        except Exception as e:
            print(f"❌ Error saving file locally: {e}")
            # Fallback to temp file path
            return temp_file_path
    
    async def get_file_path(self, file_path: str) -> str:
        """Return the local file path (files are already stored locally)"""
        try:
            if file_path.startswith("mock://"):
                # Mock implementation - return a placeholder path  
                return "/tmp/mock_homework_file.png"
            
            # File is already stored locally, just return the path
            if os.path.exists(file_path):
                print(f"✅ File found locally: {file_path}")
                return file_path
            else:
                print(f"⚠️  File not found: {file_path}")
                return "/tmp/mock_homework_file.png"
            
        except Exception as e:
            print(f"❌ Error accessing file: {e}")
            return "/tmp/mock_homework_file.png"
    
    async def create_homework_problem(self, file_path: str, filename: str) -> str:
        """Create a new homework problem record in Firestore"""
        try:
            problem_id = str(uuid.uuid4())
            homework_data = {
                "id": problem_id,
                "filename": filename,
                "file_path": file_path,  # Local file path instead of URL
                "upload_timestamp": datetime.now(),
                "status": "uploaded"
            }
            
            if self.db:
                loop = asyncio.get_event_loop()
                await loop.run_in_executor(
                    self.executor,
                    lambda: self.db.collection("homework_problems").document(problem_id).set(homework_data)
                )
                print(f"✅ Homework problem created in Firestore: {problem_id}")
            else:
                # Mock implementation for development
                print(f"⚠️  Mock: Created homework problem {problem_id}")
            
            return problem_id
            
        except Exception as e:
            print(f"❌ Error creating homework problem: {e}")
            return str(uuid.uuid4())  # Return mock ID
    
    async def get_homework_problem(self, problem_id: str) -> Optional[HomeworkProblem]:
        """Retrieve homework problem by ID"""
        try:
            if not self.db:
                # Mock implementation
                return HomeworkProblem(
                    id=problem_id,
                    filename="mock_homework.png",
                    file_path="mock://local-storage/mock_homework.png",
                    upload_timestamp=datetime.now(),
                    status="uploaded"
                )
            
            loop = asyncio.get_event_loop()
            doc = await loop.run_in_executor(
                self.executor,
                lambda: self.db.collection("homework_problems").document(problem_id).get()
            )
            
            if doc.exists:
                data = doc.to_dict()
                # Handle backward compatibility for old records with file_url
                if "file_url" in data and "file_path" not in data:
                    data["file_path"] = data["file_url"]
                    del data["file_url"]
                return HomeworkProblem(**data)
            
            return None
            
        except Exception as e:
            print(f"❌ Error retrieving homework problem: {e}")
            return None
    
    async def update_homework_solution(self, problem_id: str, solution: Solution):
        """Update homework problem with solution"""
        try:
            if not self.db:
                print(f"Mock: Updated homework {problem_id} with solution")
                return
            
            loop = asyncio.get_event_loop()
            await loop.run_in_executor(
                self.executor,
                lambda: self.db.collection("homework_problems").document(problem_id).update({
                    "solution": solution.dict(),
                    "status": "solved"
                })
            )
            
        except Exception as e:
            print(f"Error updating homework solution: {e}")
    
    async def list_homework_problems(self, limit: int = 10, offset: int = 0) -> List[HomeworkProblem]:
        """List recent homework problems"""
        try:
            if not self.db:
                # Mock implementation
                return [
                    HomeworkProblem(
                        id="mock-1",
                        filename="sample_homework.png",
                        file_path="mock://local-storage/sample_homework.png",
                        upload_timestamp=datetime.now(),
                        status="uploaded"
                    )
                ]
            
            loop = asyncio.get_event_loop()
            docs = await loop.run_in_executor(
                self.executor,
                lambda: self.db.collection("homework_problems")
                           .order_by("upload_timestamp", direction=firestore.Query.DESCENDING)
                           .limit(limit)
                           .offset(offset)
                           .stream()
            )
            
            problems = []
            for doc in docs:
                data = doc.to_dict()
                problems.append(HomeworkProblem(**data))
            
            return problems
            
        except Exception as e:
            print(f"Error listing homework problems: {e}")
            return []
