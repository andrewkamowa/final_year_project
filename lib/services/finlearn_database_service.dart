import '../models/achievement_model.dart';
import '../models/course_model.dart';
import '../models/enrollment_model.dart';
import '../models/quiz_model.dart';
import '../models/user_profile_model.dart';
import '../models/user_stats_model.dart';
import './supabase_service.dart';

class FinLearnDatabaseService {
  static final FinLearnDatabaseService _instance = FinLearnDatabaseService._();
  static FinLearnDatabaseService get instance => _instance;
  FinLearnDatabaseService._();

  final _client = SupabaseService.instance.client;

  // User Profile Methods
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<UserProfileModel?> updateUserProfile(UserProfileModel profile) async {
    try {
      final response = await _client
          .from('user_profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  // Course Methods
  Future<List<CourseModel>> getCourses({
    String? difficulty,
    String? searchQuery,
    String? sortBy,
    int? limit,
  }) async {
    try {
      var query = _client.from('courses').select('''
        *,
        user_profiles!courses_instructor_id_fkey(full_name)
      ''');

      if (difficulty != null && difficulty != 'All Courses') {
        query = query.eq('difficulty', difficulty);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Apply sorting
      final List<Map<String, dynamic>> response;
      switch (sortBy) {
        case 'Popular':
          response = await query.order('review_count', ascending: false);
          break;
        case 'Rating':
          response = await query.order('rating', ascending: false);
          break;
        case 'A-Z':
          response = await query.order('title', ascending: true);
          break;
        case 'Z-A':
          response = await query.order('title', ascending: false);
          break;
        default:
          response = await query.order('created_at', ascending: false);
      }

      final List<Map<String, dynamic>> finalResponse;
      if (limit != null) {
        finalResponse = response.take(limit).toList();
      } else {
        finalResponse = response;
      }

      return finalResponse.map((course) {
        final courseData = Map<String, dynamic>.from(course);
        if (courseData['user_profiles'] != null) {
          courseData['instructor_name'] =
              courseData['user_profiles']['full_name'];
        }
        courseData.remove('user_profiles');
        return CourseModel.fromJson(courseData);
      }).toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final response = await _client.from('courses').select('''
            *,
            user_profiles!courses_instructor_id_fkey(full_name)
          ''').eq('id', courseId).single();

      final courseData = Map<String, dynamic>.from(response);
      if (courseData['user_profiles'] != null) {
        courseData['instructor_name'] =
            courseData['user_profiles']['full_name'];
      }
      courseData.remove('user_profiles');

      return CourseModel.fromJson(courseData);
    } catch (e) {
      print('Error fetching course: $e');
      return null;
    }
  }

  // Enrollment Methods
  Future<List<EnrollmentModel>> getUserEnrollments(String userId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .order('enrolled_at', ascending: false);

      return response.map((e) => EnrollmentModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching enrollments: $e');
      return [];
    }
  }

  Future<EnrollmentModel?> getEnrollment(String userId, String courseId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .single();

      return EnrollmentModel.fromJson(response);
    } catch (e) {
      print('Error fetching enrollment: $e');
      return null;
    }
  }

  Future<EnrollmentModel?> enrollInCourse(
      String userId, String courseId) async {
    try {
      final response = await _client
          .from('enrollments')
          .insert({
            'user_id': userId,
            'course_id': courseId,
            'progress': 0.0,
            'is_completed': false,
            'is_bookmarked': false,
            'enrolled_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return EnrollmentModel.fromJson(response);
    } catch (e) {
      print('Error enrolling in course: $e');
      return null;
    }
  }

  Future<EnrollmentModel?> updateEnrollmentProgress(
    String userId,
    String courseId,
    double progress,
  ) async {
    try {
      final response = await _client
          .from('enrollments')
          .update({
            'progress': progress,
            'is_completed': progress >= 1.0,
            'updated_at': DateTime.now().toIso8601String(),
            'completed_at':
                progress >= 1.0 ? DateTime.now().toIso8601String() : null,
          })
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .select()
          .single();

      return EnrollmentModel.fromJson(response);
    } catch (e) {
      print('Error updating enrollment progress: $e');
      return null;
    }
  }

  Future<EnrollmentModel?> toggleBookmark(
      String userId, String courseId) async {
    try {
      final enrollment = await getEnrollment(userId, courseId);
      if (enrollment == null) return null;

      final response = await _client
          .from('enrollments')
          .update({
            'is_bookmarked': !enrollment.isBookmarked,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .select()
          .single();

      return EnrollmentModel.fromJson(response);
    } catch (e) {
      print('Error toggling bookmark: $e');
      return null;
    }
  }

  // Achievement Methods
  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      final response = await _client
          .from('achievements')
          .select()
          .eq('user_id', userId)
          .order('earned_date', ascending: false);

      return response.map((e) => AchievementModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  // User Stats Methods
  Future<UserStatsModel?> getUserStats(String userId) async {
    try {
      final response = await _client
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .single();

      return UserStatsModel.fromJson(response);
    } catch (e) {
      print('Error fetching user stats: $e');
      // Return default stats if none exist
      return UserStatsModel(
        userId: userId,
        coursesCompleted: 0,
        pointsEarned: 0,
        currentStreak: 0,
        certificatesObtained: 0,
        quizzesCompleted: 0,
        averageScore: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<UserStatsModel?> updateUserStats(UserStatsModel stats) async {
    try {
      final response = await _client
          .from('user_stats')
          .upsert(stats.toJson())
          .select()
          .single();

      return UserStatsModel.fromJson(response);
    } catch (e) {
      print('Error updating user stats: $e');
      return null;
    }
  }

  // Quiz Methods
  Future<List<QuizModel>> getCourseQuizzes(String courseId) async {
    try {
      final response = await _client.from('quizzes').select('''
            *,
            quiz_questions(*)
          ''').eq('course_id', courseId).eq('is_active', true);

      return response.map((quiz) {
        final quizData = Map<String, dynamic>.from(quiz);
        if (quizData['quiz_questions'] != null) {
          quizData['questions'] = quizData['quiz_questions'];
        }
        quizData.remove('quiz_questions');
        return QuizModel.fromJson(quizData);
      }).toList();
    } catch (e) {
      print('Error fetching course quizzes: $e');
      return [];
    }
  }

  // Dashboard specific methods
  Future<List<Map<String, dynamic>>> getRecentActivity(String userId) async {
    try {
      // Get recent enrollments and completions
      final enrollments = await _client
          .from('enrollments')
          .select('''
            *,
            courses(title)
          ''')
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(10);

      List<Map<String, dynamic>> activities = [];

      for (var enrollment in enrollments) {
        if (enrollment['is_completed']) {
          activities.add({
            'type': 'course_completed',
            'title': 'Course Completed',
            'description': enrollment['courses']['title'],
            'timestamp': DateTime.parse(
                enrollment['completed_at'] ?? enrollment['updated_at']),
            'points': 150,
          });
        } else if (enrollment['progress'] > 0) {
          activities.add({
            'type': 'course_progress',
            'title': 'Course Progress',
            'description':
                '${enrollment['courses']['title']} - ${(enrollment['progress'] * 100).round()}% complete',
            'timestamp': DateTime.parse(enrollment['updated_at']),
            'points': 25,
          });
        }
      }

      // Sort by timestamp
      activities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      return activities.take(5).toList();
    } catch (e) {
      print('Error fetching recent activity: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    try {
      final stats = await getUserStats(userId);
      if (stats == null) {
        return {
          'completed_courses': 0,
          'points_earned': 0,
          'current_level': 'Beginner',
          'achievements_count': 0,
        };
      }

      // Determine level based on points
      String level = 'Beginner';
      if (stats.pointsEarned >= 5000) {
        level = 'Expert';
      } else if (stats.pointsEarned >= 2000) {
        level = 'Pro';
      } else if (stats.pointsEarned >= 500) {
        level = 'Intermediate';
      }

      return {
        'completed_courses': stats.coursesCompleted,
        'points_earned': stats.pointsEarned,
        'current_level': level,
        'achievements_count': stats.certificatesObtained,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'completed_courses': 0,
        'points_earned': 0,
        'current_level': 'Beginner',
        'achievements_count': 0,
      };
    }
  }

  Future<EnrollmentModel?> getCurrentCourse(String userId) async {
    try {
      final response = await _client
          .from('enrollments')
          .select('''
            *,
            courses(*)
          ''')
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('updated_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      return EnrollmentModel.fromJson(response.first);
    } catch (e) {
      print('Error fetching current course: $e');
      return null;
    }
  }
}