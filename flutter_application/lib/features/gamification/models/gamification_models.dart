class UserProfile {
  final String id;
  final int level;
  final int totalXp;
  final int currentStreak;
  final int totalPoints;

  UserProfile({
    required this.id,
    required this.level,
    required this.totalXp,
    required this.currentStreak,
    required this.totalPoints,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      level: json['level'] ?? 1,
      totalXp: json['total_xp'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
    );
  }
}

class Mission {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int targetProgress;
  final String requirementType;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.targetProgress,
    required this.requirementType,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      title: json['title'] ?? 'Misi',
      description: json['description'] ?? '',
      xpReward: json['xp_reward'] ?? 0,
      targetProgress: json['requirement_value'] ?? 1,
      requirementType: json['requirement_type'] ?? '',
    );
  }
}

class UserMission {
  final String id;
  final String missionId;
  final int currentProgress;
  final String status; // 'in_progress', 'completed', 'claimed'
  final Mission? missionDetails;

  UserMission({
    required this.id,
    required this.missionId,
    required this.currentProgress,
    required this.status,
    this.missionDetails,
  });

  factory UserMission.fromJson(Map<String, dynamic> json) {
    return UserMission(
      id: json['id'],
      missionId: json['mission_id'],
      currentProgress: json['current_progress'] ?? 0,
      status: json['status'] ?? 'in_progress',
      // Supabase join
      missionDetails: json['missions'] != null 
          ? Mission.fromJson(json['missions']) 
          : null,
    );
  }
}