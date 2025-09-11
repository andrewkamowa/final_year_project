import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuizCompletionModal extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String skillLevel;
  final String recommendedPath;
  final VoidCallback onContinue;

  const QuizCompletionModal({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.skillLevel,
    required this.recommendedPath,
    required this.onContinue,
  });
  // Navigation function declaration for the button click start learning to go to sign up screen
  void _navigateToRegistration(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final isHighScore = percentage >= 80;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        constraints: BoxConstraints(maxHeight: 70.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Animation
              Container(
                height: 15.h,
                width: 15.h,
                child: Lottie.asset(
                  isHighScore
                      ? 'https://assets2.lottiefiles.com/packages/lf20_touohxv0.json'
                      : 'https://assets9.lottiefiles.com/packages/lf20_s2lryxtd.json',
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isHighScore
                            ? Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withValues(alpha: 0.2)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName:
                              isHighScore ? 'celebration' : 'emoji_events',
                          color: isHighScore
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.primary,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 3.h),

              // Title
              Text(
                isHighScore ? 'Excellent Work!' : 'Assessment Complete!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),

              // Score Display
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    SizedBox(height: 1.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$score',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          TextSpan(
                            text: ' / $totalQuestions',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Skill Level
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Financial Literacy Level',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),

                    //skill level box

                    SizedBox(height: 1.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: _getSkillLevelColor(skillLevel, context)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        skillLevel,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getSkillLevelColor(skillLevel, context),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Recommended Path
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .tertiary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'lightbulb',
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Recommended Learning Path',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      recommendedPath,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToRegistration(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Start Learning Journey',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //To be used when i want to show users skill level

  Color _getSkillLevelColor(String level, BuildContext context) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Theme.of(context).colorScheme.error;
      case 'intermediate':
        return Theme.of(context).colorScheme.tertiary;
      case 'advanced':
        return Theme.of(context).colorScheme.primary;
      case 'expert':
        return const Color(0xFF38A169);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
