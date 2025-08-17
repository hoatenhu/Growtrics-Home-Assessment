import os
import uuid
import aiofiles
from fastapi import UploadFile
from typing import List
import mimetypes

class FileUtils:
    ALLOWED_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.pdf'}
    ALLOWED_MIME_TYPES = {
        'image/png', 'image/jpeg', 'image/jpg', 'application/pdf'
    }
    TEMP_DIR = '/tmp'
    
    def is_valid_file_type(self, filename: str) -> bool:
        """Check if the uploaded file type is allowed"""
        if not filename:
            return False
        
        # Check file extension
        file_extension = os.path.splitext(filename)[1].lower()
        if file_extension not in self.ALLOWED_EXTENSIONS:
            return False
        
        return True
    
    def is_valid_mime_type(self, mime_type: str) -> bool:
        """Check if the MIME type is allowed"""
        return mime_type in self.ALLOWED_MIME_TYPES
    
    async def save_temp_file(self, upload_file: UploadFile) -> str:
        """Save uploaded file to temporary location"""
        # Generate unique filename
        file_extension = os.path.splitext(upload_file.filename)[1].lower()
        temp_filename = f"{uuid.uuid4()}{file_extension}"
        temp_file_path = os.path.join(self.TEMP_DIR, temp_filename)
        
        # Save file
        async with aiofiles.open(temp_file_path, 'wb') as f:
            content = await upload_file.read()
            await f.write(content)
        
        return temp_file_path
    
    def cleanup_temp_file(self, file_path: str):
        """Remove temporary file"""
        try:
            if os.path.exists(file_path) and file_path.startswith(self.TEMP_DIR):
                os.remove(file_path)
        except Exception as e:
            print(f"Error cleaning up temp file {file_path}: {e}")
    
    def get_file_size(self, file_path: str) -> int:
        """Get file size in bytes"""
        try:
            return os.path.getsize(file_path)
        except Exception:
            return 0
    
    def get_mime_type(self, file_path: str) -> str:
        """Get MIME type of file"""
        mime_type, _ = mimetypes.guess_type(file_path)
        return mime_type or 'application/octet-stream'
    
    def ensure_temp_dir_exists(self):
        """Ensure temp directory exists"""
        os.makedirs(self.TEMP_DIR, exist_ok=True)
    
    @staticmethod
    def format_file_size(size_bytes: int) -> str:
        """Format file size in human readable format"""
        if size_bytes == 0:
            return "0B"
        
        size_names = ["B", "KB", "MB", "GB"]
        i = 0
        while size_bytes >= 1024 and i < len(size_names) - 1:
            size_bytes /= 1024.0
            i += 1
        
        return f"{size_bytes:.1f}{size_names[i]}"
