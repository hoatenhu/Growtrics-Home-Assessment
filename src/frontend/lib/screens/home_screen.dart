import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'upload_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UploadScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 0 ? MdiIcons.upload : MdiIcons.uploadOutline),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 1 ? MdiIcons.history : MdiIcons.history),
            label: AppStrings.history,
          ),
        ],
      ),
    );
  }
}
