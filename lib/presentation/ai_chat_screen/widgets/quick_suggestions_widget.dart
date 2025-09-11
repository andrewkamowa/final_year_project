import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickSuggestionsWidget extends StatelessWidget {
  final Function(String) onSuggestionTap;
  final bool isVisible;

  const QuickSuggestionsWidget({
    super.key,
    required this.onSuggestionTap,
    this.isVisible = true,
  });

  static const List<Map<String, dynamic>> _suggestions = [
    {
      'text': 'How to create a budget?',
      'icon': 'account_balance_wallet',
      'category': 'Budgeting',
    },
    {
      'text': 'Investment basics for beginners',
      'icon': 'trending_up',
      'category': 'Investing',
    },
    {
      'text': 'Debt management strategies',
      'icon': 'credit_card_off',
      'category': 'Debt Management',
    },
    {
      'text': 'Emergency fund planning',
      'icon': 'savings',
      'category': 'Savings',
    },
    {
      'text': 'Understanding credit scores',
      'icon': 'credit_score',
      'category': 'Credit',
    },
    {
      'text': 'Retirement planning tips',
      'icon': 'elderly',
      'category': 'Retirement',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return SizedBox.shrink();

    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick suggestions',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestions.map((suggestion) {
                return _buildSuggestionChip(
                  context,
                  suggestion['text'] as String,
                  suggestion['icon'] as String,
                  suggestion['category'] as String,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String text,
    String iconName,
    String category,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(right: 3.w),
      child: GestureDetector(
        onTap: () => onSuggestionTap(text),
        child: Container(
          constraints: BoxConstraints(maxWidth: 60.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(6.w),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: theme.colorScheme.primary,
                      size: 4.w,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Text(
                      category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
