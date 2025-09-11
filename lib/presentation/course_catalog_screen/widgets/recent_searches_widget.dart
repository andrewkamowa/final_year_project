import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentSearchesWidget extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onSearchTap;
  final ValueChanged<String> onSearchRemove;

  const RecentSearchesWidget({
    super.key,
    required this.recentSearches,
    required this.onSearchTap,
    required this.onSearchRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recentSearches.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Clear all recent searches
                  for (String search in recentSearches) {
                    onSearchRemove(search);
                  }
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSearches.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final search = recentSearches[index];
              return InkWell(
                onTap: () => onSearchTap(search),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'history',
                        size: 20,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          search,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onSearchRemove(search),
                        icon: CustomIconWidget(
                          iconName: 'close',
                          size: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          CustomIconWidget(
            iconName: 'search',
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Text(
            'No recent searches',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start searching to see your recent searches here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          _buildPopularSearches(theme),
        ],
      ),
    );
  }

  Widget _buildPopularSearches(ThemeData theme) {
    final popularSearches = [
      'Budgeting basics',
      'Investment strategies',
      'Retirement planning',
      'Tax optimization',
      'Emergency fund',
      'Stock market',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Searches',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: popularSearches.map((search) {
            return ActionChip(
              label: Text(
                search,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.primary,
                ),
              ),
              onPressed: () => onSearchTap(search),
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
