import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/widgets/admin_text_field.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';
import 'package:booking/screens/owner/screens_management/owner_add_screen.dart';
import 'package:booking/screens/owner/screens_management/owner_layout_editor_screen.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/seat_row_model.dart';

/// Screens list screen for the Owner module.
///
/// Shows all cinema screens for a theater, allows switching between them,
/// viewing their seating layout preview, and opening the layout editor.
class OwnerScreensListScreen extends StatefulWidget {
  final String theaterName;
  const OwnerScreensListScreen({super.key, this.theaterName = 'Kairali'});

  @override
  State<OwnerScreensListScreen> createState() => _OwnerScreensListScreenState();
}

class _OwnerScreensListScreenState extends State<OwnerScreensListScreen> {
  /// All screen names available for this theater (derived from screenPrices).
  List<String> get _screenNames {
    final prices = MockData.screenPrices[widget.theaterName];
    if (prices == null || prices.isEmpty) return ['Screen 01', 'Screen 02'];
    return prices.keys.toList()..sort();
  }

  late String _activeScreen;
  late final TextEditingController _standardRateCtrl;

  @override
  void initState() {
    super.initState();
    _activeScreen = _screenNames.first;
    _standardRateCtrl = TextEditingController(text: _getPrice(_activeScreen));
  }

  String _getPrice(String screen) {
    final price = MockData.screenPrices[widget.theaterName]?[screen] ?? 140.0;
    return price.toStringAsFixed(2);
  }

  void _setActiveScreen(String screen) {
    setState(() {
      _activeScreen = screen;
      _standardRateCtrl.text = _getPrice(screen);
    });
  }

  Future<void> _updateRate() async {
    final newPrice = double.tryParse(_standardRateCtrl.text);
    if (newPrice != null) {
      MockData.screenPrices[widget.theaterName] ??= {};
      MockData.screenPrices[widget.theaterName]![_activeScreen] = newPrice;
      await MockData.saveAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_activeScreen rate updated to ₹${newPrice.toStringAsFixed(2)}!'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid price format'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _standardRateCtrl.dispose();
    super.dispose();
  }

  // ── Computed helpers ──

  List<SeatRow> get _activeRows {
    return MockData.getLayout(widget.theaterName, _activeScreen);
  }

  int get _totalSeats => _activeRows.fold(0, (s, r) => s + r.seatCount);

  int _totalSeatsForScreen(String screen) {
    final rows = MockData.getLayout(widget.theaterName, screen);
    return rows.fold(0, (s, r) => s + r.seatCount);
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(title: widget.theaterName, noLeading: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header + Add screen button ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Screens',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OwnerAddScreen(theaterName: widget.theaterName),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: AppSizes.iconMd,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Screen Selector Tabs ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _screenNames.map((screen) {
                  final isActive = _activeScreen == screen;
                  return GestureDetector(
                    onTap: () => _setActiveScreen(screen),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: isActive
                            ? null
                            : Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        screen,
                        style: TextStyle(
                          color: isActive
                              ? AppColors.textWhite
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Screen Cards (one per screen) ──
            ..._screenNames.map((screen) {
              final isActive = _activeScreen == screen;
              return GestureDetector(
                onTap: () => _setActiveScreen(screen),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: isActive
                        ? null
                        : Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isActive) ...[
                              Text(
                                'NOW EDITING',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textWhite.withValues(alpha: 0.8),
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                            ],
                            Text(
                              screen,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isActive
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Icon(
                                  Icons.chair_outlined,
                                  size: AppSizes.iconSm,
                                  color: isActive
                                      ? AppColors.textWhite
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '${_totalSeatsForScreen(screen)} Seats Total',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isActive
                                        ? AppColors.textWhite
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            isActive
                                ? Icons.grid_view_rounded
                                : Icons.grid_view_outlined,
                            color: isActive
                                ? AppColors.textWhite
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            '₹${_getPrice(screen)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isActive
                                  ? AppColors.textWhite
                                  : AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            // ── Set Pricing Section ──
            Text(
              'Set Pricing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Rate (₹)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            AdminTextField(
              controller: _standardRateCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            AdminButton(text: 'Update Rates', onPressed: _updateRate),
            const SizedBox(height: AppSpacing.xxl),

            // ── Seating Layout Section ──
            _buildLayoutSection(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LAYOUT SECTION
  // ─────────────────────────────────────────────

  Widget _buildLayoutSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Seating Layout',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _activeScreen,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              // Capacity pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chair_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_totalSeats seats',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Screen indicator bar
          Center(
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S C R E E N   T H I S   W A Y',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 2.0,
                    fontSize: 8,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Compact seating preview
          _activeRows.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chair_outlined,
                          size: 36,
                          color: AppColors.divider,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No layout defined.\nTap "Customize Layout" to get started.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _activeRows.map(_buildCompactPreviewRow).toList(),
                  ),
                ),

          const SizedBox(height: AppSpacing.xl),

          // Capacity summary bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CAPACITY',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$_totalSeats ',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                color: AppColors.primary,
                              ),
                            ),
                            TextSpan(
                              text: 'seats',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_activeRows.length} rows',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_activeRows.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Rows: ${_activeRows.map((r) => r.rowName).join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Customize Layout button — navigates to dedicated editor
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OwnerLayoutEditorScreen(
                      theaterName: widget.theaterName,
                      screenName: _activeScreen,
                    ),
                  ),
                );
                // Refresh after returning from editor
                setState(() {});
              },
              icon: const Icon(Icons.tune, size: 18, color: AppColors.textWhite),
              label: const Text(
                'Customize Layout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPreviewRow(SeatRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          // Row label – left
          SizedBox(
            width: 20,
            child: Text(
              row.rowName.isEmpty ? '?' : row.rowName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Seat boxes
          ...List.generate(row.seatCount, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          // Row label – right
          SizedBox(
            width: 20,
            child: Text(
              row.rowName.isEmpty ? '?' : row.rowName,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
