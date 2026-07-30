<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    // Passenger: Buat pesanan baru
    public function store(Request $request)
    {
        $request->validate([
            'service_type' => 'required|in:od_ride,od_send',
            'pickup_location' => 'required|string',
            'dropoff_location' => 'required|string',
            'price' => 'required|numeric',
            'payment_method' => 'required|in:cash,ewallet,transfer',
        ]);

        $order = Order::create([
            'passenger_id' => $request->user()->id,
            'service_type' => $request->service_type,
            'pickup_location' => $request->pickup_location,
            'dropoff_location' => $request->dropoff_location,
            'price' => $request->price,
            'status' => 'pending',
        ]);

        Payment::create([
            'order_id' => $order->id,
            'amount' => $request->price,
            'payment_method' => $request->payment_method,
            'payment_status' => 'pending', // Bisa diubah nanti kalau e-wallet dll sudah sukses
        ]);

        return response()->json([
            'message' => 'Pesanan berhasil dibuat',
            'order' => $order
        ], 201);
    }

    // Driver: Lihat daftar pesanan yang berstatus pending
    public function index()
    {
        // Ambil semua order 'pending' beserta nama penumpangnya
        $orders = Order::where('status', 'pending')
                       ->with('passenger:id,name,phone_number')
                       ->get();

        return response()->json($orders);
    }

    // Driver: Terima pesanan
    public function accept(Request $request, $id)
    {
        $order = Order::find($id);

        if (!$order) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        if ($order->status !== 'pending') {
            return response()->json(['message' => 'Pesanan sudah diambil atau tidak valid'], 400);
        }

        $order->update([
            'driver_id' => $request->user()->id,
            'status' => 'accepted'
        ]);

        return response()->json([
            'message' => 'Pesanan berhasil diterima',
            'order' => $order
        ]);
    }
}
