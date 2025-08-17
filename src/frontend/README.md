# Homework Solver Flutter App

A beautiful, modern Flutter application that allows students to upload their math homework problems and get AI-powered solutions. The app provides an intuitive interface for taking photos, uploading files, and viewing detailed step-by-step solutions.

## Features

### 📱 Core Functionality
- **Photo Capture**: Take photos of homework problems using the device camera
- **File Upload**: Upload images (JPG, PNG) or PDF files from device storage
- **AI-Powered Solving**: Get detailed solutions with step-by-step explanations
- **Problem History**: View and manage previously uploaded problems
- **Solution Display**: Beautiful formatting of answers, explanations, and steps

### 🎨 User Experience
- **Modern UI**: Clean, material design with custom theme
- **Smooth Animations**: Engaging transitions and loading states
- **Responsive Design**: Works on phones and tablets
- **Error Handling**: Comprehensive error messages and retry mechanisms
- **Offline Support**: Graceful handling of network issues

### 🔧 Technical Features
- **Permission Management**: Smart camera and photo library permissions
- **File Validation**: Automatic file type and size validation
- **Progress Tracking**: Real-time upload and solving progress
- **State Management**: Efficient app state handling
- **API Integration**: Seamless backend communication

## Screenshots

The app includes several key screens:

1. **Upload Screen**: Clean interface with camera, gallery, and file picker options
2. **Solving Screen**: Animated progress indicator while AI processes the problem
3. **Solution Screen**: Detailed display of answers with expandable explanations
4. **History Screen**: List of previous problems with status indicators

## Installation & Setup

### Prerequisites

1. **Flutter SDK**: Install Flutter 3.10.0 or later
   ```bash
   # Check if Flutter is installed
   flutter --version
   
   # If not installed, download from https://flutter.dev/docs/get-started/install
   ```

2. **Development Environment**: 
   - VS Code with Flutter extension, or
   - Android Studio with Flutter plugin

3. **Backend Service**: Ensure the backend API is running on `http://localhost:8000`

### Quick Start

1. **Navigate to the frontend directory**:
   ```bash
   cd src/frontend
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate model files** (if needed):
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**:
   ```bash
   # For development
   flutter run
   
   # For release
   flutter run --release
   ```

### Configuration

#### Backend URL Configuration
Update the API base URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:8000';
```

For local development, use:
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000`

#### Permissions

The app requires the following permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos of homework problems.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select homework images.</string>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── homework_models.dart  # API response models
│   └── homework_models.g.dart # Generated JSON serialization
├── screens/                  # App screens
│   ├── home_screen.dart      # Main navigation
│   ├── upload_screen.dart    # File upload interface
│   ├── solving_screen.dart   # Progress display
│   ├── solution_screen.dart  # Results display
│   └── history_screen.dart   # Problem history
├── services/                 # Business logic
│   ├── api_service.dart      # Backend communication
│   └── camera_service.dart   # Camera/file operations
├── utils/                    # Utilities
│   ├── app_theme.dart        # Theme configuration
│   ├── constants.dart        # App constants
│   └── helpers.dart          # Helper functions
└── widgets/                  # Reusable components
    ├── loading_dialog.dart   # Loading overlay
    ├── error_dialog.dart     # Error display
    ├── question_card.dart    # Question display
    ├── expandable_card.dart  # Collapsible content
    └── homework_card.dart    # History item display
```

## API Integration

The app communicates with the backend through several endpoints:

### Upload Homework
```dart
POST /upload-homework
Content-Type: multipart/form-data
Body: file (image/PDF)
Response: { problem_id, message, filename }
```

### Solve Problem
```dart
POST /homework/solve/{problem_id}
Response: Solution object with questions and explanations
```

### Get Problem Details
```dart
GET /homework/{problem_id}
Response: HomeworkProblem object
```

### List Problems
```dart
GET /homework?limit=10&offset=0
Response: Array of HomeworkProblem objects
```

## Development

### Building for Production

```bash
# Android APK
flutter build apk --release

# iOS (requires Xcode and Apple Developer account)
flutter build ios --release

# Web
flutter build web
```

### Code Generation

When modifying data models, regenerate serialization code:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

## Troubleshooting

### Common Issues

1. **Flutter command not found**
   - Ensure Flutter is installed and added to your PATH
   - Restart your terminal/IDE after installation

2. **Permission denied errors**
   - Check that camera/storage permissions are properly configured
   - Test on a real device if emulator permissions fail

3. **Network connection errors**
   - Verify backend is running and accessible
   - Check firewall settings for local development
   - Use correct IP address for physical device testing

4. **Build errors**
   - Run `flutter clean` then `flutter pub get`
   - Delete `pubspec.lock` and reinstall dependencies
   - Check Flutter version compatibility

### Performance Tips

- Use `flutter run --profile` for performance testing
- Enable `flutter inspector` for widget debugging
- Monitor memory usage with `flutter attach --observe`

## Contributing

1. Follow Flutter/Dart style guidelines
2. Use meaningful commit messages
3. Test on both Android and iOS
4. Update documentation for new features

## Dependencies

Key packages used in this project:

- **dio**: HTTP client for API communication
- **image_picker**: Camera and gallery access
- **file_picker**: File selection functionality
- **permission_handler**: Runtime permission management
- **material_design_icons_flutter**: Extended icon set
- **json_annotation**: JSON serialization support

For a complete list, see `pubspec.yaml`.

## License

This project is part of the Growtrics Home Assessment.
