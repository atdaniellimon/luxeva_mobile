import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'digital_card_screen.dart';
import 'documents_screen.dart';
import 'home_vault_screen.dart';
import 'wealth_screen.dart';

class MainTabScaffold extends StatefulWidget {
  final UserSession user;

  const MainTabScaffold({super.key, required this.user});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _currentIndex = 0;
  final CupertinoTabController _tabController = CupertinoTabController();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserSession?>(
      valueListenable: AuthService.instance.currentSession,
      builder: (context, sessionUser, _) {
        final currentUser = sessionUser ?? widget.user;

        return CupertinoTabScaffold(
          controller: _tabController,
          tabBar: CupertinoTabBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index != _currentIndex) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
              }
            },
            backgroundColor: LuxevaTheme.glassBg,
            activeColor: LuxevaTheme.goldAccent,
            inactiveColor: LuxevaTheme.textSecondary,
            border: const Border(
              top: BorderSide(
                color: LuxevaTheme.borderSubtle,
                width: LuxevaTheme.hairline,
              ),
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.shield),
                activeIcon: Icon(CupertinoIcons.shield_fill),
                label: 'Bóveda',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.creditcard),
                activeIcon: Icon(CupertinoIcons.creditcard_fill),
                label: 'Tarjeta',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_pie),
                activeIcon: Icon(CupertinoIcons.chart_pie_fill),
                label: 'Patrimonio',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.doc_text),
                activeIcon: Icon(CupertinoIcons.doc_text_fill),
                label: 'Documentos',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (tabContext) {
                switch (index) {
                  case 0:
                    return HomeVaultScreen(user: currentUser);
                  case 1:
                    return DigitalCardScreen(user: currentUser);
                  case 2:
                    return WealthScreen(user: currentUser);
                  case 3:
                    return DocumentsScreen(user: currentUser);
                  default:
                    return HomeVaultScreen(user: currentUser);
                }
              },
            );
          },
        );
      },
    );
  }
}
