import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuizNavigationButtons extends StatelessWidget {
  final bool canGoBack;
  final bool canGoNext;
  final bool isLastQuestion;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  const QuizNavigationButtons({
    super.key,
    required this.canGoBack,
    required this.canGoNext,
    required this.isLastQuestion,
    this.onPrevious,
    this.onNext,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          if (canGoBack) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'arrow_back_ios',
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Previous',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 3.w),
          ],
          Expanded(
            flex: canGoBack ? 2 : 1,
            child: ElevatedButton(
              onPressed:
                  canGoNext ? (isLastQuestion ? onSubmit : onNext) : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: canGoNext
                    ? (isLastQuestion
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.primary)
                    : Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastQuestion ? 'Submit Quiz' : 'Next Question',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: canGoNext
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                        ),
                  ),
                  if (!isLastQuestion) ...[
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'arrow_forward_ios',
                      color: canGoNext
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
