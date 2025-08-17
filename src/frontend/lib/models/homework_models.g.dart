// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      questionNumber: json['question_number'] as int,
      questionText: json['question_text'] as String,
      problemType: $enumDecode(_$ProblemTypeEnumMap, json['problem_type']),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      correctAnswer: json['correct_answer'] as String?,
      explanation: json['explanation'] as String?,
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'question_number': instance.questionNumber,
      'question_text': instance.questionText,
      'problem_type': _$ProblemTypeEnumMap[instance.problemType]!,
      'options': instance.options,
      'correct_answer': instance.correctAnswer,
      'explanation': instance.explanation,
      'steps': instance.steps,
    };

const _$ProblemTypeEnumMap = {
  ProblemType.multipleChoice: 'multiple_choice',
  ProblemType.wordProblem: 'word_problem',
  ProblemType.calculation: 'calculation',
  ProblemType.geometry: 'geometry',
  ProblemType.algebra: 'algebra',
  ProblemType.other: 'other',
};

ExtractedContent _$ExtractedContentFromJson(Map<String, dynamic> json) =>
    ExtractedContent(
      rawText: json['raw_text'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      imagesFound: json['images_found'] as int,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
    );

Map<String, dynamic> _$ExtractedContentToJson(ExtractedContent instance) =>
    <String, dynamic>{
      'raw_text': instance.rawText,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'images_found': instance.imagesFound,
      'confidence_score': instance.confidenceScore,
    };

Solution _$SolutionFromJson(Map<String, dynamic> json) => Solution(
      problemId: json['problem_id'] as String,
      questionsSolved: (json['questions_solved'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallExplanation: json['overall_explanation'] as String,
      totalQuestions: json['total_questions'] as int,
      solvedAt: DateTime.parse(json['solved_at'] as String),
      processingTimeSeconds:
          (json['processing_time_seconds'] as num).toDouble(),
    );

Map<String, dynamic> _$SolutionToJson(Solution instance) => <String, dynamic>{
      'problem_id': instance.problemId,
      'questions_solved':
          instance.questionsSolved.map((e) => e.toJson()).toList(),
      'overall_explanation': instance.overallExplanation,
      'total_questions': instance.totalQuestions,
      'solved_at': instance.solvedAt.toIso8601String(),
      'processing_time_seconds': instance.processingTimeSeconds,
    };

HomeworkProblem _$HomeworkProblemFromJson(Map<String, dynamic> json) =>
    HomeworkProblem(
      id: json['id'] as String,
      filename: json['filename'] as String,
      filePath: json['file_path'] as String,
      uploadTimestamp: DateTime.parse(json['upload_timestamp'] as String),
      extractedContent: json['extracted_content'] == null
          ? null
          : ExtractedContent.fromJson(
              json['extracted_content'] as Map<String, dynamic>),
      solution: json['solution'] == null
          ? null
          : Solution.fromJson(json['solution'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'uploaded',
    );

Map<String, dynamic> _$HomeworkProblemToJson(HomeworkProblem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'file_path': instance.filePath,
      'upload_timestamp': instance.uploadTimestamp.toIso8601String(),
      'extracted_content': instance.extractedContent?.toJson(),
      'solution': instance.solution?.toJson(),
      'status': instance.status,
    };

UploadResponse _$UploadResponseFromJson(Map<String, dynamic> json) =>
    UploadResponse(
      problemId: json['problem_id'] as String,
      message: json['message'] as String,
      filename: json['filename'] as String,
    );

Map<String, dynamic> _$UploadResponseToJson(UploadResponse instance) =>
    <String, dynamic>{
      'problem_id': instance.problemId,
      'message': instance.message,
      'filename': instance.filename,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}
