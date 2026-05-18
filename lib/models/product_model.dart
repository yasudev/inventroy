class Product {
  final int? id;
  final String name;
  final String sku;
  final int? categoryId;
  final int? unitId;
  final int? brandId;
  final double price;
  final double cost;
  final double stockQuantity;
  final double reorderLevel;
  final int? warehouseId;
  final int? locationId;
  final String description;
  final String? createdAt;
  final String? updatedAt;
  final String syncStatus;
  final String? categoryName;
  final String? unitName;
  final String? brandName;
  final String? warehouseName;
  final String? locationName;

  Product({
    this.id,
    required this.name,
    this.sku = '',
    this.categoryId,
    this.unitId,
    this.brandId,
    this.price = 0,
    this.cost = 0,
    this.stockQuantity = 0,
    this.reorderLevel = 0,
    this.warehouseId,
    this.locationId,
    this.description = '',
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'synced',
    this.categoryName,
    this.unitName,
    this.brandName,
    this.warehouseName,
    this.locationName,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'sku': sku,
    'category_id': categoryId,
    'unit_id': unitId,
    'brand_id': brandId,
    'price': price,
    'cost': cost,
    'stock_quantity': stockQuantity,
    'reorder_level': reorderLevel,
    'warehouse_id': warehouseId,
    'location_id': locationId,
    'description': description,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
    'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
    name: map['name'] ?? '',
    sku: map['sku'] ?? '',
    categoryId: map['category_id'] is int ? map['category_id'] : (map['category_id'] != null ? int.tryParse(map['category_id'].toString()) : null),
    unitId: map['unit_id'] is int ? map['unit_id'] : (map['unit_id'] != null ? int.tryParse(map['unit_id'].toString()) : null),
    brandId: map['brand_id'] is int ? map['brand_id'] : (map['brand_id'] != null ? int.tryParse(map['brand_id'].toString()) : null),
    price: (map['price'] ?? 0).runtimeType == double ? map['price'] : double.tryParse(map['price']?.toString() ?? '0') ?? 0,
    cost: (map['cost'] ?? 0).runtimeType == double ? map['cost'] : double.tryParse(map['cost']?.toString() ?? '0') ?? 0,
    stockQuantity: (map['stock_quantity'] ?? 0).runtimeType == double ? map['stock_quantity'] : double.tryParse(map['stock_quantity']?.toString() ?? '0') ?? 0,
    reorderLevel: (map['reorder_level'] ?? 0).runtimeType == double ? map['reorder_level'] : double.tryParse(map['reorder_level']?.toString() ?? '0') ?? 0,
    warehouseId: map['warehouse_id'] is int ? map['warehouse_id'] : (map['warehouse_id'] != null ? int.tryParse(map['warehouse_id'].toString()) : null),
    locationId: map['location_id'] is int ? map['location_id'] : (map['location_id'] != null ? int.tryParse(map['location_id'].toString()) : null),
    description: map['description'] ?? '',
    createdAt: map['created_at'],
    updatedAt: map['updated_at'],
    syncStatus: map['sync_status'] ?? 'synced',
    categoryName: map['category_name'],
    unitName: map['unit_name'],
    brandName: map['brand_name'],
    warehouseName: map['warehouse_name'],
    locationName: map['location_name'],
  );

  Product copyWith({
    int? id,
    String? name,
    String? sku,
    int? categoryId,
    int? unitId,
    int? brandId,
    double? price,
    double? cost,
    double? stockQuantity,
    double? reorderLevel,
    int? warehouseId,
    int? locationId,
    String? description,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
    String? categoryName,
    String? unitName,
    String? brandName,
    String? warehouseName,
    String? locationName,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    categoryId: categoryId ?? this.categoryId,
    unitId: unitId ?? this.unitId,
    brandId: brandId ?? this.brandId,
    price: price ?? this.price,
    cost: cost ?? this.cost,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    reorderLevel: reorderLevel ?? this.reorderLevel,
    warehouseId: warehouseId ?? this.warehouseId,
    locationId: locationId ?? this.locationId,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    categoryName: categoryName ?? this.categoryName,
    unitName: unitName ?? this.unitName,
    brandName: brandName ?? this.brandName,
    warehouseName: warehouseName ?? this.warehouseName,
    locationName: locationName ?? this.locationName,
  );
}
