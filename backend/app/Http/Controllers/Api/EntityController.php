<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class EntityController extends Controller
{
    private function getModel(string $entity): Model
    {
        $modelClass = 'App\\Models\\' . Str::studly(Str::singular($entity));
        if (!class_exists($modelClass)) {
            abort(404, "Entity '$entity' not found");
        }
        return new $modelClass;
    }

    public function index(string $entity)
    {
        $model = $this->getModel($entity);
        $query = $model->query();

        if (method_exists($model, 'location') && $entity === 'locations') {
            $query->with('warehouse');
        }

        if (in_array($entity, ['products', 'sales'])) {
            if ($entity === 'products') {
                $query->with(['category', 'unit', 'brand', 'warehouse', 'location']);
            }
            if ($entity === 'sales') {
                $query->with(['user', 'customer', 'items.product']);
            }
        }

        return response()->json($query->orderBy('name', 'asc')->get());
    }

    public function show(string $entity, int $id)
    {
        $model = $this->getModel($entity);
        $record = $model->findOrFail($id);
        return response()->json($record);
    }

    public function store(string $entity, Request $request)
    {
        $model = $this->getModel($entity);
        $record = $model->create($request->all());
        return response()->json($record, 201);
    }

    public function update(string $entity, int $id, Request $request)
    {
        $model = $this->getModel($entity);
        $record = $model->findOrFail($id);
        $record->update($request->all());
        return response()->json($record);
    }

    public function destroy(string $entity, int $id)
    {
        $model = $this->getModel($entity);
        $record = $model->findOrFail($id);
        $record->delete();
        return response()->json(['message' => 'Deleted']);
    }
}
