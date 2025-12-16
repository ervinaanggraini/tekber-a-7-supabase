import 'package:supabase_flutter/supabase_flutter.dart';
import '/features/notification/user_settings.dart';

class UserSettingsService {
  final supabase = Supabase.instance.client;

  /// Ambil user_settings berdasarkan user_id
  Future<UserSettings?> loadSettings(String userId) async {
    final data = await supabase
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;

    return UserSettings.fromMap(data);
  }

  /// Update satu field dalam user_settings
  Future<void> updateSetting(String userId, String key, bool value) async {
    await supabase
        .from('user_settings')
        .update({key: value})
        .eq('user_id', userId);
  }
}