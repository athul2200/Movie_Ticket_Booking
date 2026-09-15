import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'sidebar.dart';
import 'admin_movie_management_screen.dart';
import 'all_bookings_screen.dart';
import 'show_management_screen.dart';
import 'seat_blocking_screen.dart';
import 'user_directory_screen.dart';
import 'reviews_screen.dart';
import 'user_table.dart';
import 'review_section.dart';
import 'custom_card.dart';

/// Breakpoint: screens wider than this show the permanent sidebar.
const double _kSidebarBreakpoint = 800;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _currentSection = 'home';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<String> _sections = [
    'home',
    'movie_management',
    'all_bookings',
    'show_management',
    'seat_blocking',
    'user_directory',
    'reviews',
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      _HomeDashboard(),
      AdminMovieManagementScreen(),
      AllBookingsScreen(),
      ShowManagementScreen(),
      Padding(padding: EdgeInsets.all(24), child: SeatBlockingScreen()),
      UserDirectoryScreen(),
      ReviewsScreen(),
    ];
  }

  // ── Section title ─────────────────────────────────────────────
  String get _sectionTitle {
    switch (_currentSection) {
      case 'movie_management': return 'Movie Management';
      case 'all_bookings':     return 'All Bookings';
      case 'show_management':  return 'Show Management';
      case 'seat_blocking':    return 'Seat Blocking';
      case 'user_directory':   return 'User Directory';
      case 'reviews':          return 'Reviews';
      default:                 return 'Dashboard';
    }
  }

  void _navigate(String section) {
    setState(() => _currentSection = section);
    // Close drawer on mobile after navigation
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  // ── Content area ──────────────────────────────────────────────
  Widget _buildContent() {
    final index = _sections.indexOf(_currentSection);
    return Expanded(
      child: Container(
        color: AppTheme.background,
        child: IndexedStack(
          index: index != -1 ? index : 0,
          children: _screens,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= _kSidebarBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,

      // ── Mobile drawer ─────────────────────────────────────────
      drawer: isWide
          ? null
          : Drawer(
              backgroundColor: Colors.white,
              child: SafeArea(
                child: Sidebar(onItemTap: _navigate, activeSection: _currentSection),
              ),
            ),

      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Persistent sidebar (desktop) ─────────────────
            if (isWide)
              Sidebar(onItemTap: _navigate, activeSection: _currentSection),

            // ── Main column ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AdminHeader(
                    title: _sectionTitle,
                    showMenuButton: !isWide,
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    onBackTap: () =>
                        Navigator.pushReplacementNamed(context, '/'),
                  ),
                  _buildContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Dashboard ─────────────────────────────────────────────────────────────
class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final totalMovies = MockData.allMovies.length;
    final activeMovies = MockData.activeMoviesCount;
    final totalBookings = MockData.bookings.length;
    final todayBookings = MockData.todayBookingsCount;
    final totalUsers = MockData.users.length;
    final totalRevenue = MockData.totalRevenue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Executive Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time metrics and system activity across all cinema operations.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // ── Stat Summary Cards ──
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildStatMetricCard(
                context,
                'Total Revenue',
                '₹${totalRevenue.toStringAsFixed(2)}',
                '${MockData.bookings.where((b) => b.status != "Cancelled").length} Paid Bookings',
                Icons.account_balance_wallet_outlined,
                AppTheme.primaryRed,
              ),
              _buildStatMetricCard(
                context,
                'Total Bookings',
                '$totalBookings',
                '$todayBookings Today',
                Icons.confirmation_number_outlined,
                AppTheme.darkRed,
              ),
              _buildStatMetricCard(
                context,
                'Total Movies',
                '$totalMovies',
                '$activeMovies Currently Active',
                Icons.movie_outlined,
                AppTheme.textPrimary,
              ),
              _buildStatMetricCard(
                context,
                'Registered Users',
                '$totalUsers',
                '${MockData.users.where((u) => u.status == "ACTIVE").length} Active Members',
                Icons.people_outline,
                AppTheme.successGreen,
              ),
            ],
          ),
          const SizedBox(height: 32),

          const UserTable(),
          const SizedBox(height: 24),
          const ReviewSection(),
        ],
      ),
    );
  }

  Widget _buildStatMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color accentColor,
  ) {
    return SizedBox(
      width: 240,
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary)),
                Icon(icon, size: 20, color: accentColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accentColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Responsive Admin Header ────────────────────────────────────────────────────
class _AdminHeader extends StatelessWidget {
  final String title;
  final bool showMenuButton;
  final VoidCallback onMenuTap;
  final VoidCallback onBackTap;

  const _AdminHeader({
    required this.title,
    required this.showMenuButton,
    required this.onMenuTap,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Row(
        children: [
          // Hamburger on mobile, back arrow on desktop
          if (showMenuButton)
            IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
              onPressed: onMenuTap,
              tooltip: 'Menu',
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: onBackTap,
              tooltip: 'Back',
            ),
          const SizedBox(width: 8),
          Text(
            'Movix',
            style: const TextStyle(
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: AppTheme.borderLight),
          const SizedBox(width: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          // Search (hidden on very small screens)
          if (MediaQuery.of(context).size.width > 500)
            SizedBox(
              width: 220,
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          // Back button on mobile (inside header)
          if (showMenuButton)
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.primaryRed),
              onPressed: onBackTap,
              tooltip: 'Exit Admin',
            ),
        ],
      ),
    );
  }
}