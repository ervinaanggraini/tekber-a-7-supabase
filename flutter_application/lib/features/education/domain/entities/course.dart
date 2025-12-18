import 'package:equatable/equatable.dart';

class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String level;
  final String category;
  final int durationMinutes;
  final int xpReward;
  final String thumbnailUrl;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.category,
    required this.durationMinutes,
    required this.xpReward,
    required this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        level,
        category,
        durationMinutes,
        xpReward,
        thumbnailUrl,
      ];
}
