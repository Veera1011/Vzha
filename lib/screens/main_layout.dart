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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          leadingWidth: 60,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4, bottom: 4),
            child: ClipOval(
              child: Image.asset(
                'assets/App_log.png',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
          ),
          titleSpacing: 8,
          title: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.search, color: Colors.black54),
                ),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search VZHA...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.black54),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 1)),
        ),
        child: NavigationBar(
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
      ),
    );
  }
}
