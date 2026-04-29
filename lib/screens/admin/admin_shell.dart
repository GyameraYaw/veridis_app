import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../services/wallet_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_layout.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_withdrawals_screen.dart';
import 'admin_bins_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  static const _tabTitles = ['Overview', 'Users', 'Withdrawals', 'Bins'];

  List<Widget> get _pages => const [
        AdminDashboardScreen(),
        AdminUsersScreen(),
        AdminWithdrawalsScreen(),
        AdminBinsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('VERIDIS Admin', style: AppTextStyles.heroCaption),
              Text(
                _tabTitles[_selectedIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                SessionService().clearLocalData();
                WalletService().clearLocalData();
                await AuthService().signOut();
              },
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              label: 'Withdrawals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delete_outline),
              label: 'Bins',
            ),
          ],
        ),
      ),
    );
  }
}
