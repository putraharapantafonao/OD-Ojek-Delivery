<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\OrderController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Endpoint Pemesanan
    Route::post('/orders', [OrderController::class, 'store']); // Penumpang buat pesanan
    Route::get('/orders', [OrderController::class, 'index']); // Driver lihat pesanan tersedia
    Route::post('/orders/{id}/accept', [OrderController::class, 'accept']); // Driver terima pesanan
});
