import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../models/product_model.dart';
import '../../../theme/app_theme.dart';
import 'product_form_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                onChanged: (v) => inv.setSearch(v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search products...',
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
              child: inv.filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inventory_2_rounded, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text('No products found', style: TextStyle(color: Colors.white38, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _openForm(context, null),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => inv.refresh(),
                      child: ListView.builder(
                        itemCount: inv.filteredProducts.length,
                        itemBuilder: (_, i) => _ProductTile(
                          product: inv.filteredProducts[i],
                          onEdit: () => _openForm(context, inv.filteredProducts[i]),
                          onDelete: () => _confirmDelete(context, inv.filteredProducts[i]),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context, Product? product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(editProduct: product)),
    );
    if (result == true && mounted) {
      context.read<InventoryProvider>().refresh();
    }
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${product.name}"?', style: const TextStyle(color: Colors.white70)),
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
      final success = await context.read<InventoryProvider>().deleteEntity('products', product.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Product deleted'), backgroundColor: AppTheme.successColor),
        );
      }
    }
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final lowStock = product.stockQuantity <= product.reorderLevel;
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\$${product.price.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(
          'SKU: ${product.sku} | Stock: ${product.stockQuantity.toStringAsFixed(0)} ${product.unitName ?? ''}'
          '${product.categoryName != null ? ' | ${product.categoryName}' : ''}',
          style: TextStyle(color: lowStock ? AppTheme.warningColor : Colors.white.withValues(alpha: 0.6), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lowStock)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('LOW', style: TextStyle(fontSize: 10, color: AppTheme.warningColor, fontWeight: FontWeight.bold)),
              ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: Colors.white.withValues(alpha: 0.6)),
              onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Edit'))),
                const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18, color: AppTheme.errorColor), title: Text('Delete', style: TextStyle(color: AppTheme.errorColor)))),
              ],
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
