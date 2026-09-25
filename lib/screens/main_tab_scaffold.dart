import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'account_screen.dart';
import 'home_vault_screen.dart';
import 'transactions_screen.dart';
import 'wealth_screen.dart';

class MainTabScaffold extends StatefulWidget {
  final UserSession user;

  const MainTabScaffold({super.key, required this.user});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserSession?>(
      valueListenable: AuthService.instance.currentSession,
      builder: (context, sessionUser, _) {
        final currentUser = sessionUser ?? widget.user;

        return CupertinoTabScaffold(
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
            border: Border(
              top: BorderSide(
                color: LuxevaTheme.borderGold.withOpacity(0.25),
                width: 0.5,
              ),
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.shield),
                activeIcon: Icon(CupertinoIcons.shield_fill),
                label: 'Bóveda',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.graph_circle),
                activeIcon: Icon(CupertinoIcons.graph_circle_fill),
                label: 'Patrimonio',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.doc_text),
                activeIcon: Icon(CupertinoIcons.doc_text_fill),
                label: 'Bitácora',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_crop_circle),
                activeIcon: Icon(CupertinoIcons.person_crop_circle_fill),
                label: 'Titular',
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
                    return WealthScreen(user: currentUser);
                  case 2:
                    return TransactionsScreen(user: currentUser);
                  case 3:
                    return AccountScreen(user: currentUser);
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
