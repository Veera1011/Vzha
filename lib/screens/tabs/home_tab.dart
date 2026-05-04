import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final Function(int) onTabSelected;
  
  const HomeTab({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100, // Clean light background
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Carousel Banner for announcements
            SizedBox(
              height: 180,
              child: PageView(
                children: [
                  _buildBanner(context, 'Explore Developer Tools', Colors.blue.shade800),
                  _buildBanner(context, 'Top NPM Packages of 2026', Colors.teal.shade700),
                  _buildBanner(context, 'Critical Vulnerabilities Update', Colors.red.shade800),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'News Feed',
              description: 'Stay updated with the latest tech articles curated for you.',
              icon: Icons.article_outlined,
              color: Colors.blue,
              onTap: () => onTabSelected(1), // Index 1 is Feed
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Package Tracker',
              description: 'Instantly check versions for NPM and Pub.dev packages.',
              icon: Icons.inventory_2_outlined,
              color: Colors.green,
              onTap: () => onTabSelected(2), // Index 2 is Packages
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Vulnerability Alerts',
              description: 'Query the OSV database for the latest security threats.',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              onTap: () => onTabSelected(3), // Index 3 is Alerts
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
