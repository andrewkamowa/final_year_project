class AchievementModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String icon;
  final String type;
  final int pointsAwarded;
  final DateTime earnedDate;
  final DateTime createdAt;

  const AchievementModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.pointsAwarded,
    required this.earnedDate,
    required this.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      type: json['type'] ?? '',
      pointsAwarded: json['points_awarded'] ?? 0,
      earnedDate: DateTime.parse(json['earned_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type,
      'points_awarded': pointsAwarded,
      'earned_date': earnedDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
