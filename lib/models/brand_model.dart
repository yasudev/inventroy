class Brand {
  final int? id;
  final String name;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  final String syncStatus;

  Brand({
    this.id,
    required this.name,
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'description': description,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
    'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Brand.fromMap(Map<String, dynamic> map) => Brand(
    id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
    syncStatus: map['sync_status'] ?? 'synced',
  );

  Brand copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
  }) => Brand(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}
