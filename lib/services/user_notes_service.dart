import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class UserNotesService {
  static UserNotesService? _instance;
  static UserNotesService get instance => _instance ??= UserNotesService._();

  UserNotesService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get notes for a module
  Future<List<Map<String, dynamic>>> getModuleNotes(String moduleId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('user_notes')
          .select('*')
          .eq('user_id', user.id)
          .eq('module_id', moduleId)
          .order('timestamp_seconds', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch notes: $error');
    }
  }

  // Add a new note
  Future<String> addNote({
    required String moduleId,
    required String content,
    int timestampSeconds = 0,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('user_notes')
          .insert({
            'user_id': user.id,
            'module_id': moduleId,
            'content': content,
            'timestamp_seconds': timestampSeconds,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (error) {
      throw Exception('Failed to add note: $error');
    }
  }

  // Update a note
  Future<void> updateNote({
    required String noteId,
    required String content,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('user_notes')
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', noteId)
          .eq('user_id', user.id); // Ensure user owns the note
    } catch (error) {
      throw Exception('Failed to update note: $error');
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client
          .from('user_notes')
          .delete()
          .eq('id', noteId)
          .eq('user_id', user.id); // Ensure user owns the note
    } catch (error) {
      throw Exception('Failed to delete note: $error');
    }
  }

  // Get all user's notes across all modules
  Future<List<Map<String, dynamic>>> getAllUserNotes() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('user_notes').select('''
            *,
            course_modules:module_id (
              title,
              courses:course_id (
                title
              )
            )
          ''').eq('user_id', user.id).order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch all notes: $error');
    }
  }

  // Search notes by content
  Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('user_notes')
          .select('''
            *,
            course_modules:module_id (
              title,
              courses:course_id (
                title
              )
            )
          ''')
          .eq('user_id', user.id)
          .textSearch('content', query)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search notes: $error');
    }
  }

  // Get notes count for a user
  Future<int> getNotesCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;

      final response =
          await _client.from('user_notes').select('id').eq('user_id', user.id);

      return response.length;
    } catch (error) {
      return 0;
    }
  }
}
