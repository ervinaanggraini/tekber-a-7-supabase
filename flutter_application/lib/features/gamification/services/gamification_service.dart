import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gamification_models.dart';
import 'package:injectable/injectable.dart';

@lazySingleton // atau @injectable
class GamificationService {

  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Ambil Data Profil User (XP, Level)
  Future<UserProfile?> getUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  // 2. Ambil Misi User (Include detail misinya)
  Future<List<UserMission>> getUserMissions() async {
    final userId = _supabase.auth.currentUser?.id;
    
    // Syntax select(*, missions(*)) adalah cara Supabase melakukan JOIN
    final response = await _supabase
        .from('user_missions')
        .select('*, missions(*)') 
        .eq('user_id', userId!)
        .neq('status', 'claimed'); // Jangan tampilkan yang sudah diklaim

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => UserMission.fromJson(json)).toList();
  }

  // 3. CORE LOGIC: Update Progress Misi
  // Panggil fungsi ini setiap kali user melakukan aksi (misal: tambah transaksi)
  Future<void> updateMissionProgress(String actionType) async {
    final userId = _supabase.auth.currentUser?.id;

    // A. Cari misi aktif user yang requirement_type-nya cocok dengan aksi ini
    // Kita join dengan tabel missions untuk cek requirement_type
    final activeMissionsData = await _supabase
        .from('user_missions')
        .select('*, missions!inner(*)') // !inner memaksa join
        .eq('user_id', userId!)
        .eq('status', 'in_progress')
        .eq('missions.requirement_type', actionType);

    // B. Loop setiap misi yang cocok dan update progress
    for (var item in activeMissionsData) {
      final userMissionId = item['id'];
      final currentProgress = item['current_progress'] as int;
      final target = item['missions']['requirement_value'] as int;
      
      int newProgress = currentProgress + 1;
      String newStatus = 'in_progress';

      // Cek apakah target tercapai
      if (newProgress >= target) {
        newProgress = target;
        newStatus = 'completed'; // Siap diklaim
        // Opsional: Kirim notifikasi lokal "Misi Selesai!"
      }

      // Update ke database
      await _supabase.from('user_missions').update({
        'current_progress': newProgress,
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userMissionId);
    }
  }

  // 4. Claim Reward
  Future<void> claimReward(UserMission userMission) async {
    final userId = _supabase.auth.currentUser?.id;
    final rewardXp = userMission.missionDetails?.xpReward ?? 0;

    // A. Update status misi jadi 'claimed'
    await _supabase
        .from('user_missions')
        .update({'status': 'claimed'})
        .eq('id', userMission.id);

    // B. Tambah XP ke User Profile (RPC function lebih aman, tapi ini cara direct update)
    // Ambil data user saat ini dulu
    final userProfile = await getUserProfile();
    final newXp = (userProfile?.totalXp ?? 0) + rewardXp;
    
    // Cek Level Up Logic sederhana (misal tiap 100 XP naik level)
    final newLevel = (newXp / 100).floor() + 1;

    await _supabase.from('user_profiles').update({
      'total_xp': newXp,
      'level': newLevel,
    }).eq('id', userId!);
  }
}