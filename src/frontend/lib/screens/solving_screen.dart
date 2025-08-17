import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/homework_models.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/error_dialog.dart';
import 'solution_screen.dart';

class SolvingScreen extends StatefulWidget {
  final String problemId;
  final String filename;

  const SolvingScreen({
    super.key,
    required this.problemId,
    required this.filename,
  });

  @override
  State<SolvingScreen> createState() => _SolvingScreenState();
}

class _SolvingScreenState extends State<SolvingScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  bool _isSolving = false;
  String _currentStatus = 'Preparing to solve...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSolving();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.solvingProblem),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSolving ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              _buildFileInfo(),
              const Spacer(),
              _buildSolvingAnimation(),
              const SizedBox(height: AppConstants.largePadding),
              _buildStatusText(),
              const SizedBox(height: AppConstants.largePadding),
              _buildProgressSteps(),
              const Spacer(),
              _buildRetryButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Helpers.isPdfFile(widget.filename)
                    ? MdiIcons.filePdfBox
                    : MdiIcons.fileImage,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.filename,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Problem ID: ${widget.problemId}',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolvingAnimation() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: Icon(
                    MdiIcons.brain,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusText() {
    return Column(
      children: [
        Text(
          AppStrings.solvingProblem,
          style: AppTheme.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          _currentStatus,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressSteps() {
    return Column(
      children: [
        _buildProgressStep(
          icon: MdiIcons.upload,
          title: 'File Uploaded',
          isCompleted: true,
          isActive: false,
        ),
        _buildProgressStep(
          icon: MdiIcons.eyeOutline,
          title: 'Analyzing Content',
          isCompleted: false,
          isActive: _isSolving,
        ),
        _buildProgressStep(
          icon: MdiIcons.brain,
          title: 'Solving Problems',
          isCompleted: false,
          isActive: false,
        ),
        _buildProgressStep(
          icon: MdiIcons.checkCircle,
          title: 'Solution Ready',
          isCompleted: false,
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required IconData icon,
    required String title,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color iconColor;
    Color textColor;
    
    if (isCompleted) {
      iconColor = AppTheme.successColor;
      textColor = AppTheme.textPrimary;
    } else if (isActive) {
      iconColor = AppTheme.primaryColor;
      textColor = AppTheme.textPrimary;
    } else {
      iconColor = AppTheme.textHint;
      textColor = AppTheme.textHint;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCompleted ? MdiIcons.check : icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: textColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isActive)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isSolving ? null : _startSolving,
        child: const Text(AppStrings.retry),
      ),
    );
  }

  Future<void> _startSolving() async {
    setState(() {
      _isSolving = true;
      _currentStatus = 'Analyzing your homework...';
    });

    try {
      // Add a small delay for better UX
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _currentStatus = 'Solving mathematical problems...';
      });

      // Call solve API
      final solution = await _apiService.solveHomework(widget.problemId);
      
      setState(() {
        _currentStatus = 'Solution ready!';
      });

      // Navigate to solution screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SolutionScreen(
              problemId: widget.problemId,
              solution: solution,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSolving = false;
        _currentStatus = 'Failed to solve. Please try again.';
      });
      
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: 'Solving Error',
        message: message,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startSolving();
            },
            child: const Text(AppStrings.retry),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
