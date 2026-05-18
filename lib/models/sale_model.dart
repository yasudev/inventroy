class SaleItem {
  int? id;
  int? saleId;
  int productId;
  double quantity;
  double unitPrice;
  double subtotal;
  String? productName;

  SaleItem({
    this.id,
    this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.productName,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'sale_id': saleId,
    'product_id': productId,
    'quantity': quantity,
    'unit_price': unitPrice,
    'subtotal': subtotal,
  };

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
    id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
    saleId: map['sale_id'] is int ? map['sale_id'] : int.tryParse(map['sale_id']?.toString() ?? ''),
    productId: (map['product_id'] ?? 0) is int ? map['product_id'] : int.tryParse(map['product_id']?.toString() ?? '0') ?? 0,
    quantity: (map['quantity'] ?? 0).runtimeType == double ? map['quantity'] : double.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
    unitPrice: (map['unit_price'] ?? 0).runtimeType == double ? map['unit_price'] : double.tryParse(map['unit_price']?.toString() ?? '0') ?? 0,
    subtotal: (map['subtotal'] ?? 0).runtimeType == double ? map['subtotal'] : double.tryParse(map['subtotal']?.toString() ?? '0') ?? 0,
    productName: map['product_name'],
  );
}

class Sale {
  final int? id;
  final int userId;
  final int? customerId;
  final double totalAmount;
  final String paymentMethod;
  final String? createdAt;
  final String syncStatus;
  final String? userName;
  final String? customerName;
  final List<SaleItem> items;

  Sale({
    this.id,
    required this.userId,
    this.customerId,
    this.totalAmount = 0,
    this.paymentMethod = 'cash',
    this.createdAt,
    this.syncStatus = 'synced',
    this.userName,
    this.customerName,
    this.items = const [],
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'customer_id': customerId,
    'total_amount': totalAmount,
    'payment_method': paymentMethod,
    'created_at': createdAt ?? DateTime.now().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Sale.fromMap(Map<String, dynamic> map) => Sale(
    id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
    userId: (map['user_id'] ?? 0) is int ? map['user_id'] : int.tryParse(map['user_id']?.toString() ?? '0') ?? 0,
    customerId: map['customer_id'] is int ? map['customer_id'] : (map['customer_id'] != null ? int.tryParse(map['customer_id'].toString()) : null),
    totalAmount: (map['total_amount'] ?? 0).runtimeType == double ? map['total_amount'] : double.tryParse(map['total_amount']?.toString() ?? '0') ?? 0,
    paymentMethod: map['payment_method'] ?? 'cash',
    createdAt: map['created_at'],
    syncStatus: map['sync_status'] ?? 'synced',
    userName: map['user_name'],
    customerName: map['customer_name'],
    items: map['items'] != null ? (map['items'] as List).map((e) => SaleItem.fromMap(e)).toList() : [],
  );
}
