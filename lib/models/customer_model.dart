class Customer {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? createdAt;
  final String? updatedAt;
  final String syncStatus;

  Customer({
    this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
    'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    email: map['email'] ?? '',
    address: map['address'] ?? '',
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
    syncStatus: map['sync_status'] ?? 'synced',
  );

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    address: address ?? this.address,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
}
