import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/category_model.dart';
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
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controllers = _buildControllers();
    if (widget.editData != null) {
      _isActive = _getIsActive(widget.editData);
    }
  }

  bool _getIsActive(dynamic data) {
    if (data is Map) {
      return data['is_active'] == 1 ||
          data['is_active'] == true ||
          data['is_active'] == '1';
    }
    if (data is ItemCategory) return data.isActive;
    return true;
  }

  Map<String, TextEditingController> _buildControllers() {
    final map = <String, TextEditingController>{};
    final fields = _getFields();
    for (final f in fields) {
      final val = widget.editData != null
          ? _getFieldValue(widget.editData, f.key)
          : '';
      map[f.key] = TextEditingController(text: val?.toString() ?? '');
    }
    return map;
  }

  List<_FieldDef> _getFields() {
    switch (widget.entity) {
      case 'categories':
        return [
          _FieldDef('name', 'Name', Icons.label),
          _FieldDef(
            'description',
            'Description',
            Icons.description,
            multiline: true,
          ),
        ];
      case 'units':
        return [
          _FieldDef('name', 'Name', Icons.straighten),
          _FieldDef(
            'abbreviation',
            'Abbreviation (e.g. kg, pcs)',
            Icons.text_fields,
          ),
        ];
      case 'brands':
        return [
          _FieldDef('name', 'Name', Icons.branding_watermark),
          _FieldDef(
            'description',
            'Description',
            Icons.description,
            multiline: true,
          ),
        ];
      case 'customers':
        return [
          _FieldDef('name', 'Name', Icons.person),
          _FieldDef('phone', 'Phone', Icons.phone),
          _FieldDef('email', 'Email', Icons.email),
          _FieldDef('address', 'Address', Icons.location_on, multiline: true),
        ];
      case 'warehouses':
        return [
          _FieldDef('name', 'Name', Icons.warehouse),
          _FieldDef('address', 'Address', Icons.location_on, multiline: true),
        ];
      case 'locations':
        return [
          _FieldDef('name', 'Name', Icons.location_on),
          _FieldDef('code', 'Code / Aisle', Icons.qr_code),
        ];
      default:
        return [];
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
    data['is_active'] = _isActive ? 1 : 0;

    bool success;
    if (widget.editData != null) {
      success = await context.read<InventoryProvider>().updateEntity(
        widget.entity,
        data,
        widget.editData.id!,
      );
    } else {
      success = await context.read<InventoryProvider>().createEntity(
        widget.entity,
        data,
      );
    }

    if (mounted) {
      setState(() => _saving = false);
      final t = AppLocalizations.of(context);
      if (success) {
        _showToast(
          context,
          '${widget.title} ${widget.editData != null ? t.translate('updated') : t.translate('created')}',
          AppTheme.successColor,
        );
        Navigator.pop(context, true);
      } else {
        _showToast(
          context,
          context.read<InventoryProvider>().error ??
              t.translate('failedToSave'),
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

  @override
  Widget build(BuildContext context) {
    final fields = _getFields();
    final isCategory = widget.entity == 'categories';
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.editData != null ? 'Edit ' : 'New '}${widget.title}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ...fields.map(
                (f) => Padding(
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
                        ? (v) => v == null || v.trim().isEmpty
                              ? 'Name is required'
                              : null
                        : null,
                  ),
                ),
              ),
              if (isCategory) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: SwitchListTile(
                    title: Text(
                      t.translate('active'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      _isActive
                          ? t.translate('categoryActiveSubtitle')
                          : t.translate('categoryInactiveSubtitle'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    value: _isActive,
                    activeTrackColor: AppTheme.successColor.withValues(
                      alpha: 0.4,
                    ),
                    activeThumbColor: AppTheme.successColor,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero,
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            (_isActive ? AppTheme.successColor : Colors.white38)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isActive
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _isActive
                            ? AppTheme.successColor
                            : Colors.white38,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
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
