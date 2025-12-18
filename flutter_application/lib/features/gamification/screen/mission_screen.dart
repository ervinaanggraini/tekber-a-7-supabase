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
  final GamificationService _service = GetIt.I<GamificationService>();
  
  UserProfile? _userProfile;
  List<UserMission> _missions = [];
  bool _isLoading = true;

  // Warna-warna sesuai desain Figma
  final Color _primaryPink = const Color(0xFFFF6B6B);
  final Color _softPinkBg = const Color(0xFFFFF0F3);
  final Color _cardGradient1 = const Color(0xFFFF9A9E);
  final Color _cardGradient2 = const Color(0xFFFECFEF);

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
        SnackBar(content: Text("Hore! +${mission.missionDetails?.xpReward} XP")),
      );
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Mission", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER PROFIL (Investor Pemula)
                  _buildProfileHeader(),
                  
                  const SizedBox(height: 24),

                  // 2. KARTU PORTOFOLIO (Rp100.000.000)
                  _buildPortfolioCard(),

                  const SizedBox(height: 24),
                  
                  // 3. JUDUL MISI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Misi & Tantangan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // Filter button kecil jika perlu
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. LIST MISI
                  _buildMissionList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    if (_userProfile == null) return const SizedBox();

    // Hitung progress XP (0.0 sampai 1.0)
    int nextLevelXp = _userProfile!.level * 100;
    int currentLevelBaseXp = (_userProfile!.level - 1) * 100;
    int xpInThisLevel = _userProfile!.totalXp - currentLevelBaseXp;
    double progress = xpInThisLevel / 100.0;
    if (progress > 1.0) progress = 1.0;

    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 28,
          backgroundColor: _softPinkBg,
          child: Image.asset('assets/icons/app_icon.png', width: 30, errorBuilder: (c,o,s) => Icon(Icons.person, color: _primaryPink)),
        ),
        const SizedBox(width: 16),
        
        // Info Level & XP
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Investor Pemula", // Bisa diganti logic title berdasarkan level
                style: TextStyle(color: _primaryPink, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Level ${_userProfile!.level}", style: const TextStyle(fontSize: 12, color: Colors.orange)),
                  Text("$xpInThisLevel/100 XP", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: _primaryPink,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_cardGradient1, _cardGradient2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _cardGradient1.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Nilai Portofolio",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Rp100.000.000,-", // Nanti bisa diambil dari TransactionService
            style: TextStyle(
              color: Colors.white, 
              fontSize: 28, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "↑ +Rp0 (0.00%)",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionList() {
    if (_missions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 10),
              const Text("Belum ada misi aktif.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _missions.map((mission) {
        final details = mission.missionDetails;
        final isCompleted = mission.status == 'completed';
        final isClaimed = mission.status == 'claimed';
        
        // Jangan tampilkan yang sudah diklaim (atau tampilkan di tab riwayat)
        if (isClaimed) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _softPinkBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.star_border, 
                color: _primaryPink
              ),
            ),
            title: Text(
              details?.title ?? "Misi",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  details?.description ?? "Lakukan tugas ini",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (!isCompleted) ...[
                  const SizedBox(height: 8),
                  // Progress bar kecil untuk misi
                  LinearProgressIndicator(
                    value: (mission.currentProgress / (details?.targetProgress ?? 1)).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[100],
                    color: Colors.green, // Warna hijau agar beda
                    minHeight: 4,
                  ),
                ]
              ],
            ),
            trailing: isCompleted
                ? ElevatedButton(
                    onPressed: () => _handleClaim(mission),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                    ),
                    child: const Text("Klaim", style: TextStyle(fontSize: 12)),
                  )
                : Text(
                    "+${details?.xpReward} XP",
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                  ),
          ),
        );
      }).toList(),
    );
  }
}