import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/review_model.dart';

class ReviewSection extends StatefulWidget {
  const ReviewSection({super.key});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  Future<void> _approveReview(ReviewModel review) async {
    final idx = MockData.reviews.indexWhere((r) => r.id == review.id);
    if (idx != -1) {
      setState(() {
        MockData.reviews[idx] = review.copyWith(isApproved: true);
      });
      await MockData.saveAll();
    }
  }

  Future<void> _deleteReview(ReviewModel review) async {
    setState(() {
      MockData.reviews.removeWhere((r) => r.id == review.id);
    });
    await MockData.saveAll();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = MockData.reviews;

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
            ],
          ),
          Text(
            'Moderation queue • ${reviews.where((r) => !r.isApproved).length} pending reviews requiring action.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // ── Review cards — wraps on narrow screens ────────────
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No pending reviews in queue.'),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: reviews
                  .map((r) => SizedBox(
                        width: 320,
                        child: _ReviewCard(
                          review: r,
                          onApprove: () => _approveReview(r),
                          onDelete: () => _deleteReview(r),
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
  final ReviewModel review;
  final VoidCallback onApprove;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.onApprove,
    required this.onDelete,
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
                  review.userInitials,
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
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textPrimary),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 13,
                          color: i < review.rating ? AppTheme.primaryRed : AppTheme.borderLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(review.timeAgo, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${review.comment}"',
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
                  onPressed: review.isApproved ? null : onApprove,
                  icon: Icon(
                    Icons.check_circle_outline,
                    size: 15,
                    color: review.isApproved ? AppTheme.successGreen : AppTheme.textSecondary,
                  ),
                  label: Text(
                    review.isApproved ? 'Approved' : 'Approve',
                    style: TextStyle(
                      fontSize: 13,
                      color: review.isApproved ? AppTheme.successGreen : AppTheme.textSecondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: review.isApproved ? AppTheme.successGreen : AppTheme.borderLight,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 15, color: Colors.white),
                  label: const Text('Delete', style: TextStyle(fontSize: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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