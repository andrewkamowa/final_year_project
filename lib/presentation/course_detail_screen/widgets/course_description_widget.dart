import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CourseDescriptionWidget extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseDescriptionWidget({
    Key? key,
    required this.courseData,
  }) : super(key: key);

  @override
  State<CourseDescriptionWidget> createState() =>
      _CourseDescriptionWidgetState();
}

class _CourseDescriptionWidgetState extends State<CourseDescriptionWidget> {
  bool _isExpanded = false;
  final int _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    final description = widget.courseData['description'] ??
        'This comprehensive course will teach you essential financial literacy skills to help you make informed decisions about your money and build a secure financial future.';

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Course',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                  maxLines: _maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = true),
                  child: Text(
                    'Read More',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 2.h),

                // What you'll learn section
                Text(
                  'What You\'ll Learn',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),

                ..._buildLearningPoints(),

                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = false),
                  child: Text(
                    'Show Less',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLearningPoints() {
    final learningPoints =
        (widget.courseData['learningPoints'] as List?)?.cast<String>() ??
            [
              'Understand basic financial concepts and terminology',
              'Create and manage a personal budget effectively',
              'Learn about different investment options and strategies',
              'Develop skills for debt management and credit building',
              'Plan for retirement and long-term financial goals',
            ];

    return learningPoints
        .map((point) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 0.8.h, right: 3.w),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
