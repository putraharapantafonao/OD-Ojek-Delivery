<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Fillable;

#[Fillable([
    'passenger_id',
    'driver_id',
    'service_type',
    'pickup_location',
    'dropoff_location',
    'price',
    'status'
])]
class Order extends Model
{
    public function passenger()
    {
        return $this->belongsTo(User::class, 'passenger_id');
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }
}
