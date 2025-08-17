"""
Mathematics Homework Solver API

A FastAPI application that uses AI to solve student mathematics homework problems
from uploaded images or PDFs.

Main entry point for the application.
"""

import uvicorn
from dotenv import load_dotenv

from core.app import create_app

# Load environment variables
load_dotenv()

# Create the FastAPI application
app = create_app()

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
