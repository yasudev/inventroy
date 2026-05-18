import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../models/sale_model.dart';
import '../../../theme/app_theme.dart';

class SaleHistoryPage extends StatefulWidget {
  const SaleHistoryPage({super.key});

  @override
  State<SaleHistoryPage> createState() => _SaleHistoryPageState();
}

class _SaleHistoryPageState extends State<SaleHistoryPage> {
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
        if (inv.sales.isEmpty && !inv.isLoading) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_rounded, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text('No sales yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => inv.refresh(),
          child: ListView.builder(
            itemCount: inv.filteredSales.length,
            itemBuilder: (_, i) => _SaleCard(sale: inv.filteredSales[i]),
          ),
        );
      },
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.receipt_rounded, color: AppTheme.successColor, size: 22),
        ),
        title: Row(
          children: [
            Text('#${sale.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('\$${sale.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        subtitle: Text(
          sale.createdAt != null ? sale.createdAt!.substring(0, 19).replaceAll('T', ' ') : '',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sale.customerName != null)
                  Text('Customer: ${sale.customerName}', style: TextStyle(color: Colors.white70, fontSize: 13)),
                if (sale.userName != null)
                  Text('Cashier: ${sale.userName}', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('Payment: ${sale.paymentMethod.toUpperCase()}', style: TextStyle(color: Colors.white70, fontSize: 13)),
                if (sale.items.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Items:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ...sale.items.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.productName ?? 'Product #${item.productId}', style: TextStyle(color: Colors.white70, fontSize: 12))),
                        Text('${item.quantity.toStringAsFixed(0)} x \$${item.unitPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(width: 8),
                        Text('\$${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
