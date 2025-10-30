import 'package:flutter/material.dart';
import 'package:game_rank/pages/tabs/settings_page.dart';

import 'tabs/home_page.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[HomePage(), SettingsPage(),SettingsPage()];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00F0FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00F0FF), width: 2),
              ),
              child: Icon(
                Icons.videogame_asset,
                color: const Color(0xFF00F0FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GAME RANK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00F0FF),
                    letterSpacing: 2,
                    height: 1,
                  ),
                ),
                Text(
                  'EVENTO 2025',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF39FF14),
                    letterSpacing: 1.5,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1A1F3A), const Color(0xFF0F1629)],
            ),
            border: Border(
              bottom: BorderSide(color: const Color(0xFF00F0FF), width: 2),
            ),
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1A1F3A), const Color(0xFF0F1629)],
          ),
          border: Border(
            top: BorderSide(color: const Color(0xFF00F0FF), width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F0FF).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF00F0FF),
          unselectedItemColor: const Color(0xFF607D8B),
          selectedFontSize: 12,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          unselectedLabelStyle: const TextStyle(letterSpacing: 1),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.games, 0),
              activeIcon: _buildActiveNavIcon(Icons.games, 0),
              label: 'JUEGOS',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.leaderboard, 1),
              activeIcon: _buildActiveNavIcon(Icons.leaderboard, 1),
              label: 'STATS',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.settings, 2),
              activeIcon: _buildActiveNavIcon(Icons.settings, 2),
              label: 'CONFIG',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, size: 24),
    );
  }

  Widget _buildActiveNavIcon(IconData icon, int index) {
    Color iconColor;
    switch (index) {
      case 0:
        iconColor = const Color(0xFF00F0FF);
        break;
      case 1:
        iconColor = const Color(0xFFFF00FF);
        break;
      case 2:
        iconColor = const Color(0xFF39FF14);
        break;
      default:
        iconColor = const Color(0xFF00F0FF);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, size: 24, color: iconColor),
    );
  }
}
