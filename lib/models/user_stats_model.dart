class UserStatsModel {
  final String userId;
  final int coursesCompleted;
  final int pointsEarned;
  final int currentStreak;
  final int certificatesObtained;
  final int quizzesCompleted;
  final double averageScore;
  final DateTime? lastActivityDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserStatsModel({
    required this.userId,
    required this.coursesCompleted,
    required this.pointsEarned,
    required this.currentStreak,
    required this.certificatesObtained,
    required this.quizzesCompleted,
    required this.averageScore,
    this.lastActivityDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['user_id'] ?? '',
      coursesCompleted: json['courses_completed'] ?? 0,
      pointsEarned: json['points_earned'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      certificatesObtained: json['certificates_obtained'] ?? 0,
      quizzesCompleted: json['quizzes_completed'] ?? 0,
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'courses_completed': coursesCompleted,
      'points_earned': pointsEarned,
      'current_streak': currentStreak,
      'certificates_obtained': certificatesObtained,
      'quizzes_completed': quizzesCompleted,
      'average_score': averageScore,
      'last_activity_date': lastActivityDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
