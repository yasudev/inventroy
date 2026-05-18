import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';
import 'entities/entity_list_page.dart';
import 'products/product_list_page.dart';

class ManageDataPage extends StatelessWidget {
  final AppLocalizations t;
  const ManageDataPage({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inv, _) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _EntityCard(
                t: t, icon: Icons.category_rounded, titleKey: 'categories',
                descKey: 'categoriesDesc', count: inv.categories.length,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EntityListPage(entity: 'categories', title: 'Categories', icon: Icons.category_rounded),
                )),
              ),
              _EntityCard(
                t: t, icon: Icons.straighten_rounded, titleKey: 'units',
                descKey: 'unitsDesc', count: inv.units.length,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EntityListPage(entity: 'units', title: 'Units', icon: Icons.straighten_rounded),
                )),
              ),
              _EntityCard(
                t: t, icon: Icons.branding_watermark_rounded, titleKey: 'brands',
                descKey: 'brandsDesc', count: inv.brands.length,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EntityListPage(entity: 'brands', title: 'Brands', icon: Icons.branding_watermark_rounded),
                )),
              ),
              _EntityCard(
                t: t, icon: Icons.people_rounded, titleKey: 'customers',
                descKey: 'customersDesc', count: inv.customers.length,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EntityListPage(entity: 'customers', title: 'Customers', icon: Icons.people_rounded),
                )),
              ),
              _EntityCard(
                t: t, icon: Icons.warehouse_rounded, titleKey: 'warehouses',
                descKey: 'warehousesDesc', count: inv.warehouses.length,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EntityListPage(entity: 'warehouses', title: 'Warehouses', icon: Icons.warehouse_rounded),
                )),
              ),
              _EntityCard(
                t: t, icon: Icons.location_on_rounded, titleKey: 'locations',
                descKey: 'locationsDesc', count: inv.locations.length,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EntityListPage(entity: 'locations', title: 'Locations', icon: Icons.location_on_rounded),
                )),
              ),
              _EntityCard(
                t: t, icon: Icons.inventory_2_rounded, titleKey: 'products',
                descKey: 'inventoryItems', count: inv.products.length,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ProductListPage(),
                )),
                color: AppTheme.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntityCard extends StatelessWidget {
  final AppLocalizations t;
  final IconData icon;
  final String titleKey;
  final String descKey;
  final int count;
  final VoidCallback onTap;
  final Color? color;

  const _EntityCard({
    required this.t, required this.icon, required this.titleKey,
    required this.descKey, required this.count, required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.all(24),
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
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: c, size: 22),
                ),
                const Spacer(),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: c,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              t.translate(titleKey),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              t.translate(descKey),
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text('Manage ${t.translate(titleKey)}', style: const TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c,
                  side: BorderSide(color: c.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
