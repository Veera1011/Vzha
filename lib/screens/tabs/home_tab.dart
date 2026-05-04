import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final Function(int) onTabSelected;
  
  const HomeTab({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Welcome to VZHA',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 32,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your personalized developer productivity hub.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 48),
          _buildActionCard(
            context,
            title: 'News Feed',
            description: 'Stay updated with the latest tech articles cached specifically for you.',
            icon: Icons.article,
            onTap: () => onTabSelected(1), // Index 1 is Feed
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            title: 'Package Tracker',
            description: 'Instantly check versions for NPM and Pub.dev packages.',
            icon: Icons.inventory_2,
            onTap: () => onTabSelected(2), // Index 2 is Packages
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            title: 'Vulnerability Alerts',
            description: 'Query the OSV database for the latest security threats.',
            icon: Icons.warning_rounded,
            onTap: () => onTabSelected(3), // Index 3 is Alerts
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(description, style: Theme.of(context).textTheme.bodyMedium),
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
