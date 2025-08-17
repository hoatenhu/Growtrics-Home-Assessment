import 'package:intl/intl.dart';
import '../models/homework_models.dart';
import 'constants.dart';

class Helpers {
  /// Format DateTime to human readable string
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
  
  /// Format DateTime for detailed display
  static String formatDetailedDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy at hh:mm a').format(dateTime);
  }
  
  /// Format file size in MB
  static String formatFileSize(double sizeInMB) {
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)} KB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }
  
  /// Format processing time
  static String formatProcessingTime(double seconds) {
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)}s';
    } else {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = (seconds % 60).toStringAsFixed(0);
      return '${minutes}m ${remainingSeconds}s';
    }
  }
  
  /// Format confidence score as percentage
  static String formatConfidenceScore(double score) {
    return '${(score * 100).toStringAsFixed(1)}%';
  }
  
  /// Get problem type display name
  static String getProblemTypeName(ProblemType type) {
    switch (type) {
      case ProblemType.multipleChoice:
        return AppConstants.problemTypeNames['multiple_choice']!;
      case ProblemType.wordProblem:
        return AppConstants.problemTypeNames['word_problem']!;
      case ProblemType.calculation:
        return AppConstants.problemTypeNames['calculation']!;
      case ProblemType.geometry:
        return AppConstants.problemTypeNames['geometry']!;
      case ProblemType.algebra:
        return AppConstants.problemTypeNames['algebra']!;
      case ProblemType.other:
        return AppConstants.problemTypeNames['other']!;
    }
  }
  
  /// Get status display name
  static String getStatusName(String status) {
    return AppConstants.statusNames[status] ?? status.toUpperCase();
  }
  
  /// Check if file is an image
  static bool isImageFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return AppConstants.supportedImageExtensions.contains(extension);
  }
  
  /// Check if file is a PDF
  static bool isPdfFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return extension == 'pdf';
  }
  
  /// Validate file extension
  static bool isValidFileExtension(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return AppConstants.supportedFileExtensions.contains(extension);
  }
  
  /// Get file extension
  static String getFileExtension(String fileName) {
    return fileName.toLowerCase().split('.').last;
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  /// Get ordinal number (1st, 2nd, 3rd, etc.)
  static String getOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
  
  /// Generate problem summary
  static String generateProblemSummary(HomeworkProblem problem) {
    if (problem.extractedContent != null) {
      final questions = problem.extractedContent!.questions.length;
      if (questions == 1) {
        return '1 question';
      } else {
        return '$questions questions';
      }
    }
    return 'Math problem';
  }
  
  /// Get solution summary
  static String getSolutionSummary(Solution solution) {
    final solved = solution.questionsSolved.length;
    final total = solution.totalQuestions;
    
    if (solved == total) {
      return 'All $total questions solved';
    } else {
      return '$solved of $total questions solved';
    }
  }
  
  /// Format question title
  static String formatQuestionTitle(int questionNumber) {
    return 'Question ${getOrdinal(questionNumber)}';
  }
  
  /// Check if problem has been solved
  static bool isProblemSolved(HomeworkProblem problem) {
    return problem.solution != null && problem.status == 'solved';
  }
  
  /// Check if problem is being processed
  static bool isProblemProcessing(HomeworkProblem problem) {
    return problem.status == 'processing';
  }
  
  /// Check if problem has error
  static bool isProblemError(HomeworkProblem problem) {
    return problem.status == 'error';
  }
}
