import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/booking_model.dart';
import 'package:booking/widgets/app_image.dart';
import 'custom_card.dart';

class AllBookingsScreen extends StatefulWidget {
  const AllBookingsScreen({super.key});

  @override
  State<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  String _selectedStatusFilter = 'All'; // 'All', 'Confirmed', 'Pending', 'Cancelled'
  String _searchQuery = '';

  List<BookingModel> get _filteredBookings {
    return MockData.bookings.where((b) {
      final matchesStatus = _selectedStatusFilter == 'All' ||
          b.status.toLowerCase() == _selectedStatusFilter.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          b.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.movieTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.userPhone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.cinema.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel booking ${booking.id} for "${booking.movieTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final index = MockData.bookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      setState(() {
        MockData.bookings[index] = booking.copyWith(
          status: 'Cancelled',
          isConfirmed: false,
        );
      });
      await MockData.saveAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking ${booking.id} cancelled successfully.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showBookingDetailsModal(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking Details',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Movie & Customer info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppImage(
                        urlOrPath: booking.moviePosterUrl,
                        width: 90,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.movieTitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Booking ID: ${booking.id}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.darkRed)),
                          const SizedBox(height: 10),
                          _infoDetailRow('Customer:', booking.userName),
                          _infoDetailRow('Email:', booking.userEmail),
                          _infoDetailRow('Phone:', booking.userPhone),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Booking schedule & seat info grid
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _infoCell(context, 'CINEMA / THEATRE', booking.cinema),
                    _infoCell(context, 'SCREEN', booking.screen.isNotEmpty ? booking.screen : 'Screen 01'),
                    _infoCell(context, 'SHOW DATE & TIME', '${booking.date} at ${booking.time}'),
                    _infoCell(context, 'BOOKED SEATS (${booking.seats.length})', booking.seatsFormatted),
                    _infoCell(context, 'TOTAL AMOUNT', '₹${booking.totalAmount.toStringAsFixed(2)}'),
                    _infoCell(context, 'EXPERIENCE', booking.experience),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (booking.status != 'Cancelled')
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _cancelBooking(booking);
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 18, color: AppTheme.errorRed),
                        label: const Text('Cancel Booking', style: TextStyle(color: AppTheme.errorRed)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.errorRed)),
                      )
                    else
                      const SizedBox(),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$label ', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCell(BuildContext context, String label, String value) {
    return SizedBox(
      width: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningYellow;
      case 'cancelled':
        return AppTheme.errorRed;
      default:
        return AppTheme.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;
    final totalRevenue = MockData.totalRevenue;
    final todayCount = MockData.todayBookingsCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats Row ──
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(
                width: 280,
                child: _buildStatCard(context, "Today's Bookings", '$todayCount', 'Active Today', true),
              ),
              SizedBox(
                width: 280,
                child: _buildStatCard(context, 'Total Completed Revenue', '₹${totalRevenue.toStringAsFixed(2)}', 'Paid Transactions', true),
              ),
              SizedBox(
                width: 280,
                child: _buildOccupancyCard(
                  context,
                  'Average Occupancy',
                  MockData.bookings.isNotEmpty ? '78%' : '0%',
                  MockData.bookings.isNotEmpty ? 0.78 : 0.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Search & Export Control Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 320,
                height: 42,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by ID, User, Movie or Phone...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking report generated with ${bookings.length} entries.'),
                      backgroundColor: AppTheme.textPrimary,
                    ),
                  );
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export Report'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Booking Register Table Card ──
          CustomCard(
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1050,
                child: Column(
                  children: [
                    // Table Header & Tabs
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Booking Register', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(width: 24),
                              _buildTab('All'),
                              const SizedBox(width: 8),
                              _buildTab('Confirmed'),
                              const SizedBox(width: 8),
                              _buildTab('Pending'),
                              const SizedBox(width: 8),
                              _buildTab('Cancelled'),
                            ],
                          ),
                          Text('${bookings.length} Bookings', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),

                    // Column Headers
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      color: const Color(0xFFFDF6F6),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text('Booking ID', style: _headerStyle(context))),
                          Expanded(flex: 2, child: Text('User Name', style: _headerStyle(context))),
                          Expanded(flex: 3, child: Text('Movie/Show', style: _headerStyle(context))),
                          Expanded(flex: 2, child: Text('Theater & Screen', style: _headerStyle(context))),
                          Expanded(flex: 2, child: Text('Seats', style: _headerStyle(context))),
                          Expanded(flex: 2, child: Text('Amount', style: _headerStyle(context))),
                          Expanded(flex: 2, child: Text('Status', style: _headerStyle(context))),
                          Expanded(flex: 1, child: Text('Actions', style: _headerStyle(context))),
                        ],
                      ),
                    ),

                    // Rows
                    if (bookings.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'No bookings found.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...bookings.asMap().entries.map((entry) {
                        final booking = entry.value;
                        final isLast = entry.key == bookings.length - 1;
                        return Column(
                          children: [
                            _buildRow(booking),
                            if (!isLast) const Divider(height: 1),
                          ],
                        );
                      }),

                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppTheme.borderLight)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Showing ${bookings.length} entries', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isActive = _selectedStatusFilter.toLowerCase() == title.toLowerCase();
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = title),
      child: Container(
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
      ),
    );
  }

  TextStyle? _headerStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
        );
  }

  Widget _buildRow(BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Booking ID
          Expanded(
            flex: 2,
            child: Text(
              booking.id,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.darkRed, fontWeight: FontWeight.bold),
            ),
          ),
          // User Name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.lightRed,
                  child: Text(
                    booking.userName.isNotEmpty ? booking.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 11, color: AppTheme.darkRed, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.userName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Movie & Show Time
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.movieTitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text('${booking.date}, ${booking.time}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          // Theater & Screen
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.cinema, style: Theme.of(context).textTheme.bodyMedium),
                if (booking.screen.isNotEmpty)
                  Text(booking.screen, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          // Seats
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: booking.seats
                  .map((seat) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(4)),
                        child: Text(seat, style: Theme.of(context).textTheme.bodySmall),
                      ))
                  .toList(),
            ),
          ),
          // Total Amount
          Expanded(
            flex: 2,
            child: Text('₹${booking.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(booking.status, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
              onPressed: () => _showBookingDetailsModal(booking),
              tooltip: 'View Details',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String trend, bool isPositive) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.darkRed, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(trend, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard(BuildContext context, String title, String value, double percent) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
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
