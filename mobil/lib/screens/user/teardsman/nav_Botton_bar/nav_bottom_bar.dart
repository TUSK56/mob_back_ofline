import 'package:flutter/material.dart';
import '../Tradesman_Messages/messages_list.dart';
import '../home/find_jobs.dart';
import '../home/tradesman_my_apps_screen.dart';
import '../home/tradesman_browse_companies_screen.dart';
import '../profile/tradesman_profile.dart';

class Navbotton extends StatefulWidget {
  const Navbotton({super.key});

  @override
  State<Navbotton> createState() => _NavbottonState();
}

class _NavbottonState extends State<Navbotton> {
  int _selectedIndex = 0;

  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';

  final List<Widget> _pages = [
    const FindJobs(), 
    const TradesmanMyAppsScreen(),
    const TradesmanBrowseCompaniesScreen(),
    const MessagesList(), 
    const TradesmanProfile(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Theme.of(context).cardColor,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: _isAr ? 'اكتشف' : 'Discover',
          ),
          NavigationDestination(
            icon: const Icon(Icons.fact_check),
            label: _isAr ? 'تقديماتي' : 'My Apps',
          ),
          NavigationDestination(
            icon: const Icon(Icons.business),
            label: _isAr ? 'الشركات' : 'Companies',
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble),
            label: _isAr ? 'الرسائل' : 'Messages',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: _isAr ? 'الملف الشخصي' : 'Profile',
          ),
        ],
      ),
    );
  }
}
