import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application/features/gamification/models/gamification_models.dart';

@lazySingleton
class GamificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Ambil Data Profil User
  Future<UserProfile?> getUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }

  // 2. Ambil Daftar Misi
  Future<List<UserMission>> getUserMissions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('user_missions')
          .select('*, missions(*)')
          .eq('user_id', userId)
          .neq('status', 'claimed')
          .order('created_at');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => UserMission.fromJson(json)).toList();
    } catch (e) {
      print("Error getting missions: $e");
      return [];
    }
  }

  // 3. Update Progress (Dipanggil saat Transaksi dibuat)
  Future<void> updateMissionProgress(String actionType) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final activeMissionsData = await _supabase
          .from('user_missions')
          .select('*, missions!inner(*)')
          .eq('user_id', userId)
          .eq('status', 'in_progress')
          .eq('missions.requirement_type', actionType);
      
      final List<dynamic> missionsList = activeMissionsData as List<dynamic>;

      for (var item in missionsList) {
        final userMissionId = item['id'];
        final currentProgress = item['current_progress'] as int;
        final target = item['missions']['requirement_value'] as int;
        
        int newProgress = currentProgress + 1;
        String newStatus = 'in_progress';

        if (newProgress >= target) {
          newProgress = target;
          newStatus = 'completed';
        }

        await _supabase.from('user_missions').update({
          'current_progress': newProgress,
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userMissionId);
      }
    } catch (e) {
      print("Error updating progress: $e");
    }
  }

  // 4. Klaim Hadiah XP
  Future<void> claimReward(UserMission userMission) async {
    final userId = _supabase.auth.currentUser?.id;
    final rewardXp = userMission.missionDetails?.xpReward ?? 0;

    // A. Tandai Claimed
    await _supabase
        .from('user_missions')
        .update({'status': 'claimed'})
        .eq('id', userMission.id);

    // B. Tambah XP dan Update Level
    final userProfile = await getUserProfile();
    final newXp = (userProfile?.totalXp ?? 0) + rewardXp;
    final newLevel = (newXp / 100).floor() + 1;

    await _supabase.from('user_profiles').update({
      'total_xp': newXp,
      'level': newLevel,
    }).eq('id', userId!);
  }
}