import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/features/gamification/services/gamification_service.dart';
import 'package:flutter_application/features/gamification/models/gamification_models.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  // Service tetap kita inisialisasi, tapi nanti kita bypass datanya
  final GamificationService _service = GetIt.I<GamificationService>();
  
  UserProfile? _userProfile;
  List<UserMission> _missions = [];
  bool _isLoading = true;

  // Warna sesuai Figma
  final Color _primaryPink = const Color(0xFFFF6B6B);
  final Color _softPinkBg = const Color(0xFFFFF0F3);
  final Color _cardGradient1 = const Color(0xFFFF9A9E);
  final Color _cardGradient2 = const Color(0xFFFECFEF);

  @override
  void initState() {
    super.initState();
    _loadMockData(); // PANGGIL DATA PALSU BIAR MUNCUL
  }

  // --- FUNGSI DATA DUMMY (MOCKUP) ---
  Future<void> _loadMockData() async {
    setState(() => _isLoading = true);
    
    // Simulasi loading sebentar biar kerasa 'real'
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      // 1. DATA PROFIL PALSU
      _userProfile = UserProfile(
        id: 'user-123',
        level: 1,
        totalXp: 20, // Ceritanya baru dapet 20 XP
        currentStreak: 3,
        totalPoints: 0,
      );

      // 2. DATA MISI PALSU (Sesuai Desain Figma)
      _missions = [
        // Misi 1: Selesai (Bisa Klaim)
        UserMission(
          id: 'm1',
          missionId: 'master-1',
          currentProgress: 1,
          status: 'completed', // Status completed -> Tombol Klaim Muncul
          missionDetails: Mission(
            id: 'master-1',
            title: 'Langkah Pertama',
            description: 'Lakukan pembelian aset pertamamu',
            xpReward: 50,
            requirementType: 'buy',
            targetProgress: 1,
          ),
        ),
        // Misi 2: Progress (Setengah jalan)
        UserMission(
          id: 'm2',
          missionId: 'master-2',
          currentProgress: 1, // Baru 1 dari 2
          status: 'in_progress',
          missionDetails: Mission(
            id: 'master-2',
            title: 'Diversifikasi Awal',
            description: 'Miliki minimal 2 jenis aset berbeda',
            xpReward: 100,
            requirementType: 'assets',
            targetProgress: 2,
          ),
        ),
        // Misi 3: Masih Awal
        UserMission(
          id: 'm3',
          missionId: 'master-3',
          currentProgress: 2, // Baru 2 dari 5
          status: 'in_progress',
          missionDetails: Mission(
            id: 'master-3',
            title: 'Trader Aktif',
            description: 'Lakukan total 5 transaksi (beli/jual)',
            xpReward: 150,
            requirementType: 'transaction',
            targetProgress: 5,
          ),
        ),
         // Misi 4: Masih 0
        UserMission(
          id: 'm4',
          missionId: 'master-4',
          currentProgress: 0, 
          status: 'in_progress',
          missionDetails: Mission(
            id: 'master-4',
            title: 'Calon Sultan',
            description: 'Raih total nilai portofolio Rp 120 Juta',
            xpReward: 250,
            requirementType: 'balance',
            targetProgress: 1,
          ),
        ),
      ];
      
      _isLoading = false;
    });
  }

  Future<void> _handleClaim(UserMission mission) async {
    // Efek Klaim Palsu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Hore! +${mission.missionDetails?.xpReward} XP"),
        backgroundColor: Colors.green,
      ),
    );
    
    // Update UI biar tombol klaim hilang setelah diklik
    setState(() {
       final index = _missions.indexWhere((m) => m.id == mission.id);
       if (index != -1) {
         _missions[index] = UserMission(
           id: mission.id,
           missionId: mission.missionId,
           currentProgress: mission.currentProgress,
           status: 'claimed',
           missionDetails: mission.missionDetails,
         );
       }

       _userProfile = UserProfile(
         id: _userProfile!.id,
         level: _userProfile!.level,
         totalXp: _userProfile!.totalXp + (mission.missionDetails?.xpReward ?? 0),
         currentStreak: _userProfile!.currentStreak,
         totalPoints: _userProfile!.totalPoints
       );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Mission", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  // 1. HEADER PROFIL
                  _buildProfileHeader(),
                  
                  const SizedBox(height: 24),

                  // 2. KARTU PORTOFOLIO
                  _buildPortfolioCard(),

                  const SizedBox(height: 24),
                  
                  // 3. JUDUL MISI
                  Text(
                    "Misi & Tantangan",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
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

    int targetXp = 100; // Target XP level 1
    double progress = _userProfile!.totalXp / targetXp;

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: _softPinkBg,
          child: Icon(Icons.person, color: _primaryPink, size: 30),
        ),
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Investor Pemula", 
                style: GoogleFonts.poppins(color: _primaryPink, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Level ${_userProfile!.level}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange)),
                  Text("${_userProfile!.totalXp}/$targetXp XP", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
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
          Text(
            "Total Nilai Portofolio",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Rp100.000.000,-", 
            style: GoogleFonts.poppins(
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
            child: Text(
              "↑ +Rp0 (0.00%)",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
              Text("Belum ada misi aktif.", style: GoogleFonts.poppins(color: Colors.grey)),
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
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  details?.description ?? "Lakukan tugas ini",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
                if (!isCompleted) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (mission.currentProgress / (details?.targetProgress ?? 1)).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[100],
                    color: _primaryPink, 
                    minHeight: 4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${mission.currentProgress}/${details?.targetProgress ?? 1}",
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                  )
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
                    child: Text("Klaim", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                  )
                : Text(
                    "+${details?.xpReward} XP",
                    style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12),
                  ),
          ),
        );
      }).toList(),
    );
  }
}