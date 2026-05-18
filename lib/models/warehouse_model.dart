class Warehouse {
  final int? id;
  final String name;
  final String address;
  final String? createdAt;
  final String? updatedAt;
  final String syncStatus;

  Warehouse({
    this.id,
    required this.name,
    this.address = '',
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'address': address,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
    'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Warehouse.fromMap(Map<String, dynamic> map) => Warehouse(
    id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    name: map['name'] ?? '',
    address: map['address'] ?? '',
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
    syncStatus: map['sync_status'] ?? 'synced',
  );

  Warehouse copyWith({
    int? id,
    String? name,
    String? address,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
  }) => Warehouse(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address ?? this.address,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}
