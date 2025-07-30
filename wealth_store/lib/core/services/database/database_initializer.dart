import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';


class DatabaseInitializer {
  final SupabaseClient _client;

  DatabaseInitializer(this._client);

  // SQL script for database setup
  static const String databaseSetupScript = '''
-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL,
    image_url TEXT,
    category_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id),
    total NUMERIC NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC NOT NULL
);

-- Create admins table
CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample categories
INSERT INTO categories (name, description) VALUES
    ('Electronics', 'Phones, laptops, gadgets'),
    ('Clothing', 'Men and women wear'),
    ('Groceries', 'Food and beverages'),
    ('Books', 'Educational and leisure books'),
    ('Home & Kitchen', 'Appliances and utensils')
ON CONFLICT DO NOTHING;

-- Insert sample products
INSERT INTO products (name, description, price, category_id) VALUES
    ('Samsung Galaxy A14', 'Affordable Android phone', 120000, 1),
    ('Men T-Shirt', 'Comfortable cotton T-shirt', 4500, 2),
    ('Golden Penny Spaghetti', '900g pack', 750, 3),
    ('Atomic Habits', 'Self-development book', 8500, 4),
    ('Electric Blender', '500W motor', 18000, 5)
ON CONFLICT DO NOTHING;
''';

  // RLS setup script
  static const String rlsSetupScript = '''
-- Enable RLS on all tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Create policies for public access
CREATE POLICY IF NOT EXISTS categories_select_policy ON categories FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS products_select_policy ON products FOR SELECT USING (true);

-- Create policies for customer access
CREATE POLICY IF NOT EXISTS customers_insert_policy ON customers FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY IF NOT EXISTS customers_select_policy ON customers FOR SELECT USING (auth.uid() = id);
CREATE POLICY IF NOT EXISTS customers_update_policy ON customers FOR UPDATE USING (auth.uid() = id);

CREATE POLICY IF NOT EXISTS orders_select_policy ON orders FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY IF NOT EXISTS orders_insert_policy ON orders FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY IF NOT EXISTS order_items_select_policy ON order_items 
FOR SELECT USING (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.customer_id = auth.uid())
);

CREATE POLICY IF NOT EXISTS order_items_insert_policy ON order_items 
FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.customer_id = auth.uid())
);
''';

  /// Initialize the database by running SQL scripts
  Future<void> initializeDatabase() async {
    try {
      debugPrint('Initializing database tables...');
      
      // Use direct SQL execution through Postgrest
      // Split the script by semicolons to execute statements separately
      final statements = databaseSetupScript.split(';');
      
      for (final statement in statements) {
        final trimmed = statement.trim();
        if (trimmed.isNotEmpty) {
          try {
            // Direct SQL execution through REST API
            await _client.rpc('run_sql', params: {'query': '$trimmed;'}).catchError((e) {
              debugPrint('SQL error: $e');
              return null; // Continue with other statements
            });
          } catch (e) {
            debugPrint('Error executing statement: $e');
            // Continue with other statements
          }
        }
      }
      
      // Now try to set up RLS policies
      await _setupRLSPolicies();
      
    } catch (e) {
      debugPrint('Failed to initialize database: $e');
      // Don't throw, as we want the app to continue even if DB setup fails
    }
  }

  /// Set up RLS policies
  Future<void> _setupRLSPolicies() async {
    try {
      debugPrint('Setting up RLS policies...');
      
      // Split the script by semicolons
      final statements = rlsSetupScript.split(';');
      
      for (final statement in statements) {
        final trimmed = statement.trim();
        if (trimmed.isNotEmpty) {
          try {
            await _client.rpc('run_sql', params: {'query': '$trimmed;'}).catchError((e) {
              debugPrint('RLS SQL error: $e');
              return null; // Continue with other statements
            });
          } catch (e) {
            debugPrint('Error setting up RLS policy: $e');
            // Continue with other policies
          }
        }
      }
      
      // Now specifically set up the customers RLS with alternative approach
      await _setupCustomersRLS();
      
    } catch (e) {
      debugPrint('Error setting up RLS policies: $e');
      // Continue anyway
    }
  }

  /// Check if the database has been initialized
  Future<bool> isDatabaseInitialized() async {
    try {
      // Check if the categories table exists and has data
      final result = await _client.from('categories').select('id').limit(1);
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking database initialization: $e');
      return false;
    }
  }

  /// Initialize database only if it hasn't been initialized yet
  Future<void> ensureDatabaseInitialized() async {
    try {
      final isInitialized = await isDatabaseInitialized();
      if (!isInitialized) {
        await initializeDatabase();
      } else {
        debugPrint('Database already initialized, skipping setup');
      }
      
      // Set up RLS policies for customers table
      // This is needed even if the database is initialized to ensure proper security
      await _setupCustomersRLS();
    } catch (e) {
      debugPrint('Error ensuring database is initialized: $e');
    }
  }
  
  /// Setup or update RLS policies for the customers table directly
  Future<void> _setupCustomersRLS() async {
    try {
      debugPrint('Setting up customers RLS policies directly...');
      
      // Direct SQL statements without using a function
      final customersRLS = [
        'ALTER TABLE customers ENABLE ROW LEVEL SECURITY;',
        'DROP POLICY IF EXISTS "customers_insert_policy" ON customers;',
        'DROP POLICY IF EXISTS "customers_select_policy" ON customers;',
        'DROP POLICY IF EXISTS "customers_update_policy" ON customers;',
        'CREATE POLICY "customers_insert_policy" ON customers FOR INSERT WITH CHECK (auth.uid() = id);',
        'CREATE POLICY "customers_select_policy" ON customers FOR SELECT USING (auth.uid() = id);',
        'CREATE POLICY "customers_update_policy" ON customers FOR UPDATE USING (auth.uid() = id);',
      ];
      
      // Execute each statement directly
      for (final sql in customersRLS) {
        try {
          await _client.rpc('run_sql', params: {'query': sql}).catchError((e) {
            debugPrint('Customers RLS error: $e');
            return null; // Continue with other statements
          });
        } catch (e) {
          debugPrint('Error executing customers RLS statement: $e');
          // Continue with other statements
        }
      }
    } catch (e) {
      debugPrint('Error setting up customers RLS policies directly: $e');
      // Don't rethrow, as this shouldn't prevent the app from starting
    }
  }
} 