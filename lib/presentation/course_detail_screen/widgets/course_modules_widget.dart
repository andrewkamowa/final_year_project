import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CourseModulesWidget extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const CourseModulesWidget({
    Key? key,
    required this.courseData,
  }) : super(key: key);

  @override
  State<CourseModulesWidget> createState() => _CourseModulesWidgetState();
}

class _CourseModulesWidgetState extends State<CourseModulesWidget> {
  int? _expandedModuleIndex;

  @override
  Widget build(BuildContext context) {
    final modules =
        (widget.courseData['modules'] as List?)?.cast<Map<String, dynamic>>() ??
            _getDefaultModules();

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Content',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) =>
                _buildModuleCard(modules[index], index),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module, int index) {
    final isExpanded = _expandedModuleIndex == index;
    final isLocked = module['isLocked'] ?? false;
    final isCompleted = module['isCompleted'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: isExpanded ? 12 : 4,
            offset: Offset(0, isExpanded ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: isLocked ? null : () => _toggleModule(index),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Module status icon
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: _getModuleStatusColor(isLocked, isCompleted),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _getModuleStatusIcon(isLocked, isCompleted),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  SizedBox(width: 4.w),

                  // Module info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module['title'] ?? 'Module ${index + 1}',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isLocked
                                ? AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant
                                : AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: _getContentTypeIcon(
                                  module['contentType'] ?? 'video'),
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${module['duration'] ?? '15 min'} • ${_getContentTypeLabel(module['contentType'] ?? 'video')}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (isLocked) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            module['requirement'] ??
                                'Complete previous modules to unlock',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.error,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Expand/collapse icon
                  if (!isLocked)
                    CustomIconWidget(
                      iconName: isExpanded ? 'expand_less' : 'expand_more',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded && !isLocked)
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                  SizedBox(height: 2.h),

                  // Module description
                  Text(
                    module['description'] ??
                        'Learn essential concepts and practical skills in this comprehensive module.',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Preview/Start button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startModule(module),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.primary,
                      ),
                      child: Text(
                        isCompleted ? 'Review Module' : 'Start Module',
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

  void _toggleModule(int index) {
    setState(() {
      _expandedModuleIndex = _expandedModuleIndex == index ? null : index;
    });
  }

  void _startModule(Map<String, dynamic> module) {
    Navigator.pushNamed(context, '/learning-content-screen');
  }

  Color _getModuleStatusColor(bool isLocked, bool isCompleted) {
    if (isLocked) return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    if (isCompleted) return AppTheme.lightTheme.colorScheme.secondary;
    return AppTheme.lightTheme.colorScheme.primary;
  }

  String _getModuleStatusIcon(bool isLocked, bool isCompleted) {
    if (isLocked) return 'lock';
    if (isCompleted) return 'check';
    return 'play_arrow';
  }

  String _getContentTypeIcon(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'video':
        return 'play_circle_outline';
      case 'audio':
        return 'headphones';
      case 'text':
        return 'article';
      default:
        return 'play_circle_outline';
    }
  }

  String _getContentTypeLabel(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'text':
        return 'Reading';
      default:
        return 'Video';
    }
  }

  List<Map<String, dynamic>> _getDefaultModules() {
    return [
      {
        'title': 'Introduction to Financial Literacy',
        'description':
            'Get started with the basics of personal finance and money management.',
        'duration': '20 min',
        'contentType': 'video',
        'isLocked': false,
        'isCompleted': true,
      },
      {
        'title': 'Understanding Budgeting',
        'description':
            'Learn how to create and maintain an effective personal budget.',
        'duration': '25 min',
        'contentType': 'video',
        'isLocked': false,
        'isCompleted': false,
      },
      {
        'title': 'Saving Strategies',
        'description':
            'Discover different approaches to saving money and building an emergency fund.',
        'duration': '18 min',
        'contentType': 'audio',
        'isLocked': false,
        'isCompleted': false,
      },
      {
        'title': 'Investment Basics',
        'description':
            'Introduction to different investment options and risk management.',
        'duration': '30 min',
        'contentType': 'video',
        'isLocked': true,
        'isCompleted': false,
        'requirement': 'Complete "Saving Strategies" to unlock',
      },
      {
        'title': 'Credit and Debt Management',
        'description':
            'Understanding credit scores, loans, and effective debt management strategies.',
        'duration': '22 min',
        'contentType': 'text',
        'isLocked': true,
        'isCompleted': false,
        'requirement': 'Complete "Investment Basics" to unlock',
      },
    ];
  }
}
