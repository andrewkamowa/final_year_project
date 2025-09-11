import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PreferencesSectionWidget extends StatelessWidget {
  final String selectedContentType;
  final bool notificationsEnabled;
  final bool courseRemindersEnabled;
  final bool achievementNotificationsEnabled;
  final ValueChanged<String> onContentTypeChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onCourseRemindersChanged;
  final ValueChanged<bool> onAchievementNotificationsChanged;

  const PreferencesSectionWidget({
    super.key,
    required this.selectedContentType,
    required this.notificationsEnabled,
    required this.courseRemindersEnabled,
    required this.achievementNotificationsEnabled,
    required this.onContentTypeChanged,
    required this.onNotificationsChanged,
    required this.onCourseRemindersChanged,
    required this.onAchievementNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Preferences',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildContentTypeSelector(context),
          SizedBox(height: 3.h),
          _buildNotificationSettings(context),
        ],
      ),
    );
  }

  Widget _buildContentTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final contentTypes = ['Video', 'Audio', 'Text'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Content Type',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: contentTypes.map((type) {
              final isSelected = selectedContentType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onContentTypeChanged(type),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: _getContentTypeIcon(type),
                          size: 4.w,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          type,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Settings',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        _buildNotificationToggle(
          context,
          'Push Notifications',
          'Receive general app notifications',
          'notifications',
          notificationsEnabled,
          onNotificationsChanged,
        ),
        SizedBox(height: 1.h),
        _buildNotificationToggle(
          context,
          'Course Reminders',
          'Get reminded about your learning schedule',
          'schedule',
          courseRemindersEnabled,
          onCourseRemindersChanged,
        ),
        SizedBox(height: 1.h),
        _buildNotificationToggle(
          context,
          'Achievement Alerts',
          'Celebrate your learning milestones',
          'emoji_events',
          achievementNotificationsEnabled,
          onAchievementNotificationsChanged,
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              size: 5.w,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _getContentTypeIcon(String type) {
    switch (type) {
      case 'Video':
        return 'play_circle';
      case 'Audio':
        return 'headphones';
      case 'Text':
        return 'article';
      default:
        return 'help';
    }
  }
}
