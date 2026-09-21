import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/review_model.dart';
import 'custom_card.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  Future<void> _approveReview(ReviewModel review) async {
    final idx = MockData.reviews.indexWhere((r) => r.id == review.id);
    if (idx != -1) {
      setState(() {
        MockData.reviews[idx] = review.copyWith(isApproved: true);
      });
      await MockData.saveAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review approved successfully.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _deleteReview(ReviewModel review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review'),
        content: Text('Are you sure you want to delete review by "${review.userName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      MockData.reviews.removeWhere((r) => r.id == review.id);
    });
    await MockData.saveAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review deleted.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = MockData.reviews;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Full Review Queue',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Moderation queue • ${reviews.where((r) => !r.isApproved).length} pending reviews requiring action.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No reviews in moderation queue.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: reviews.map((r) => SizedBox(width: 380, child: _buildReviewCard(r))).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
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
                    child: Text(review.userInitials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
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
                child: Text(review.timeAgo, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Movie: ${review.movieTitle}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.darkRed),
          ),
          const SizedBox(height: 8),
          Text(
            '"${review.comment}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!review.isApproved)
                OutlinedButton.icon(
                  onPressed: () => _approveReview(review),
                  icon: const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.successGreen),
                  label: const Text('Approve', style: TextStyle(color: AppTheme.successGreen)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.successGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreenBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Approved', style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _deleteReview(review),
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
