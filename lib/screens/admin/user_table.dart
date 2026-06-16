import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';

class UserTable extends StatelessWidget {
  const UserTable({super.key});

  static const List<Map<String, String>> _users = [
    {'initials': 'JD', 'name': 'Julianne Devis',  'email': 'julianne.d@example.com', 'movies': '45', 'bookings': '32', 'genre': 'Sci-Fi'},
    {'initials': 'MW', 'name': 'Marcus Wright',   'email': 'm.wright@cinema.com',    'movies': '12', 'bookings': '8',  'genre': 'Action'},
    {'initials': 'SC', 'name': 'Sarah Chen',      'email': 'schen.creative@ui.com',  'movies': '8',  'bookings': '5',  'genre': 'Drama'},
    {'initials': 'AK', 'name': 'Aaron Kessler',   'email': 'akessler@web.net',       'movies': '0',  'bookings': '0',  'genre': 'N/A'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Profiles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active member directory focusing on tier status and engagement.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Scrollable table ───────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 600,
                    maxWidth: constraints.maxWidth > 600 ? constraints.maxWidth : 600,
                  ),
                  child: Column(
                children: [
                  // Table header
                  Container(
                    color: const Color(0xFFFDF6F6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        _headerCell('MEMBER', flex: 3),
                        _headerCell('MOVIES SEEN'),
                        _headerCell('TOTAL BOOKINGS'),
                        _headerCell('FAV GENRE'),
                        _headerCell('ACTIONS'),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Rows
                  ..._users.asMap().entries.map((e) {
                    final isLast = e.key == _users.length - 1;
                    return Column(
                      children: [
                        _buildRow(context, e.value),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),

          // ── Footer ────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                Text(
                  'Showing 4 of 2,481 users',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                _pageBtn(Icons.chevron_left),
                const SizedBox(width: 6),
                _pageBtn(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, Map<String, String> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Member column (flex 3)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.lightRed,
                  child: Text(
                    user['initials']!,
                    style: const TextStyle(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name']!,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user['email']!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(user['movies']!)),
          Expanded(child: Text(user['bookings']!)),
          Expanded(child: Text(user['genre']!)),
          const Expanded(
            child: Icon(Icons.more_vert, color: AppTheme.textLight, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: AppTheme.textSecondary),
    );
  }
}