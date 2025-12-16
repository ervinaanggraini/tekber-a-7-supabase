import 'package:hive/hive.dart';

const _themeBoxName = "themeMode";
const _appSettingsBoxName = "appSettings";

extension HiveBoxExtension on HiveInterface {
  Future<Box> openThemeModeBox() async {
    return await openBox(_themeBoxName);
  }

  Box get themeModeBox => box(_themeBoxName);

  Future<Box> openAppSettingsBox() async {
    return await openBox(_appSettingsBoxName);
  }

  Box get appSettingsBox => box(_appSettingsBoxName);
}
