import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../models/product_model.dart';
import '../../../theme/app_theme.dart';

class ProductFormPage extends StatefulWidget {
  final Product? editProduct;
  const ProductFormPage({super.key, this.editProduct});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _reorderCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int? _categoryId;
  int? _unitId;
  int? _brandId;
  int? _warehouseId;
  int? _locationId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editProduct != null) {
      final p = widget.editProduct!;
      _nameCtrl.text = p.name;
      _skuCtrl.text = p.sku;
      _priceCtrl.text = p.price.toString();
      _costCtrl.text = p.cost.toString();
      _stockCtrl.text = p.stockQuantity.toString();
      _reorderCtrl.text = p.reorderLevel.toString();
      _descCtrl.text = p.description;
      _categoryId = p.categoryId;
      _unitId = p.unitId;
      _brandId = p.brandId;
      _warehouseId = p.warehouseId;
      _locationId = p.locationId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    _costCtrl.dispose();
    _stockCtrl.dispose();
    _reorderCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'sku': _skuCtrl.text.trim().isEmpty ? 'SKU-${DateTime.now().millisecondsSinceEpoch}' : _skuCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text) ?? 0,
      'cost': double.tryParse(_costCtrl.text) ?? 0,
      'stock_quantity': double.tryParse(_stockCtrl.text) ?? 0,
      'reorder_level': double.tryParse(_reorderCtrl.text) ?? 0,
      'description': _descCtrl.text.trim(),
      'category_id': _categoryId,
      'unit_id': _unitId,
      'brand_id': _brandId,
      'warehouse_id': _warehouseId,
      'location_id': _locationId,
    };

    final inv = context.read<InventoryProvider>();
    bool success;
    if (widget.editProduct != null) {
      success = await inv.updateEntity('products', data, widget.editProduct!.id!);
    } else {
      success = await inv.createEntity('products', data);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editProduct != null ? 'Product updated' : 'Product created'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(inv.error ?? 'Failed to save'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.editProduct != null ? 'Edit' : 'New'} Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Product Name', prefixIcon: Icon(Icons.inventory_2_rounded)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skuCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'SKU (leave blank for auto)', prefixIcon: Icon(Icons.qr_code)),
              ),
              const SizedBox(height: 16),
              Consumer<InventoryProvider>(
                builder: (context, inv, _) => Row(
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: 'Category',
                        value: _categoryId,
                        items: inv.categories,
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DropdownField(
                        label: 'Unit',
                        value: _unitId,
                        items: inv.units,
                        onChanged: (v) => setState(() => _unitId = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Consumer<InventoryProvider>(
                builder: (context, inv, _) => _DropdownField(
                  label: 'Brand',
                  value: _brandId,
                  items: inv.brands,
                  onChanged: (v) => setState(() => _brandId = v),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: _priceCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price', prefixIcon: Icon(Icons.attach_money)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(
                    controller: _costCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cost', prefixIcon: Icon(Icons.money_off)),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: _stockCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock Qty', prefixIcon: Icon(Icons.inventory)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(
                    controller: _reorderCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reorder Level', prefixIcon: Icon(Icons.warning_amber_rounded)),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<InventoryProvider>(
                builder: (context, inv, _) => Row(
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: 'Warehouse',
                        value: _warehouseId,
                        items: inv.warehouses,
                        onChanged: (v) => setState(() {
                          _warehouseId = v;
                          _locationId = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DropdownField(
                        label: 'Location',
                        value: _locationId,
                        items: _warehouseId != null
                            ? inv.locations.where((l) => l.warehouseId == _warehouseId).toList()
                            : inv.locations,
                        onChanged: (v) => setState(() => _locationId = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : Text(widget.editProduct != null ? 'Update Product' : 'Create Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final int? value;
  final List<dynamic> items;
  final void Function(int?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      style: const TextStyle(color: Colors.white),
      dropdownColor: AppTheme.cardColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('None', style: TextStyle(color: Colors.white54))),
        ...items.map((item) => DropdownMenuItem<int>(
          value: item.id,
          child: Text(item.name ?? '', style: const TextStyle(color: Colors.white)),
        )),
      ],
      onChanged: onChanged,
    );
  }
}
