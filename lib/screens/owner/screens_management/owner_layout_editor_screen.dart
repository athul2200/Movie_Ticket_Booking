import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/seat_row_model.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';

/// Full-screen seating layout editor for a single cinema screen.
///
/// Receives [theaterName] and [screenName], reads and mutates
/// [MockData.screenLayouts] in memory — no persistence.
class OwnerLayoutEditorScreen extends StatefulWidget {
  final String theaterName;
  final String screenName;

  const OwnerLayoutEditorScreen({
    super.key,
    required this.theaterName,
    required this.screenName,
  });

  @override
  State<OwnerLayoutEditorScreen> createState() =>
      _OwnerLayoutEditorScreenState();
}

class _OwnerLayoutEditorScreenState extends State<OwnerLayoutEditorScreen> {
  late List<SeatRow> _rows;
  // Tracks TextEditingControllers for each row name field
  final List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    _loadRows();
  }

  void _loadRows() {
    final layout = MockData.getLayout(widget.theaterName, widget.screenName);
    _rows = layout.map((r) => r.copyWith()).toList();
    _rebuildControllers();
  }

  void _rebuildControllers() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    _nameControllers.clear();
    for (final row in _rows) {
      _nameControllers.add(TextEditingController(text: row.rowName));
    }
  }

  int get _totalSeats => _rows.fold(0, (sum, r) => sum + r.seatCount);

  void _addRow() {
    setState(() {
      // Auto-suggest next letter
      final nextChar = _rows.isEmpty
          ? 'A'
          : String.fromCharCode(
              _rows.last.rowName.isNotEmpty
                  ? _rows.last.rowName.codeUnitAt(0) + 1
                  : 65,
            );
      _rows.add(SeatRow(rowName: nextChar, seatCount: 8));
      _nameControllers.add(TextEditingController(text: nextChar));
    });
    _persistToMockData();
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);
    });
    _persistToMockData();
  }

  void _updateRowName(int index, String value) {
    _rows[index].rowName = value.toUpperCase();
    _persistToMockData();
  }

  void _incrementSeats(int index) {
    setState(() => _rows[index].seatCount++);
    _persistToMockData();
  }

  void _decrementSeats(int index) {
    if (_rows[index].seatCount > 1) {
      setState(() => _rows[index].seatCount--);
      _persistToMockData();
    }
  }

  void _resetLayout() {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text(
          'Reset Layout?',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will restore the default layout for ${widget.screenName}. Any custom changes will be lost.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _rows = MockData.defaultLayoutFor(widget.screenName);
          _rebuildControllers();
        });
        _persistToMockData();
      }
    });
  }

  void _persistToMockData() {
    MockData.screenLayouts[widget.theaterName] ??= {};
    MockData.screenLayouts[widget.theaterName]![widget.screenName] =
        _rows.map((r) => r.copyWith()).toList();
  }

  Future<void> _saveChanges() async {
    _persistToMockData();
    await MockData.saveAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.screenName} seating layout saved successfully!'),
          backgroundColor: AppColors.primaryDark,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(
        title: '${widget.screenName} Layout',
        showBackButton: true,
        actions: [
          // Capacity badge in appbar
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.lg),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chair_outlined, size: 14, color: AppColors.primary),
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
      body: Column(
        children: [
          // ── Live Preview ──
          _buildPreviewSection(),

          const Divider(color: AppColors.divider, height: 1),

          // ── Row Editor ──
          Expanded(
            child: _buildEditorSection(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                label: const Text(
                  'Add Row',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.textWhite),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  PREVIEW SECTION
  // ─────────────────────────────────────────────

  Widget _buildPreviewSection() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SEATING PREVIEW',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.5,
                  color: AppColors.textHint,
                ),
              ),
              GestureDetector(
                onTap: _resetLayout,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restart_alt, size: 13, color: Colors.redAccent),
                      SizedBox(width: 4),
                      Text(
                        'Reset',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Screen bar
          Center(
            child: Column(
              children: [
                Container(
                  width: 160,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S C R E E N',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 3,
                    fontSize: 9,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Scrollable seat grid
          if (_rows.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(
                  'No rows yet. Tap "Add Row" to begin.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _rows.asMap().entries.map((entry) {
                  return _buildPreviewRow(entry.value);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(SeatRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Row label — left
          SizedBox(
            width: 24,
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
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.divider),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          // Row label — right
          SizedBox(
            width: 24,
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

  // ─────────────────────────────────────────────
  //  EDITOR SECTION
  // ─────────────────────────────────────────────

  Widget _buildEditorSection() {
    if (_rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chair_outlined, size: 48, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No rows added yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      itemCount: _rows.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final row = _rows.removeAt(oldIndex);
          _rows.insert(newIndex, row);
          final ctrl = _nameControllers.removeAt(oldIndex);
          _nameControllers.insert(newIndex, ctrl);
        });
        _persistToMockData();
      },
      itemBuilder: (context, index) {
        return _buildRowEditorCard(index, key: ValueKey('row_$index'));
      },
    );
  }

  Widget _buildRowEditorCard(int index, {required Key key}) {
    final row = _rows[index];

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Drag handle
          const Icon(Icons.drag_handle, color: AppColors.textHint, size: 20),
          const SizedBox(width: AppSpacing.md),

          // Row name field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ROW',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1,
                  fontSize: 9,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 52,
                child: TextField(
                  controller: _nameControllers[index],
                  maxLength: 3,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                  onChanged: (val) {
                    _updateRowName(index, val);
                    setState(() {}); // Rebuild preview
                  },
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    filled: true,
                    fillColor: AppColors.primary.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),

          // Seat count stepper
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEATS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1,
                    fontSize: 9,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _stepperButton(
                      icon: Icons.remove,
                      onTap: () => _decrementSeats(index),
                      enabled: row.seatCount > 1,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 48,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        '${row.seatCount}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _stepperButton(
                      icon: Icons.add,
                      onTap: () => _incrementSeats(index),
                      enabled: true,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'seats',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete button
          GestureDetector(
            onTap: () => _removeRow(index),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.divider.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : AppColors.textHint,
        ),
      ),
    );
  }
}
