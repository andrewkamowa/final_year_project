class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;
  final double progress;
  final bool isCompleted;
  final bool isBookmarked;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.progress,
    required this.isCompleted,
    required this.isBookmarked,
    required this.enrolledAt,
    this.completedAt,
    this.updatedAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      courseId: json['course_id'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      enrolledAt: DateTime.parse(json['enrolled_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'progress': progress,
      'is_completed': isCompleted,
      'is_bookmarked': isBookmarked,
      'enrolled_at': enrolledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
