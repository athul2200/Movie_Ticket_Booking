import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  final Function(String)? onItemTap;
  final String activeSection;

  const Sidebar({
    super.key,
    this.onItemTap,
    this.activeSection = 'home',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // ── Brand title ────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Cinema\nConcierge',
              style: TextStyle(
                color: AppTheme.primaryRed,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Admin Panel',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 28),
          Divider(color: AppTheme.borderLight, thickness: 1, height: 1),
          const SizedBox(height: 16),

          // ── Nav section label ──────────────────────────────
          _sectionLabel('MANAGEMENT'),
          const SizedBox(height: 8),
          _menuItem(Icons.confirmation_number_outlined, 'All Bookings',    'all_bookings'),
          _menuItem(Icons.movie_creation_outlined,      'Show Management', 'show_management'),
          _menuItem(Icons.event_seat_outlined,          'Seat Blocking',   'seat_blocking'),

          const SizedBox(height: 16),
          Divider(color: AppTheme.borderLight, thickness: 1, height: 1),
          const SizedBox(height: 16),

          _sectionLabel('USERS'),
          const SizedBox(height: 8),
          _menuItem(Icons.people_outline,       'User Directory', 'user_directory'),
          _menuItem(Icons.auto_awesome_outlined, 'Reviews',       'reviews'),

          const Spacer(),

          Divider(color: AppTheme.borderLight, thickness: 1, height: 1),
          const SizedBox(height: 4),

          // ── Home (Dashboard) ───────────────────────────────
          _menuItem(Icons.dashboard_outlined, 'Dashboard', 'home'),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textLight,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String route) {
    final bool isActive = activeSection == route;
    return GestureDetector(
      onTap: () => onItemTap?.call(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.lightRed : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppTheme.primaryRed : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryRed : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}