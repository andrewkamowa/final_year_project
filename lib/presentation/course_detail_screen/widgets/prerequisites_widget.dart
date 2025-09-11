import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrerequisitesWidget extends StatelessWidget {
  final Map<String, dynamic> courseData;

  const PrerequisitesWidget({
    Key? key,
    required this.courseData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prerequisites =
        (courseData['prerequisites'] as List?)?.cast<Map<String, dynamic>>() ??
            _getDefaultPrerequisites();

    if (prerequisites.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Prerequisites',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'To get the most out of this course, you should have:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          ...prerequisites
              .map((prerequisite) => _buildPrerequisiteItem(prerequisite))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPrerequisiteItem(Map<String, dynamic> prerequisite) {
    final isCompleted = prerequisite['isCompleted'] ?? false;
    final isRequired = prerequisite['isRequired'] ?? true;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppTheme.lightTheme.colorScheme.secondary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : isRequired
                      ? AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: isCompleted
                    ? 'check'
                    : isRequired
                        ? 'priority_high'
                        : 'info',
                color: isCompleted
                    ? Colors.white
                    : isRequired
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Prerequisite info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        prerequisite['title'] ?? 'Prerequisite',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Required',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                if (prerequisite['description'] != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    prerequisite['description'],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (prerequisite['skillLevel'] != null) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Text(
                        'Skill Level: ',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getSkillLevelColor(prerequisite['skillLevel'])
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          prerequisite['skillLevel'],
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color:
                                _getSkillLevelColor(prerequisite['skillLevel']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action button
          if (!isCompleted && prerequisite['courseId'] != null)
            TextButton(
              onPressed: () => _navigateToPrerequisite(prerequisite),
              child: Text(
                'Start',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'beginner':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'intermediate':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'advanced':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _navigateToPrerequisite(Map<String, dynamic> prerequisite) {
    // Navigate to prerequisite course
  }

  List<Map<String, dynamic>> _getDefaultPrerequisites() {
    return [
      {
        'title': 'Basic Math Skills',
        'description':
            'Understanding of basic arithmetic operations and percentages',
        'skillLevel': 'Beginner',
        'isRequired': true,
        'isCompleted': true,
      },
      {
        'title': 'Introduction to Economics',
        'description':
            'Basic understanding of economic principles and market concepts',
        'skillLevel': 'Beginner',
        'isRequired': false,
        'isCompleted': false,
        'courseId': 'intro-economics-101',
      },
    ];
  }
}
