import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuestionCardWidget extends StatelessWidget {
  final String question;
  final List<String> options;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;
  final String questionType;
  final TextEditingController? textController;

  const QuestionCardWidget({
    Key? key,
    required this.question,
    required this.options,
    this.selectedAnswer,
    required this.onAnswerSelected,
    this.questionType = 'multiple_choice',
    this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          SizedBox(height: 3.h),
          _buildAnswerOptions(),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    switch (questionType) {
      case 'true_false':
        return _buildTrueFalseOptions();
      case 'numerical':
        return _buildNumericalInput();
      default:
        return _buildMultipleChoiceOptions();
    }
  }

  Widget _buildMultipleChoiceOptions() {
    return Column(
      children: options.map((option) {
        final isSelected = selectedAnswer == option;
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 2.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onAnswerSelected(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              size: 3.w,
                            )
                          : null,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        option,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseButton('True', selectedAnswer == 'True'),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildTrueFalseButton('False', selectedAnswer == 'False'),
        ),
      ],
    );
  }

  Widget _buildTrueFalseButton(String value, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAnswerSelected(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericalInput() {
    return Container(
      width: double.infinity,
      child: TextField(
        controller: textController,
        keyboardType: TextInputType.number,
        onChanged: onAnswerSelected,
        decoration: InputDecoration(
          hintText: 'Enter your answer',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'calculate',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
        ),
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
