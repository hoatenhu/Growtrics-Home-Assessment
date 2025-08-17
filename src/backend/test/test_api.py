import requests
import json
import time
from pathlib import Path

# API base URL
BASE_URL = "http://localhost:8000"

def test_health_check():
    """Test the health check endpoint"""
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"Health Check: {response.status_code} - {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Health check failed: {e}")
        return False

def test_upload_homework():
    """Test homework upload endpoint"""
    try:
        # Create a test file or use existing file
        test_file_path = Path("test_homework.png")
        
        if not test_file_path.exists():
            print("Test file not found. Please add a test image file named 'test_homework.png'")
            return None
        
        with open(test_file_path, "rb") as f:
            files = {"file": ("test_homework.png", f, "image/png")}
            response = requests.post(f"{BASE_URL}/upload-homework", files=files)
        
        print(f"Upload Response: {response.status_code} - {response.json()}")
        
        if response.status_code == 200:
            return response.json().get("problem_id")
        return None
        
    except Exception as e:
        print(f"Upload test failed: {e}")
        return None

def test_solve_homework(problem_id):
    """Test homework solving endpoint"""
    try:
        response = requests.post(f"{BASE_URL}/solve-homework/{problem_id}")
        print(f"Solve Response: {response.status_code}")
        
        if response.status_code == 200:
            solution = response.json()
            print(f"Solution found for {solution['total_questions']} questions")
            print(f"Processing time: {solution['processing_time_seconds']:.2f} seconds")
            
            for question in solution['questions_solved']:
                print(f"\nQ{question['question_number']}: {question['question_text'][:100]}...")
                if question.get('correct_answer'):
                    print(f"Answer: {question['correct_answer']}")
                if question.get('explanation'):
                    print(f"Explanation: {question['explanation'][:150]}...")
        
        return response.status_code == 200
        
    except Exception as e:
        print(f"Solve test failed: {e}")
        return False

def test_get_homework(problem_id):
    """Test get homework details endpoint"""
    try:
        response = requests.get(f"{BASE_URL}/homework/{problem_id}")
        print(f"Get Homework Response: {response.status_code}")
        
        if response.status_code == 200:
            homework = response.json()
            print(f"Homework ID: {homework['id']}")
            print(f"Filename: {homework['filename']}")
            print(f"Status: {homework['status']}")
        
        return response.status_code == 200
        
    except Exception as e:
        print(f"Get homework test failed: {e}")
        return False

def test_list_homework():
    """Test list homework endpoint"""
    try:
        response = requests.get(f"{BASE_URL}/homework")
        print(f"List Homework Response: {response.status_code}")
        
        if response.status_code == 200:
            problems = response.json()
            print(f"Found {len(problems)} homework problems")
            for problem in problems[:3]:  # Show first 3
                print(f"- {problem['id']}: {problem['filename']} ({problem['status']})")
        
        return response.status_code == 200
        
    except Exception as e:
        print(f"List homework test failed: {e}")
        return False

def main():
    """Run all API tests"""
    print("=== Testing Mathematics Homework Solver API ===\n")
    
    # Test health check
    print("1. Testing Health Check...")
    if not test_health_check():
        print("API is not running. Please start the server first.")
        return
    
    # Test upload
    print("\n2. Testing Homework Upload...")
    problem_id = test_upload_homework()
    
    if problem_id:
        # Test solving
        print(f"\n3. Testing Homework Solving (ID: {problem_id})...")
        time.sleep(1)  # Give a moment for processing
        test_solve_homework(problem_id)
        
        # Test get homework
        print(f"\n4. Testing Get Homework Details...")
        test_get_homework(problem_id)
    
    # Test list homework
    print(f"\n5. Testing List Homework...")
    test_list_homework()
    
    print("\n=== API Testing Complete ===")

if __name__ == "__main__":
    main()
