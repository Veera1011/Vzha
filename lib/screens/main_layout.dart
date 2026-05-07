import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/chat_service.dart';
import 'auth/login_screen.dart';
import 'settings_screen.dart';
import 'saved_screen.dart';
import 'tabs/feed_tab.dart';
import 'tabs/tools_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/chat_rooms_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final SupabaseService _supabaseService = SupabaseService();
  final _chatService = ChatService();
  int _totalUnread = 0;

  // Bottom nav visibility (auto-hide on scroll)
  bool _navVisible = true;
  static const _navAnimDuration = Duration(milliseconds: 220);

  // Pages — each kept alive via IndexedStack
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(onTabSelected: (i) => setState(() => _currentIndex = i)),
      const FeedTab(),
      const ToolsTab(),
      const ChatRoomsScreen(),
    ];
    _updateUnreadCount();
  }

  Future<void> _updateUnreadCount() async {
    final count = await _chatService.getTotalUnreadCount();
    if (mounted) {
      setState(() => _totalUnread = count);
    }
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 3 && _navVisible) setState(() => _navVisible = false);
      if (delta < -3 && !_navVisible) setState(() => _navVisible = true);
    }
  }

  Future<void> _logout() async {
    await _supabaseService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  static const _titles = ['Home', 'Feed', 'Tools', 'Dev Chat'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Developer';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'D';

    return Scaffold(
      // ════════════════════════════════════════════════════════════════════
      // Navigation Drawer
      // ════════════════════════════════════════════════════════════════════
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // ── User header ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                color: cs.primaryContainer,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: cs.primary,
                      child: Text(initial, style: tt.titleLarge?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onPrimaryContainer), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Developer', style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: cs.outlineVariant),

              // ── Menu items ───────────────────────────────────────────────
              ListTile(
                leading: Icon(Icons.bookmark_outline, color: cs.onSurface),
                title: Text('Saved Items', style: tt.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: cs.onSurface),
                title: Text('Settings & Appearance', style: tt.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),

              const Spacer(),
              Divider(height: 1, color: cs.outlineVariant),

              // ── Sign out ─────────────────────────────────────────────────
              ListTile(
                leading: Icon(Icons.logout, color: cs.error),
                title: Text('Sign Out', style: tt.bodyMedium?.copyWith(color: cs.error)),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // ════════════════════════════════════════════════════════════════════
      // AppBar
      // ════════════════════════════════════════════════════════════════════
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(_titles[_currentIndex]),
        actions: [
          // User avatar pill
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  initial,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ════════════════════════════════════════════════════════════════════
      // Body — IndexedStack keeps each page alive
      // ════════════════════════════════════════════════════════════════════
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          _onScroll(n);
          return false;
        },
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),

      // ════════════════════════════════════════════════════════════════════
      // Bottom Navigation Bar — hides on scroll down, shows on scroll up
      // ════════════════════════════════════════════════════════════════════
      bottomNavigationBar: AnimatedSlide(
        duration: _navAnimDuration,
        curve: Curves.easeInOut,
        offset: _navVisible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: _navAnimDuration,
          opacity: _navVisible ? 1.0 : 0.0,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) {
              setState(() {
                _currentIndex = i;
                _navVisible = true; // always show on tab switch
              });
              _updateUnreadCount();
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article_rounded),
                label: 'Feed',
              ),
              const NavigationDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build_rounded),
                label: 'Tools',
              ),
              NavigationDestination(
                icon: Badge(
                  label: Text(_totalUnread.toString()),
                  isLabelVisible: _totalUnread > 0,
                  child: const Icon(Icons.forum_outlined),
                ),
                selectedIcon: const Icon(Icons.forum_rounded),
                label: 'Chat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
