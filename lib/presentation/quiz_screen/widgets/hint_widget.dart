import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HintWidget extends StatefulWidget {
  final List<String> hints;
  final VoidCallback? onHintUsed;

  const HintWidget({
    Key? key,
    required this.hints,
    this.onHintUsed,
  }) : super(key: key);

  @override
  State<HintWidget> createState() => _HintWidgetState();
}

class _HintWidgetState extends State<HintWidget> {
  int _currentHintIndex = -1;
  bool _isExpanded = false;

  void _showNextHint() {
    if (_currentHintIndex < widget.hints.length - 1) {
      setState(() {
        _currentHintIndex++;
        _isExpanded = true;
      });
      widget.onHintUsed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _currentHintIndex < widget.hints.length - 1
                  ? _showNextHint
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'help',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        _currentHintIndex < widget.hints.length - 1
                            ? 'Need a hint? Tap here'
                            : 'All hints used',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.lightTheme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    if (_currentHintIndex >= 0)
                      Text(
                        '${_currentHintIndex + 1}/${widget.hints.length}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: AppTheme.lightTheme.colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded && _currentHintIndex >= 0) ...[
            SizedBox(height: 1.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Hint ${_currentHintIndex + 1}',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _isExpanded = false),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.all(1.w),
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              size: 4.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    widget.hints[_currentHintIndex],
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
