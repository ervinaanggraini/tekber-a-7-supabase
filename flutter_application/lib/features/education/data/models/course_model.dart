import 'package:flutter_application/features/education/domain/entities/course.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.level,
    required super.category,
    required super.durationMinutes,
    required super.xpReward,
    required super.thumbnailUrl,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 'beginner',
      category: json['category'] ?? 'general',
      durationMinutes: json['duration_minutes'] ?? 0,
      xpReward: json['xp_reward'] ?? 0,
      thumbnailUrl: json['thumbnail_url'] ?? '',
    );
  }
}
