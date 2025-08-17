import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/api_service.dart';
import '../services/camera_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/error_dialog.dart';
import 'solving_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ApiService _apiService = ApiService();
  final CameraService _cameraService = CameraService();
  bool _isUploading = false;
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.uploadHomework),
        centerTitle: true,
        leading: _selectedFile != null 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _clearSelection,
            )
          : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: _selectedFile == null 
            ? _buildUploadFlow()
            : _buildPreviewFlow(),
        ),
      ),
    );
  }

  Widget _buildUploadFlow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: AppConstants.largePadding),
        _buildUploadOptions(),
        const Spacer(),
        _buildBottomInfo(),
      ],
    );
  }

  Widget _buildPreviewFlow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPreviewHeader(),
        const SizedBox(height: AppConstants.largePadding),
        Expanded(child: _buildFilePreview()),
        const SizedBox(height: AppConstants.largePadding),
        _buildSolveButton(),
        const SizedBox(height: AppConstants.defaultPadding),
        _buildChangeFileButton(),
      ],
    );
  }

  Widget _buildPreviewHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            MdiIcons.checkCircle,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          'File Selected',
          style: AppTheme.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Review your file and click "Solve" to start processing',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    if (_selectedFile == null) return const SizedBox.shrink();

    final fileName = _selectedFile!.path.split('/').last;
    final fileExtension = fileName.toLowerCase().split('.').last;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          children: [
            // File preview
            Expanded(
              child: _buildFileContent(fileExtension),
            ),
            // File info
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.borderRadius),
                  bottomRight: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(fileExtension),
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatFileSize(_selectedFile!.lengthSync()),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileContent(String fileExtension) {
    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      return Image.file(
        _selectedFile!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFileErrorWidget();
        },
      );
    } else if (fileExtension == 'pdf') {
      return _buildPdfPreview();
    } else {
      return _buildFileErrorWidget();
    }
  }

  Widget _buildPdfPreview() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.filePdfBox,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'PDF File',
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'PDF preview not available',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileErrorWidget() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.alertCircleOutline,
            size: 60,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Preview not available',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolveButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _solveHomework,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      child: _isUploading
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Processing...'),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.calculator),
              const SizedBox(width: AppConstants.smallPadding),
              const Text(
                'Solve Homework',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildChangeFileButton() {
    return OutlinedButton(
      onPressed: _isUploading ? null : _clearSelection,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        side: BorderSide(color: AppTheme.primaryColor),
      ),
      child: const Text(
        'Choose Different File',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
    });
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return MdiIcons.filePdfBox;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return MdiIcons.fileImageOutline;
      default:
        return MdiIcons.fileOutline;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            MdiIcons.calculator,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          AppStrings.selectSource,
          style: AppTheme.headingMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          AppStrings.selectSourceDescription,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUploadOptions() {
    return Column(
      children: [
        _buildOptionCard(
          icon: MdiIcons.camera,
          title: AppStrings.takePhoto,
          subtitle: 'Use your camera to capture homework',
          onTap: _takePhoto,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        _buildOptionCard(
          icon: MdiIcons.filePdfBox,
          title: AppStrings.pickFile,
          subtitle: 'Choose PDF or image file',
          onTap: _pickFile,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: _isUploading ? null : onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.informationOutline,
                size: 20,
                color: AppTheme.successColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Supported Formats',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'JPG, PNG, PDF files up to ${AppConstants.maxFileSizeMB}MB',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final file = await _cameraService.takePhoto();
      if (file != null) {
        _selectFile(file);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _cameraService.pickImageFromGallery();
      if (file != null) {
        _selectFile(file);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await _cameraService.pickFile();
      if (file != null) {
        _selectFile(file);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _selectFile(File file) {
    // Validate file before selecting
    if (!_cameraService.isSupportedFile(file)) {
      _showErrorDialog(AppConstants.unsupportedFile);
      return;
    }

    if (!_cameraService.validateFileSize(file)) {
      _showErrorDialog(AppConstants.fileTooBig);
      return;
    }

    setState(() {
      _selectedFile = file;
    });
  }

  Future<void> _solveHomework() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingDialog(
          message: 'Uploading homework...',
        ),
      );

      // Upload file
      final uploadResponse = await _apiService.uploadHomework(_selectedFile!);
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to solving screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SolvingScreen(
              problemId: uploadResponse.problemId,
              filename: uploadResponse.filename,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: 'Upload Error',
        message: message,
      ),
    );
  }
}
