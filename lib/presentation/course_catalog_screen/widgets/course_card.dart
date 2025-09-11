import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onPreview;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.onBookmark,
    this.onShare,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnrolled = course['isEnrolled'] as bool? ?? false;
    final progress = course['progress'] as double? ?? 0.0;
    final rating = course['rating'] as double? ?? 0.0;
    final isBookmarked = course['isBookmarked'] as bool? ?? false;

    return Slidable(
      key: ValueKey(course['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onBookmark?.call(),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            label: 'Save',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onShare?.call(),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onPreview?.call(),
            backgroundColor:
                AppTheme.getSuccessColor(theme.brightness == Brightness.light),
            foregroundColor: Colors.white,
            icon: Icons.play_circle_outline,
            label: 'Preview',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course thumbnail and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageWidget(
                        imageUrl: course['thumbnail'] as String,
                        width: 20.w,
                        height: 15.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Course details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            course['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          // Instructor
                          Text(
                            'by ${course['instructor'] as String}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1.h),
                          // Difficulty badge and duration
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(
                                      course['difficulty'] as String, theme),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  course['difficulty'] as String,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'access_time',
                                size: 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                course['duration'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bookmark icon
                    IconButton(
                      onPressed: onBookmark,
                      icon: CustomIconWidget(
                        iconName: isBookmarked ? 'bookmark' : 'bookmark_border',
                        size: 20,
                        color: isBookmarked
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Rating and progress
                Row(
                  children: [
                    // Rating
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          size: 16,
                          color: AppTheme.getAccentColor(
                              theme.brightness == Brightness.light),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '(${course['reviewCount'] as int})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Content type icon
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: _getContentTypeIcon(
                                course['contentType'] as String),
                            size: 14,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            course['contentType'] as String,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Progress bar for enrolled courses
                if (isEnrolled) ...[
                  SizedBox(height: 2.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.getSuccessColor(theme.brightness == Brightness.light);
      case 'semi-pro':
        return AppTheme.getAccentColor(theme.brightness == Brightness.light);
      case 'pro':
        return theme.colorScheme.secondary;
      case 'expert':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getContentTypeIcon(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'video':
        return 'play_circle_outline';
      case 'audio':
        return 'headphones';
      case 'text':
        return 'article';
      case 'interactive':
        return 'touch_app';
      default:
        return 'school';
    }
  }
}
