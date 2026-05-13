import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.user, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _posExpanded = false;

  final _pages = [
    const _DashboardPage(),
    const _PosSalePage(),
    const _SaleHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final data = _roleData(widget.user.role);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(_titles[_currentIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                widget.user.displayName,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      drawer: _AppDrawer(
        user: widget.user,
        roleData: data,
        currentIndex: _currentIndex,
        posExpanded: _posExpanded,
        onItemTap: (index) {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
        onPosToggle: () => setState(() => _posExpanded = !_posExpanded),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
    );
  }

  static const _titles = ['Dashboard', 'POS Sale', 'Sale History'];

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

class _AppDrawer extends StatelessWidget {
  final AppUser user;
  final _RoleData roleData;
  final int currentIndex;
  final bool posExpanded;
  final void Function(int) onItemTap;
  final VoidCallback onPosToggle;

  const _AppDrawer({
    required this.user,
    required this.roleData,
    required this.currentIndex,
    required this.posExpanded,
    required this.onItemTap,
    required this.onPosToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _DrawerHeader(user: user, roleData: roleData),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 0,
                  currentIndex: currentIndex,
                  roleColor: roleData.color,
                  onTap: onItemTap,
                ),
                _PosSection(
                  expanded: posExpanded,
                  currentIndex: currentIndex,
                  roleColor: roleData.color,
                  onToggle: onPosToggle,
                  onItemTap: onItemTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final AppUser user;
  final _RoleData roleData;
  const _DrawerHeader({required this.user, required this.roleData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(gradient: roleData.gradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(roleData.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'Yum Inventory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roleData.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Color roleColor;
  final void Function(int) onTap;
  final double indent;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.roleColor,
    required this.onTap,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final selected = currentIndex == index;
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? roleColor.withValues(alpha: 0.15) : null,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: selected ? roleColor : Colors.white54,
            size: 22,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? roleColor : Colors.white70,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: () => onTap(index),
        ),
      ),
    );
  }
}

class _PosSection extends StatelessWidget {
  final bool expanded;
  final int currentIndex;
  final Color roleColor;
  final VoidCallback onToggle;
  final void Function(int) onItemTap;

  const _PosSection({
    required this.expanded,
    required this.currentIndex,
    required this.roleColor,
    required this.onToggle,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final posSelected = currentIndex == 1 || currentIndex == 2;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: posSelected ? roleColor.withValues(alpha: 0.15) : null,
          ),
          child: ListTile(
            leading: Icon(
              Icons.shopping_cart_rounded,
              color: posSelected ? roleColor : Colors.white54,
              size: 22,
            ),
            title: Text(
              'POS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: posSelected ? FontWeight.w600 : FontWeight.w400,
                color: posSelected ? roleColor : Colors.white70,
              ),
            ),
            trailing: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: posSelected ? roleColor : Colors.white54,
                size: 20,
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: onToggle,
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              _DrawerItem(
                icon: Icons.receipt_long_rounded,
                label: 'POS Sale',
                index: 1,
                currentIndex: currentIndex,
                roleColor: roleColor,
                onTap: onItemTap,
                indent: 16,
              ),
              _DrawerItem(
                icon: Icons.history_rounded,
                label: 'Sale History',
                index: 2,
                currentIndex: currentIndex,
                roleColor: roleColor,
                onTap: onItemTap,
                indent: 16,
              ),
            ],
          ),
          crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dashboard_rounded, color: Colors.white24, size: 64),
          SizedBox(height: 16),
          Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Overview and statistics',
            style: TextStyle(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _PosSalePage extends StatelessWidget {
  const _PosSalePage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.point_of_sale_rounded, color: Colors.white24, size: 64),
          SizedBox(height: 16),
          Text(
            'POS Sale',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Process new sales transactions',
            style: TextStyle(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _SaleHistoryPage extends StatelessWidget {
  const _SaleHistoryPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, color: Colors.white24, size: 64),
          SizedBox(height: 16),
          Text(
            'Sale History',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'View past transactions',
            style: TextStyle(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
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
