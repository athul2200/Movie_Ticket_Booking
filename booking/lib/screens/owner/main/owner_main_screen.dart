import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/screens/owner/screens_management/owner_screens_list_screen.dart';
import 'package:booking/screens/owner/movies_management/owner_movies_screen.dart';
import 'package:booking/screens/owner/schedule_management/owner_schedule_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Screens for each tab
  final List<Widget> _screens = const [
    OwnerScreensListScreen(),
    OwnerMoviesScreen(),
    OwnerScheduleScreen(),
    Center(child: Text("Profile (Admin)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: setIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Screens',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_creation_outlined),
              activeIcon: Icon(Icons.movie_creation),
              label: 'Movies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
