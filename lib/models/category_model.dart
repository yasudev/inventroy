class ItemCategory {
  final int? id;
  final String name;
  final String description;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String syncStatus;

  ItemCategory({
    this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
    'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory ItemCategory.fromMap(Map<String, dynamic> map) => ItemCategory(
    id: map['id'] is int
        ? map['id']
        : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    isActive:
        map['is_active'] == 1 ||
        map['is_active'] == true ||
        map['is_active'] == '1',
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
    syncStatus: map['sync_status'] ?? 'synced',
  );

  ItemCategory copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
  }) => ItemCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}
