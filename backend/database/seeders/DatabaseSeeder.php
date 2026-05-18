<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        User::create([
            'username' => 'admin',
            'display_name' => 'Admin',
            'password' => bcrypt('admin'),
            'role' => 'admin',
        ]);

        User::create([
            'username' => 'cashier',
            'display_name' => 'Cashier',
            'password' => bcrypt('cashier'),
            'role' => 'cashier',
        ]);

        User::create([
            'username' => 'manager',
            'display_name' => 'Manager',
            'password' => bcrypt('manager'),
            'role' => 'manager',
        ]);

        User::create([
            'username' => 'seller',
            'display_name' => 'Seller',
            'password' => bcrypt('seller'),
            'role' => 'seller',
        ]);
    }
}
