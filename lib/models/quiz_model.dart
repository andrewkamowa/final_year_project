class QuizModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final List<QuizQuestionModel> questions;
  final int timeLimit;
  final int passingScore;
  final bool isActive;
  final DateTime createdAt;

  const QuizModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeLimit,
    required this.passingScore,
    required this.isActive,
    required this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? '',
      courseId: json['course_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((q) => QuizQuestionModel.fromJson(q))
          .toList(),
      timeLimit: json['time_limit'] ?? 0,
      passingScore: json['passing_score'] ?? 0,
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'time_limit': timeLimit,
      'passing_score': passingScore,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class QuizQuestionModel {
  final String id;
  final String quizId;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int order;

  const QuizQuestionModel({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.order,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] ?? '',
      quizId: json['quiz_id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
      explanation: json['explanation'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question': question,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'order': order,
    };
  }
}
