class AppConstants {
  // App Info
  static const String appName = 'Homework Solver';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:8000';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  
  // File Upload Constraints
  static const double maxFileSizeMB = 10.0;
  static const List<String> supportedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> supportedFileExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
  
  // Image Quality
  static const int imageQuality = 85;
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1920;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String fileTooBig = 'File size exceeds 10MB limit.';
  static const String unsupportedFile = 'Unsupported file format.';
  static const String cameraPermissionDenied = 'Camera permission is required to take photos.';
  static const String photosPermissionDenied = 'Photos permission is required to access gallery.';
  
  // Success Messages
  static const String uploadSuccess = 'File uploaded successfully!';
  static const String solveSuccess = 'Problem solved successfully!';
  
  // Problem Types Display Names
  static const Map<String, String> problemTypeNames = {
    'multiple_choice': 'Multiple Choice',
    'word_problem': 'Word Problem',
    'calculation': 'Calculation',
    'geometry': 'Geometry',
    'algebra': 'Algebra',
    'other': 'Other',
  };
  
  // Status Display Names
  static const Map<String, String> statusNames = {
    'uploaded': 'Uploaded',
    'processing': 'Processing',
    'solved': 'Solved',
    'error': 'Error',
  };
}

class AppStrings {
  // Navigation
  static const String home = 'Home';
  static const String history = 'History';
  static const String settings = 'Settings';
  
  // Actions
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String pickFile = 'Pick File';
  static const String solve = 'Solve';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String share = 'Share';
  
  // Headers
  static const String uploadHomework = 'Upload Homework';
  static const String selectSource = 'Select Source';
  static const String solvingProblem = 'Solving Problem';
  static const String solution = 'Solution';
  static const String problemDetails = 'Problem Details';
  static const String recentProblems = 'Recent Problems';
  
  // Descriptions
  static const String uploadDescription = 'Take a photo or upload an image/PDF of your math homework to get AI-powered solutions.';
  static const String selectSourceDescription = 'Choose how you want to provide your homework problem:';
  static const String solvingDescription = 'Our AI is analyzing your homework problem. This may take a few moments...';
  static const String noProblemsYet = 'No homework problems uploaded yet.';
  static const String getStarted = 'Get started by uploading your first homework!';
  
  // File Information
  static const String fileSize = 'File Size';
  static const String uploadTime = 'Upload Time';
  static const String processingTime = 'Processing Time';
  static const String questionsFound = 'Questions Found';
  static const String confidenceScore = 'Confidence Score';
  
  // Solution Information
  static const String overallExplanation = 'Overall Explanation';
  static const String stepByStep = 'Step by Step';
  static const String answer = 'Answer';
  static const String explanation = 'Explanation';
  static const String options = 'Options';
}

class AppAssets {
  // Images
  static const String logoPath = 'assets/images/logo.png';
  static const String emptyStatePath = 'assets/images/empty_state.png';
  static const String errorStatePath = 'assets/images/error_state.png';
  
  // Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String uploadAnimation = 'assets/animations/upload.json';
}
