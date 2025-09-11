import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptySearchState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;
  final ValueChanged<String>? onSuggestionTap;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          // Empty state icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'search_off',
                size: 40,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          // Title
          Text(
            'No courses found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          // Subtitle
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'No results for '),
                TextSpan(
                  text: '"$searchQuery"',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const TextSpan(
                    text:
                        '\nTry adjusting your search or browse our suggestions below'),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClearSearch,
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: const Text('Clear Search'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to browse all courses
                    onSuggestionTap?.call('');
                  },
                  icon: CustomIconWidget(
                    iconName: 'explore',
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text('Browse All'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          // Search suggestions
          _buildSearchSuggestions(theme),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(ThemeData theme) {
    final suggestions = [
      'Personal Finance',
      'Investment Basics',
      'Budgeting 101',
      'Retirement Planning',
      'Stock Market',
      'Cryptocurrency',
      'Real Estate',
      'Tax Planning',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Try searching for:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: suggestions.map((suggestion) {
            return ActionChip(
              label: Text(
                suggestion,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              onPressed: () => onSuggestionTap?.call(suggestion),
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              avatar: CustomIconWidget(
                iconName: 'search',
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 4.h),
        // Tips section
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'lightbulb_outline',
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Search Tips',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                '• Try different keywords or phrases\n'
                '• Use broader terms like "investing" instead of specific terms\n'
                '• Check your spelling\n'
                '• Browse by difficulty level using the filter chips above',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
