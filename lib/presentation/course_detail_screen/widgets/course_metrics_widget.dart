import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CourseMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> courseData;

  const CourseMetricsWidget({
    Key? key,
    required this.courseData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            icon: 'schedule',
            value: courseData['duration'] ?? '4h 30m',
            label: 'Duration',
          ),
          _buildDivider(),
          _buildMetricItem(
            icon: 'play_circle_outline',
            value: '${courseData['lessonCount'] ?? 12}',
            label: 'Lessons',
          ),
          _buildDivider(),
          _buildRatingItem(
            rating: courseData['rating']?.toDouble() ?? 4.8,
            reviewCount: courseData['reviewCount'] ?? 1250,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem({
    required double rating,
    required int reviewCount,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'star',
                color: Colors.amber,
                size: 20,
              ),
              SizedBox(width: 1.w),
              Text(
                rating.toStringAsFixed(1),
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '${reviewCount} reviews',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 6.h,
      width: 1,
      color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
    );
  }
}
