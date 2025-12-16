import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/features/notification/user_settings.dart';
import '/features/notification/services/user_settings_services.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _service = UserSettingsService();
  UserSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final settings = await _service.loadSettings(user.id);
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _update(String key, bool value) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await _service.updateSetting(user.id, key, value);

    setState(() {
      if (_settings != null) {
        switch (key) {
          case 'enable_notifications':
            _settings = UserSettings(
              enableNotifications: value,
              enableDailyReminders: _settings!.enableDailyReminders,
              enableMissionAlerts: _settings!.enableMissionAlerts,
              enableBudgetAlerts: _settings!.enableBudgetAlerts,
            );
            break;
          case 'enable_daily_reminders':
            _settings = UserSettings(
              enableNotifications: _settings!.enableNotifications,
              enableDailyReminders: value,
              enableMissionAlerts: _settings!.enableMissionAlerts,
              enableBudgetAlerts: _settings!.enableBudgetAlerts,
            );
            break;
          case 'enable_mission_alerts':
            _settings = UserSettings(
              enableNotifications: _settings!.enableNotifications,
              enableDailyReminders: _settings!.enableDailyReminders,
              enableMissionAlerts: value,
              enableBudgetAlerts: _settings!.enableBudgetAlerts,
            );
            break;
          case 'enable_budget_alerts':
            _settings = UserSettings(
              enableNotifications: _settings!.enableNotifications,
              enableDailyReminders: _settings!.enableDailyReminders,
              enableMissionAlerts: _settings!.enableMissionAlerts,
              enableBudgetAlerts: value,
            );
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_settings == null) {
      return const Center(child: Text("User settings tidak ditemukan"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: _settings!.enableNotifications,
            onChanged: (v) => _update('enable_notifications', v),
          ),
          SwitchListTile(
            title: const Text("Daily Reminders"),
            value: _settings!.enableDailyReminders,
            onChanged: (v) => _update('enable_daily_reminders', v),
          ),
          SwitchListTile(
            title: const Text("Mission Alerts"),
            value: _settings!.enableMissionAlerts,
            onChanged: (v) => _update('enable_mission_alerts', v),
          ),
          SwitchListTile(
            title: const Text("Budget Alerts"),
            value: _settings!.enableBudgetAlerts,
            onChanged: (v) => _update('enable_budget_alerts', v),
          ),
        ],
      ),
    );
  }
}
