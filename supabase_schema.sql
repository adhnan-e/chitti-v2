-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT,
    phone TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE,
    address TEXT,
    role TEXT NOT NULL DEFAULT 'user',
    photo_url TEXT,
    documents JSONB DEFAULT '[]'::jsonb,
    is_deleted BOOLEAN DEFAULT FALSE,
    has_app_access BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Chittis Table
CREATE TABLE chittis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    duration INTEGER NOT NULL,
    start_month TEXT NOT NULL,
    gold_options JSONB NOT NULL,
    max_slots INTEGER NOT NULL,
    payment_day INTEGER NOT NULL,
    lucky_draw_day INTEGER NOT NULL,
    reward_config JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Slots Table
CREATE TABLE slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chitti_id UUID REFERENCES chittis(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user_name TEXT,
    slot_number INTEGER NOT NULL,
    selected_gold_option JSONB NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(chitti_id, slot_number)
);

-- 4. Payments Table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chitti_id UUID REFERENCES chittis(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    slot_id UUID REFERENCES slots(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    payment_method TEXT NOT NULL,
    received_by UUID REFERENCES users(id),
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'paid',
    paid_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Transactions Table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slot_id UUID REFERENCES slots(id) ON DELETE CASCADE,
    chitti_id UUID REFERENCES chittis(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    user_name TEXT,
    slot_number INTEGER,
    type TEXT NOT NULL,
    amount_in_cents BIGINT NOT NULL,
    balance_before_in_cents BIGINT NOT NULL,
    balance_after_in_cents BIGINT NOT NULL,
    month_key TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    payment_method TEXT,
    linked_transaction_id UUID REFERENCES transactions(id),
    reference_number TEXT,
    notes TEXT,
    receipt_number TEXT,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Winners Table
CREATE TABLE winners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chitti_id UUID REFERENCES chittis(id) ON DELETE CASCADE,
    chitti_name TEXT,
    month_key TEXT NOT NULL,
    month_label TEXT NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user_name TEXT,
    slot_id UUID REFERENCES slots(id) ON DELETE CASCADE,
    slot_number INTEGER NOT NULL,
    prize TEXT NOT NULL,
    won_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Settings Table
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed default settings
INSERT INTO settings (key, value) VALUES ('app_config', '{"currency_symbol": "₹"}'::jsonb);

-- 8. Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_chittis_updated_at BEFORE UPDATE ON chittis FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON settings FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- 9. Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE chittis ENABLE ROW LEVEL SECURITY;
ALTER TABLE slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE winners ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION get_my_role()
RETURNS TEXT AS $$
    SELECT role FROM users WHERE id = auth.uid();
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE POLICY "Organizers can manage all users" ON users FOR ALL USING (get_my_role() = 'organiser');
CREATE POLICY "Users can view themselves" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Everyone can view active chittis" ON chittis FOR SELECT USING (TRUE);
CREATE POLICY "Organizers can manage chittis" ON chittis FOR ALL USING (get_my_role() = 'organiser');
CREATE POLICY "Users can view their own slots" ON slots FOR SELECT USING (auth.uid() = user_id OR get_my_role() = 'organiser');
CREATE POLICY "Organizers can manage slots" ON slots FOR ALL USING (get_my_role() = 'organiser');
CREATE POLICY "Users can view their own payments" ON payments FOR SELECT USING (auth.uid() = user_id OR get_my_role() = 'organiser');
CREATE POLICY "Organizers can manage payments" ON payments FOR ALL USING (get_my_role() = 'organiser');
CREATE POLICY "Users can view their own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id OR get_my_role() = 'organiser');
CREATE POLICY "Organizers can manage transactions" ON transactions FOR ALL USING (get_my_role() = 'organiser');
CREATE POLICY "Everyone can view winners" ON winners FOR SELECT USING (TRUE);
CREATE POLICY "Organizers can manage winners" ON winners FOR ALL USING (get_my_role() = 'organiser');
CREATE POLICY "Everyone can view settings" ON settings FOR SELECT USING (TRUE);
CREATE POLICY "Organizers can manage settings" ON settings FOR ALL USING (get_my_role() = 'organiser');

-- 10. RPC Functions
CREATE OR REPLACE FUNCTION get_chitti_financials(p_chitti_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_total_collected DECIMAL(15, 2);
    v_total_slots INTEGER;
    v_total_winners INTEGER;
BEGIN
    SELECT COALESCE(SUM(amount), 0) INTO v_total_collected
    FROM payments
    WHERE chitti_id = p_chitti_id AND status = 'paid';

    SELECT COUNT(*) INTO v_total_slots
    FROM slots
    WHERE chitti_id = p_chitti_id;

    SELECT COUNT(*) INTO v_total_winners
    FROM winners
    WHERE chitti_id = p_chitti_id;

    RETURN jsonb_build_object(
        'totalCollected', v_total_collected,
        'totalSlots', v_total_slots,
        'totalWinners', v_total_winners
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE VIEW slot_balances AS
SELECT
    slot_id,
    chitti_id,
    user_id,
    SUM(CASE
        WHEN type IN ('payment', 'adjustment', 'openingBalance', 'settlementPayment') THEN amount_in_cents
        WHEN type IN ('discount', 'prizePayout', 'goldHandover', 'settlementRefund') THEN -amount_in_cents
        ELSE 0
    END) as current_balance_in_cents
FROM transactions
WHERE status = 'verified'
GROUP BY slot_id, chitti_id, user_id;
