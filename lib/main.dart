import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab_scaffold.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait orientation for luxury iOS experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system navigation bar & status bar transparent for edge-to-edge obsidian UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: CupertinoColors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: LuxevaTheme.obsidianBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize cached session from SharedPreferences
  await AuthService.instance.init();

  runApp(const LuxevaApp());
}

class LuxevaApp extends StatelessWidget {
  const LuxevaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'LUXEVA Private Wealth',
      debugShowCheckedModeBanner: false,
      theme: LuxevaTheme.cupertinoTheme,
      home: ValueListenableBuilder<UserSession?>(
        valueListenable: AuthService.instance.currentSession,
        builder: (context, session, _) {
          if (session == null) {
            return const LoginScreen();
          }
          return MainTabScaffold(user: session);
        },
      ),
    );
  }
}
