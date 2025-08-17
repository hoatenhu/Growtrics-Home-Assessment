import firebase_admin
from firebase_admin import credentials, firestore, storage
from google.cloud.firestore_v1.base_query import FieldFilter
import uuid
import os
import aiofiles
from datetime import datetime
from typing import List, Optional
import asyncio
from concurrent.futures import ThreadPoolExecutor

from models.homework_models import HomeworkProblem, Solution, ExtractedContent

class FirebaseService:
    def __init__(self):
        self.db = None
        self.bucket = None
        self.executor = ThreadPoolExecutor(max_workers=4)
    
    def initialize(self):
        """Initialize Firebase Admin SDK"""
        try:
            # Initialize Firebase Admin (you'll need to set up service account)
            if not firebase_admin._apps:
                # For development, you can use the default credentials
                # In production, use a service account key file
                if os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH"):
                    cred = credentials.Certificate(os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH"))
                    firebase_admin.initialize_app(cred, {
                        'storageBucket': os.getenv("FIREBASE_STORAGE_BUCKET")
                    })
                else:
                    # For local development without service account
                    firebase_admin.initialize_app({
                        'storageBucket': os.getenv("FIREBASE_STORAGE_BUCKET", "growtrics-homework-solver.appspot.com")
                    })
            
            self.db = firestore.client()
            self.bucket = storage.bucket()
            
        except Exception as e:
            print(f"Firebase initialization error: {e}")
            # For development, create mock services
            self.db = None
            self.bucket = None
    
    async def upload_file(self, local_file_path: str, original_filename: str) -> str:
        """Upload file to Firebase Storage and return the download URL"""
        try:
            if not self.bucket:
                # Mock implementation for development
                return f"mock://firebase-storage/{original_filename}"
            
            # Generate unique filename
            file_extension = os.path.splitext(original_filename)[1]
            unique_filename = f"homework/{uuid.uuid4()}{file_extension}"
            
            # Upload file
            loop = asyncio.get_event_loop()
            blob = await loop.run_in_executor(
                self.executor,
                lambda: self.bucket.blob(unique_filename)
            )
            
            await loop.run_in_executor(
                self.executor,
                lambda: blob.upload_from_filename(local_file_path)
            )
            
            # Make the blob publicly readable
            await loop.run_in_executor(
                self.executor,
                lambda: blob.make_public()
            )
            
            return blob.public_url
            
        except Exception as e:
            print(f"Error uploading file to Firebase: {e}")
            # Return mock URL for development
            return f"mock://firebase-storage/{original_filename}"
    
    async def download_file(self, file_url: str) -> str:
        """Download file from Firebase Storage to local temp file"""
        try:
            if file_url.startswith("mock://"):
                # Mock implementation - return a placeholder path
                return "/tmp/mock_homework_file.png"
            
            # Extract blob name from URL
            blob_name = file_url.split('/')[-1]
            blob = self.bucket.blob(f"homework/{blob_name}")
            
            # Create temp file path
            temp_file_path = f"/tmp/{uuid.uuid4()}_{blob_name}"
            
            # Download file
            loop = asyncio.get_event_loop()
            await loop.run_in_executor(
                self.executor,
                lambda: blob.download_to_filename(temp_file_path)
            )
            
            return temp_file_path
            
        except Exception as e:
            print(f"Error downloading file from Firebase: {e}")
            return "/tmp/mock_homework_file.png"
    
    async def create_homework_problem(self, file_url: str, filename: str) -> str:
        """Create a new homework problem record in Firestore"""
        try:
            problem_id = str(uuid.uuid4())
            homework_data = {
                "id": problem_id,
                "filename": filename,
                "file_url": file_url,
                "upload_timestamp": datetime.now(),
                "status": "uploaded"
            }
            
            if self.db:
                loop = asyncio.get_event_loop()
                await loop.run_in_executor(
                    self.executor,
                    lambda: self.db.collection("homework_problems").document(problem_id).set(homework_data)
                )
            else:
                # Mock implementation for development
                print(f"Mock: Created homework problem {problem_id}")
            
            return problem_id
            
        except Exception as e:
            print(f"Error creating homework problem: {e}")
            return str(uuid.uuid4())  # Return mock ID
    
    async def get_homework_problem(self, problem_id: str) -> Optional[HomeworkProblem]:
        """Retrieve homework problem by ID"""
        try:
            if not self.db:
                # Mock implementation
                return HomeworkProblem(
                    id=problem_id,
                    filename="mock_homework.png",
                    file_url="mock://firebase-storage/mock_homework.png",
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
                return HomeworkProblem(**data)
            
            return None
            
        except Exception as e:
            print(f"Error retrieving homework problem: {e}")
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
                        file_url="mock://firebase-storage/sample_homework.png",
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
