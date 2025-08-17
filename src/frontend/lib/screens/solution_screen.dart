import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/homework_models.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/question_card.dart';
import '../widgets/expandable_card.dart';

class SolutionScreen extends StatefulWidget {
  final String problemId;
  final Solution solution;

  const SolutionScreen({
    super.key,
    required this.problemId,
    required this.solution,
  });

  @override
  State<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.solution),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.shareVariant),
            onPressed: _shareSolution,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSolutionHeader(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildOverallExplanation(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildQuestionsList(),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildSolutionStats(),
            const SizedBox(height: AppConstants.largePadding),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    MdiIcons.checkCircle,
                    color: AppTheme.successColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solution Complete',
                        style: AppTheme.headingSmall.copyWith(
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.getSolutionSummary(widget.solution),
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Divider(color: AppTheme.dividerColor),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                _buildStatItem(
                  icon: MdiIcons.clockOutline,
                  label: 'Solved at',
                  value: Helpers.formatDetailedDateTime(widget.solution.solvedAt),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                _buildStatItem(
                  icon: MdiIcons.timerOutline,
                  label: 'Processing time',
                  value: Helpers.formatProcessingTime(widget.solution.processingTimeSeconds),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall,
                ),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallExplanation() {
    return ExpandableCard(
      title: AppStrings.overallExplanation,
      icon: MdiIcons.lightbulbOutline,
      child: Text(
        widget.solution.overallExplanation,
        style: AppTheme.bodyMedium,
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions & Solutions',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.solution.questionsSolved.length,
          separatorBuilder: (context, index) => 
              const SizedBox(height: AppConstants.defaultPadding),
          itemBuilder: (context, index) {
            final question = widget.solution.questionsSolved[index];
            return QuestionCard(
              question: question,
              questionIndex: index + 1,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSolutionStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solution Statistics',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: MdiIcons.formatListNumbered,
                    label: 'Total Questions',
                    value: '${widget.solution.totalQuestions}',
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    icon: MdiIcons.checkCircle,
                    label: 'Solved',
                    value: '${widget.solution.questionsSolved.length}',
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: MdiIcons.speedometer,
                    label: 'Processing Time',
                    value: Helpers.formatProcessingTime(widget.solution.processingTimeSeconds),
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: _buildStatCard(
                    icon: MdiIcons.target,
                    label: 'Success Rate',
                    value: '${((widget.solution.questionsSolved.length / widget.solution.totalQuestions) * 100).toStringAsFixed(0)}%',
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: AppTheme.headingSmall.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(MdiIcons.plus),
            label: const Text('Solve Another Problem'),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _copySolutionToClipboard,
            icon: const Icon(MdiIcons.contentCopy),
            label: const Text('Copy Solution'),
          ),
        ),
      ],
    );
  }

  void _shareSolution() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }

  void _copySolutionToClipboard() {
    final buffer = StringBuffer();
    buffer.writeln('Mathematics Homework Solution');
    buffer.writeln('================================');
    buffer.writeln();
    
    buffer.writeln('Overall Explanation:');
    buffer.writeln(widget.solution.overallExplanation);
    buffer.writeln();
    
    for (int i = 0; i < widget.solution.questionsSolved.length; i++) {
      final question = widget.solution.questionsSolved[i];
      buffer.writeln('Question ${i + 1}:');
      buffer.writeln(question.questionText);
      buffer.writeln();
      
      if (question.options != null && question.options!.isNotEmpty) {
        buffer.writeln('Options:');
        for (int j = 0; j < question.options!.length; j++) {
          buffer.writeln('${String.fromCharCode(65 + j)}) ${question.options![j]}');
        }
        buffer.writeln();
      }
      
      if (question.correctAnswer != null) {
        buffer.writeln('Answer: ${question.correctAnswer}');
        buffer.writeln();
      }
      
      if (question.explanation != null) {
        buffer.writeln('Explanation:');
        buffer.writeln(question.explanation);
        buffer.writeln();
      }
      
      if (question.steps != null && question.steps!.isNotEmpty) {
        buffer.writeln('Steps:');
        for (int j = 0; j < question.steps!.length; j++) {
          buffer.writeln('${j + 1}. ${question.steps![j]}');
        }
        buffer.writeln();
      }
      
      buffer.writeln('---');
      buffer.writeln();
    }
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solution copied to clipboard!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
