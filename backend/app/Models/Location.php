<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Location extends Model
{
    protected $fillable = ['warehouse_id', 'name', 'code'];

    public function warehouse()
    {
        return $this->belongsTo(Warehouse::class);
    }
}
