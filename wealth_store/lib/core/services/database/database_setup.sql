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

-- Create RLS (Row Level Security) policies

-- Enable RLS on all tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Create policies for public access
CREATE POLICY categories_select_policy ON categories FOR SELECT USING (true);
CREATE POLICY products_select_policy ON products FOR SELECT USING (true);

-- Create policies for customer access
CREATE POLICY customers_select_policy ON customers FOR SELECT USING (auth.uid() = id);
CREATE POLICY customers_update_policy ON customers FOR UPDATE USING (auth.uid() = id);

CREATE POLICY orders_select_policy ON orders FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY orders_insert_policy ON orders FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY order_items_select_policy ON order_items 
FOR SELECT USING (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.customer_id = auth.uid())
);

CREATE POLICY order_items_insert_policy ON order_items 
FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.customer_id = auth.uid())
);

-- Create policies for admin access
CREATE POLICY admin_categories_all_policy ON categories FOR ALL USING (
    EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid())
);

CREATE POLICY admin_products_all_policy ON products FOR ALL USING (
    EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid())
);

CREATE POLICY admin_customers_select_policy ON customers FOR SELECT USING (
    EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid())
);

CREATE POLICY admin_orders_all_policy ON orders FOR ALL USING (
    EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid())
);

CREATE POLICY admin_order_items_all_policy ON order_items FOR ALL USING (
    EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid())
);

CREATE POLICY admin_admins_select_policy ON admins FOR SELECT USING (
    EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid())
);

-- Enable Row Level Security
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- Create policy for inserting customer records during signup
CREATE POLICY "Allow users to create their own customer record" 
ON customers FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Create policy for users to view their own record
CREATE POLICY "Allow users to view their own customer record" 
ON customers FOR SELECT 
USING (auth.uid() = id);

-- Create policy for users to update their own record
CREATE POLICY "Allow users to update their own customer record" 
ON customers FOR UPDATE 
USING (auth.uid() = id);

-- Allow service role full access
CREATE POLICY "Service role has full access to customers" 
ON customers 
USING (auth.role() = 'service_role');

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