import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_card.dart';

class AllBookingsScreen extends StatelessWidget {
  const AllBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(width: 280, child: _buildStatCard(context, 'Total Bookings Today', '1,284', '+12%', true)),
              SizedBox(width: 280, child: _buildStatCard(context, 'Revenue (MTD)', '\$42,850', '+5.4%', true)),
              SizedBox(width: 280, child: _buildOccupancyCard(context, 'Average Occupancy', '78%', 0.78)),
            ],
          ),
          const SizedBox(height: 32),
          // Booking Register
          const CustomCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1000, // Minimum width to prevent squishing
                child: BookingRegisterTable(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String trend, bool isPositive) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.darkRed, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(trend, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isPositive ? AppTheme.successGreen : AppTheme.errorRed, fontWeight: FontWeight.bold)),
                    Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: isPositive ? AppTheme.successGreen : AppTheme.errorRed),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard(BuildContext context, String title, String value, double percent) {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: AppTheme.borderLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BookingRegisterTable extends StatelessWidget {
  const BookingRegisterTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header & Tabs
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Booking Register', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(width: 24),
                  _buildTab(context, 'All', true),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Confirmed', false),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Pending', false),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary, // Blackish background
                ),
              ),
            ],
          ),
        ),
        // Column Headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: const Color(0xFFFDF6F6),
          child: Row(
            children: [
              Expanded(flex: 1, child: Text('Booking\nID', style: _headerStyle(context))),
              Expanded(flex: 2, child: Text('User Name', style: _headerStyle(context))),
              Expanded(flex: 2, child: Text('Movie/Show', style: _headerStyle(context))),
              Expanded(flex: 1, child: Text('Theater', style: _headerStyle(context))),
              Expanded(flex: 1, child: Text('Screen', style: _headerStyle(context))),
              Expanded(flex: 2, child: Text('Seats', style: _headerStyle(context))),
              Expanded(flex: 1, child: Text('Status', style: _headerStyle(context))),
            ],
          ),
        ),
        // Rows
        _buildRow(context, '#CA-82910', 'JD', 'Jonathan Doe', 'Neon Horizon:\nDirector\'s Cut', 'Today, 7:30 PM', 'Grand\nCinema', 'IMAX\nPremium', ['F12', 'F13'], 'Confirmed', AppTheme.successGreen),
        const Divider(height: 1),
        _buildRow(context, '#CA-82911', 'SM', 'Sarah Miller', 'The Velvet\nSymphony', 'Tonight, 9:00 PM', 'Star\nMultiplex', 'Screen 4\n(Dolby)', ['A4'], 'Pending', AppTheme.warningYellow, avatarUrl: 'https://i.pravatar.cc/150?img=5'),
        const Divider(height: 1),
        _buildRow(context, '#CA-82895', 'MK', 'Marcus Kane', 'Obsidian\nSkies', 'Yesterday, 6:00 PM', 'Metro\nPlaza', 'IMAX\nPremium', ['G1', 'G2', 'G3'], 'Cancelled', AppTheme.errorRed),
        const Divider(height: 1),
        _buildRow(context, '#CA-82912', 'ER', 'Elena Rodriguez', 'Neon Horizon:\nDirector\'s Cut', 'Today, 10:15 PM', 'Grand\nCinema', 'Screen\n2', ['B10', 'B11'], 'Confirmed', AppTheme.successGreen, avatarUrl: 'https://i.pravatar.cc/150?img=9'),

        // Pagination
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.borderLight)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Showing 1 to 4 of 1,284 entries', style: Theme.of(context).textTheme.bodySmall),
              Row(
                children: [
                  _buildPageButton(Icons.chevron_left, false),
                  const SizedBox(width: 8),
                  _buildPageNumber('1', true),
                  const SizedBox(width: 8),
                  _buildPageNumber('2', false),
                  const SizedBox(width: 8),
                  _buildPageNumber('3', false),
                  const SizedBox(width: 8),
                  _buildPageButton(Icons.chevron_right, false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.borderLight : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  TextStyle? _headerStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppTheme.textSecondary,
    );
  }

  Widget _buildRow(BuildContext context, String id, String initials, String name, String movie, String time, String theater, String screen, List<String> seats, String status, Color statusColor, {String? avatarUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(id, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.darkRed, fontWeight: FontWeight.bold))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.borderLight,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? Text(initials, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(time, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(theater, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(flex: 1, child: Text(screen, style: Theme.of(context).textTheme.bodyMedium)),
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: seats.map((seat) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(4)),
                child: Text(seat, style: Theme.of(context).textTheme.bodySmall),
              )).toList(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(status, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: AppTheme.textSecondary),
    );
  }

  Widget _buildPageNumber(String number, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.darkRed : Colors.transparent,
        border: Border.all(color: isActive ? AppTheme.darkRed : AppTheme.borderLight),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        number,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
