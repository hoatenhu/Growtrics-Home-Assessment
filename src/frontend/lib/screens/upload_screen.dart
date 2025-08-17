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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.uploadHomework),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppConstants.largePadding),
              _buildUploadOptions(),
              const Spacer(),
              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
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
          child: const Icon(
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
          icon: MdiIcons.imageMultiple,
          title: AppStrings.chooseFromGallery,
          subtitle: 'Select an image from your gallery',
          onTap: _pickFromGallery,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        _buildOptionCard(
          icon: MdiIcons.filePdf,
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
        await _uploadFile(file);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _cameraService.pickImageFromGallery();
      if (file != null) {
        await _uploadFile(file);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await _cameraService.pickFile();
      if (file != null) {
        await _uploadFile(file);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _uploadFile(File file) async {
    // Validate file
    if (!_cameraService.isSupportedFile(file)) {
      _showErrorDialog(AppConstants.unsupportedFile);
      return;
    }

    if (!_cameraService.validateFileSize(file)) {
      _showErrorDialog(AppConstants.fileTooBig);
      return;
    }

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
      final uploadResponse = await _apiService.uploadHomework(file);
      
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
