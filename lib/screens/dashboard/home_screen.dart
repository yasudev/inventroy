import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final data = _roleData(user.role);
    return Scaffold(
      appBar: AppBar(
        title: Text('${data.title} Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                user.displayName,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: data.gradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.35),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(data.icon, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome ${data.title}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              data.description,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  _RoleData _roleData(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return _RoleData(
          title: 'Admin',
          color: AppTheme.primaryColor,
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.admin_panel_settings_rounded,
          description: 'You have full system access',
        );
      case UserRole.cashier:
        return _RoleData(
          title: 'Cashier',
          color: const Color(0xFF00E5FF),
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF00B8D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.point_of_sale_rounded,
          description: 'Process customer transactions',
        );
      case UserRole.manager:
        return _RoleData(
          title: 'Manager',
          color: const Color(0xFF4CAF50),
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.analytics_rounded,
          description: 'Oversee operations and reports',
        );
      case UserRole.seller:
        return _RoleData(
          title: 'Seller',
          color: const Color(0xFFAB47BC),
          gradient: const LinearGradient(
            colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.store_rounded,
          description: 'Manage your sales and inventory',
        );
    }
  }
}

class _RoleData {
  final String title;
  final Color color;
  final Gradient gradient;
  final IconData icon;
  final String description;
  const _RoleData({
    required this.title,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.description,
  });
}
