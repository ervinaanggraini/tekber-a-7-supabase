import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moneyvesto/core/config/my_app.dart';

// SharedPreferencesUtils sharedPreferencesUtils = SharedPreferencesUtils();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // sharedPreferencesUtils.init();

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
