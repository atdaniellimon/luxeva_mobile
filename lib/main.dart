import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';
import 'theme/luxeva_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_vault_screen.dart';
import 'screens/deposit_screen.dart';
import 'screens/cards_screen.dart';
import 'screens/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const LuxevaApp());
}

class LuxevaApp extends StatefulWidget {
  const LuxevaApp({super.key});

  @override
  State<LuxevaApp> createState() => _LuxevaAppState();
}

class _LuxevaAppState extends State<LuxevaApp> {
  bool _isInitialized = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final session = await ApiService.instance.loadSession();
    if (mounted) {
      setState(() {
        _isAuthenticated = session != null && session.accountNumber.isNotEmpty;
        _isInitialized = true;
      });
    }
  }

  void _onLoginSuccess() {
    setState(() => _isAuthenticated = true);
  }

  void _onLogout() {
    setState(() => _isAuthenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Luxeva',
      theme: LuxevaTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: !_isInitialized
          ? Container(
              color: LuxevaTheme.background,
              child: const Center(
                child: CupertinoActivityIndicator(color: LuxevaTheme.accentGold),
              ),
            )
          : _isAuthenticated
              ? MainNavigationScaffold(onLogout: _onLogout)
              : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  final VoidCallback onLogout;
  const MainNavigationScaffold({super.key, required this.onLogout});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  final CupertinoTabController _tabController = CupertinoTabController();

  void _changeTab(int index) {
    HapticFeedback.selectionClick();
    _tabController.index = index;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xE60D0D11),
        activeColor: LuxevaTheme.accentGold,
        inactiveColor: const Color(0xFF636368),
        iconSize: 22,
        onTap: (index) {
          HapticFeedback.selectionClick();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Bóveda',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.plus_circle_fill),
            label: 'Fondeo',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.creditcard_fill),
            label: 'Instrumentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'Titular',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (_) => HomeVaultScreen(onTabChange: _changeTab));
          case 1:
            return CupertinoTabView(builder: (_) => const DepositScreen());
          case 2:
            return CupertinoTabView(builder: (_) => const CardsScreen());
          case 3:
            return CupertinoTabView(builder: (_) => AccountScreen(onLogout: widget.onLogout));
          default:
            return CupertinoTabView(builder: (_) => HomeVaultScreen(onTabChange: _changeTab));
        }
      },
    );
  }
}
