import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_application/features/gamification/services/gamification_service.dart';
import 'package:flutter_application/features/gamification/models/gamification_models.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  // Ambil service (pastikan GetIt sudah disetup)
  final GamificationService _service = GetIt.I<GamificationService>();
  
  UserProfile? _userProfile;
  List<UserMission> _missions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _service.getUserProfile();
      final missions = await _service.getUserMissions();
      setState(() {
        _userProfile = profile;
        _missions = missions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleClaim(UserMission mission) async {
    await _service.claimReward(mission);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil klaim +${mission.missionDetails?.xpReward} XP!")),
      );
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Misi & Level")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  const Text("Misi Aktif", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildMissionList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    if (_userProfile == null) return const SizedBox();
    return Card(
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Level ${_userProfile!.level}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text("${_userProfile!.totalXp} XP Total", style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionList() {
    if (_missions.isEmpty) return const Center(child: Text("Belum ada misi."));

    return Column(
      children: _missions.map((mission) {
        final isCompleted = mission.status == 'completed';
        return Card(
          child: ListTile(
            title: Text(mission.missionDetails?.title ?? "Misi"),
            subtitle: Text("${mission.currentProgress} / ${mission.missionDetails?.targetProgress}"),
            trailing: isCompleted
                ? ElevatedButton(
                    onPressed: () => _handleClaim(mission),
                    child: const Text("Klaim"),
                  )
                : Text("+${mission.missionDetails?.xpReward} XP"),
          ),
        );
      }).toList(),
    );
  }
}