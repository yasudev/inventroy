class InventoryLocation {
  final int? id;
  final int? warehouseId;
  final String name;
  final String code;
  final String? createdAt;
  final String? updatedAt;
  final String syncStatus;
  final String? warehouseName;

  InventoryLocation({
    this.id,
    this.warehouseId,
    required this.name,
    this.code = '',
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'synced',
    this.warehouseName,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'warehouse_id': warehouseId,
    'name': name,
    'code': code,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
    'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory InventoryLocation.fromMap(Map<String, dynamic> map) => InventoryLocation(
    id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    warehouseId: map['warehouse_id'] is int ? map['warehouse_id'] : (map['warehouse_id'] != null ? int.tryParse(map['warehouse_id'].toString()) : null),
    name: map['name'] ?? '',
    code: map['code'] ?? '',
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
    syncStatus: map['sync_status'] ?? 'synced',
    warehouseName: map['warehouse_name'] ?? map['warehouse'] is Map ? (map['warehouse'] as Map)['name'] : null,
  );

  InventoryLocation copyWith({
    int? id,
    int? warehouseId,
    String? name,
    String? code,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
    String? warehouseName,
  }) => InventoryLocation(
    id: id ?? this.id,
    warehouseId: warehouseId ?? this.warehouseId,
    name: name ?? this.name,
    code: code ?? this.code,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    warehouseName: warehouseName ?? this.warehouseName,
  );
}
