import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/widgets/admin_text_field.dart';
import 'package:booking/screens/owner/widgets/admin_dropdown.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';

class OwnerMoviesScreen extends StatefulWidget {
  const OwnerMoviesScreen({super.key});

  @override
  State<OwnerMoviesScreen> createState() => _OwnerMoviesScreenState();
}

class _OwnerMoviesScreenState extends State<OwnerMoviesScreen> {
  final TextEditingController _movieNameCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _trailerCtrl = TextEditingController();
  String _selectedLanguage = 'English';

  @override
  void dispose() {
    _movieNameCtrl.dispose();
    _durationCtrl.dispose();
    _trailerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text(
              'Movie Management',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add new titles to your catalog and manage\nexisting theater listings.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Add New Movie Card ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Add New Movie',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Movie Name',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminTextField(
                    controller: _movieNameCtrl,
                    hintText: 'e.g. Interstellar',
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Language',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            AdminDropdown<String>(
                              value: _selectedLanguage,
                              items: const [
                                DropdownMenuItem(
                                  value: 'English',
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: 'Malayalam',
                                  child: Text('Malayalam'),
                                ),
                                DropdownMenuItem(
                                  value: 'Tamil',
                                  child: Text('Tamil'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedLanguage = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duration',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            AdminTextField(
                              controller: _durationCtrl,
                              hintText: 'HH:MM',
                              suffixIcon: const Icon(
                                Icons.access_time,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'YouTube Trailer Link',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminTextField(
                    controller: _trailerCtrl,
                    hintText: 'https://youtube.com/watch?v=...',
                    prefixIcon: const Icon(
                      Icons.play_circle_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AdminButton(text: 'Save Movie', onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Banner Card ──
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=2070&auto=format&fit=crop',
                  ), // Cinema hall abstract
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expand Your Library',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add up to 50 active listings per theater.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Currently Managed Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Currently Managed',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.grid_view,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.format_list_bulleted,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Movie List
            _buildManagedMovieCard(
              title: 'Cosmic Horizon',
              language: 'English',
              duration: '02:15',
              imageUrl:
                  'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?q=80&w=1000&auto=format&fit=crop',
              badgeText: 'Live Now',
              isLive: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildManagedMovieCard(
              title: 'Midnight Rain',
              language: 'French',
              duration: '01:48',
              imageUrl:
                  'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1000&auto=format&fit=crop',
              badgeText: 'Scheduled',
              isLive: false,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildManagedMovieCard(
              title: 'Dust Runners',
              language: 'English',
              duration: '02:30',
              imageUrl:
                  'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=1000&auto=format&fit=crop',
              badgeText: null,
              isLive: false,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Add More Movies Button
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppColors.background,
                side: const BorderSide(
                  color: AppColors.divider,
                  style: BorderStyle.solid,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Add More Movies',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildManagedMovieCard({
    required String title,
    required String language,
    required String duration,
    required String imageUrl,
    required String? badgeText,
    required bool isLive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (badgeText != null)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isLive
                          ? AppColors.textWhite
                          : AppColors.textWhite.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      badgeText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isLive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$language • $duration',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
