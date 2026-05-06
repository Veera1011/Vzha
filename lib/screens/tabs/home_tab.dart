import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  final Function(int) onTabSelected;

  const HomeTab({super.key, required this.onTabSelected});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Future<void> _handleRefresh() async {
    // Simulate a refresh delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Container(
        color: cs.surfaceContainerLowest,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Carousel banner ──────────────────────────────────────────
              SizedBox(
                height: 170,
                child: PageView(
                  children: [
                    _buildBanner(context, '📰 Latest Tech News', 'Curated from Dev.to, HN & GitHub', cs.primaryContainer, cs.onPrimaryContainer),
                    _buildBanner(context, '📦 Package Tracker', 'npm & pub.dev versions at a glance', cs.secondaryContainer, cs.onSecondaryContainer),
                    _buildBanner(context, '🔐 Vulnerability Alerts', 'Stay ahead of security issues', cs.errorContainer, cs.onErrorContainer),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Text('Quick Access', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // ── Action cards (index matches bottom nav) ───────────────────
              _buildActionCard(
                context,
                title: 'News Feed',
                description: 'Stay updated with the latest tech articles curated for you.',
                icon: Icons.article_rounded,
                containerColor: cs.primaryContainer,
                iconColor: cs.onPrimaryContainer,
                onTap: () => widget.onTabSelected(1),
              ),
              const SizedBox(height: 10),
              _buildActionCard(
                context,
                title: 'Package & Alerts',
                description: 'Check npm/pub.dev versions and scan for CVEs in one place.',
                icon: Icons.build_rounded,
                containerColor: cs.secondaryContainer,
                iconColor: cs.onSecondaryContainer,
                onTap: () => widget.onTabSelected(2),
              ),
              const SizedBox(height: 10),
              _buildActionCard(
                context,
                title: 'Dev Chat',
                description: 'Collaborate in package and topic rooms with inline AI assistance.',
                icon: Icons.forum_rounded,
                containerColor: cs.tertiaryContainer,
                iconColor: cs.onTertiaryContainer,
                onTap: () => widget.onTabSelected(3),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, String title, String subtitle, Color bg, Color fg) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.titleLarge?.copyWith(color: fg, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: tt.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String description, required IconData icon, required Color containerColor, required Color iconColor, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(description, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 2),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
