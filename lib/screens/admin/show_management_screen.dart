import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'custom_card.dart';

class ShowManagementScreen extends StatelessWidget {
  const ShowManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Show Schedule',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Managing 4 Screens • October 24th, 2023',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: const BorderSide(color: AppTheme.borderLight),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          // Screens Grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1200, // Fixed width to prevent squishing on smaller screens
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildScreenColumn(
                      context,
                      'SCREEN 01 - IMAX',
                      'Premium',
                      AppTheme.errorRedBg,
                      AppTheme.darkRed,
                      [
                        _buildShowCard(
                          context,
                          'Dune: Part Two',
                          '10:30 AM - 1:15 PM',
                          '142 / 150',
                          '\$2,450.00',
                          'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=200&auto=format&fit=crop', // Poster Placeholder
                          0.95,
                        ),
                        const SizedBox(height: 16),
                        _buildShowCard(
                          context,
                          'Oppenheimer',
                          '2:00 PM - 4:45 PM',
                          null,
                          null,
                          null,
                          0.6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildScreenColumn(
                      context,
                      'SCREEN 02 - DOLBY',
                      'Standard',
                      AppTheme.borderLight,
                      AppTheme.textSecondary,
                      [
                        _buildShowCard(
                          context,
                          'Spider-Man: Beyond',
                          '11:00 AM - 1:00 PM',
                          '88 / 120',
                          '\$1,320.00',
                          'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=200&auto=format&fit=crop', // Poster Placeholder
                          0.73,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(child: SizedBox()), // Screen 3 placeholder
                  const SizedBox(width: 24),
                  const Expanded(child: SizedBox()), // Screen 4 placeholder
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenColumn(BuildContext context, String title, String badgeText, Color badgeBg, Color badgeTextCol, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: badgeTextCol,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildShowCard(BuildContext context, String title, String time, String? seats, String? revenue, String? imageUrl, double occupancy) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image / Header area
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(time, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      const Icon(Icons.more_vert, size: 18, color: AppTheme.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: occupancy,
                    minHeight: 4,
                    backgroundColor: AppTheme.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkRed),
                  )
                ],
              ),
            ),

          // Details & Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (seats != null && revenue != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(seats, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('Seats', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                      Text(revenue, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkRed)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: AppTheme.errorRed),
                    label: const Text('Cancel Show', style: TextStyle(color: AppTheme.errorRed)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRedBg,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
