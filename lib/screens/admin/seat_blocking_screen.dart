import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'custom_card.dart';

class SeatBlockingScreen extends StatefulWidget {
  const SeatBlockingScreen({super.key});

  @override
  State<SeatBlockingScreen> createState() => _SeatBlockingScreenState();
}

class _SeatBlockingScreenState extends State<SeatBlockingScreen> {
  Set<String> selectedSeats = {};
  
  // Mock data for booked and blocked seats
  final Set<String> bookedSeats = {'E7', 'E8', 'E9', 'E10', 'E11'};
  final Set<String> blockedSeats = {'A1', 'A2'};
  
  void toggleSeatSelection(String seatId) {
    if (bookedSeats.contains(seatId) || blockedSeats.contains(seatId)) {
      return; // Cannot select booked or blocked seats
    }
    setState(() {
      if (selectedSeats.contains(seatId)) {
        selectedSeats.remove(seatId);
      } else {
        selectedSeats.add(seatId);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedSeats.clear();
    });
  }

  void blockSelectedSeats() {
    setState(() {
      blockedSeats.addAll(selectedSeats);
      selectedSeats.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column
            SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSessionDetails(),
                    const SizedBox(height: 24),
                    _buildAuditoriumStatus(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Right Column
            Expanded(
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFloorPlanHeader(),
                      const SizedBox(height: 40),
                      _buildScreenIndicator(),
                      const SizedBox(height: 40),
                      Expanded(
                        child: _buildSeatGrid(),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildFloorPlanFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Floating Bottom Bar
        if (selectedSeats.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildFloatingSelectionBar(),
            ),
          ),
      ],
    );
  }

  Widget _buildSessionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session Details', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Selected Movie', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                // Placeholder for movie poster
                child: const Icon(Icons.movie, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nebula's Horizon", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text("2h 15m • Sci-Fi / Drama", style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Auditorium', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('IMAX Theatre\n04', style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time Slot', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('19:45 PM\n', style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.5)), // Added \n for height matching
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuditoriumStatus() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AUDITORIUM STATUS', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatusBox('142', 'Available', const Color(0xFFF3F4F6))),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusBox('58', 'Booked', const Color(0xFFE5E7EB))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatusBox('12', 'Blocked', const Color(0xFFF3F4F6))),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      border: Border.all(color: const Color(0xFFFECACA)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${selectedSeats.length}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryRed)),
                        const SizedBox(height: 4),
                        Text('Selected to\nBlock', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryRed)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBox(String count, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: selectedSeats.isEmpty ? null : blockSelectedSeats,
          icon: const Icon(Icons.lock_outline),
          label: const Text('Confirm Block Selection'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.darkRed, // using dark red as per image
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: selectedSeats.isEmpty ? null : clearSelection,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppTheme.borderLight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Clear Current Selection', style: TextStyle(color: AppTheme.textPrimary)),
        ),
      ],
    );
  }

  Widget _buildFloorPlanHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interactive Floor\nPlan', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(width: 16),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(Colors.white, 'Available', true),
              _buildLegendItem(const Color(0xFFE5E7EB), 'Booked'),
              _buildLegendItem(const Color(0xFF6B7280), 'Blocked'),
              _buildLegendItem(AppTheme.primaryRed, 'Selection'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, [bool withBorder = false]) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: withBorder ? Border.all(color: AppTheme.borderLight) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildScreenIndicator() {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [Color(0x00E5E7EB), Color(0xFFE5E7EB), Color(0xFFE5E7EB), Color(0x00E5E7EB)],
              stops: [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('SCREEN THIS WAY', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 4, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildSeatGrid() {
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                children: rows.map((row) => _buildSeatRow(row)).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeatRow(String rowLetter) {
    List<Widget> children = [
      SizedBox(
        width: 32,
        child: Center(
          child: Text(
            rowLetter,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ];

    for (int i = 1; i <= 14; i++) {
      if (i == 3) {
        children.add(const SizedBox(width: 36)); // Aisle between 2 and 3
      }
      children.add(_buildSeat(rowLetter, i));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _buildSeat(String rowLetter, int seatNumber) {
    // Gap logic: rows other than 'E' have a gap at columns 9 and 10.
    if (rowLetter != 'E' && (seatNumber == 9 || seatNumber == 10)) {
      return const SizedBox(width: 36); // Size of a seat + padding
    }

    final seatId = '$rowLetter$seatNumber';
    final isBooked = bookedSeats.contains(seatId);
    final isBlocked = blockedSeats.contains(seatId);
    final isSelected = selectedSeats.contains(seatId);

    Color bgColor = Colors.white;
    Color textColor = AppTheme.textPrimary;
    Color borderColor = AppTheme.borderLight;

    if (isBooked) {
      bgColor = const Color(0xFFE5E7EB);
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (isBlocked) {
      bgColor = const Color(0xFF6B7280);
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (isSelected) {
      bgColor = AppTheme.primaryRed;
      textColor = Colors.white;
      borderColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: () => toggleSeatSelection(seatId),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: isBlocked
            ? const Icon(Icons.block, size: 14, color: Colors.white)
            : Text(
                '$seatNumber',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildFloorPlanFooter() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildFooterButton('Select Full\nRow'),
        _buildFooterButton('Select\nOdd/Even'),
        const SizedBox(width: 4),
        const Icon(Icons.info_outline, size: 16, color: AppTheme.textLight),
        Text('Tip: Drag across seats to select multiple (Planned Update)', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFooterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildFloatingSelectionBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.primaryRed,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${selectedSeats.length} Seats Selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryRed),
            ),
            const SizedBox(width: 24),
            Container(height: 24, width: 1, color: AppTheme.borderLight),
            const SizedBox(width: 24),
            ElevatedButton(
              onPressed: blockSelectedSeats,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Block Selected'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: clearSelection,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: const Color(0xFFF3F4F6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
