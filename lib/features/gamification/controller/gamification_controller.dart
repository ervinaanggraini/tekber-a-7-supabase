import 'package:get/get.dart';
import 'package:moneyvesto/data/gamification_datasource.dart';

class GamificationController extends GetxController {
  final GamificationDataSource _dataSource = GamificationDataSourceImpl();

  var isLoading = true.obs;
  var userProfile = {}.obs;
  var badges = <Map<String, dynamic>>[].obs;
  var missions = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGamificationData();
  }

  Future<void> fetchGamificationData() async {
    try {
      isLoading(true);
      
      // Fetch all data in parallel
      final results = await Future.wait([
        _dataSource.getProfile(),
        _dataSource.getBadges(),
        _dataSource.getMissions(),
      ]);

      if (results[0].statusCode == 200) {
        userProfile.value = results[0].data;
      }
      
      if (results[1].statusCode == 200) {
        badges.assignAll(List<Map<String, dynamic>>.from(results[1].data));
      }

      if (results[2].statusCode == 200) {
        missions.assignAll(List<Map<String, dynamic>>.from(results[2].data));
      }

    } catch (e) {
      print("Error fetching gamification data: $e");
      Get.snackbar("Error", "Gagal memuat data gamifikasi");
    } finally {
      isLoading(false);
    }
  }
}
