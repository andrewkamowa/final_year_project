import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingBottomWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  const OnboardingBottomWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = currentPage == totalPages - 1;

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        children: [
          // Page Indicator
          Container(
            margin: EdgeInsets.only(bottom: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalPages,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  width: currentPage == index ? 8.w : 2.w,
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? (isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight)
                        : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    borderRadius: BorderRadius.circular(0.5.h),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip Button
              isLastPage
                  ? SizedBox(width: 20.w)
                  : TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),

              // Next/Get Started Button
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: isLastPage ? 0 : 4.w),
                  child: ElevatedButton(
                    onPressed: isLastPage ? onGetStarted : onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      foregroundColor: isDark
                          ? AppTheme.onPrimaryDark
                          : AppTheme.onPrimaryLight,
                      elevation: 2.0,
                      shadowColor:
                          isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? 'Start Learning' : 'Next',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.onPrimaryDark
                                : AppTheme.onPrimaryLight,
                          ),
                        ),
                        if (!isLastPage) ...[
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'arrow_forward',
                            color: isDark
                                ? AppTheme.onPrimaryDark
                                : AppTheme.onPrimaryLight,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
