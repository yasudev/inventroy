import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Consumer<InventoryProvider>(
      builder: (context, inv, _) {
        final items = _getItems(inv);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                onChanged: (v) => inv.setSearch(v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title}...',
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
                          Text('No ${widget.title} found',
                              style: TextStyle(color: Colors.white38, fontSize: 16)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => inv.refresh(),
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) => _EntityTile(
                          entity: widget.entity,
                          title: _getDisplayName(items[i]),
                          subtitle: _getSubtitle(items[i]),
                          icon: widget.icon,
                          onEdit: () => _openForm(context, items[i]),
                          onDelete: () => _confirmDelete(context, items[i]),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _getItems(InventoryProvider inv) {
    switch (widget.entity) {
      case 'categories': return inv.filteredCategories;
      case 'units': return inv.filteredUnits;
      case 'brands': return inv.filteredBrands;
      case 'customers': return inv.filteredCustomers;
      case 'warehouses': return inv.filteredWarehouses;
      case 'locations': return inv.filteredLocations;
      default: return [];
    }
  }

  String _getDisplayName(dynamic item) {
    return item.name ?? item.title ?? '';
  }

  String _getSubtitle(dynamic item) {
    if (item is Map) return item['description'] ?? item['phone'] ?? '';
    if (item.warehouseName != null) return 'Warehouse: ${item.warehouseName}';
    if (item.phone != null && item.phone.isNotEmpty) return item.phone;
    if (item.description != null && item.description.isNotEmpty) return item.description;
    return '';
  }

  Future<void> _openForm(BuildContext context, dynamic item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EntityFormPage(
          entity: widget.entity,
          title: widget.title,
          editData: item.id != null ? item : null,
        ),
      ),
    );
    if (result == true && mounted) {
      context.read<InventoryProvider>().refresh();
    }
  }

  Future<void> _confirmDelete(BuildContext context, dynamic item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${_getDisplayName(item)}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final success = await context.read<InventoryProvider>().deleteEntity(widget.entity, item.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.title} deleted'), backgroundColor: AppTheme.successColor),
        );
      }
    }
  }
}

class _EntityTile extends StatelessWidget {
  final String entity;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EntityTile({
    required this.entity,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: subtitle.isNotEmpty
            ? Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12))
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: Colors.white.withValues(alpha: 0.6)),
          onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Edit'))),
            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18, color: AppTheme.errorColor), title: Text('Delete', style: TextStyle(color: AppTheme.errorColor)))),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
