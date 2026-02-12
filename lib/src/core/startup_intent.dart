enum AppLaunchSource { normal, notification, deepLink }

class StartupIntent {
  static AppLaunchSource source = AppLaunchSource.normal;
  static Map<String, dynamic>? payload;
  static bool handled = false;
}
