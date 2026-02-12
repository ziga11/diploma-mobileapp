import 'package:diplomaapp/src/services/firebase_api.dart';
import 'package:diplomaapp/src/services/link_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:diplomaapp/src/constants/theme.dart';
import 'package:diplomaapp/src/core/app_router.dart';
import 'package:diplomaapp/src/core/navigation/splash_page.dart';
import 'package:diplomaapp/src/services/language_service.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/user_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await setupLocator();

  await Future.wait([
    getIt<FirebaseAPI>().bootstrapNotifications(),
    getIt<UserService>().initializeSession(),
    getIt<LanguageService>().init(),
    getIt<StartupService>().init(),
  ]);

  runApp(const DiplomaApp());
}

class DiplomaApp extends StatelessWidget {
  const DiplomaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ColorTheme.darkTheme,
      home: SplashPage(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generate,
    );
  }
}
