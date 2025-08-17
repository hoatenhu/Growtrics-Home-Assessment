import 'package:json_annotation/json_annotation.dart';

part 'homework_models.g.dart';

enum ProblemType {
  @JsonValue('multiple_choice')
  multipleChoice,
  @JsonValue('word_problem')
  wordProblem,
  @JsonValue('calculation')
  calculation,
  @JsonValue('geometry')
  geometry,
  @JsonValue('algebra')
  algebra,
  @JsonValue('other')
  other,
}

@JsonSerializable()
class Question {
  @JsonKey(name: 'question_number')
  final int questionNumber;
  
  @JsonKey(name: 'question_text')
  final String questionText;
  
  @JsonKey(name: 'problem_type')
  final ProblemType problemType;
  
  final List<String>? options;
  
  @JsonKey(name: 'correct_answer')
  final String? correctAnswer;
  
  final String? explanation;
  final List<String>? steps;

  Question({
    required this.questionNumber,
    required this.questionText,
    required this.problemType,
    this.options,
    this.correctAnswer,
    this.explanation,
    this.steps,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

@JsonSerializable()
class ExtractedContent {
  @JsonKey(name: 'raw_text')
  final String rawText;
  
  final List<Question> questions;
  
  @JsonKey(name: 'images_found')
  final int imagesFound;
  
  @JsonKey(name: 'confidence_score')
  final double confidenceScore;

  ExtractedContent({
    required this.rawText,
    required this.questions,
    required this.imagesFound,
    required this.confidenceScore,
  });

  factory ExtractedContent.fromJson(Map<String, dynamic> json) => _$ExtractedContentFromJson(json);
  Map<String, dynamic> toJson() => _$ExtractedContentToJson(this);
}

@JsonSerializable()
class Solution {
  @JsonKey(name: 'problem_id')
  final String problemId;
  
  @JsonKey(name: 'questions_solved')
  final List<Question> questionsSolved;
  
  @JsonKey(name: 'overall_explanation')
  final String overallExplanation;
  
  @JsonKey(name: 'total_questions')
  final int totalQuestions;
  
  @JsonKey(name: 'solved_at')
  final DateTime solvedAt;
  
  @JsonKey(name: 'processing_time_seconds')
  final double processingTimeSeconds;

  Solution({
    required this.problemId,
    required this.questionsSolved,
    required this.overallExplanation,
    required this.totalQuestions,
    required this.solvedAt,
    required this.processingTimeSeconds,
  });

  factory Solution.fromJson(Map<String, dynamic> json) => _$SolutionFromJson(json);
  Map<String, dynamic> toJson() => _$SolutionToJson(this);
}

@JsonSerializable()
class HomeworkProblem {
  final String id;
  final String filename;
  
  @JsonKey(name: 'file_path')
  final String filePath;
  
  @JsonKey(name: 'upload_timestamp')
  final DateTime uploadTimestamp;
  
  @JsonKey(name: 'extracted_content')
  final ExtractedContent? extractedContent;
  
  final Solution? solution;
  final String status;

  HomeworkProblem({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.uploadTimestamp,
    this.extractedContent,
    this.solution,
    this.status = 'uploaded',
  });

  factory HomeworkProblem.fromJson(Map<String, dynamic> json) => _$HomeworkProblemFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkProblemToJson(this);
}

@JsonSerializable()
class UploadResponse {
  @JsonKey(name: 'problem_id')
  final String problemId;
  
  final String message;
  final String filename;

  UploadResponse({
    required this.problemId,
    required this.message,
    required this.filename,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) => _$UploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UploadResponseToJson(this);
}
