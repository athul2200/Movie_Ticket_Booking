import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({super.key});

  static const List<Map<String, dynamic>> _reviews = [
    {
      'initials': 'SM',
      'name': 'Sandra Muller',
      'timeAgo': '10m ago',
      'rating': 4,
      'review':
          '"The Dolby Atmos sound in Theater 4 was absolutely incredible. Made the new blockbuster feel so immersive. Just wish the popcorn was a bit fresher!"',
    },
    {
      'initials': 'TL',
      'name': 'Tom Lewis',
      'timeAgo': '1h ago',
      'rating': 2,
      'review':
          '"Had trouble with the digital ticket scanner. The staff was helpful but it delayed us getting to our seats by 15 minutes."',
    },
    {
      'initials': 'RK',
      'name': 'Riya Kapoor',
      'timeAgo': '3h ago',
      'rating': 5,
      'review':
          '"Cinema Concierge is a game changer. Booked the lounge seats and the service was impeccable. Highly recommended!"',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'Full Review Queue',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All →',
                  style: TextStyle(color: AppTheme.primaryRed, fontSize: 13),
                ),
              ),
            ],
          ),
          Text(
            'Moderation queue • 12 pending reviews from the last 24 hours.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // ── Review cards — wraps on narrow screens ────────────
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _reviews
                .map((r) => LayoutBuilder(
                      builder: (ctx, constraints) => SizedBox(
                        width: double.infinity,
                        child: _ReviewCard(
                          initials: r['initials'] as String,
                          name: r['name'] as String,
                          timeAgo: r['timeAgo'] as String,
                          rating: r['rating'] as int,
                          review: r['review'] as String,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String initials;
  final String name;
  final String timeAgo;
  final int rating;
  final String review;

  const _ReviewCard({
    required this.initials,
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name + time
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryRed,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: AppTheme.textPrimary)),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          size: 13,
                          color: i < rating
                              ? AppTheme.primaryRed
                              : AppTheme.borderLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(timeAgo,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline,
                      size: 15, color: AppTheme.textSecondary),
                  label: const Text('Approve',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.borderLight),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline,
                      size: 15, color: Colors.white),
                  label: const Text('Delete',
                      style:
                          TextStyle(fontSize: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
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