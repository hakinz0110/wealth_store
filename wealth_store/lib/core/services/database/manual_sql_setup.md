# Manual SQL Setup for Wealth App

This guide provides step-by-step instructions for setting up the database schema and RLS policies in Supabase manually. Follow these steps in the Supabase SQL Editor.

## 1. Create SQL Functions

First, create the SQL functions needed for database operations:

```sql
-- Create run_sql function (for database setup)
CREATE OR REPLACE FUNCTION run_sql(query text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  EXECUTE query;
END;
$$;

-- Create run_sql_query function (for RLS policy management)
CREATE OR REPLACE FUNCTION run_sql_query(query text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  EXECUTE query;
END;
$$;
```

## 2. Create Database Tables

```sql
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
```

## 3. Set Up Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (everyone can read categories and products)
CREATE POLICY IF NOT EXISTS "categories_select_policy" ON categories FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "products_select_policy" ON products FOR SELECT USING (true);

-- CRITICAL: Allow users to create their own customer record
CREATE POLICY IF NOT EXISTS "customers_insert_policy" ON customers 
FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can only see their own profile
CREATE POLICY IF NOT EXISTS "customers_select_policy" ON customers 
FOR SELECT USING (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY IF NOT EXISTS "customers_update_policy" ON customers 
FOR UPDATE USING (auth.uid() = id);

-- Order policies
CREATE POLICY IF NOT EXISTS "orders_select_policy" ON orders 
FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY IF NOT EXISTS "orders_insert_policy" ON orders 
FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- Order items policies
CREATE POLICY IF NOT EXISTS "order_items_select_policy" ON order_items 
FOR SELECT USING (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.customer_id = auth.uid())
);

CREATE POLICY IF NOT EXISTS "order_items_insert_policy" ON order_items 
FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.customer_id = auth.uid())
);
```

## 4. Insert Sample Data

```sql
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
```

## 5. Temporary Debug Policy (Remove in Production)

If you're still having issues with customer profile creation, you can temporarily add this policy to bypass RLS for testing:

```sql
-- TEMPORARY: Allow any authenticated user to insert into customers table
-- REMOVE THIS IN PRODUCTION!
CREATE POLICY "temp_customers_insert_policy" ON customers 
FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

## 6. Verify Setup

Run these queries to verify your setup:

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check RLS policies on customers table
SELECT * FROM pg_policies WHERE tablename = 'customers';

-- Check sample data
SELECT * FROM categories;
SELECT * FROM products;
```

## 7. Troubleshooting

If you're still having issues with RLS policies, try these steps:

1. Verify that the user's UUID matches the ID in the customers table
2. Check that the auth.uid() function is working properly
3. Temporarily disable RLS for testing: `ALTER TABLE customers DISABLE ROW LEVEL SECURITY;`
4. Re-enable RLS after testing: `ALTER TABLE customers ENABLE ROW LEVEL SECURITY;`

Remember to remove any temporary debug policies before deploying to production. 