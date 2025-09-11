import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_bottom_widget.dart';
import './widgets/onboarding_page_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;
  bool _userInteracted = false;

  // Mock data for onboarding pages
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Personalized Learning Paths",
      "description":
          "Discover financial concepts tailored to your skill level. Our adaptive system creates custom learning journeys from beginner to expert.",
      "imageUrl":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8ZGF0YSUyMGFuYWx5dGljc3xlbnwwfHwwfHx8MA%3D%3D",
    },
    {
      "title": "AI-Powered Zachuma Financial Assistant",
      "description":
          "Get instant answers to your financial questions. Our intelligent chatbot provides personalized guidance and explanations 24/7.",
      "imageUrl":
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8YWklMjBjaGF0Ym90fGVufDB8fDB8fHww",
    },
    {
      "title": "Track Your Progress",
      "description":
          "Monitor your financial literacy journey with detailed analytics, achievements, and personalized recommendations for continuous improvement.",
      "imageUrl":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZ3Jlc3MlMjB0cmFja2luZ3xlbnwwfHwwfHx8MA%3D%3D",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startAutoAdvanceTimer();
  }

  void _initializeControllers() {
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!_userInteracted && mounted) {
        _nextPage();
      }
    });
  }

  void _pauseAutoAdvance() {
    setState(() {
      _userInteracted = true;
    });
    _autoAdvanceTimer?.cancel();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _pauseAutoAdvance();
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/assessment-quiz-screen');
  }

  void _handleNext() {
    _pauseAutoAdvance();
    HapticFeedback.lightImpact();

    if (_currentPage < _onboardingData.length - 1) {
      _nextPage();
    }
  }

  void _handleGetStarted() {
    _pauseAutoAdvance();
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, '/assessment-quiz-screen');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    if (!_userInteracted) {
      _startAutoAdvanceTimer();
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: GestureDetector(
          onTap: _pauseAutoAdvance,
          onPanStart: (_) => _pauseAutoAdvance(),
          child: Column(
            children: [
              // Main Content Area
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final pageData = _onboardingData[index];
                    return OnboardingPageWidget(
                      title: pageData["title"] as String,
                      description: pageData["description"] as String,
                      imageUrl: pageData["imageUrl"] as String,
                      isLastPage: index == _onboardingData.length - 1,
                    );
                  },
                ),
              ),

              // Bottom Navigation Area
              OnboardingBottomWidget(
                currentPage: _currentPage,
                totalPages: _onboardingData.length,
                onSkip: _skipOnboarding,
                onNext: _handleNext,
                onGetStarted: _handleGetStarted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
