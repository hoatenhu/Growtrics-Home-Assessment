"""
Homework management endpoints

Endpoints for uploading, solving, and managing homework problems.
"""

from fastapi import APIRouter, UploadFile, File, HTTPException
from typing import List, Dict, Any

from models.homework_models import HomeworkProblem, Solution
from core.dependencies import (
    get_firebase_service, 
    get_ocr_service, 
    get_math_solver_service, 
    get_file_utils
)

# Main homework router (with /homework prefix)
router = APIRouter()

# Separate upload router (for backwards compatibility without prefix)
upload_router = APIRouter()

@upload_router.post("/upload-homework", response_model=Dict[str, Any])
async def upload_homework(file: UploadFile = File(...)):
    """
    Upload homework image/PDF and get the problem ID for processing
    
    Accepts PNG, JPG, JPEG, or PDF files containing mathematical problems.
    Returns a problem ID that can be used to solve the homework.
    """
    firebase_service = get_firebase_service()
    file_utils = get_file_utils()
    
    try:
        # Validate file type
        if not file_utils.is_valid_file_type(file.filename):
            raise HTTPException(
                status_code=400, 
                detail="Invalid file type. Please upload PNG, JPG, JPEG, or PDF files."
            )
        
        # Save file temporarily
        temp_file_path = await file_utils.save_temp_file(file)
        
        # Upload to Firebase Storage
        firebase_url = await firebase_service.upload_file(temp_file_path, file.filename)
        
        # Create homework problem record
        problem_id = await firebase_service.create_homework_problem(firebase_url, file.filename)
        
        # Clean up temp file
        file_utils.cleanup_temp_file(temp_file_path)
        
        return {
            "problem_id": problem_id,
            "status": "uploaded",
            "message": "Homework uploaded successfully. Use the problem_id to get solutions.",
            "filename": file.filename
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Error uploading homework: {str(e)}"
        )

@router.post("/solve/{problem_id}", response_model=Solution)
async def solve_homework(problem_id: str):
    """
    Solve the homework problem identified by problem_id
    
    Downloads the homework file, extracts mathematical content using OCR,
    and solves the problems using AI. Returns detailed solutions with explanations.
    """
    firebase_service = get_firebase_service()
    ocr_service = get_ocr_service()
    math_solver_service = get_math_solver_service()
    file_utils = get_file_utils()
    
    try:
        # Get homework problem from database
        homework_problem = await firebase_service.get_homework_problem(problem_id)
        if not homework_problem:
            raise HTTPException(status_code=404, detail="Homework problem not found")
        
        # Download file from Firebase Storage
        local_file_path = await firebase_service.download_file(homework_problem.file_url)
        
        # Extract text and mathematical content using OCR
        extracted_content = await ocr_service.extract_content(local_file_path)
        
        # Solve the mathematical problems using AI
        solution = await math_solver_service.solve_problems(extracted_content)
        
        # Set the problem ID in the solution
        solution.problem_id = problem_id
        
        # Update the homework problem with the solution
        await firebase_service.update_homework_solution(problem_id, solution)
        
        # Clean up downloaded file
        file_utils.cleanup_temp_file(local_file_path)
        
        return solution
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Error solving homework: {str(e)}"
        )

@router.get("/{problem_id}", response_model=HomeworkProblem)
async def get_homework_problem(problem_id: str):
    """
    Get homework problem details and solution if available
    
    Returns the complete homework problem record including upload details
    and solution if it has been solved.
    """
    firebase_service = get_firebase_service()
    
    try:
        homework_problem = await firebase_service.get_homework_problem(problem_id)
        if not homework_problem:
            raise HTTPException(status_code=404, detail="Homework problem not found")
        
        return homework_problem
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Error retrieving homework: {str(e)}"
        )

@router.get("", response_model=List[HomeworkProblem])
async def list_homework_problems(limit: int = 10, offset: int = 0):
    """
    List recent homework problems
    
    Returns a paginated list of homework problems, most recent first.
    """
    firebase_service = get_firebase_service()
    
    try:
        if limit > 100:
            limit = 100  # Prevent excessive data transfer
            
        problems = await firebase_service.list_homework_problems(limit, offset)
        return problems
        
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Error listing homework: {str(e)}"
        )

@router.delete("/{problem_id}")
async def delete_homework_problem(problem_id: str):
    """
    Delete a homework problem and its associated files
    
    Removes the homework problem from the database and cleans up
    any associated storage files.
    """
    firebase_service = get_firebase_service()
    
    try:
        # Check if homework exists
        homework_problem = await firebase_service.get_homework_problem(problem_id)
        if not homework_problem:
            raise HTTPException(status_code=404, detail="Homework problem not found")
        
        # TODO: Implement actual deletion logic
        # This would involve:
        # 1. Deleting the file from Firebase Storage
        # 2. Removing the record from Firestore
        
        return {
            "message": f"Homework problem {problem_id} deletion requested",
            "status": "pending",
            "note": "Deletion functionality not yet implemented"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Error deleting homework: {str(e)}"
        )
