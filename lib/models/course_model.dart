class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String? instructorName;
  final String difficulty;
  final String duration;
  final double rating;
  final int reviewCount;
  final String contentType;
  final String? thumbnailUrl;
  final String? price;
  final List<String> topics;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    this.instructorName,
    required this.difficulty,
    required this.duration,
    required this.rating,
    required this.reviewCount,
    required this.contentType,
    this.thumbnailUrl,
    this.price,
    required this.topics,
    required this.isPublished,
    required this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructorId: json['instructor_id'] ?? '',
      instructorName: json['instructor_name'],
      difficulty: json['difficulty'] ?? 'Beginner',
      duration: json['duration'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      contentType: json['content_type'] ?? 'Video',
      thumbnailUrl: json['thumbnail_url'],
      price: json['price'],
      topics: List<String>.from(json['topics'] ?? []),
      isPublished: json['is_published'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'difficulty': difficulty,
      'duration': duration,
      'rating': rating,
      'review_count': reviewCount,
      'content_type': contentType,
      'thumbnail_url': thumbnailUrl,
      'price': price,
      'topics': topics,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
