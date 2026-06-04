import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: Color(0xFF203554),
        border: Border(top: BorderSide(color: Color(0xFF2E4A72))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        backgroundColor: const Color(0xFF203554),
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos_outlined),
            activeIcon: Icon(Icons.sos_rounded),
            label: 'Rescue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            activeIcon: Icon(Icons.manage_accounts_rounded),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Import lazy untuk menghindari circular import
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/admin/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/admin/rescue');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/admin/profile');
    }
  }
}
