import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget>? actions;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      title: Row(
        children: [
          Icon(
            MdiIcons.alertCircle,
            color: AppTheme.errorColor,
            size: 24,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            title,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTheme.bodyMedium,
      ),
      actions: actions ?? [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
