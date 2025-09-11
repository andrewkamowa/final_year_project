import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/answer_option_card.dart';
import './widgets/exit_confirmation_modal.dart';
import './widgets/question_card.dart';
import './widgets/quiz_completion_modal.dart';
import './widgets/quiz_navigation_buttons.dart';
import './widgets/quiz_progress_bar.dart';
import './widgets/quiz_timer.dart';

class AssessmentQuizScreen extends StatefulWidget {
  const AssessmentQuizScreen({super.key});

  @override
  State<AssessmentQuizScreen> createState() => _AssessmentQuizScreenState();
}

class _AssessmentQuizScreenState extends State<AssessmentQuizScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late Timer _timer;

  int _currentQuestionIndex = 0;
  Duration _remainingTime = const Duration(minutes: 20);
  Map<int, String> _selectedAnswers = {};
  bool _isQuizCompleted = false;

  // Mock quiz data
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      "id": 1,
      "type": "Multiple Choice",
      "question":
          "What is the recommended percentage of your income to save for emergencies?",
      "image": null,
      "options": [
        {"key": "A", "text": "5-10% of monthly income"},
        {"key": "B", "text": "10-15% of monthly income"},
        {"key": "C", "text": "15-20% of monthly income"},
        {"key": "D", "text": "3-6 months of living expenses"},
      ],
      "correctAnswer": "D"
    },
    {
      "id": 2,
      "type": "Scenario",
      "question":
          "Sarah earns \K4,000 per month and spends \K3,200. She wants to buy a car worth \K15,000. What should be her priority?",
      "image":
          "https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop",
      "options": [
        {"key": "A", "text": "Take a loan immediately for the car"},
        {"key": "B", "text": "Build emergency fund first, then save for car"},
        {"key": "C", "text": "Use credit cards to buy the car"},
        {"key": "D", "text": "Ask family for money"},
      ],
      "correctAnswer": "B"
    },
    {
      "id": 3,
      "type": "Definition",
      "question": "What does APR stand for in financial terms?",
      "image": null,
      "options": [
        {"key": "A", "text": "Annual Percentage Rate"},
        {"key": "B", "text": "Average Payment Ratio"},
        {"key": "C", "text": "Automatic Payment Reminder"},
        {"key": "D", "text": "Annual Profit Return"},
      ],
      "correctAnswer": "A"
    },
    {
      "id": 4,
      "type": "Calculation",
      "question":
          "If you invest \K1,000 at 5% annual interest compounded annually, how much will you have after 2 years?",
      "image": null,
      "options": [
        {"key": "A", "text": "\K1,050"},
        {"key": "B", "text": "\K1,100"},
        {"key": "C", "text": "\K1,102"},
        {"key": "D", "text": "\K1,125"},
      ],
      "correctAnswer": "C"
    },
    {
      "id": 5,
      "type": "True/False",
      "question":
          "Credit cards should be used for emergency expenses when you don't have an emergency fund.",
      "image": null,
      "options": [
        {"key": "A", "text": "True - Credit cards are good for emergencies"},
        {"key": "B", "text": "False - Build emergency fund first"},
      ],
      "correctAnswer": "B"
    },
    {
      "id": 6,
      "type": "Multiple Choice",
      "question": "What is the 50/30/20 budgeting rule?",
      "image": null,
      "options": [
        {"key": "A", "text": "50% needs, 30% wants, 20% savings"},
        {"key": "B", "text": "50% savings, 30% needs, 20% wants"},
        {"key": "C", "text": "50% wants, 30% savings, 20% needs"},
        {"key": "D", "text": "50% investments, 30% expenses, 20% emergency"},
      ],
      "correctAnswer": "A"
    },
    {
      "id": 7,
      "type": "Scenario",
      "question":
          "John has \K5,000 in credit card debt at 18% APR. He also has \K5,000 in savings earning 2% interest. What should he do?",
      "image":
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&h=400&fit=crop",
      "options": [
        {"key": "A", "text": "Keep savings and pay minimum on credit card"},
        {"key": "B", "text": "Use savings to pay off credit card debt"},
        {"key": "C", "text": "Invest the savings in stocks"},
        {"key": "D", "text": "Take another loan to pay credit card"},
      ],
      "correctAnswer": "B"
    },
    {
      "id": 8,
      "type": "Definition",
      "question": "What is diversification in investing?",
      "image": null,
      "options": [
        {"key": "A", "text": "Putting all money in one stock"},
        {"key": "B", "text": "Spreading investments across different assets"},
        {"key": "C", "text": "Only investing in bonds"},
        {"key": "D", "text": "Keeping money in savings account"},
      ],
      "correctAnswer": "B"
    },
    {
      "id": 9,
      "type": "Calculation",
      "question":
          "If inflation is 3% per year, what will \K100 be worth in purchasing power after 1 year?",
      "image": null,
      "options": [
        {"key": "A", "text": "\K103"},
        {"key": "B", "text": "\K100"},
        {"key": "C", "text": "\K97"},
        {"key": "D", "text": "\K95"},
      ],
      "correctAnswer": "C"
    },
    {
      "id": 10,
      "type": "Multiple Choice",
      "question": "What is the primary benefit of a 401(k) retirement plan?",
      "image": null,
      "options": [
        {"key": "A", "text": "Immediate access to funds"},
        {"key": "B", "text": "Tax advantages and employer matching"},
        {"key": "C", "text": "Guaranteed returns"},
        {"key": "D", "text": "No contribution limits"},
      ],
      "correctAnswer": "B"
    },
    {
      "id": 11,
      "type": "Scenario",
      "question":
          "Maria is 25 and wants to retire at 65. She can invest \K200 monthly. Which strategy is best for long-term growth?",
      "image":
          "https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=800&h=400&fit=crop",
      "options": [
        {"key": "A", "text": "Keep money in savings account"},
        {"key": "B", "text": "Invest in diversified index funds"},
        {"key": "C", "text": "Buy individual stocks only"},
        {"key": "D", "text": "Invest in bonds only"},
      ],
      "correctAnswer": "B"
    },
    {
      "id": 12,
      "type": "Definition",
      "question": "What is a credit score primarily based on?",
      "image": null,
      "options": [
        {"key": "A", "text": "Your income level"},
        {"key": "B", "text": "Your payment history and credit utilization"},
        {"key": "C", "text": "Your age and education"},
        {"key": "D", "text": "Your job title"},
      ],
      "correctAnswer": "B"
    },
    {
      "id": 13,
      "type": "True/False",
      "question":
          "It's better to pay off low-interest debt before building an emergency fund.",
      "image": null,
      "options": [
        {"key": "A", "text": "True - Always pay debt first"},
        {"key": "B", "text": "False - Emergency fund should come first"},
      ],
      "correctAnswer": "B"
    },
    {
      "id": 14,
      "type": "Calculation",
      "question":
          "If you have a credit card with \K2,000 balance at 20% APR and pay \K100 monthly, approximately how long to pay off?",
      "image": null,
      "options": [
        {"key": "A", "text": "20 months"},
        {"key": "B", "text": "24 months"},
        {"key": "C", "text": "26 months"},
        {"key": "D", "text": "30 months"},
      ],
      "correctAnswer": "C"
    },
    {
      "id": 15,
      "type": "Multiple Choice",
      "question":
          "What is the most important factor when choosing an investment?",
      "image": null,
      "options": [
        {"key": "A", "text": "Highest possible returns"},
        {"key": "B", "text": "Your risk tolerance and time horizon"},
        {"key": "C", "text": "What your friends are investing in"},
        {"key": "D", "text": "The latest market trends"},
      ],
      "correctAnswer": "B"
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  void _initializeQuiz() {
    _pageController = PageController();
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOut,
    ));

    _startTimer();
    _slideAnimationController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0 && !_isQuizCompleted) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      } else if (_remainingTime.inSeconds <= 0) {
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideAnimationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _selectAnswer(String answer) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _slideAnimationController.reset();
      _slideAnimationController.forward();
    }
  }

  void _navigateToRegistration() {
    Navigator.pushReplacementNamed(context, '/registration-screen');
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _slideAnimationController.reset();
      _slideAnimationController.forward();
    }
  }

  void _submitQuiz() {
    if (_isQuizCompleted) return;

    setState(() {
      _isQuizCompleted = true;
    });
    _timer.cancel();

    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < _quizQuestions.length; i++) {
      final selectedAnswer = _selectedAnswers[i];
      final correctAnswer = _quizQuestions[i]['correctAnswer'] as String;
      if (selectedAnswer == correctAnswer) {
        correctAnswers++;
      }
    }

    // Determine skill level
    final percentage = (correctAnswers / _quizQuestions.length * 100).round();
    String skillLevel;
    String recommendedPath;

    if (percentage >= 85) {
      skillLevel = 'Expert';
      recommendedPath =
          'Advanced investment strategies, tax optimization, and wealth management courses.';
    } else if (percentage >= 70) {
      skillLevel = 'Advanced';
      recommendedPath =
          'Investment fundamentals, retirement planning, and advanced budgeting techniques.';
    } else if (percentage >= 50) {
      skillLevel = 'Intermediate';
      recommendedPath =
          'Credit management, basic investing, and emergency fund building strategies.';
    } else {
      skillLevel = 'Beginner';
      recommendedPath =
          'Financial basics, budgeting fundamentals, and debt management essentials.';
    }

    // Show completion modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizCompletionModal(
        score: correctAnswers,
        totalQuestions: _quizQuestions.length,
        skillLevel: skillLevel,
        recommendedPath: recommendedPath,
        onContinue: _navigateToRegistration,
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ExitConfirmationModal(
        onConfirmExit: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final currentQuestion = _quizQuestions[_currentQuestionIndex];
    final selectedAnswer = _selectedAnswers[_currentQuestionIndex];
    final canGoNext = selectedAnswer != null;
    final canGoBack = _currentQuestionIndex > 0;
    final isLastQuestion = _currentQuestionIndex == _quizQuestions.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: _showExitConfirmation,
        ),
        title: Text(
          'Financial Assessment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: QuizTimer(
              remainingTime: _remainingTime,
              isActive: !_isQuizCompleted,
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          // Progress Bar
          QuizProgressBar(
            currentQuestion: _currentQuestionIndex + 1,
            totalQuestions: _quizQuestions.length,
          ),

          // Main Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _quizQuestions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final question = _quizQuestions[index];
                final options =
                    (question['options'] as List).cast<Map<String, dynamic>>();

                return SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),

                        // Question Card
                        QuestionCard(
                          question: question['question'] as String,
                          questionImage: question['image'] as String?,
                          questionType: question['type'] as String,
                        ),

                        SizedBox(height: 3.h),

                        // Answer Options
                        ...options.map((option) {
                          final optionKey = option['key'] as String;
                          final optionText = option['text'] as String;
                          final isSelected = selectedAnswer == optionKey;

                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: AnswerOptionCard(
                              option: optionKey,
                              optionText: optionText,
                              isSelected: isSelected,
                              onTap: () => _selectAnswer(optionKey),
                            ),
                          );
                        }).toList(),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation Buttons
          QuizNavigationButtons(
            canGoBack: canGoBack,
            canGoNext: canGoNext,
            isLastQuestion: isLastQuestion,
            onPrevious: canGoBack ? _previousQuestion : null,
            onNext: canGoNext && !isLastQuestion ? _nextQuestion : null,
            onSubmit: canGoNext && isLastQuestion ? _submitQuiz : null,
          ),
        ],
      ),
    );
  }
}
