class Unit {
  final int? id;
  final String name;
  final String abbreviation;
  final String? createdAt;
  final String? updatedAt;
  final String syncStatus;

  Unit({
    this.id,
    required this.name,
    this.abbreviation = '',
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'abbreviation': abbreviation,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
    'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Unit.fromMap(Map<String, dynamic> map) => Unit(
    id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    name: map['name'] ?? '',
    abbreviation: map['abbreviation'] ?? '',
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
    syncStatus: map['sync_status'] ?? 'synced',
  );

  Unit copyWith({
    int? id,
    String? name,
    String? abbreviation,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
  }) => Unit(
    id: id ?? this.id,
    name: name ?? this.name,
    abbreviation: abbreviation ?? this.abbreviation,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}
