import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/audio_player_widget.dart';
import './widgets/completion_animation_widget.dart';
import './widgets/content_header_widget.dart';
import './widgets/navigation_controls_widget.dart';
import './widgets/notes_widget.dart';
import './widgets/text_content_widget.dart';
import './widgets/video_player_widget.dart';

class LearningContentScreen extends StatefulWidget {
  const LearningContentScreen({Key? key}) : super(key: key);

  @override
  State<LearningContentScreen> createState() => _LearningContentScreenState();
}

class _LearningContentScreenState extends State<LearningContentScreen> {
  // Mock lesson data
  final Map<String, dynamic> currentLesson = {
    "id": 1,
    "title": "Introduction to Personal Finance",
    "type": "video", // video, audio, text
    "content": {
      "video":
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      "audio": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "text":
          """Personal finance is the management of your money and financial decisions. It encompasses budgeting, saving, investing, and planning for your financial future.

Understanding personal finance is crucial for achieving financial stability and reaching your life goals. Whether you want to buy a house, start a business, or retire comfortably, good financial management is the foundation.

Key areas of personal finance include:

1. **Budgeting**: Creating a plan for how you'll spend and save your money each month. This helps you live within your means and allocate funds for your priorities.

2. **Emergency Fund**: Setting aside money for unexpected expenses like medical bills, car repairs, or job loss. Financial experts recommend saving 3-6 months of living expenses.

3. **Debt Management**: Understanding different types of debt and strategies to pay them off efficiently. This includes credit cards, student loans, and mortgages.

4. **Investing**: Growing your wealth over time through various investment vehicles like stocks, bonds, and mutual funds.

5. **Insurance**: Protecting yourself and your assets from financial risks through health, auto, home, and life insurance.

6. **Retirement Planning**: Preparing financially for your later years through employer-sponsored plans like 401(k)s and individual retirement accounts (IRAs).

The earlier you start managing your finances, the more time your money has to grow through compound interest. Even small amounts saved and invested regularly can lead to significant wealth over time.

Remember, personal finance is personal. What works for one person may not work for another. The key is to understand your own financial situation, set realistic goals, and create a plan that works for your lifestyle and circumstances.

Start with the basics: track your income and expenses, create a simple budget, and begin building an emergency fund. As you become more comfortable with these fundamentals, you can explore more advanced topics like investing and tax planning."""
    },
    "duration": "15 minutes",
    "hasNext": true,
    "hasPrevious": false,
  };

  double _progress = 0.0;
  bool _isBookmarked = false;
  bool _showCompletionAnimation = false;
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  void _loadSavedProgress() {
    // In a real app, this would load from local storage or API
    setState(() {
      _progress = 0.0;
      _isBookmarked = false;
      _notes = [
        {
          "content": "Remember to track all expenses for better budgeting",
          "timestamp":
              DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
        },
        {
          "content": "Emergency fund should be 3-6 months of expenses",
          "timestamp": null,
        },
      ];
    });
  }

  void _onProgressUpdate(double progress) {
    setState(() {
      _progress = progress;
    });

    // Auto-save progress
    _saveProgress(progress);

    // Show completion animation when reaching 95%
    if (progress >= 0.95 && !_showCompletionAnimation) {
      setState(() {
        _showCompletionAnimation = true;
      });
    }
  }

  void _saveProgress(double progress) {
    // In a real app, this would save to local storage or API
    print('Progress saved: ${(progress * 100).toInt()}%');
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    // In a real app, this would save to API
    print('Bookmark ${_isBookmarked ? 'added' : 'removed'}');
  }

  void _onBackTap() {
    Navigator.pop(context);
  }

  void _onPreviousTap() {
    if (currentLesson['hasPrevious'] as bool) {
      // Navigate to previous lesson
      print('Navigate to previous lesson');
    }
  }

  void _onNextTap() {
    if (currentLesson['hasNext'] as bool) {
      // Navigate to next lesson
      print('Navigate to next lesson');
    }
  }

  void _onQuizTap() {
    Navigator.pushNamed(context, '/quiz-screen');
  }

  void _onAddNote(String content, String? timestamp) {
    setState(() {
      _notes.add({
        "content": content,
        "timestamp": timestamp ?? DateTime.now().toIso8601String(),
      });
    });
  }

  void _onDeleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _onCompletionAnimationComplete() {
    setState(() {
      _showCompletionAnimation = false;
    });

    // Auto-advance to next lesson or quiz
    if (currentLesson['hasNext'] as bool) {
      _onNextTap();
    } else {
      _onQuizTap();
    }
  }

  Widget _buildContentWidget() {
    final contentType = currentLesson['type'] as String;
    final content = currentLesson['content'] as Map<String, dynamic>;

    switch (contentType) {
      case 'video':
        return VideoPlayerWidget(
          videoUrl: content['video'] as String,
          onProgressUpdate: _onProgressUpdate,
          initialProgress: _progress,
        );
      case 'audio':
        return AudioPlayerWidget(
          audioUrl: content['audio'] as String,
          onProgressUpdate: _onProgressUpdate,
          initialProgress: _progress,
        );
      case 'text':
        return Expanded(
          child: TextContentWidget(
            content: content['text'] as String,
            onProgressUpdate: _onProgressUpdate,
            initialProgress: _progress,
          ),
        );
      default:
        return Container(
          height: 50.h,
          child: Center(
            child: Text(
              'Unsupported content type',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              ContentHeaderWidget(
                lessonTitle: currentLesson['title'] as String,
                progress: _progress,
                isBookmarked: _isBookmarked,
                onBookmarkTap: _toggleBookmark,
                onBackTap: _onBackTap,
              ),

              // Content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),

                      // Main content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          children: [
                            _buildContentWidget(),
                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),

                      // Notes section
                      NotesWidget(
                        notes: _notes,
                        onAddNote: _onAddNote,
                        onDeleteNote: _onDeleteNote,
                      ),

                      // Bottom spacing for navigation controls
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom navigation controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavigationControlsWidget(
              hasPrevious: currentLesson['hasPrevious'] as bool,
              hasNext: currentLesson['hasNext'] as bool,
              onPreviousTap: _onPreviousTap,
              onNextTap: _onNextTap,
              onQuizTap: _onQuizTap,
            ),
          ),

          // Completion animation overlay
          if (_showCompletionAnimation)
            CompletionAnimationWidget(
              onAnimationComplete: _onCompletionAnimationComplete,
            ),
        ],
      ),
    );
  }
}
