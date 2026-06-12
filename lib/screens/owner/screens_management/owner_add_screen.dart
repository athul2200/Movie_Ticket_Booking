import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_text_field.dart';
import 'package:booking/screens/owner/widgets/admin_dropdown.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';

class OwnerAddScreen extends StatefulWidget {
  const OwnerAddScreen({super.key});

  @override
  State<OwnerAddScreen> createState() => _OwnerAddScreenState();
}

class _OwnerAddScreenState extends State<OwnerAddScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _capacityCtrl = TextEditingController(
    text: '120',
  );
  String _selectedProjection = 'Standard 2D';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 200,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Icons.arrow_back,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Back to Screens',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'JD',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text(
              'Add New Screen',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Merge room details and seating configuration\nin one view.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Screen Details Section ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Screen Details',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Screen Name',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminTextField(
                    controller: _nameCtrl,
                    hintText: 'e.g., Screen 04',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Total Capacity',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminTextField(
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                    suffixIcon: const Icon(
                      Icons.chair_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Projection Type',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminDropdown<String>(
                    value: _selectedProjection,
                    items: const [
                      DropdownMenuItem(
                        value: 'Standard Laser',
                        child: Text('Standard Laser'),
                      ),
                      DropdownMenuItem(
                        value: 'Standard 2D',
                        child: Text('Standard 2D'),
                      ),
                      DropdownMenuItem(
                        value: 'Dolby Cinema',
                        child: Text('Dolby Cinema'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedProjection = val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Seating Configuration Section ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'SEATING CONFIGURATION',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Screen visual
                  Center(
                    child: Container(
                      width: 120,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      'SCREEN',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Rows
                  _buildRowConfig('A', 12),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRowConfig('B', 12),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRowConfig('C', 12),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRowConfig('D', 12),
                  const SizedBox(height: AppSpacing.xl),

                  // Add Row Button
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(
                        color: AppColors.divider,
                        style: BorderStyle.solid,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      '+ Add Row',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Create Screen Button
                  AdminButton(
                    text: 'Create Screen',
                    icon: Icons.add_circle_outline,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowConfig(String letter, int seats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('SEATS', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 60,
              height: 32,
              child: TextField(
                controller: TextEditingController(text: seats.toString()),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(
                  10, // Mock showing 10 small boxes
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }
}
