import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../theme/app_theme.dart';

class EntityFormPage extends StatefulWidget {
  final String entity;
  final String title;
  final dynamic editData;

  const EntityFormPage({
    super.key,
    required this.entity,
    required this.title,
    this.editData,
  });

  @override
  State<EntityFormPage> createState() => _EntityFormPageState();
}

class _EntityFormPageState extends State<EntityFormPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controllers = _buildControllers();
  }

  Map<String, TextEditingController> _buildControllers() {
    final map = <String, TextEditingController>{};
    final fields = _getFields();
    for (final f in fields) {
      final val = widget.editData != null ? _getFieldValue(widget.editData, f.key) : '';
      map[f.key] = TextEditingController(text: val?.toString() ?? '');
    }
    return map;
  }

  List<_FieldDef> _getFields() {
    switch (widget.entity) {
      case 'categories': return [
          _FieldDef('name', 'Name', Icons.label),
          _FieldDef('description', 'Description', Icons.description, multiline: true),
        ];
      case 'units': return [
          _FieldDef('name', 'Name', Icons.straighten),
          _FieldDef('abbreviation', 'Abbreviation (e.g. kg, pcs)', Icons.text_fields),
        ];
      case 'brands': return [
          _FieldDef('name', 'Name', Icons.branding_watermark),
          _FieldDef('description', 'Description', Icons.description, multiline: true),
        ];
      case 'customers': return [
          _FieldDef('name', 'Name', Icons.person),
          _FieldDef('phone', 'Phone', Icons.phone),
          _FieldDef('email', 'Email', Icons.email),
          _FieldDef('address', 'Address', Icons.location_on, multiline: true),
        ];
      case 'warehouses': return [
          _FieldDef('name', 'Name', Icons.warehouse),
          _FieldDef('address', 'Address', Icons.location_on, multiline: true),
        ];
      case 'locations': return [
          _FieldDef('name', 'Name', Icons.location_on),
          _FieldDef('code', 'Code / Aisle', Icons.qr_code),
        ];
      default: return [];
    }
  }

  dynamic _getFieldValue(dynamic data, String key) {
    if (data is Map) return data[key];
    if (key == 'name') return data.name;
    if (key == 'description') return data.description;
    if (key == 'abbreviation') return data.abbreviation;
    if (key == 'phone') return data.phone;
    if (key == 'email') return data.email;
    if (key == 'address') return data.address;
    if (key == 'code') return data.code;
    return '';
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      data[entry.key] = entry.value.text.trim();
    }

    bool success;
    if (widget.editData != null) {
      success = await context.read<InventoryProvider>().updateEntity(
        widget.entity, data, widget.editData.id!,
      );
    } else {
      success = await context.read<InventoryProvider>().createEntity(
        widget.entity, data,
      );
    }

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editData != null ? '${widget.title} updated' : '${widget.title} created'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<InventoryProvider>().error ?? 'Failed to save'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = _getFields();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.editData != null ? 'Edit' : 'New'} ${widget.title}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ...fields.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _controllers[f.key],
                  maxLines: f.multiline ? 3 : 1,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: f.label,
                    prefixIcon: Icon(f.icon),
                  ),
                  validator: f.key == 'name'
                      ? (v) => v == null || v.trim().isEmpty ? 'Name is required' : null
                      : null,
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : Text(widget.editData != null ? 'Update' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldDef {
  final String key;
  final String label;
  final IconData icon;
  final bool multiline;
  _FieldDef(this.key, this.label, this.icon, {this.multiline = false});
}
