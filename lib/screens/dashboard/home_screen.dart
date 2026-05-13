import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_provider.dart';
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;
  final LocaleProvider localeProvider;
  const HomeScreen({super.key, required this.user, required this.onLogout, required this.localeProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _posExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = _roleData(widget.user.role);
    final pages = <Widget>[
      _DashboardPage(t: t),
      _PosSalePage(t: t),
      _SaleHistoryPage(t: t),
      SettingsPage(localeProvider: widget.localeProvider),
    ];
    final titles = [
      t.translate('dashboard'),
      t.translate('posSale'),
      t.translate('saleHistory'),
      t.translate('settings'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                _Sidebar(
                  roleData: data,
                  currentIndex: _currentIndex,
                  posExpanded: _posExpanded,
                  onItemTap: (index) => setState(() => _currentIndex = index),
                  onPosToggle: () => setState(() => _posExpanded = !_posExpanded),
                  onLogout: widget.onLogout,
                  t: t,
                ),
                Expanded(
                  child: Scaffold(
                    body: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titles[_currentIndex],
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subtitles(_currentIndex, t),
                            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          const SizedBox(height: 28),
                          Expanded(child: pages[_currentIndex]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(titles[_currentIndex]),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _roleTitle(widget.user.role, t),
                      style: TextStyle(fontSize: 12, color: data.color, fontWeight: FontWeight.w600),
                    ),
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
            roleData: data,
            currentIndex: _currentIndex,
            posExpanded: _posExpanded,
            onItemTap: (index) {
              setState(() => _currentIndex = index);
              Navigator.pop(context);
            },
            onPosToggle: () => setState(() => _posExpanded = !_posExpanded),
            t: t,
          ),
          body: pages[_currentIndex],
        );
      },
    );
  }

  String _subtitles(int index, AppLocalizations t) {
    switch (index) {
      case 0: return t.translate('overview');
      case 1: return t.translate('createSale');
      case 2: return t.translate('viewHistory');
      case 3: return '';
      default: return '';
    }
  }

  String _roleTitle(UserRole role, AppLocalizations t) {
    switch (role) {
      case UserRole.admin: return t.translate('admin');
      case UserRole.cashier: return t.translate('cashier');
      case UserRole.manager: return t.translate('manager');
      case UserRole.seller: return t.translate('seller');
    }
  }

  _RoleData _roleData(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return _RoleData(
          title: 'Admin',
          color: const Color(0xFF4F8CFF),
          gradient: const LinearGradient(
            colors: [Color(0xFF4F8CFF), Color(0xFF6C5CE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.admin_panel_settings_rounded,
        );
      case UserRole.cashier:
        return _RoleData(
          title: 'Cashier',
          color: const Color(0xFF2DD4BF),
          gradient: const LinearGradient(
            colors: [Color(0xFF2DD4BF), Color(0xFF0891B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.point_of_sale_rounded,
        );
      case UserRole.manager:
        return _RoleData(
          title: 'Manager',
          color: const Color(0xFF8B5CF6),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.analytics_rounded,
        );
      case UserRole.seller:
        return _RoleData(
          title: 'Seller',
          color: const Color(0xFFFB923C),
          gradient: const LinearGradient(
            colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.store_rounded,
        );
    }
  }
}

class _Sidebar extends StatelessWidget {
  final _RoleData roleData;
  final int currentIndex;
  final bool posExpanded;
  final void Function(int) onItemTap;
  final VoidCallback onPosToggle;
  final VoidCallback onLogout;
  final AppLocalizations t;

  const _Sidebar({
    required this.roleData,
    required this.currentIndex,
    required this.posExpanded,
    required this.onItemTap,
    required this.onPosToggle,
    required this.onLogout,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF141929),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          _SidebarHeader(roleData: roleData),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: t.translate('dashboard'),
                  index: 0,
                  currentIndex: currentIndex,
                  roleColor: roleData.color,
                  onTap: onItemTap,
                ),
                _PosNavSection(
                  expanded: posExpanded,
                  currentIndex: currentIndex,
                  roleColor: roleData.color,
                  onToggle: onPosToggle,
                  onItemTap: onItemTap,
                  t: t,
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: t.translate('settings'),
                  index: 3,
                  currentIndex: currentIndex,
                  roleColor: roleData.color,
                  onTap: onItemTap,
                ),
              ],
            ),
          ),
          _SidebarFooter(onLogout: onLogout),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final _RoleData roleData;
  final int currentIndex;
  final bool posExpanded;
  final void Function(int) onItemTap;
  final VoidCallback onPosToggle;
  final AppLocalizations t;

  const _AppDrawer({
    required this.roleData,
    required this.currentIndex,
    required this.posExpanded,
    required this.onItemTap,
    required this.onPosToggle,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _SidebarHeader(roleData: roleData),
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: t.translate('dashboard'),
            index: 0,
            currentIndex: currentIndex,
            roleColor: roleData.color,
            onTap: onItemTap,
          ),
          _PosNavSection(
            expanded: posExpanded,
            currentIndex: currentIndex,
            roleColor: roleData.color,
            onToggle: onPosToggle,
            onItemTap: onItemTap,
            t: t,
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: t.translate('settings'),
            index: 3,
            currentIndex: currentIndex,
            roleColor: roleData.color,
            onTap: onItemTap,
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final _RoleData roleData;
  const _SidebarHeader({required this.roleData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(gradient: roleData.gradient),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(roleData.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('appName'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                roleData.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final VoidCallback onLogout;
  const _SidebarFooter({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: Text(t.translate('logout'), style: const TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: onLogout,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Color roleColor;
  final void Function(int) onTap;
  final double indent;

  const _NavItem({
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? roleColor.withValues(alpha: 0.12) : null,
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: Icon(
            icon,
            color: selected ? roleColor : Colors.white70,
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? roleColor : Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: () => onTap(index),
        ),
      ),
    );
  }
}

class _PosNavSection extends StatelessWidget {
  final bool expanded;
  final int currentIndex;
  final Color roleColor;
  final VoidCallback onToggle;
  final void Function(int) onItemTap;
  final AppLocalizations t;

  const _PosNavSection({
    required this.expanded,
    required this.currentIndex,
    required this.roleColor,
    required this.onToggle,
    required this.onItemTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final posSelected = currentIndex == 1 || currentIndex == 2;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: posSelected ? roleColor.withValues(alpha: 0.12) : null,
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            leading: Icon(
              Icons.shopping_cart_rounded,
              color: posSelected ? roleColor : Colors.white70,
              size: 20,
            ),
            title: Text(
              t.translate('pos'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: posSelected ? FontWeight.w600 : FontWeight.w400,
                color: posSelected ? roleColor : Colors.white,
              ),
            ),
            trailing: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: posSelected ? roleColor : Colors.white70,
                size: 18,
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: onToggle,
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: t.translate('posSale'),
                index: 1,
                currentIndex: currentIndex,
                roleColor: roleColor,
                onTap: onItemTap,
                indent: 16,
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: t.translate('saleHistory'),
                index: 2,
                currentIndex: currentIndex,
                roleColor: roleColor,
                onTap: onItemTap,
                indent: 16,
              ),
            ],
          ),
          crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}

class _DashboardPage extends StatelessWidget {
  final AppLocalizations t;
  const _DashboardPage({required this.t});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.6,
      children: [
        _MetricCard(title: t.translate('totalSales'), value: '\$12,845', change: '+12.5%', up: true, color: const Color(0xFF34D399)),
        _MetricCard(title: t.translate('orders'), value: '346', change: '+8.2%', up: true, color: const Color(0xFF4F8CFF)),
        _MetricCard(title: t.translate('customers'), value: '189', change: '+5.7%', up: true, color: const Color(0xFF8B5CF6)),
        _MetricCard(title: t.translate('revenue'), value: '\$48,230', change: '+15.3%', up: true, color: const Color(0xFFFF6B8A)),
        _MetricCard(title: t.translate('products'), value: '1,024', change: '+3.1%', up: true, color: const Color(0xFF2DD4BF)),
        _MetricCard(title: t.translate('growth'), value: '23.8%', change: '+2.4%', up: true, color: const Color(0xFFFB923C)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool up;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.up,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 16,
                color: up ? const Color(0xFF34D399) : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: up ? const Color(0xFF34D399) : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PosSalePage extends StatelessWidget {
  final AppLocalizations t;
  const _PosSalePage({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.point_of_sale_rounded, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(
            t.translate('posSale'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            t.translate('createSale'),
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.38)),
          ),
        ],
      ),
    );
  }
}

class _SaleHistoryPage extends StatelessWidget {
  final AppLocalizations t;
  const _SaleHistoryPage({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(
            t.translate('saleHistory'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            t.translate('viewHistory'),
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.38)),
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
  const _RoleData({
    required this.title,
    required this.color,
    required this.gradient,
    required this.icon,
  });
}
