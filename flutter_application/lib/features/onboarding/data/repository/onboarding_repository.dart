import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_application/core/extensions/hive_extensions.dart';

abstract class OnboardingRepository {
  bool get isOnboardingSeen;
  Future<void> setOnboardingSeen();
}

@Injectable(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  
  @override
  bool get isOnboardingSeen => Hive.appSettingsBox.get('onboarding_seen', defaultValue: false);

  @override
  Future<void> setOnboardingSeen() async {
    await Hive.appSettingsBox.put('onboarding_seen', true);
  }
}
