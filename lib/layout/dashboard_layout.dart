import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../screens/user_directory_screen.dart';
import '../screens/all_bookings_screen.dart';
import '../screens/show_management_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/seat_blocking_screen.dart';
import '../theme/app_theme.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _selectedIndex = 3; // Default to User Directory based on Image 1

  final List<Widget> _screens = [
    const AllBookingsScreen(),
    const ShowManagementScreen(),
    const SeatBlockingScreen(),
    const UserDirectoryScreen(),
    const ReviewsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    String topBarTitle = 'CineAdmin Premium';
    String topBarSearchHint = 'Search global data...';

    if (_selectedIndex == 0) {
      topBarTitle = 'All Bookings';
      topBarSearchHint = 'Search by Booking ID or Name...';
    } else if (_selectedIndex == 1) {
      topBarSearchHint = 'Search shows...';
    } else if (_selectedIndex == 2) {
      topBarTitle = 'Seat Blocking Panel';
      topBarSearchHint = 'Search auditoriums...';
    }

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          // Right Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                TopBar(title: topBarTitle, searchHint: topBarSearchHint),
                // Main Content
                Expanded(
                  child: Container(
                    color: AppTheme.background,
                    padding: const EdgeInsets.all(24.0),
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
