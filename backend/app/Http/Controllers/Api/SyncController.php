<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Brand;
use App\Models\Category;
use App\Models\Customer;
use App\Models\Location;
use App\Models\Product;
use App\Models\Sale;
use App\Models\SyncLog;
use App\Models\Unit;
use App\Models\Warehouse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SyncController extends Controller
{
    private array $models = [
        'categories' => Category::class,
        'units' => Unit::class,
        'brands' => Brand::class,
        'customers' => Customer::class,
        'warehouses' => Warehouse::class,
        'locations' => Location::class,
        'products' => Product::class,
        'sales' => Sale::class,
    ];

    public function sync(Request $request)
    {
        $request->validate([
            'changes' => 'array',
            'last_sync' => 'nullable|string',
        ]);

        $synced = [];
        $errors = [];

        foreach ($request->changes ?? [] as $change) {
            $entity = $change['entity'] ?? '';
            $action = $change['action'] ?? '';
            $data = $change['data'] ?? [];

            $modelClass = $this->models[$entity] ?? null;
            if (!$modelClass) {
                $errors[] = ['entity' => $entity, 'error' => 'Unknown entity'];
                continue;
            }

            try {
                $result = $this->processChange($modelClass, $action, $data, $request->user()->id);
                $synced[] = ['entity' => $entity, 'action' => $action, 'data' => $result];
            } catch (\Exception $e) {
                $errors[] = ['entity' => $entity, 'action' => $action, 'error' => $e->getMessage()];
            }
        }

        $serverChanges = $this->getServerChanges($request->last_sync);

        return response()->json([
            'synced' => $synced,
            'changes' => $serverChanges,
            'errors' => $errors,
            'server_time' => now()->toIso8601String(),
        ]);
    }

    private function processChange(string $modelClass, string $action, array $data, int $userId): ?array
    {
        $model = new $modelClass;

        switch ($action) {
            case 'create':
                $record = $model->create($data);
                SyncLog::create([
                    'entity' => $model->getTable(),
                    'entity_id' => $record->id,
                    'action' => 'create',
                    'payload' => json_encode($data),
                ]);
                return $record->toArray();

            case 'update':
                $id = $data['id'] ?? null;
                if ($id) {
                    $record = $model->findOrFail($id);
                    $record->update($data);
                    SyncLog::create([
                        'entity' => $model->getTable(),
                        'entity_id' => $id,
                        'action' => 'update',
                        'payload' => json_encode($data),
                    ]);
                    return $record->fresh()->toArray();
                }
                return null;

            case 'delete':
                $id = $data['id'] ?? null;
                if ($id) {
                    $record = $model->findOrFail($id);
                    $record->delete();
                    SyncLog::create([
                        'entity' => $model->getTable(),
                        'entity_id' => $id,
                        'action' => 'delete',
                        'payload' => json_encode($data),
                    ]);
                }
                return null;

            default:
                return null;
        }
    }

    private function getServerChanges(?string $lastSync): array
    {
        $changes = [];
        $since = $lastSync ?: now()->subYear()->toIso8601String();

        foreach ($this->models as $entity => $modelClass) {
            $records = $modelClass::where('updated_at', '>', $since)->get();
            foreach ($records as $record) {
                $changes[] = [
                    'entity' => $entity,
                    'action' => 'sync',
                    'data' => $record->toArray(),
                ];
            }
        }

        return $changes;
    }
}
