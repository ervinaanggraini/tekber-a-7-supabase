import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moneyvesto/core/config/my_app.dart';
import 'package:moneyvesto/core/utils/shared_preferences_utils.dart';

// SharedPreferencesUtils sharedPreferencesUtils = SharedPreferencesUtils();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  await SharedPreferencesUtils().init();
  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('en_US', null);

  // FlavorConfig(name: "PRODUCTION", color: Colors.red, variables: {
  //   "counter": 0,
  //   "baseUrl": "https://www.example.com",
  // });

  // runApp(const MainApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const MainApp());
  });
}
