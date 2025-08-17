import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final bool canCancel;
  final VoidCallback? onCancel;

  const LoadingDialog({
    super.key,
    required this.message,
    this.canCancel = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canCancel,
      child: Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                message,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (canCancel) ...[
                const SizedBox(height: AppConstants.defaultPadding),
                TextButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
