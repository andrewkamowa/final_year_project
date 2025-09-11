import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CourseHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> courseData;

  const CourseHeaderWidget({
    Key? key,
    required this.courseData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      width: double.infinity,
      child: Stack(
        children: [
          // Hero image with parallax effect
          Positioned.fill(
            child: CustomImageWidget(
              imageUrl: courseData['heroImage'] ?? '',
              width: double.infinity,
              height: 35.h,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // Course information overlay
          Positioned(
            bottom: 4.h,
            left: 4.w,
            right: 4.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Difficulty badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(
                        courseData['difficulty'] ?? 'Beginner'),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    courseData['difficulty'] ?? 'Beginner',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Course title
                Text(
                  courseData['title'] ?? 'Course Title',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 1.h),

                // Instructor information
                Row(
                  children: [
                    CircleAvatar(
                      radius: 2.5.w,
                      backgroundImage: NetworkImage(
                        courseData['instructorAvatar'] ??
                            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'By ${courseData['instructorName'] ?? 'John Smith'}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 6.h,
            left: 4.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Bookmark and share buttons
          Positioned(
            top: 6.h,
            right: 4.w,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => _toggleBookmark(context),
                    icon: CustomIconWidget(
                      iconName: courseData['isBookmarked'] == true
                          ? 'bookmark'
                          : 'bookmark_border',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => _shareCourse(context),
                    icon: CustomIconWidget(
                      iconName: 'share',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'intermediate':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'advanced':
        return AppTheme.lightTheme.colorScheme.error;
      case 'expert':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  void _toggleBookmark(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          courseData['isBookmarked'] == true
              ? 'Course removed from bookmarks'
              : 'Course bookmarked successfully',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareCourse(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
