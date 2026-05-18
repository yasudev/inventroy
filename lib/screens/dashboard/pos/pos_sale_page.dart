import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../models/product_model.dart';
import '../../../models/sale_model.dart';
import '../../../theme/app_theme.dart';

class PosSalePage extends StatefulWidget {
  final int userId;
  const PosSalePage({super.key, required this.userId});

  @override
  State<PosSalePage> createState() => _PosSalePageState();
}

class _PosSalePageState extends State<PosSalePage> {
  final _searchCtrl = TextEditingController();
  final List<SaleItem> _cart = [];
  int? _customerId;
  String _paymentMethod = 'cash';
  bool _saving = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  double get _total => _cart.fold(0, (sum, item) => sum + item.subtotal);

  void _addToCart(Product product) {
    final existing = _cart.where((i) => i.productId == product.id).firstOrNull;
    setState(() {
      if (existing != null) {
        existing.quantity += 1;
        existing.subtotal = existing.quantity * existing.unitPrice;
      } else {
        _cart.add(SaleItem(
          productId: product.id!,
          quantity: 1,
          unitPrice: product.price,
          subtotal: product.price,
          productName: product.name,
        ));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _updateQty(int index, double qty) {
    if (qty <= 0) {
      _removeFromCart(index);
      return;
    }
    setState(() {
      _cart[index].quantity = qty;
      _cart[index].subtotal = qty * _cart[index].unitPrice;
    });
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;
    setState(() => _saving = true);

    final inv = context.read<InventoryProvider>();
    final sale = await inv.createSale(
      userId: widget.userId,
      customerId: _customerId,
      items: _cart,
    );

    if (mounted) {
      setState(() => _saving = false);
      if (sale != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: const Text('Sale Complete', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sale #${sale.id}', style: const TextStyle(color: Colors.white70)),
                Text('Total: \$${sale.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.successColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _cart.clear();
                    _customerId = null;
                  });
                },
                child: const Text('New Sale'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inv, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => inv.setSearch(v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      onPressed: () {},
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: inv.filteredProducts.isEmpty
                      ? Center(child: Text('No products found', style: TextStyle(color: Colors.white38)))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: inv.filteredProducts.length,
                          itemBuilder: (_, i) => _buildProductCard(inv.filteredProducts[i]),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_cart_rounded, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text('Cart (${_cart.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _cart.isEmpty
                        ? Center(child: Text('Cart is empty', style: TextStyle(color: Colors.white38)))
                        : ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (_, i) => _CartItemTile(
                              item: _cart[i],
                              onQtyChanged: (qty) => _updateQty(i, qty),
                              onRemove: () => _removeFromCart(i),
                            ),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Payment:', style: TextStyle(color: Colors.white70)),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _paymentMethod,
                              dropdownColor: AppTheme.cardColor,
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                                DropdownMenuItem(value: 'card', child: Text('Card')),
                                DropdownMenuItem(value: 'mobile', child: Text('Mobile')),
                              ],
                              onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: (_cart.isEmpty || _saving) ? null : _checkout,
                            icon: _saving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.receipt_long_rounded),
                            label: Text(_saving ? 'Processing...' : 'Checkout \$${_total.toStringAsFixed(2)}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              disabledBackgroundColor: AppTheme.successColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final inCart = _cart.any((i) => i.productId == product.id);
    return GestureDetector(
      onTap: product.stockQuantity > 0 ? () => _addToCart(product) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: inCart ? AppTheme.primaryColor.withValues(alpha: 0.15) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: inCart ? AppTheme.primaryColor.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Stock: ${product.stockQuantity.toStringAsFixed(0)}', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final SaleItem item;
  final void Function(double) onQtyChanged;
  final VoidCallback onRemove;

  const _CartItemTile({required this.item, required this.onQtyChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                Text('\$${item.unitPrice.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 18),
                color: Colors.white54,
                onPressed: () => onQtyChanged(item.quantity - 1),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              Text(item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                color: Colors.white54,
                onPressed: () => onQtyChanged(item.quantity + 1),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              const SizedBox(width: 4),
              Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold, fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                color: AppTheme.errorColor,
                onPressed: onRemove,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
