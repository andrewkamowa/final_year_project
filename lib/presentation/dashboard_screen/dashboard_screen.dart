import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/auth_service.dart';
import '../../services/finlearn_database_service.dart';
import '../../models/user_profile_model.dart';
import '../../models/enrollment_model.dart';
import './widgets/continue_learning_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/learning_streak_card_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/recommended_courses_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRefreshing = false;
  bool _isLoading = true;

  // User data from Supabase

  UserProfileModel? _userProfile;
  Map<String, dynamic> _dashboardStats = {};
  EnrollmentModel? _currentCourse;
  List<Map<String, dynamic>> _quickStats = [];
  List<Map<String, dynamic>> _recommendedCourses = [];
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) {
        Navigator.pushReplacementNamed(context, '/onboarding-flow');
        return;
      }

      // Load all dashboard data in parallel

      final futures = await Future.wait([
        AuthService.instance.getUserProfile(),
        FinLearnDatabaseService.instance.getDashboardStats(userId),
        FinLearnDatabaseService.instance.getCurrentCourse(userId),
        FinLearnDatabaseService.instance.getRecentActivity(userId),
        FinLearnDatabaseService.instance.getCourses(limit: 3),
      ]);

      if (mounted) {
        setState(() {
          _userProfile = futures[0] as UserProfileModel?;
          _dashboardStats = futures[1] as Map<String, dynamic>;
          _currentCourse = futures[2] as EnrollmentModel?;
          _recentActivities = futures[3] as List<Map<String, dynamic>>;
          _recommendedCourses = (futures[4] as List)
              .map((course) => {
                    'id': course.id,
                    'title': course.title,
                    'instructor': course.instructorName ?? 'Unknown',
                    'image': course.thumbnailUrl ??
                        'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
                    'difficulty': course.difficulty,
                    'duration': course.duration,
                    'rating': course.rating,
                    'isBookmarked': false,
                  })
              .toList();

          _quickStats = [
            {
              "icon": "school",
              "value": "${_dashboardStats['completed_courses'] ?? 0}",
              "label": "Completed Courses",
              "color": Colors.blue,
            },
            {
              "icon": "stars",
              "value": "${_dashboardStats['points_earned'] ?? 0}",
              "label": "Points Earned",
              "color": Colors.amber,
            },
            {
              "icon": "trending_up",
              "value": _dashboardStats['current_level'] ?? 'Beginner',
              "label": "Current Level",
              "color": Colors.green,
            },
            {
              "icon": "emoji_events",
              "value": "${_dashboardStats['achievements_count'] ?? 0}",
              "label": "Achievements",
              "color": Colors.purple,
            },
          ];

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppBar(
          variant: CustomAppBarVariant.withActions,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
        bottomNavigationBar: const CustomBottomBar(
          currentIndex: 0,
          variant: CustomBottomBarVariant.standard,
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        variant: CustomAppBarVariant.withActions,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Header
              GreetingHeaderWidget(
                userName: _userProfile?.fullName ?? 'User',
                onNotificationTap: _handleNotificationTap,
              ),

              // Learning Streak Card
              LearningStreakCardWidget(
                streakDays: _dashboardStats['current_streak'] ?? 0,
                progressPercentage: 75.0, // This could come from daily goals
                motivationalMessage: _getMotivationalMessage(),
              ),

              // Continue Learning Section
              if (_currentCourse != null)
                ContinueLearningWidget(
                  courseData: {
                    "id": _currentCourse!.courseId,
                    "title":
                        "Personal Finance Fundamentals", // You might want to join with course data
                    "instructor": "Loading...",
                    "thumbnail":
                        "https://images.unsplash.com/photo-1554224155-6726b3ff858f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
                    "progress": _currentCourse!.progress,
                  },
                  onResumeTap: _handleResumeCourse,
                ),

              // Quick Stats
              QuickStatsWidget(
                statsData: _quickStats,
              ),

              // Recommended Courses
              RecommendedCoursesWidget(
                recommendedCourses: _recommendedCourses,
                onCourseTap: _handleCourseTap,
                onBookmarkTap: _handleBookmarkTap,
              ),

              // Recent Activity
              RecentActivityWidget(
                activities: _recentActivities,
              ),

              // Bottom padding for floating action button
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 0,
        variant: CustomBottomBarVariant.standard,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleStartNewCourse,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'Start New Course',
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  String _getMotivationalMessage() {
    final streak = _dashboardStats['current_streak'] ?? 0;
    if (streak >= 10) return "You're on fire! Keep the streak alive!";
    if (streak >= 5) return "Great consistency! Keep it up!";
    if (streak >= 3) return "Building momentum! Nice work!";
    return "Ready to start your learning journey?";
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadDashboardData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _handleNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleResumeCourse() {
    Navigator.pushNamed(context, '/course-catalog-screen');
  }

  void _handleCourseTap(Map<String, dynamic> course) {
    Navigator.pushNamed(context, '/course-detail-screen');
  }

  Future<void> _handleBookmarkTap(Map<String, dynamic> course) async {
    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) return;

      await FinLearnDatabaseService.instance
          .toggleBookmark(userId, course['id']);

      setState(() {
        course['isBookmarked'] = !(course['isBookmarked'] as bool? ?? false);
      });

      final isBookmarked = course['isBookmarked'] as bool;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBookmarked
                  ? 'Course bookmarked successfully'
                  : 'Course removed from bookmarks',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating bookmark: $e')),
        );
      }
    }
  }

  void _handleStartNewCourse() {
    Navigator.pushNamed(context, '/course-catalog-screen');
  }
}
