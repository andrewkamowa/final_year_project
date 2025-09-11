import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class QuizService {
  static QuizService? _instance;
  static QuizService get instance => _instance ??= QuizService._();

  QuizService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get quiz for a module
  Future<Map<String, dynamic>?> getQuizForModule(String moduleId) async {
    try {
      final response = await _client.from('quizzes').select('''
            *,
            quiz_questions (
              *
            )
          ''').eq('module_id', moduleId).maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch quiz: $error');
    }
  }

  // Get quiz questions
  Future<List<Map<String, dynamic>>> getQuizQuestions(String quizId) async {
    try {
      final response = await _client
          .from('quiz_questions')
          .select('*')
          .eq('quiz_id', quizId)
          .order('order_index', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch quiz questions: $error');
    }
  }

  // Start quiz attempt
  Future<String> startQuizAttempt(String quizId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('quiz_attempts')
          .insert({
            'user_id': user.id,
            'quiz_id': quizId,
            'score': 0,
            'total_points': 0,
            'time_taken_minutes': 0,
            'is_passed': false,
            'answers': {},
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (error) {
      throw Exception('Failed to start quiz attempt: $error');
    }
  }

  // Submit quiz attempt
  Future<void> submitQuizAttempt(
    String attemptId, {
    required int score,
    required int totalPoints,
    required int timeTakenMinutes,
    required bool isPassed,
    required Map<String, dynamic> answers,
  }) async {
    try {
      await _client.from('quiz_attempts').update({
        'score': score,
        'total_points': totalPoints,
        'time_taken_minutes': timeTakenMinutes,
        'is_passed': isPassed,
        'answers': answers,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', attemptId);
    } catch (error) {
      throw Exception('Failed to submit quiz attempt: $error');
    }
  }

  // Get user's quiz attempts for a quiz
  Future<List<Map<String, dynamic>>> getUserQuizAttempts(String quizId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('quiz_attempts')
          .select('*')
          .eq('user_id', user.id)
          .eq('quiz_id', quizId)
          .order('started_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch quiz attempts: $error');
    }
  }

  // Get best score for a quiz
  Future<int?> getBestScore(String quizId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('quiz_attempts')
          .select('score')
          .eq('user_id', user.id)
          .eq('quiz_id', quizId)
          .order('score', ascending: false)
          .limit(1)
          .maybeSingle();

      return response?['score'] as int?;
    } catch (error) {
      return null;
    }
  }

  // Check if user has passed the quiz
  Future<bool> hasPassedQuiz(String quizId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('quiz_attempts')
          .select('is_passed')
          .eq('user_id', user.id)
          .eq('quiz_id', quizId)
          .eq('is_passed', true)
          .limit(1)
          .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }

  // Get remaining attempts for a quiz
  Future<int> getRemainingAttempts(String quizId, int maxAttempts) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return maxAttempts;

      final response = await _client
          .from('quiz_attempts')
          .select('id')
          .eq('user_id', user.id)
          .eq('quiz_id', quizId);

      final attemptCount = response.length;
      return maxAttempts - attemptCount;
    } catch (error) {
      return maxAttempts;
    }
  }
}
