import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeTab extends StatefulWidget {
  final Function(int) onTabSelected;

  const HomeTab({super.key, required this.onTabSelected});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Developer';
    final name = email.split('@')[0];

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Container(
        color: cs.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Greeting ──────────────────────────────────────────
              Text(
                '${_getGreeting()},',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(
                name.capitalize(),
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // ── Carousel banner ──────────────────────────────────────────
              SizedBox(
                height: 180,
                child: PageView(
                  children: [
                    _buildBanner(
                      context, 
                      '📰 Latest Tech News', 
                      'Stay ahead with curated updates from Dev.to & Hacker News.', 
                      [cs.primary, cs.primary.withOpacity(0.7)],
                    ),
                    _buildBanner(
                      context, 
                      '📦 Package Hub', 
                      'Monitor npm & pub.dev versions for your dependencies.', 
                      [cs.secondary, cs.secondary.withOpacity(0.7)],
                    ),
                    _buildBanner(
                      context, 
                      '🔐 Security Alerts', 
                      'Real-time CVE tracking and vulnerability scans.', 
                      [cs.tertiary, cs.tertiary.withOpacity(0.7)],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quick Explorer', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Action cards ──────────────────────────────────────────────
              _buildModernCard(
                context,
                title: 'Live News Feed',
                description: 'Real-time tech articles and trending repositories.',
                icon: Icons.article_outlined,
                color: cs.primary,
                onTap: () => widget.onTabSelected(1),
              ),
              const SizedBox(height: 12),
              _buildModernCard(
                context,
                title: 'Security & Packages',
                description: 'Dependency analysis and vulnerability alerts.',
                icon: Icons.shield_outlined,
                color: cs.secondary,
                onTap: () => widget.onTabSelected(2),
              ),
              const SizedBox(height: 12),
              _buildModernCard(
                context,
                title: 'Developer Chat',
                description: 'Global rooms and AI-powered collaboration.',
                icon: Icons.forum_outlined,
                color: cs.tertiary,
                onTap: () => widget.onTabSelected(3),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, String title, String subtitle, List<Color> colors) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            subtitle, 
            style: tt.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9), height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(BuildContext context, {required String title, required String description, required IconData icon, required Color color, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      description, 
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: cs.onSurfaceVariant.withOpacity(0.3), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

