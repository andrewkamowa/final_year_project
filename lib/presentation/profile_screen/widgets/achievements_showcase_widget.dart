import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AchievementsShowcaseWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final List<Map<String, dynamic>> certificates;
  final VoidCallback onViewAllAchievements;
  final VoidCallback onViewAllCertificates;

  const AchievementsShowcaseWidget({
    super.key,
    required this.achievements,
    required this.certificates,
    required this.onViewAllAchievements,
    required this.onViewAllCertificates,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements & Certificates',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onViewAllAchievements,
                child: Text(
                  'View All',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildAchievementsBadges(context),
          SizedBox(height: 3.h),
          _buildCertificatesSection(context),
        ],
      ),
    );
  }

  Widget _buildAchievementsBadges(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Badges',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 20.w,
          child: achievements.isEmpty
              ? _buildEmptyState(context, 'No badges earned yet')
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: achievements.length > 5 ? 5 : achievements.length,
                  separatorBuilder: (context, index) => SizedBox(width: 3.w),
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return _buildAchievementBadge(context, achievement);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
      BuildContext context, Map<String, dynamic> achievement) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showAchievementDetails(context, achievement),
      child: Container(
        width: 20.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getBadgeColor(achievement['type'] as String)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: achievement['icon'] as String,
                size: 6.w,
                color: _getBadgeColor(achievement['type'] as String),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              achievement['name'] as String,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Certificates',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (certificates.isNotEmpty)
              TextButton(
                onPressed: onViewAllCertificates,
                child: Text(
                  'View All',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 1.h),
        certificates.isEmpty
            ? _buildEmptyState(context, 'No certificates earned yet')
            : Column(
                children: certificates.take(3).map((certificate) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: _buildCertificateCard(context, certificate),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildCertificateCard(
      BuildContext context, Map<String, dynamic> certificate) {
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
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'workspace_premium',
              size: 6.w,
              color: Colors.amber,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate['courseName'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Completed on ${certificate['completionDate']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _downloadCertificate(context, certificate),
            icon: CustomIconWidget(
              iconName: 'download',
              size: 5.w,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'emoji_events',
            size: 8.w,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(String type) {
    switch (type) {
      case 'streak':
        return Colors.orange;
      case 'completion':
        return Colors.green;
      case 'points':
        return Colors.blue;
      case 'special':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAchievementDetails(
      BuildContext context, Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: _getBadgeColor(achievement['type'] as String)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: achievement['icon'] as String,
                size: 10.w,
                color: _getBadgeColor(achievement['type'] as String),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              achievement['description'] as String,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Earned on ${achievement['earnedDate']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _downloadCertificate(
      BuildContext context, Map<String, dynamic> certificate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Downloading certificate for ${certificate['courseName']}...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Handle certificate viewing
          },
        ),
      ),
    );
  }
}
