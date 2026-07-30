<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Attributes\Fillable;

#[Fillable([
    'order_id',
    'amount',
    'payment_method',
    'payment_status',
])]
class Payment extends Model
{
    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
