<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EntityController;
use App\Http\Controllers\Api\SaleController;
use App\Http\Controllers\Api\SyncController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);

    Route::post('/sync', [SyncController::class, 'sync']);

    Route::post('/sales', [SaleController::class, 'store']);
    Route::get('/sales', [SaleController::class, 'index']);

    Route::get('/{entity}', [EntityController::class, 'index']);
    Route::get('/{entity}/{id}', [EntityController::class, 'show']);
    Route::post('/{entity}', [EntityController::class, 'store']);
    Route::put('/{entity}/{id}', [EntityController::class, 'update']);
    Route::delete('/{entity}/{id}', [EntityController::class, 'destroy']);
});
