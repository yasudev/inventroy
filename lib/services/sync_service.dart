import 'database_helper.dart';
import 'api_service.dart';

class SyncService {
  final DatabaseHelper _db = DatabaseHelper();
  final ApiService _api;

  SyncService(this._api);

  Future<void> pushChanges() async {
    final queue = await _db.getSyncQueue();
    if (queue.isEmpty) return;

    final changes = <Map<String, dynamic>>[];
    for (final item in queue) {
      changes.add({
        'entity': item['entity'],
        'action': item['action'],
        'data': item['data'],
        'client_ref': item['id'],
      });
    }

    try {
      final lastSync = await _db.getSyncMeta('last_sync') ?? '';
      final result = await _api.sync({
        'changes': changes,
        'last_sync': lastSync,
      });

      await _db.clearSyncQueue();

      for (final synced in result['synced']) {
        final entity = synced['entity'];
        final data = synced['data'];
        if (data != null) {
          data['sync_status'] = 'synced';
          final localId = data['id'];
          if (localId != null) {
            await _db.upsert(entity, Map<String, dynamic>.from(data));
          }
        }
      }

      for (final change in result['changes']) {
        final entity = change['entity'];
        final data = change['data'];
        if (data != null) {
          data['sync_status'] = 'synced';
          await _db.upsert(entity, Map<String, dynamic>.from(data));
        }
      }

      await _db.setSyncMeta('last_sync', result['server_time'] ?? DateTime.now().toIso8601String());
    } catch (_) {}
  }

  Future<void> pullChanges() async {
    try {
      final lastSync = await _db.getSyncMeta('last_sync') ?? '';
      final result = await _api.sync({
        'changes': [],
        'last_sync': lastSync,
      });

      for (final change in result['changes']) {
        final entity = change['entity'];
        final data = change['data'];
        if (data != null) {
          data['sync_status'] = 'synced';
          await _db.upsert(entity, Map<String, dynamic>.from(data));
        }
      }

      if (result['server_time'] != null) {
        await _db.setSyncMeta('last_sync', result['server_time']);
      }
    } catch (_) {}
  }

  Future<void> fullSync() async {
    await pushChanges();
    await pullChanges();
  }
}
