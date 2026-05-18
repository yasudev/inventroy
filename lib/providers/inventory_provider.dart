import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/unit_model.dart';
import '../models/brand_model.dart';
import '../models/customer_model.dart';
import '../models/warehouse_model.dart';
import '../models/location_model.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  late final ApiService _api;
  late final SyncService _sync;
  final ConnectivityService _connectivity = ConnectivityService();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<ItemCategory> _categories = [];
  List<Unit> _units = [];
  List<Brand> _brands = [];
  List<Customer> _customers = [];
  List<Warehouse> _warehouses = [];
  List<InventoryLocation> _locations = [];
  List<Product> _products = [];
  List<Sale> _sales = [];

  List<ItemCategory> get categories => _categories;
  List<Unit> get units => _units;
  List<Brand> get brands => _brands;
  List<Customer> get customers => _customers;
  List<Warehouse> get warehouses => _warehouses;
  List<InventoryLocation> get locations => _locations;
  List<Product> get products => _products;
  List<Sale> get sales => _sales;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<ItemCategory> get filteredCategories => _categories.where((e) =>
      e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  List<Unit> get filteredUnits => _units.where((e) =>
      e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  List<Brand> get filteredBrands => _brands.where((e) =>
      e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  List<Customer> get filteredCustomers => _customers.where((e) =>
      e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      e.phone.contains(_searchQuery)).toList();
  List<Warehouse> get filteredWarehouses => _warehouses.where((e) =>
      e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  List<InventoryLocation> get filteredLocations => _locations.where((e) =>
      e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  List<Product> get filteredProducts => _products.where((e) =>
      e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      e.sku.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  List<Sale> get filteredSales {
    if (_searchQuery.isEmpty) return _sales;
    return _sales.where((e) =>
        (e.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (e.id?.toString().contains(_searchQuery) ?? false)).toList();
  }

  void init({required String apiUrl, required int userId, required String token}) {
    _api = ApiService(apiUrl);
    _api.setToken(token);
    _sync = SyncService(_api);
    _connectivity.init(apiBaseUrl: apiUrl);
    _connectivity.onStatusChanged.listen((online) {
      _isOnline = online;
      if (online) _sync.fullSync();
      notifyListeners();
    });
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_isOnline) {
        await _sync.fullSync();
      }
      await _loadLocal();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadLocal() async {
    _categories = (await _db.getAll('categories')).map((m) => ItemCategory.fromMap(m)).toList();
    _units = (await _db.getAll('units')).map((m) => Unit.fromMap(m)).toList();
    _brands = (await _db.getAll('brands')).map((m) => Brand.fromMap(m)).toList();
    _customers = (await _db.getAll('customers')).map((m) => Customer.fromMap(m)).toList();
    _warehouses = (await _db.getAll('warehouses')).map((m) => Warehouse.fromMap(m)).toList();
    _locations = (await _db.getAllLocations()).map((m) => InventoryLocation.fromMap(m)).toList();
    _products = (await _db.getAllProducts()).map((m) => Product.fromMap(m)).toList();
    _sales = (await _db.getAllSales()).map((m) => Sale.fromMap(m)).toList();
  }

  // =============== GENERIC CRUD ===============

  Future<bool> createEntity(String entity, Map<String, dynamic> data) async {
    try {
      data['sync_status'] = 'created';
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = data['created_at'];
      final id = await _db.insert(entity, data);
      if (_isOnline) {
        try {
          data.remove('sync_status');
          await _api.create(entity, {...data, 'id': id});
          await _db.markSynced(entity, id);
        } catch (_) {
          await _db.addToSyncQueue(entity, 'create', data);
        }
      } else {
        await _db.addToSyncQueue(entity, 'create', data);
      }
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEntity(String entity, Map<String, dynamic> data, int id) async {
    try {
      data['sync_status'] = 'updated';
      data['updated_at'] = DateTime.now().toIso8601String();
      await _db.update(entity, data, id);
      if (_isOnline) {
        try {
          data.remove('sync_status');
          data['id'] = id;
          await _api.update(entity, id, data);
          await _db.markSynced(entity, id);
        } catch (_) {
          await _db.addToSyncQueue(entity, 'update', {...data, 'id': id});
        }
      } else {
        await _db.addToSyncQueue(entity, 'update', {...data, 'id': id});
      }
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEntity(String entity, int id) async {
    try {
      if (_isOnline) {
        try {
          await _api.delete(entity, id);
        } catch (_) {
          await _db.addToSyncQueue(entity, 'delete', {'id': id});
        }
      } else {
        await _db.addToSyncQueue(entity, 'delete', {'id': id});
      }
      await _db.delete(entity, id);
      await refresh();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // =============== SALE ===============

  Future<Sale?> createSale({
    required int userId,
    int? customerId,
    required List<SaleItem> items,
  }) async {
    try {
      double total = 0;
      for (final item in items) {
        total += item.subtotal;
        final prod = _products.where((p) => p.id == item.productId).firstOrNull;
        if (prod != null) {
          final newQty = prod.stockQuantity - item.quantity;
          await _db.update('products', {
            'stock_quantity': newQty,
            'sync_status': 'updated',
            'updated_at': DateTime.now().toIso8601String(),
          }, prod.id!);
        }
      }

      final saleData = {
        'user_id': userId,
        'customer_id': customerId,
        'total_amount': total,
        'payment_method': 'cash',
        'created_at': DateTime.now().toIso8601String(),
        'sync_status': 'created',
      };
      final saleId = await _db.insert('sales', saleData);

      for (final item in items) {
        await _db.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'subtotal': item.subtotal,
        });
      }

      if (_isOnline) {
        try {
          await _api.createSale({
            'customer_id': customerId,
            'total_amount': total,
            'items': items.map((i) => i.toMap()).toList(),
          });
          await _db.markSynced('sales', saleId);
        } catch (_) {
          await _db.addToSyncQueue('sales', 'create', saleData);
        }
      } else {
        await _db.addToSyncQueue('sales', 'create', saleData);
      }

      await refresh();
      return Sale.fromMap({...saleData, 'id': saleId, 'items': items});
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
