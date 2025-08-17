import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/homework_models.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class HomeworkCard extends StatelessWidget {
  final HomeworkProblem problem;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HomeworkCard({
    super.key,
    required this.problem,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildContent(),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildFileIcon(),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                problem.filename,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                Helpers.formatDateTime(problem.uploadTimestamp),
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
        const SizedBox(width: AppConstants.smallPadding),
        _buildMenuButton(),
      ],
    );
  }

  Widget _buildFileIcon() {
    IconData icon;
    Color color;

    if (Helpers.isImageFile(problem.filename)) {
      icon = MdiIcons.fileImage;
      color = AppTheme.primaryColor;
    } else if (Helpers.isPdfFile(problem.filename)) {
      icon = MdiIcons.filePdfBox;
      color = AppTheme.errorColor;
    } else {
      icon = MdiIcons.file;
      color = AppTheme.textSecondary;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    IconData icon;
    String text;

    if (Helpers.isProblemSolved(problem)) {
      color = AppTheme.successColor;
      icon = MdiIcons.checkCircle;
      text = 'Solved';
    } else if (Helpers.isProblemProcessing(problem)) {
      color = AppTheme.warningColor;
      icon = MdiIcons.clockOutline;
      text = 'Processing';
    } else if (Helpers.isProblemError(problem)) {
      color = AppTheme.errorColor;
      icon = MdiIcons.alertCircle;
      text = 'Error';
    } else {
      color = AppTheme.textSecondary;
      icon = MdiIcons.upload;
      text = 'Uploaded';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.textSecondary,
        size: 20,
      ),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                MdiIcons.delete,
                size: 16,
                color: AppTheme.errorColor,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.delete,
                style: TextStyle(
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Helpers.generateProblemSummary(problem),
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        if (problem.extractedContent != null) ...[
          const SizedBox(height: 8),
          _buildContentInfo(),
        ],
        if (problem.solution != null) ...[
          const SizedBox(height: 8),
          _buildSolutionInfo(),
        ],
      ],
    );
  }

  Widget _buildContentInfo() {
    final content = problem.extractedContent!;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildInfoChip(
          icon: MdiIcons.formatListNumbered,
          label: '${content.questions.length} questions',
          color: AppTheme.primaryColor,
        ),
        _buildInfoChip(
          icon: MdiIcons.target,
          label: Helpers.formatConfidenceScore(content.confidenceScore),
          color: AppTheme.successColor,
        ),
      ],
    );
  }

  Widget _buildSolutionInfo() {
    final solution = problem.solution!;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildInfoChip(
          icon: MdiIcons.checkCircle,
          label: '${solution.questionsSolved.length} solved',
          color: AppTheme.successColor,
        ),
        _buildInfoChip(
          icon: MdiIcons.timerOutline,
          label: Helpers.formatProcessingTime(solution.processingTimeSeconds),
          color: AppTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    String actionText;
    IconData actionIcon;
    Color actionColor;

    if (Helpers.isProblemSolved(problem)) {
      actionText = 'View Solution';
      actionIcon = MdiIcons.eyeOutline;
      actionColor = AppTheme.primaryColor;
    } else if (Helpers.isProblemProcessing(problem)) {
      actionText = 'Processing...';
      actionIcon = MdiIcons.clockOutline;
      actionColor = AppTheme.warningColor;
    } else if (Helpers.isProblemError(problem)) {
      actionText = 'Retry';
      actionIcon = MdiIcons.refresh;
      actionColor = AppTheme.errorColor;
    } else {
      actionText = 'Solve Problem';
      actionIcon = MdiIcons.brain;
      actionColor = AppTheme.primaryColor;
    }

    return Row(
      children: [
        Icon(
          actionIcon,
          size: 16,
          color: actionColor,
        ),
        const SizedBox(width: 8),
        Text(
          actionText,
          style: AppTheme.bodyMedium.copyWith(
            color: actionColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }
}
