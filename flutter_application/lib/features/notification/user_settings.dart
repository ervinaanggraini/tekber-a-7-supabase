class UserSettings {
  final bool enableNotifications;
  final bool enableDailyReminders;
  final bool enableMissionAlerts;
  final bool enableBudgetAlerts;

  UserSettings({
    required this.enableNotifications,
    required this.enableDailyReminders,
    required this.enableMissionAlerts,
    required this.enableBudgetAlerts,
  });

  UserSettings copyWith({
  bool? enableNotifications,
  bool? enableDailyReminders,
  bool? enableMissionAlerts,
  bool? enableBudgetAlerts,
  }) {
    
  return UserSettings(
    enableNotifications: enableNotifications ?? this.enableNotifications,
    enableDailyReminders: enableDailyReminders ?? this.enableDailyReminders,
    enableMissionAlerts: enableMissionAlerts ?? this.enableMissionAlerts,
    enableBudgetAlerts: enableBudgetAlerts ?? this.enableBudgetAlerts,
  );
}

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      enableNotifications: map['enable_notifications'] ?? false,
      enableDailyReminders: map['enable_daily_reminders'] ?? false,
      enableMissionAlerts: map['enable_mission_alerts'] ?? false,
      enableBudgetAlerts: map['enable_budget_alerts'] ?? false,
    );
  }
}


