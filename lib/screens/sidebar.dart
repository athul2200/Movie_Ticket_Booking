import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function(String)? onItemTap; // 👈 ADDED

  const Sidebar({super.key, this.onItemTap}); // 👈 ADDED

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Cinema\nConcierge",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Normal menu items
          _menuItem(Icons.confirmation_number_outlined, "All Bookings", "all_bookings"),   // 👈 route added
          const SizedBox(height: 16),
          _menuItem(Icons.movie_creation_outlined, "Show Management", "show_management"), // 👈 route added
          const SizedBox(height: 16),
          _menuItem(Icons.event_seat_outlined, "Seat Blocking", "seat_blocking"),         // 👈 route added
          const SizedBox(height: 16),

          // Highlighted items
          _highlightedMenuItem(Icons.people_outline, "User Directory", "user_directory"),     // 👈 route added
          const SizedBox(height: 4),
          _highlightedMenuItem(Icons.auto_awesome_outlined, "Reviews", "reviews"),            // 👈 route added

          const Spacer(),

          // Divider above logout
          Divider(color: Colors.grey.shade200, thickness: 1),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: () {
                // TODO: handle logout
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.logout,
                    color: Color(0xFFE53935),
                    size: 22,
                  ),
                  SizedBox(width: 14),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // 👇 ONLY CHANGE: added `String route` param + GestureDetector wrap
  Widget _menuItem(IconData icon, String title, String route) {
    return GestureDetector(
      onTap: () => onItemTap?.call(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A4A4A), size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF3A3A3A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 👇 ONLY CHANGE: added `String route` param + GestureDetector wrap
  Widget _highlightedMenuItem(IconData icon, String title, String route) {
    return GestureDetector(
      onTap: () => onItemTap?.call(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A4A4A), size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF3A3A3A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}