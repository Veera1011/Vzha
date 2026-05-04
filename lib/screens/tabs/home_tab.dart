import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final Function(int) onTabSelected;
  
  const HomeTab({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200, // Amazon's light grey background
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Carousel Banner Mock
            SizedBox(
              height: 200,
              child: PageView(
                children: [
                  _buildBanner(context, 'Explore Developer Tools', Colors.blue.shade800),
                  _buildBanner(context, 'Top NPM Packages of 2026', Colors.teal.shade700),
                  _buildBanner(context, 'Critical Vulnerabilities Update', Colors.red.shade800),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Horizontal scrolling category list
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Keep exploring for your projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildCategoryItem(context, 'News Feed', Icons.article, () => onTabSelected(1)),
                        _buildCategoryItem(context, 'Packages', Icons.inventory_2, () => onTabSelected(2)),
                        _buildCategoryItem(context, 'Alerts', Icons.warning_rounded, () => onTabSelected(3)),
                        _buildCategoryItem(context, 'Saved', Icons.bookmark, () => onTabSelected(4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Deal of the Day / Featured Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Productivity Picks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGridCard(context, 'Flutter Favorites', Icons.flutter_dash, () => onTabSelected(2)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGridCard(context, 'Daily Tech News', Icons.newspaper, () => onTabSelected(1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGridCard(context, 'Security Advisories', Icons.security, () => onTabSelected(3)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGridCard(context, 'Your Saved Items', Icons.favorite_border, () => onTabSelected(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, String text, Color color) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
