import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class CourseService {
  static CourseService? _instance;
  static CourseService get instance => _instance ??= CourseService._();

  CourseService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all published courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _client.from('courses').select('''
            *,
            instructors:instructor_id (
              user_profiles:user_id (
                full_name,
                avatar_url
              )
            )
          ''').eq('status', 'published').order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch courses: $error');
    }
  }

  // Get course details with modules
  Future<Map<String, dynamic>?> getCourseDetails(String courseId) async {
    try {
      final response = await _client.from('courses').select('''
            *,
            instructors:instructor_id (
              bio,
              rating,
              total_students,
              user_profiles:user_id (
                full_name,
                avatar_url
              )
            ),
            course_modules (
              *
            )
          ''').eq('id', courseId).eq('status', 'published').single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch course details: $error');
    }
  }

  // Check if user is enrolled in course
  Future<Map<String, dynamic>?> getUserEnrollment(String courseId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('enrollments')
          .select('*')
          .eq('user_id', user.id)
          .eq('course_id', courseId)
          .maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to check enrollment: $error');
    }
  }

  // Enroll user in course
  Future<void> enrollInCourse(String courseId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('enrollments').insert({
        'user_id': user.id,
        'course_id': courseId,
        'status': 'active',
        'progress': 0.0,
      });
    } catch (error) {
      throw Exception('Failed to enroll in course: $error');
    }
  }

  // Get user's course progress
  Future<List<Map<String, dynamic>>> getUserProgress(String courseId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('module_progress').select('''
            *,
            course_modules:module_id (
              id,
              title,
              course_id
            )
          ''').eq('user_id', user.id);

      // Filter by course_id
      final courseProgress = response.where((progress) {
        final module = progress['course_modules'];
        return module != null && module['course_id'] == courseId;
      }).toList();

      return List<Map<String, dynamic>>.from(courseProgress);
    } catch (error) {
      throw Exception('Failed to fetch user progress: $error');
    }
  }

  // Update module progress
  Future<void> updateModuleProgress(
    String moduleId, {
    bool? isCompleted,
    int? timeSpentMinutes,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updateData = <String, dynamic>{};
      if (isCompleted != null) {
        updateData['is_completed'] = isCompleted;
        if (isCompleted) {
          updateData['completed_at'] = DateTime.now().toIso8601String();
        }
      }
      if (timeSpentMinutes != null) {
        updateData['time_spent_minutes'] = timeSpentMinutes;
      }

      await _client.from('module_progress').upsert({
        'user_id': user.id,
        'module_id': moduleId,
        ...updateData,
      });
    } catch (error) {
      throw Exception('Failed to update module progress: $error');
    }
  }

  // Get course reviews
  Future<List<Map<String, dynamic>>> getCourseReviews(String courseId) async {
    try {
      final response = await _client.from('course_reviews').select('''
            *,
            user_profiles:user_id (
              full_name,
              avatar_url
            )
          ''').eq('course_id', courseId).order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch course reviews: $error');
    }
  }

  // Add course review
  Future<void> addCourseReview(
      String courseId, int rating, String content) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('course_reviews').insert({
        'user_id': user.id,
        'course_id': courseId,
        'rating': rating,
        'content': content,
      });
    } catch (error) {
      throw Exception('Failed to add review: $error');
    }
  }

  // Toggle course bookmark
  Future<void> toggleBookmark(String courseId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final existing = await _client
          .from('course_bookmarks')
          .select('id')
          .eq('user_id', user.id)
          .eq('course_id', courseId)
          .maybeSingle();

      if (existing != null) {
        // Remove bookmark
        await _client
            .from('course_bookmarks')
            .delete()
            .eq('user_id', user.id)
            .eq('course_id', courseId);
      } else {
        // Add bookmark
        await _client.from('course_bookmarks').insert({
          'user_id': user.id,
          'course_id': courseId,
        });
      }
    } catch (error) {
      throw Exception('Failed to toggle bookmark: $error');
    }
  }

  // Check if course is bookmarked
  Future<bool> isBookmarked(String courseId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('course_bookmarks')
          .select('id')
          .eq('user_id', user.id)
          .eq('course_id', courseId)
          .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }
}
