import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'auth/login_screen.dart';
import 'tabs/feed_tab.dart';
import 'tabs/packages_tab.dart';
import 'tabs/alerts_tab.dart';
import 'tabs/saved_tab.dart';
import 'settings_screen.dart';
import 'tabs/home_tab.dart';
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final SupabaseService _supabaseService = SupabaseService();

  final List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    _tabs.addAll([
      HomeTab(onTabSelected: (index) => setState(() => _currentIndex = index)),
      const FeedTab(),
      const PackagesTab(),
      const AlertsTab(),
      const SavedTab(),
    ]);
  }

  Future<void> _logout() async {
    await _supabaseService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VZHA', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Packages'),
          NavigationDestination(icon: Icon(Icons.warning_amber_rounded), selectedIcon: Icon(Icons.warning_rounded), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }
}
