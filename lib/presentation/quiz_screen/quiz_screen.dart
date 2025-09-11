import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/feedback_widget.dart';
import './widgets/hint_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/question_card_widget.dart';
import './widgets/results_summary_widget.dart';
import './widgets/timer_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  int _currentQuestionIndex = 0;
  int _totalScore = 0;
  int _correctAnswers = 0;
  bool _showFeedback = false;
  bool _quizCompleted = false;
  int _remainingTime = 300; // 5 minutes
  bool _timerActive = true;

  final TextEditingController _numericalController = TextEditingController();
  final Map<int, String> _userAnswers = {};
  final Map<int, bool> _answeredCorrectly = {};

  // Mock quiz data
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      "id": 1,
      "question":
          "What is the recommended percentage of income to save for emergency funds?",
      "type": "multiple_choice",
      "options": ["10-15%", "20-25%", "30-35%", "5-10%"],
      "correct_answer": "20-25%",
      "explanation":
          "Financial experts recommend saving 20-25% of your income for emergency funds to cover 3-6 months of expenses.",
      "concept_reference": "Emergency Fund Planning",
      "points": 10,
      "hints": [
        "Think about covering several months of expenses",
        "It's more than just a small percentage",
        "Most experts suggest between 20-30%"
      ]
    },
    {
      "id": 2,
      "question": "Compound interest works better over longer time periods.",
      "type": "true_false",
      "options": ["True", "False"],
      "correct_answer": "True",
      "explanation":
          "Compound interest benefits from time as interest earns interest, creating exponential growth over longer periods.",
      "concept_reference": "Compound Interest Fundamentals",
      "points": 8,
      "hints": [
        "Consider how interest builds on itself",
        "Time is a key factor in compound growth"
      ]
    },
    {
      "id": 3,
      "question":
          "If you invest \$1,000 at 5% annual interest compounded annually, how much will you have after 2 years? (Round to nearest dollar)",
      "type": "numerical",
      "options": [],
      "correct_answer": "1103",
      "explanation":
          "Using the compound interest formula: \$1,000 × (1.05)² = \$1,102.50, rounded to \$1,103.",
      "concept_reference": "Compound Interest Calculations",
      "points": 15,
      "hints": [
        "Use the formula A = P(1 + r)^t",
        "P = \$1,000, r = 0.05, t = 2",
        "Calculate \$1,000 × 1.05 × 1.05"
      ]
    },
    {
      "id": 4,
      "question":
          "Which investment strategy involves buying a mix of different asset types to reduce risk?",
      "type": "multiple_choice",
      "options": [
        "Dollar-cost averaging",
        "Diversification",
        "Value investing",
        "Day trading"
      ],
      "correct_answer": "Diversification",
      "explanation":
          "Diversification involves spreading investments across different asset classes to reduce overall portfolio risk.",
      "concept_reference": "Investment Risk Management",
      "points": 12,
      "hints": [
        "This strategy is about not putting all eggs in one basket",
        "It involves mixing different types of investments",
        "The goal is to reduce risk through variety"
      ]
    },
    {
      "id": 5,
      "question": "A credit score of 750 is considered excellent.",
      "type": "true_false",
      "options": ["True", "False"],
      "correct_answer": "True",
      "explanation":
          "Credit scores range from 300-850, with 750+ generally considered excellent by most lenders.",
      "concept_reference": "Credit Score Ranges",
      "points": 8,
      "hints": [
        "Credit scores go up to 850",
        "750 is in the higher range of scores"
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _celebrationController.dispose();
    _numericalController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_timerActive && _remainingTime > 0 && !_quizCompleted && mounted) {
        setState(() {
          _remainingTime--;
        });
        _startTimer();
      } else if (_remainingTime <= 0 && !_quizCompleted) {
        _completeQuiz();
      }
    });
  }

  void _onAnswerSelected(String answer) {
    if (_showFeedback) return;

    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  void _submitAnswer() {
    if (_userAnswers[_currentQuestionIndex] == null) return;

    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final userAnswer = _userAnswers[_currentQuestionIndex]!;
    final correctAnswer = currentQuestion["correct_answer"] as String;
    final isCorrect = _checkAnswer(
        userAnswer, correctAnswer, currentQuestion["type"] as String);

    setState(() {
      _answeredCorrectly[_currentQuestionIndex] = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
        _totalScore += currentQuestion["points"] as int;
        _celebrationController.forward().then((_) {
          _celebrationController.reset();
        });
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
      _showFeedback = true;
    });
  }

  bool _checkAnswer(
      String userAnswer, String correctAnswer, String questionType) {
    if (questionType == "numerical") {
      final userNum = double.tryParse(userAnswer) ?? 0;
      final correctNum = double.tryParse(correctAnswer) ?? 0;
      return (userNum - correctNum).abs() <= 5; // Allow 5 unit tolerance
    }
    return userAnswer.toLowerCase().trim() ==
        correctAnswer.toLowerCase().trim();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showFeedback = false;
        _numericalController.clear();
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _showFeedback = false;
        final currentQuestion = _quizQuestions[_currentQuestionIndex];
        if (currentQuestion["type"] == "numerical") {
          _numericalController.text = _userAnswers[_currentQuestionIndex] ?? "";
        }
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
      _timerActive = false;
    });
  }

  void _retryQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _totalScore = 0;
      _correctAnswers = 0;
      _showFeedback = false;
      _quizCompleted = false;
      _remainingTime = 300;
      _timerActive = true;
      _userAnswers.clear();
      _answeredCorrectly.clear();
      _numericalController.clear();
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _startTimer();
  }

  void _continueToNextContent() {
    Navigator.pushReplacementNamed(context, '/learning-content-screen');
  }

  Map<String, int> _getTopicBreakdown() {
    final Map<String, List<bool>> topicResults = {};

    for (int i = 0; i < _quizQuestions.length; i++) {
      final concept = _quizQuestions[i]["concept_reference"] as String;
      final isCorrect = _answeredCorrectly[i] ?? false;

      if (!topicResults.containsKey(concept)) {
        topicResults[concept] = [];
      }
      topicResults[concept]!.add(isCorrect);
    }

    final Map<String, int> breakdown = {};
    topicResults.forEach((topic, results) {
      final correctCount = results.where((result) => result).length;
      final percentage = (correctCount / results.length * 100).round();
      breakdown[topic] = percentage;
    });

    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Quiz Results',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: ResultsSummaryWidget(
              totalScore: _totalScore,
              correctAnswers: _correctAnswers,
              totalQuestions: _quizQuestions.length,
              topicBreakdown: _getTopicBreakdown(),
              onRetry: _retryQuiz,
              onContinue: _continueToNextContent,
            ),
          ),
        ),
      );
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final progressPercentage =
        ((_currentQuestionIndex + 1) / _quizQuestions.length) * 100;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Financial Literacy Quiz',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: TimerWidget(
              remainingTime: _remainingTime,
              isUrgent: _remainingTime <= 60,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ProgressIndicatorWidget(
              currentQuestion: _currentQuestionIndex + 1,
              totalQuestions: _quizQuestions.length,
              progressPercentage: progressPercentage,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    AnimatedBuilder(
                      animation: _celebrationAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_celebrationAnimation.value * 0.1),
                          child: QuestionCardWidget(
                            question: currentQuestion["question"] as String,
                            options: (currentQuestion["options"] as List)
                                .cast<String>(),
                            selectedAnswer: _userAnswers[_currentQuestionIndex],
                            onAnswerSelected: _onAnswerSelected,
                            questionType: currentQuestion["type"] as String,
                            textController:
                                currentQuestion["type"] == "numerical"
                                    ? _numericalController
                                    : null,
                          ),
                        );
                      },
                    ),
                    if (!_showFeedback) ...[
                      HintWidget(
                        hints:
                            (currentQuestion["hints"] as List).cast<String>(),
                        onHintUsed: () {
                          HapticFeedback.lightImpact();
                        },
                      ),
                      SizedBox(height: 2.h),
                    ],
                    if (_showFeedback) ...[
                      FeedbackWidget(
                        isCorrect:
                            _answeredCorrectly[_currentQuestionIndex] ?? false,
                        explanation: currentQuestion["explanation"] as String,
                        conceptReference:
                            currentQuestion["concept_reference"] as String,
                        pointsEarned:
                            _answeredCorrectly[_currentQuestionIndex] == true
                                ? currentQuestion["points"] as int
                                : 0,
                        onContinue: _nextQuestion,
                      ),
                    ],
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
            if (!_showFeedback)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow
                          .withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentQuestionIndex > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousQuestion,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'arrow_back',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Previous',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                    ],
                    Expanded(
                      flex: _currentQuestionIndex > 0 ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: _userAnswers[_currentQuestionIndex] != null
                            ? _submitAnswer
                            : null,
                        child: Text(
                          'Submit Answer',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
