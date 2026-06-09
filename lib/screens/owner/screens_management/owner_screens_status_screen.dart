import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/screens_management/owner_screen_details_screen.dart';

class OwnerScreensStatusScreen extends StatefulWidget {
  const OwnerScreensStatusScreen({super.key});

  @override
  State<OwnerScreensStatusScreen> createState() =>
      _OwnerScreensStatusScreenState();
}

class _OwnerScreensStatusScreenState extends State<OwnerScreensStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AdminAppBar(showBackButton: Navigator.canPop(context)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Active Screens : 12',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: AppColors.textWhite,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio:
                    0.85, // Makes it slightly taller than a perfect square to fit content
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                // Mock data variations
                bool isImax = index % 3 == 0;
                String screenName =
                    'SCREEN ${index + 1 < 10 ? '0${index + 1}' : index + 1} - ${isImax ? 'IMAX' : 'STANDARD'}';
                String movieTitle = isImax ? 'Dune: Part Two' : 'Oppenheimer';
                String imageUrl = isImax
                    ? 'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?q=80&w=1000&auto=format&fit=crop'
                    : 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1000&auto=format&fit=crop';
                double occupancy = 0.3 + ((index * 0.17) % 0.6);
                String timeLabel = index % 2 == 0 ? 'Ends at' : 'Next Show';
                String timeValue = index % 2 == 0 ? '14:45' : '15:15';

                return _buildScreenListItem(
                  screenName: screenName,
                  movieTitle: movieTitle,
                  imageUrl: imageUrl,
                  occupancy: occupancy,
                  timeLabel: timeLabel,
                  timeValue: timeValue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OwnerScreenDetailsScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenListItem({
    required String screenName,
    required String movieTitle,
    required String imageUrl,
    required double occupancy,
    required String timeLabel,
    required String timeValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      screenName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      movieTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeLabel,
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(fontSize: 10),
                        ),
                        Text(
                          timeValue,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: occupancy,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryDark,
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${(occupancy * 100).toInt()}%',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
