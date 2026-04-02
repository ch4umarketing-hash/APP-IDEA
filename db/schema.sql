-- PostgreSQL starter schema for Multi-Store Mobile Shop Operations App (MVP v1)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  address TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('super_admin', 'store_manager', 'sales_agent', 'repair_tech', 'analyst')),
  default_store_id UUID REFERENCES stores(id),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sku TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  category TEXT NOT NULL,
  is_serialized BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id),
  store_id UUID NOT NULL REFERENCES stores(id),
  serial_or_imei TEXT,
  quantity INTEGER NOT NULL CHECK (quantity >= 0),
  unit_cost NUMERIC(12,2) NOT NULL CHECK (unit_cost >= 0),
  unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
  status TEXT NOT NULL CHECK (status IN ('active', 'reserved', 'reserved_for_transfer', 'in_transfer', 'repair', 'sold', 'defective')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_inventory_store_product ON inventory_items(store_id, product_id);
CREATE INDEX idx_inventory_status ON inventory_items(status);

CREATE TABLE inventory_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inventory_item_id UUID NOT NULL REFERENCES inventory_items(id),
  movement_type TEXT NOT NULL CHECK (movement_type IN ('delivery_in', 'adjustment', 'sale_out', 'transfer_out', 'transfer_in', 'repair_out', 'repair_in', 'write_off')),
  quantity_delta INTEGER NOT NULL,
  source_store_id UUID REFERENCES stores(id),
  destination_store_id UUID REFERENCES stores(id),
  reference_type TEXT,
  reference_id UUID,
  notes TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sales_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE NOT NULL,
  store_id UUID NOT NULL REFERENCES stores(id),
  channel TEXT NOT NULL CHECK (channel IN ('in_store', 'online')),
  status TEXT NOT NULL CHECK (status IN ('draft', 'paid', 'cancelled', 'refunded')),
  total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
  payment_reference TEXT,
  sold_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sales_order_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sales_order_id UUID NOT NULL REFERENCES sales_orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  inventory_item_id UUID REFERENCES inventory_items(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
  line_total NUMERIC(12,2) NOT NULL CHECK (line_total >= 0)
);

CREATE TABLE store_transfers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transfer_number TEXT UNIQUE NOT NULL,
  source_store_id UUID NOT NULL REFERENCES stores(id),
  destination_store_id UUID NOT NULL REFERENCES stores(id),
  status TEXT NOT NULL CHECK (status IN ('draft', 'pending_approval', 'approved', 'in_transit', 'received', 'cancelled')),
  reason TEXT,
  approved_by UUID REFERENCES users(id),
  dispatched_at TIMESTAMPTZ,
  received_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE transfer_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transfer_id UUID NOT NULL REFERENCES store_transfers(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  inventory_item_id UUID REFERENCES inventory_items(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0)
);

CREATE TABLE deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_number TEXT UNIQUE NOT NULL,
  supplier_name TEXT NOT NULL,
  store_id UUID NOT NULL REFERENCES stores(id),
  status TEXT NOT NULL CHECK (status IN ('draft', 'received', 'cancelled')),
  invoice_reference TEXT,
  received_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE delivery_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id UUID NOT NULL REFERENCES deliveries(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_cost NUMERIC(12,2) NOT NULL CHECK (unit_cost >= 0)
);

CREATE TABLE repair_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  repair_number TEXT UNIQUE NOT NULL,
  repair_type TEXT NOT NULL CHECK (repair_type IN ('store_defect', 'customer_repair')),
  store_id UUID NOT NULL REFERENCES stores(id),
  inventory_item_id UUID REFERENCES inventory_items(id),
  customer_name TEXT,
  customer_phone TEXT,
  device_description TEXT NOT NULL,
  issue_description TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('received', 'diagnosis', 'repairing', 'ready', 'collected', 'cancelled')),
  due_at TIMESTAMPTZ,
  collected_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id UUID REFERENCES users(id),
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
