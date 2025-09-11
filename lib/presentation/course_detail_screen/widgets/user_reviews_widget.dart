import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UserReviewsWidget extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const UserReviewsWidget({
    Key? key,
    required this.courseData,
  }) : super(key: key);

  @override
  State<UserReviewsWidget> createState() => _UserReviewsWidgetState();
}

class _UserReviewsWidgetState extends State<UserReviewsWidget> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    final reviews =
        (widget.courseData['reviews'] as List?)?.cast<Map<String, dynamic>>() ??
            _getDefaultReviews();
    final rating = widget.courseData['rating']?.toDouble() ?? 4.8;
    final reviewCount = widget.courseData['reviewCount'] ?? 1250;

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Reviews',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 2.h),

          // Rating overview
          _buildRatingOverview(rating, reviewCount),

          SizedBox(height: 3.h),

          // Reviews list
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _showAllReviews
                ? reviews.length
                : (reviews.length > 3 ? 3 : reviews.length),
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
          ),

          if (reviews.length > 3) ...[
            SizedBox(height: 2.h),
            Center(
              child: TextButton(
                onPressed: () =>
                    setState(() => _showAllReviews = !_showAllReviews),
                child: Text(
                  _showAllReviews
                      ? 'Show Less Reviews'
                      : 'Show All Reviews (${reviews.length})',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingOverview(double rating, int reviewCount) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Overall rating
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                      child: CustomIconWidget(
                        iconName:
                            index < rating.floor() ? 'star' : 'star_border',
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '$reviewCount reviews',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Rating distribution
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(
                5,
                (index) =>
                    _buildRatingBar(5 - index, _getRatingPercentage(5 - index)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Text(
            '$stars',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
          SizedBox(width: 1.w),
          CustomIconWidget(
            iconName: 'star',
            color: Colors.amber,
            size: 12,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Container(
              height: 0.8.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            '${percentage.toInt()}%',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 3.w,
                backgroundImage: NetworkImage(
                  review['userAvatar'] ??
                      'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] ?? 'Anonymous User',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => CustomIconWidget(
                              iconName: index < (review['rating'] ?? 5)
                                  ? 'star'
                                  : 'star_border',
                              color: Colors.amber,
                              size: 14,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          review['date'] ?? '2 weeks ago',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Helpful votes
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _voteHelpful(review),
                        icon: CustomIconWidget(
                          iconName: 'thumb_up_outlined',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                      ),
                      Text(
                        '${review['helpfulVotes'] ?? 12}',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Review content
          Text(
            review['content'] ??
                'Great course! Very informative and well-structured.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  double _getRatingPercentage(int stars) {
    // Mock rating distribution
    switch (stars) {
      case 5:
        return 68.0;
      case 4:
        return 22.0;
      case 3:
        return 7.0;
      case 2:
        return 2.0;
      case 1:
        return 1.0;
      default:
        return 0.0;
    }
  }

  void _voteHelpful(Map<String, dynamic> review) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your feedback!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, dynamic>> _getDefaultReviews() {
    return [
      {
        'userName': 'Sarah Banda',
        'userAvatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'rating': 5,
        'date': '1 week ago',
        'content':
            'Excellent course! The instructor explains complex financial concepts in a very understandable way. I feel much more confident about managing my finances now.',
        'helpfulVotes': 24,
      },
      {
        'userName': 'Michael Phiri',
        'userAvatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'rating': 4,
        'date': '2 weeks ago',
        'content':
            'Very comprehensive course with practical examples. The budgeting section was particularly helpful. Would recommend to anyone starting their financial journey.',
        'helpfulVotes': 18,
      },
      {
        'userName': 'Alice Kamowa',
        'userAvatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'rating': 5,
        'date': '3 weeks ago',
        'content':
            'This course changed my perspective on money management. The investment basics module was eye-opening. Great value for money!',
        'helpfulVotes': 31,
      },
      {
        'userName': 'David Goliati',
        'userAvatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'rating': 4,
        'date': '1 month ago',
        'content':
            'Well-structured course with good pacing. The quizzes help reinforce the learning. Some sections could use more real-world examples.',
        'helpfulVotes': 15,
      },
      {
        'userName': 'Lisa Gumula',
        'userAvatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'rating': 5,
        'date': '1 month ago',
        'content':
            'Outstanding course! The debt management strategies have already helped me save hundreds of dollars. Highly recommended!',
        'helpfulVotes': 27,
      },
    ];
  }
}
