import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/category_model.dart';
import '../../../providers/inventory_provider.dart';
import '../../../theme/app_theme.dart';
import 'entity_form_page.dart';

class EntityListPage extends StatefulWidget {
  final String entity;
  final String title;
  final IconData icon;

  const EntityListPage({
    super.key,
    required this.entity,
    required this.title,
    required this.icon,
  });

  @override
  State<EntityListPage> createState() => _EntityListPageState();
}

class _EntityListPageState extends State<EntityListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().setSearch('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Consumer<InventoryProvider>(
        builder: (context, inv, _) {
          final items = _getItems(inv);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: TextField(
                  onChanged: (v) => inv.setSearch(v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '${t.translate('search')} ${widget.title}...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: inv.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => inv.setSearch(''),
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(widget.icon, size: 64, color: Colors.white24),
                            const SizedBox(height: 16),
                            Text(
                              'No ${widget.title} found',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => inv.refresh(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _EntityTile(
                            entity: widget.entity,
                            title: _getDisplayName(items[i]),
                            subtitle: _getSubtitle(items[i]),
                            icon: widget.icon,
                            isActive: _getIsActive(items[i]),
                            onEdit: () => _openForm(context, items[i]),
                            onDelete: () => _confirmDelete(context, items[i]),
                            onToggle: _getIsActive(items[i]) != null
                                ? () => _toggleStatus(
                                    context,
                                    items[i],
                                    !(_getIsActive(items[i]) ?? true),
                                  )
                                : null,
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.translate('add')),
      ),
    );
  }

  List<dynamic> _getItems(InventoryProvider inv) {
    switch (widget.entity) {
      case 'categories':
        return inv.filteredCategories;
      case 'units':
        return inv.filteredUnits;
      case 'brands':
        return inv.filteredBrands;
      case 'customers':
        return inv.filteredCustomers;
      case 'warehouses':
        return inv.filteredWarehouses;
      case 'locations':
        return inv.filteredLocations;
      default:
        return [];
    }
  }

  String _getDisplayName(dynamic item) {
    return item.name ?? item.title ?? '';
  }

  String _getSubtitle(dynamic item) {
    if (item is Map) return item['description'] ?? item['phone'] ?? '';
    if (item.warehouseName != null) return 'Warehouse: ${item.warehouseName}';
    if (item.phone != null && item.phone.isNotEmpty) return item.phone;
    if (item.description != null && item.description.isNotEmpty) {
      return item.description;
    }
    return '';
  }

  bool? _getIsActive(dynamic item) {
    if (item is ItemCategory) return item.isActive;
    if (item is Map) {
      final v = item['is_active'];
      if (v == null) return null;
      return v == 1 || v == true || v == '1';
    }
    return null;
  }

  Future<void> _openForm(BuildContext context, dynamic item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntityFormPage(
          entity: widget.entity,
          title: widget.title,
          editData: item?.id != null ? item : null,
        ),
      ),
    );
    if (result == true && mounted) {
      if (!context.mounted) return;
      context.read<InventoryProvider>().refresh();
    }
  }

  Future<void> _toggleStatus(
    BuildContext context,
    dynamic item,
    bool newStatus,
  ) async {
    final provider = context.read<InventoryProvider>();
    final success = await provider.updateEntity(widget.entity, {
      'is_active': newStatus ? 1 : 0,
    }, item.id!);
    if (!mounted) return;
    if (!context.mounted) return;
    final t = AppLocalizations.of(context);
    if (success) {
      _showToast(
        context,
        '${_getDisplayName(item)} ${newStatus ? t.translate('activated') : t.translate('deactivated')}',
        AppTheme.successColor,
      );
    } else {
      _showToast(
        context,
        provider.error ?? t.translate('failedToUpdateStatus'),
        AppTheme.errorColor,
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, dynamic item) async {
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          t.translate('deleted'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '${t.translate('deleted')} "${_getDisplayName(item)}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted && context.mounted) {
      final provider = context.read<InventoryProvider>();
      final success = await provider.deleteEntity(widget.entity, item.id!);
      if (!mounted) return;
      if (!context.mounted) return;
      if (success) {
        _showToast(
          context,
          '${_getDisplayName(item)} ${t.translate('deleted')}',
          AppTheme.successColor,
        );
      } else {
        _showToast(
          context,
          provider.error ?? t.translate('failedToDelete'),
          AppTheme.errorColor,
        );
      }
    }
  }

  void _showToast(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppTheme.successColor
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _EntityTile extends StatelessWidget {
  final String entity;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool? isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onToggle;

  const _EntityTile({
    required this.entity,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isActive,
    required this.onEdit,
    required this.onDelete,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasStatus = isActive != null && onToggle != null;
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (isActive!
                                            ? AppTheme.successColor
                                            : Colors.white38)
                                        .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isActive! ? 'ON' : 'OFF',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isActive!
                                      ? AppTheme.successColor
                                      : Colors.white38,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasStatus)
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            (isActive! ? AppTheme.successColor : Colors.white38)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isActive!
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_outlined,
                        color: isActive!
                            ? AppTheme.successColor
                            : Colors.white38,
                        size: 28,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.edit_rounded,
                  color: AppTheme.primaryColor,
                  onTap: onEdit,
                ),
                const SizedBox(width: 4),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  color: AppTheme.errorColor,
                  onTap: onDelete,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
