import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/course_description_widget.dart';
import './widgets/course_header_widget.dart';
import './widgets/course_metrics_widget.dart';
import './widgets/course_modules_widget.dart';
import './widgets/prerequisites_widget.dart';
import './widgets/user_reviews_widget.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseData = _getCourseData();

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Course header with parallax effect
              SliverToBoxAdapter(
                child: CourseHeaderWidget(courseData: courseData),
              ),

              // Course content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Course metrics
                    CourseMetricsWidget(courseData: courseData),

                    // Course description
                    CourseDescriptionWidget(courseData: courseData),

                    // Prerequisites
                    PrerequisitesWidget(courseData: courseData),

                    // Course modules
                    CourseModulesWidget(courseData: courseData),

                    // User reviews
                    UserReviewsWidget(courseData: courseData),

                    // Bottom padding for sticky button
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),

          // Sticky bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: _buildActionButton(courseData),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> courseData) {
    final isEnrolled = courseData['isEnrolled'] ?? false;
    final progress = courseData['progress']?.toDouble() ?? 0.0;
    final isCompleted = progress >= 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress indicator for enrolled courses
        if (isEnrolled && progress > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Progress',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progress.toInt()}% Complete',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
        ],

        // Action button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: () => _handleButtonPress(courseData),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: isCompleted
                      ? 'replay'
                      : isEnrolled
                          ? 'play_arrow'
                          : 'school',
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  _getButtonText(isEnrolled, isCompleted, progress),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getButtonText(bool isEnrolled, bool isCompleted, double progress) {
    if (isCompleted) return 'Review Course';
    if (isEnrolled && progress > 0) return 'Continue Learning';
    if (isEnrolled) return 'Start Course';
    return 'Enroll Now';
  }

  void _handleButtonPress(Map<String, dynamic> courseData) {
    final isEnrolled = courseData['isEnrolled'] ?? false;
    final progress = courseData['progress']?.toDouble() ?? 0.0;
    final isCompleted = progress >= 100.0;

    if (!isEnrolled) {
      _showEnrollmentDialog();
    } else {
      Navigator.pushNamed(context, '/dashboard-screen');
    }
  }

  void _showEnrollmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enroll in Course',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to start your financial literacy journey?',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Lifetime access to course materials',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Certificate of completion',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'AI-powered learning assistance',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _enrollInCourse();
              },
              child: Text('Enroll Now'),
            ),
          ],
        );
      },
    );
  }

  void _enrollInCourse() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully enrolled in course!'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        duration: Duration(seconds: 3),
      ),
    );

    // Navigate to learning content after enrollment
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushNamed(context, '/learning-content-screen');
    });
  }

  Map<String, dynamic> _getCourseData() {
    return {
      'id': 'financial-literacy-101',
      'title': 'Complete Financial Literacy Masterclass',
      'heroImage':
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'difficulty': 'Beginner',
      'instructorName': 'Dr. Sarah Mitchell',
      'instructorAvatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'duration': '6h 45m',
      'lessonCount': 24,
      'rating': 4.8,
      'reviewCount': 1250,
      'isBookmarked': false,
      'isEnrolled': false,
      'progress': 0.0,
      'description':
          '''Master the fundamentals of personal finance with this comprehensive course designed for beginners. Learn essential money management skills, budgeting strategies, investment basics, and debt management techniques that will set you up for long-term financial success.

This course combines theoretical knowledge with practical applications, featuring real-world examples and interactive exercises. You'll gain confidence in making financial decisions and develop habits that lead to financial independence.

Perfect for young professionals, students, or anyone looking to take control of their financial future. No prior financial knowledge required - we start from the basics and build up to more advanced concepts.''',
      'learningPoints': [
        'Create and maintain a comprehensive personal budget',
        'Understand different types of savings and investment accounts',
        'Learn strategies for paying off debt efficiently',
        'Build an emergency fund and plan for major expenses',
        'Understand credit scores and how to improve them',
        'Make informed decisions about insurance and protection',
        'Set and achieve short-term and long-term financial goals',
      ],
      'prerequisites': [
        {
          'title': 'Basic Math Skills',
          'description':
              'Understanding of basic arithmetic operations and percentages',
          'skillLevel': 'Beginner',
          'isRequired': true,
          'isCompleted': true,
        },
        {
          'title': 'High School Education',
          'description': 'Basic reading comprehension and analytical thinking',
          'skillLevel': 'Beginner',
          'isRequired': true,
          'isCompleted': true,
        },
      ],
      'modules': [
        {
          'title': 'Introduction to Financial Literacy',
          'description':
              'Get started with the basics of personal finance and money management. Learn key terminology and concepts.',
          'duration': '25 min',
          'contentType': 'video',
          'isLocked': false,
          'isCompleted': false,
        },
        {
          'title': 'Understanding Your Money Mindset',
          'description':
              'Explore your relationship with money and identify limiting beliefs that may be holding you back.',
          'duration': '20 min',
          'contentType': 'audio',
          'isLocked': false,
          'isCompleted': false,
        },
        {
          'title': 'Creating Your First Budget',
          'description':
              'Learn step-by-step how to create a realistic budget that works for your lifestyle and goals.',
          'duration': '35 min',
          'contentType': 'video',
          'isLocked': false,
          'isCompleted': false,
        },
        {
          'title': 'Emergency Fund Essentials',
          'description':
              'Understand why emergency funds are crucial and how to build one systematically.',
          'duration': '18 min',
          'contentType': 'text',
          'isLocked': true,
          'isCompleted': false,
          'requirement': 'Complete "Creating Your First Budget" to unlock',
        },
        {
          'title': 'Debt Management Strategies',
          'description':
              'Learn proven methods for paying off debt efficiently and avoiding common pitfalls.',
          'duration': '30 min',
          'contentType': 'video',
          'isLocked': true,
          'isCompleted': false,
          'requirement': 'Complete "Emergency Fund Essentials" to unlock',
        },
      ],
      'reviews': [
        {
          'userName': 'Andrew Kamowa',
          'userAvatar':
              'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
          'rating': 5,
          'date': '1 week ago',
          'content':
              'This course completely transformed my approach to money management. Dr. Mitchell explains everything so clearly, and the practical exercises really helped me apply what I learned. I\'ve already started my emergency fund and feel so much more confident about my finances!',
          'helpfulVotes': 34,
        },
        {
          'userName': 'Lisa Namondwe',
          'userAvatar':
              'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
          'rating': 5,
          'date': '2 weeks ago',
          'content':
              'As someone who always avoided dealing with finances, this course made everything approachable and manageable. The budgeting section was a game-changer for me. Highly recommend to anyone starting their financial journey.',
          'helpfulVotes': 28,
        },
        {
          'userName': 'Ufulu Mavuto',
          'userAvatar':
              'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
          'rating': 4,
          'date': '3 weeks ago',
          'content':
              'Great course with solid fundamentals. The debt management strategies have already saved me money. Would love to see more advanced investment topics in a follow-up course.',
          'helpfulVotes': 22,
        },
        {
          'userName': 'Robert Malawi',
          'userAvatar':
              'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
          'rating': 5,
          'date': '1 month ago',
          'content':
              'Excellent value for money. The course is well-structured and the instructor is knowledgeable. The real-world examples made complex concepts easy to understand.',
          'helpfulVotes': 19,
        },
      ],
    };
  }
}
