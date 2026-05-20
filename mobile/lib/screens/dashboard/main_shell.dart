import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import '../leads/leads_screen.dart';
import '../meetings/meetings_screen.dart';
import '../followups/followups_screen.dart';
import '../../config/theme.dart';
import '../../widgets/voice_button.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    LeadsScreen(),
    MeetingsScreen(),
    FollowupsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      floatingActionButton: const VoiceButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.dashboard_outlined, Icons.dashboard, 'Home', 0),
            _navItem(Icons.people_alt_outlined, Icons.people_alt, 'Leads', 1),
            const SizedBox(width: 60),
            _navItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Meetings', 2),
            _navItem(Icons.flag_outlined, Icons.flag, 'Tasks', 3),
            _navItem(Icons.menu_outlined, Icons.menu, 'More', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData active, String label, int i) {
    final selected = _index == i;
    return InkWell(
      onTap: () => setState(() => _index = i),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? active : icon, color: selected ? AppColors.primary : AppColors.textgrey, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 11,
              color: selected ? AppColors.primary : AppColors.textgrey,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }
}
