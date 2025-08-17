import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/homework_models.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'expandable_card.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final int questionIndex;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionHeader(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildQuestionText(),
            if (question.options != null && question.options!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildOptions(),
            ],
            if (question.correctAnswer != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildAnswer(),
            ],
            if (question.explanation != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildExplanation(),
            ],
            if (question.steps != null && question.steps!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildSteps(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$questionIndex',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Helpers.formatQuestionTitle(question.questionNumber),
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                Helpers.getProblemTypeName(question.problemType),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildProblemTypeIcon(),
      ],
    );
  }

  Widget _buildProblemTypeIcon() {
    IconData icon;
    Color color;

    switch (question.problemType) {
      case ProblemType.multipleChoice:
        icon = MdiIcons.radioboxMarked;
        color = AppTheme.primaryColor;
        break;
      case ProblemType.calculation:
        icon = MdiIcons.calculator;
        color = AppTheme.successColor;
        break;
      case ProblemType.geometry:
        icon = MdiIcons.triangleOutline;
        color = AppTheme.warningColor;
        break;
      case ProblemType.algebra:
        icon = MdiIcons.function;
        color = AppTheme.errorColor;
        break;
      case ProblemType.wordProblem:
        icon = MdiIcons.textBoxOutline;
        color = AppTheme.secondaryColor;
        break;
      case ProblemType.other:
        icon = MdiIcons.helpCircleOutline;
        color = AppTheme.textSecondary;
        break;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildQuestionText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: Text(
        question.questionText,
        style: AppTheme.bodyMedium,
      ),
    );
  }

  Widget _buildOptions() {
    return ExpandableCard(
      title: AppStrings.options,
      icon: MdiIcons.formatListBulleted,
      isExpanded: true,
      child: Column(
        children: question.options!.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          String letter = String.fromCharCode(65 + index); // A, B, C, D...
          
          bool isCorrect = question.correctAnswer != null && 
                          (question.correctAnswer == letter || 
                           question.correctAnswer == option);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: isCorrect 
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: isCorrect 
                    ? AppTheme.successColor.withOpacity(0.3)
                    : AppTheme.borderColor,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCorrect 
                        ? AppTheme.successColor
                        : AppTheme.textSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Text(
                    option,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isCorrect 
                          ? AppTheme.successColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isCorrect)
                  Icon(
                    MdiIcons.check,
                    size: 20,
                    color: AppTheme.successColor,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnswer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.checkCircle,
            color: AppTheme.successColor,
            size: 20,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            AppStrings.answer,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Text(
              question.correctAnswer!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation() {
    return ExpandableCard(
      title: AppStrings.explanation,
      icon: MdiIcons.lightbulbOutline,
      child: Text(
        question.explanation!,
        style: AppTheme.bodyMedium,
      ),
    );
  }

  Widget _buildSteps() {
    return ExpandableCard(
      title: AppStrings.stepByStep,
      icon: MdiIcons.formatListNumbered,
      child: Column(
        children: question.steps!.asMap().entries.map((entry) {
          int index = entry.key;
          String step = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Text(
                    step,
                    style: AppTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
