import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/homework_models.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/homework_card.dart';
import '../widgets/error_dialog.dart';
import 'solution_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<HomeworkProblem> _problems = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadProblems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.history),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.refresh),
            onPressed: _refreshProblems,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _problems.isEmpty) {
      return _buildLoadingState();
    }

    if (_hasError && _problems.isEmpty) {
      return _buildErrorState();
    }

    if (_problems.isEmpty) {
      return _buildEmptyState();
    }

    return _buildProblemsList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Loading homework history...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.alertCircle,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Failed to load homework history',
              style: AppTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              _errorMessage,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton.icon(
              onPressed: _refreshProblems,
              icon: const Icon(MdiIcons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                MdiIcons.bookOpenPageVariant,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              AppStrings.noProblemsYet,
              style: AppTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              AppStrings.getStarted,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(MdiIcons.plus),
              label: const Text('Upload Homework'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemsList() {
    return RefreshIndicator(
      onRefresh: _refreshProblems,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: _problems.length + (_hasMoreData ? 1 : 0),
        separatorBuilder: (context, index) => 
            const SizedBox(height: AppConstants.defaultPadding),
        itemBuilder: (context, index) {
          if (index == _problems.length) {
            return _buildLoadMoreButton();
          }

          final problem = _problems[index];
          return HomeworkCard(
            problem: problem,
            onTap: () => _openProblem(problem),
            onDelete: () => _deleteProblem(problem),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: OutlinedButton(
        onPressed: _loadMoreProblems,
        child: const Text('Load More'),
      ),
    );
  }

  Future<void> _loadProblems() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final problems = await _apiService.listHomeworkProblems(
        limit: _pageSize,
        offset: 0,
      );
      
      setState(() {
        _problems = problems;
        _currentPage = 0;
        _hasMoreData = problems.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMoreProblems() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newProblems = await _apiService.listHomeworkProblems(
        limit: _pageSize,
        offset: (_currentPage + 1) * _pageSize,
      );
      
      setState(() {
        _problems.addAll(newProblems);
        _currentPage++;
        _hasMoreData = newProblems.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _refreshProblems() async {
    _currentPage = 0;
    _hasMoreData = true;
    await _loadProblems();
  }

  void _openProblem(HomeworkProblem problem) {
    if (Helpers.isProblemSolved(problem)) {
      // Navigate to solution screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SolutionScreen(
            problemId: problem.id,
            solution: problem.solution!,
          ),
        ),
      );
    } else {
      // Show problem details or allow retry
      _showProblemDetailsDialog(problem);
    }
  }

  void _showProblemDetailsDialog(HomeworkProblem problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.problemDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filename: ${problem.filename}'),
            const SizedBox(height: 8),
            Text('Status: ${Helpers.getStatusName(problem.status)}'),
            const SizedBox(height: 8),
            Text('Uploaded: ${Helpers.formatDetailedDateTime(problem.uploadTimestamp)}'),
            if (problem.extractedContent != null) ...[
              const SizedBox(height: 8),
              Text('Questions found: ${problem.extractedContent!.questions.length}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!Helpers.isProblemSolved(problem) && !Helpers.isProblemProcessing(problem))
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _retryProblem(problem);
              },
              child: const Text('Retry Solving'),
            ),
        ],
      ),
    );
  }

  void _retryProblem(HomeworkProblem problem) {
    // TODO: Implement retry functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retry functionality coming soon!'),
      ),
    );
  }

  Future<void> _deleteProblem(HomeworkProblem problem) async {
    final confirmed = await _showDeleteConfirmationDialog(problem);
    if (!confirmed) return;

    try {
      await _apiService.deleteHomeworkProblem(problem.id);
      setState(() {
        _problems.removeWhere((p) => p.id == problem.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Problem deleted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<bool> _showDeleteConfirmationDialog(HomeworkProblem problem) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Problem'),
        content: Text('Are you sure you want to delete "${problem.filename}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: 'Error',
        message: message,
      ),
    );
  }
}
