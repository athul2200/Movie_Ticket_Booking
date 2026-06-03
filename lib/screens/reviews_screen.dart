import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_card.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Full Review Queue',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Moderation queue • 12 pending reviews from the last 24 hours.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const ReviewQueueList(),
        ],
      ),
    );
  }
}

class ReviewQueueList extends StatelessWidget {
  const ReviewQueueList({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [
      _buildReviewCard(
        context,
        'SM',
        'Sandra Muller',
        '10m ago',
        4,
        '"The Dolby Atmos sound in Theater 4 was absolutely incredible. Made the new blockbuster feel so immersive. Just wish the popcorn was a bit fresher!"',
      ),
      _buildReviewCard(
        context,
        'TL',
        'Tom Lewis',
        '1h ago',
        3,
        '"Had trouble with the digital ticket scanner. The staff was helpful but it delayed us getting to our seats by 15 minutes."',
      ),
      _buildReviewCard(
        context,
        'RK',
        'Riya Kapoor',
        '3h ago',
        5,
        '"Cinema Concierge is a game changer. Booked the lounge seats and the service was impeccable. Highly recommended!"',
      ),
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: cards.map((c) => SizedBox(width: 380, child: c)).toList(),
    );
  }

  Widget _buildReviewCard(BuildContext context, String initials, String name, String time, int rating, String text) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.darkRed,
                    child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleSmall),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: AppTheme.primaryRed,
                            size: 14,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(time, style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.textSecondary),
                label: Text('Approve', style: TextStyle(color: AppTheme.textSecondary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.borderLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.errorRed),
                label: const Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRedBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
