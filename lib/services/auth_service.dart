import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../models/user_profile_model.dart';

/// =============================
/// AUTH + USER PROFILE SERVICES
/// =============================
class AuthService {
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  AuthService._();

  final _client = SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  // Check if user is signed in
  bool get isSignedIn => _client.auth.currentUser != null;

  // Sign up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'student',
      },
    );
    return response;
  }

  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Get user profile
  Future<UserProfileModel?> getUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

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

  // Listen to auth state changes
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // Create or update user profile
  Future<UserProfileModel?> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? bio,
    String? profileImageUrl,
    String role = 'student',
  }) async {
    try {
      final response = await _client
          .from('user_profiles')
          .upsert({
            'id': userId,
            'email': email,
            'full_name': fullName,
            'bio': bio,
            'profile_image_url': profileImageUrl,
            'role': role,
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      print('Error creating user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<UserProfileModel?> updateUserProfile({
    required String userId,
    String? fullName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (bio != null) updateData['bio'] = bio;
      if (profileImageUrl != null) {
        updateData['profile_image_url'] = profileImageUrl;
      }

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }
}

/// =============================
/// COURSE + MODULE SERVICES
/// =============================
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
            course_modules (*)
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
