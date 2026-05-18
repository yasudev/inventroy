import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._();

  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    if (_db != null) return;
    final path = join(await getDatabasesPath(), 'yum_inventory.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT DEFAULT '',
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS units (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            abbreviation TEXT DEFAULT '',
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS brands (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT DEFAULT '',
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT DEFAULT '',
            email TEXT DEFAULT '',
            address TEXT DEFAULT '',
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS warehouses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT DEFAULT '',
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            warehouse_id INTEGER,
            name TEXT NOT NULL,
            code TEXT DEFAULT '',
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            sku TEXT,
            category_id INTEGER,
            unit_id INTEGER,
            brand_id INTEGER,
            price REAL DEFAULT 0,
            cost REAL DEFAULT 0,
            stock_quantity REAL DEFAULT 0,
            reorder_level REAL DEFAULT 0,
            warehouse_id INTEGER,
            location_id INTEGER,
            description TEXT DEFAULT '',
            created_at TEXT,
            updated_at TEXT,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            customer_id INTEGER,
            total_amount REAL DEFAULT 0,
            payment_method TEXT DEFAULT 'cash',
            created_at TEXT,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sale_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity REAL NOT NULL,
            unit_price REAL NOT NULL,
            subtotal REAL NOT NULL,
            sync_status TEXT DEFAULT 'synced'
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entity TEXT NOT NULL,
            action TEXT NOT NULL,
            data TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sync_meta (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async =>
      db.query(table, orderBy: 'name ASC');

  Future<List<Map<String, dynamic>>> getAllProducts() async =>
      db.rawQuery('''
        SELECT p.*, c.name as category_name, u.name as unit_name, b.name as brand_name,
          w.name as warehouse_name, l.name as location_name
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        LEFT JOIN units u ON p.unit_id = u.id
        LEFT JOIN brands b ON p.brand_id = b.id
        LEFT JOIN warehouses w ON p.warehouse_id = w.id
        LEFT JOIN locations l ON p.location_id = l.id
        ORDER BY p.name ASC
      ''');

  Future<List<Map<String, dynamic>>> getAllLocations() async =>
      db.rawQuery('''
        SELECT l.*, w.name as warehouse_name
        FROM locations l
        LEFT JOIN warehouses w ON l.warehouse_id = w.id
        ORDER BY l.name ASC
      ''');

  Future<List<Map<String, dynamic>>> getAllSales() async =>
      db.rawQuery('''
        SELECT s.*, u.display_name as user_name, c.name as customer_name
        FROM sales s
        LEFT JOIN customers c ON s.customer_id = c.id
        ORDER BY s.created_at DESC
      ''');

  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final results = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insert(String table, Map<String, dynamic> data) async =>
      db.insert(table, data);

  Future<int> update(String table, Map<String, dynamic> data, int id) async =>
      db.update(table, data, where: 'id = ?', whereArgs: [id]);

  Future<int> delete(String table, int id) async =>
      db.delete(table, where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getUnsynced(String table) async =>
      db.query(table, where: "sync_status != 'synced'");

  Future<List<Map<String, dynamic>>> getSyncQueue() async =>
      db.query('sync_queue', orderBy: 'created_at ASC');

  Future<void> addToSyncQueue(String entity, String action, Map<String, dynamic> data) async {
    await db.insert('sync_queue', {
      'entity': entity,
      'action': action,
      'data': data.toString(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearSyncQueue() async =>
      db.delete('sync_queue');

  Future<void> setSyncMeta(String key, String value) async {
    await db.insert('sync_meta', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSyncMeta(String key) async {
    final results = await db.query('sync_meta', where: 'key = ?', whereArgs: [key]);
    return results.isNotEmpty ? results.first['value'] as String? : null;
  }

  Future<void> markSynced(String table, int id) async {
    await db.update(table, {'sync_status': 'synced'}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsert(String table, Map<String, dynamic> data) async {
    final id = data['id'];
    if (id == null) {
      await db.insert(table, data);
    } else {
      final existing = await getById(table, id is int ? id : int.parse(id.toString()));
      if (existing != null) {
        data['sync_status'] = 'synced';
        await db.update(table, data, where: 'id = ?', whereArgs: [id]);
      } else {
        await db.insert(table, data);
      }
    }
  }

  Future<List<Map<String, dynamic>>> getLocationsByWarehouse(int warehouseId) async =>
      db.query('locations', where: 'warehouse_id = ?', whereArgs: [warehouseId], orderBy: 'name ASC');
}
