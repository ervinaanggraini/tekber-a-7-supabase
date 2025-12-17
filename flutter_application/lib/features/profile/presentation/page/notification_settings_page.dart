import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application/core/constants/app_colors.dart';
import '/features/notification/user_settings.dart';
import '/features/notification/services/user_settings_services.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _service = UserSettingsService();
  UserSettings? _settings;
  bool _isLoading = true;

  // warna toggle konsisten
  final Color _toggleColor = AppColors.b93160;

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
            _settings = _settings!.copyWith(enableNotifications: value);
            break;
          case 'enable_daily_reminders':
            _settings = _settings!.copyWith(enableDailyReminders: value);
            break;
          case 'enable_mission_alerts':
            _settings = _settings!.copyWith(enableMissionAlerts: value);
            break;
          case 'enable_budget_alerts':
            _settings = _settings!.copyWith(enableBudgetAlerts: value);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_settings == null) {
      return const Scaffold(
        body: Center(child: Text("User settings tidak ditemukan")),
      );
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
            activeColor: _toggleColor,
            activeTrackColor: _toggleColor.withOpacity(0.4),
            onChanged: (v) => _update('enable_notifications', v),
          ),
          SwitchListTile(
            title: const Text("Daily Reminders"),
            value: _settings!.enableDailyReminders,
            activeColor: _toggleColor,
            activeTrackColor: _toggleColor.withOpacity(0.4),
            onChanged: (v) => _update('enable_daily_reminders', v),
          ),
          SwitchListTile(
            title: const Text("Mission Alerts"),
            value: _settings!.enableMissionAlerts,
            activeColor: _toggleColor,
            activeTrackColor: _toggleColor.withOpacity(0.4),
            onChanged: (v) => _update('enable_mission_alerts', v),
          ),
          SwitchListTile(
            title: const Text("Budget Alerts"),
            value: _settings!.enableBudgetAlerts,
            activeColor: _toggleColor,
            activeTrackColor: _toggleColor.withOpacity(0.4),
            onChanged: (v) => _update('enable_budget_alerts', v),
          ),
        ],
      ),
    );
  }
}
