-- ZimmeManagement Complete Database Setup
-- copy-paste these contents directly into the Supabase SQL Editor

-- 1. Enable Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Create Tables
CREATE TABLE IF NOT EXISTS gyms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    logo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    role TEXT CHECK (role IN ('admin', 'admin2', 'staff', 'trainer', 'member')) NOT NULL,
    profile_picture TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    gym_id UUID REFERENCES gyms(id),
    member_id UUID, -- Links to member table if applicable
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    member_id TEXT UNIQUE,
    gym_id UUID REFERENCES gyms(id),
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    gender TEXT,
    date_of_birth DATE,
    address TEXT,
    emergency_contact TEXT,
    join_date DATE DEFAULT CURRENT_DATE,
    status TEXT DEFAULT 'Active',
    profile_picture TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS batches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    name TEXT NOT NULL,
    start_time TIME,
    end_time TIME,
    capacity INT
);

CREATE TABLE IF NOT EXISTS plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    plan_name TEXT NOT NULL,
    plan_type TEXT,
    amount DECIMAL DEFAULT 0,
    duration_type TEXT CHECK (duration_type IN ('day', 'month', 'year')),
    duration_value INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS member_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    member_id UUID REFERENCES members(id),
    plan_id UUID REFERENCES plans(id),
    purchase_date DATE DEFAULT CURRENT_DATE,
    start_date DATE,
    expiry_date DATE,
    amount DECIMAL DEFAULT 0,
    paid_amount DECIMAL DEFAULT 0,
    due_amount DECIMAL DEFAULT 0,
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    member_id UUID REFERENCES members(id),
    amount DECIMAL DEFAULT 0,
    payment_date DATE DEFAULT CURRENT_DATE,
    payment_mode TEXT,
    transaction_id TEXT,
    remark TEXT,
    invoice_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS attendance (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    member_id UUID REFERENCES members(id),
    punch_in_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    punch_out_time TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'Present',
    date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS trainers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    specialization TEXT,
    joining_date DATE,
    monthly_amount DECIMAL DEFAULT 0,
    daily_amount DECIMAL DEFAULT 0,
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS trainer_attendance (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    trainer_id UUID REFERENCES trainers(id),
    date DATE DEFAULT CURRENT_DATE,
    status TEXT,
    punch_in TIMESTAMP WITH TIME ZONE,
    punch_out TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    title TEXT NOT NULL,
    category TEXT,
    amount DECIMAL DEFAULT 0,
    date DATE DEFAULT CURRENT_DATE,
    payment_mode TEXT,
    remark TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS diet_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    member_id UUID REFERENCES members(id),
    diet_data JSONB, -- Stores the 7-day schedule
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    name TEXT NOT NULL,
    amount DECIMAL DEFAULT 0,
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS member_services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    member_id UUID REFERENCES members(id),
    service_id UUID REFERENCES services(id),
    purchase_date DATE DEFAULT CURRENT_DATE,
    start_date DATE,
    amount DECIMAL DEFAULT 0,
    discount_type TEXT,
    discount_value DECIMAL DEFAULT 0,
    paid_amount DECIMAL DEFAULT 0,
    due_amount DECIMAL DEFAULT 0,
    status TEXT DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    name TEXT NOT NULL,
    product_category_id UUID REFERENCES product_categories(id),
    barcode TEXT,
    sku TEXT,
    purchase_price DECIMAL DEFAULT 0,
    selling_price DECIMAL DEFAULT 0,
    total_quantity INT DEFAULT 0,
    alert_quantity INT DEFAULT 0,
    tax_percent DECIMAL DEFAULT 0,
    status TEXT DEFAULT 'Active',
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    member_id UUID REFERENCES members(id),
    customer_name TEXT,
    customer_phone TEXT,
    subtotal DECIMAL DEFAULT 0,
    tax DECIMAL DEFAULT 0,
    total DECIMAL DEFAULT 0,
    payment_mode TEXT,
    status TEXT DEFAULT 'Completed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id),
    product_id UUID REFERENCES products(id),
    quantity INT DEFAULT 1,
    price DECIMAL DEFAULT 0,
    tax DECIMAL DEFAULT 0,
    total DECIMAL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS leads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    source TEXT,
    category TEXT,
    status TEXT DEFAULT 'New',
    follow_up_date DATE,
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS visitors (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    purpose TEXT,
    status TEXT DEFAULT 'In Progress',
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    gym_id UUID REFERENCES gyms(id),
    member_id UUID REFERENCES members(id),
    title TEXT NOT NULL,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. RLS
ALTER TABLE gyms ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE trainers ENABLE ROW LEVEL SECURITY;
ALTER TABLE batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE diet_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Dynamic Policies (Basic Permit-All)
CREATE POLICY "Public Access" ON gyms FOR ALL USING (true);
CREATE POLICY "Public Access" ON users FOR ALL USING (true);
CREATE POLICY "Public Access" ON members FOR ALL USING (true);
CREATE POLICY "Public Access" ON plans FOR ALL USING (true);
CREATE POLICY "Public Access" ON member_plans FOR ALL USING (true);
CREATE POLICY "Public Access" ON payments FOR ALL USING (true);
CREATE POLICY "Public Access" ON attendance FOR ALL USING (true);
CREATE POLICY "Public Access" ON trainers FOR ALL USING (true);
CREATE POLICY "Public Access" ON leads FOR ALL USING (true);
CREATE POLICY "Public Access" ON expenses FOR ALL USING (true);
CREATE POLICY "Public Access" ON services FOR ALL USING (true);
CREATE POLICY "Public Access" ON member_services FOR ALL USING (true);

-- 4. Admin Seeding
-- Email: razaul@gmail.com | Password: 262122
DO $$
DECLARE
    new_gym_id UUID := gen_random_uuid();
    new_user_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO gyms (id, name, email, phone)
    VALUES (new_gym_id, 'ZimmeManagement HQ', 'razaul@gmail.com', '9999999999');

    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
    VALUES (new_user_id, 'razaul@gmail.com', crypt('262122', gen_salt('bf')), now(), 'authenticated', 'authenticated', jsonb_build_object('role', 'admin', 'gym_id', new_gym_id, 'name', 'Super Admin'))
    ON CONFLICT (email) DO NOTHING;

    SELECT id INTO new_user_id FROM auth.users WHERE email = 'razaul@gmail.com';

    INSERT INTO users (id, name, email, role, gym_id, is_active)
    VALUES (new_user_id, 'Super Admin', 'razaul@gmail.com', 'admin', new_gym_id, true)
    ON CONFLICT (id) DO UPDATE SET gym_id = new_gym_id, role = 'admin';
END $$;
