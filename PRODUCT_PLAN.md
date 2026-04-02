# Multi-Store Mobile Shop Operations App — Product Blueprint (MVP v1)

## 1) Product Goal
Build a secure, multi-store operations app where staff can:
- View stock across all stores in real time.
- Add/remove/adjust stock with an audit trail.
- Automatically reduce stock when an item is sold in-store or online.
- Transfer stock between stores.
- Track deliveries, outgoing transfers, and repairs (store-owned and customer-owned).
- Monitor dashboard KPIs: stock totals, daily sales value, transfers, and delivery costs.

This document translates your ideas into a practical build plan.

---

## 2) User Roles and Access

### Roles
1. **Super Admin (HQ)**
   - Manage all stores, users, and permissions.
   - Full visibility across inventory, sales, transfers, repairs, and reports.
2. **Store Manager**
   - Manage stock, transfers, deliveries, and repairs for assigned store(s).
   - View all stores' stock for customer lookup.
3. **Store Staff / Sales Agent**
   - Sell items, reserve items, create transfer requests, basic stock actions.
4. **Repair Technician**
   - Update repair status and turnaround timelines.
5. **Read-Only Analyst (optional)**
   - Dashboard and reporting only.

### Authentication
- Email + password login (MVP).
- Optional second factor (OTP via email/SMS) for managers/admins.
- JWT/session with role-based access control (RBAC).

---

## 3) Core Modules

### A. Store & Inventory Module
Track items by:
- SKU / serial / IMEI (for high-value devices).
- Category: phone, battery, case, camera, watch, laptop, accessories, etc.
- Store location.
- Quantity and unit cost.
- Selling price and status (`active`, `reserved`, `in_transfer`, `sold`, `repair`, `defective`).

Key actions:
- Add stock.
- Manual adjustment (with reason code and approval rule).
- Remove stock.
- Bulk import/export CSV.

### B. Sales Sync (In-store + Online)
When sale happens:
- POS/terminal sends sale event to app API.
- App marks specific item(s) as sold.
- Inventory updates in real time.
- Event written to immutable transaction log.

Online sync options:
1. API polling from online storefront.
2. Webhook push from storefront marketplace.
3. Manual sales entry fallback.

### C. Cross-Store Fulfillment (your iPhone example)
Flow:
1. Staff checks availability across stores.
2. If not in current store, create **inter-store order**.
3. Source store stock status changes to `reserved_for_transfer`.
4. On dispatch, status becomes `in_transfer`.
5. On receiving store confirmation, stock is reassigned to destination store.
6. Final sale sets status `sold` and logs revenue at destination.

Supports two policies:
- **Virtual transfer first** (reserve before physical movement).
- **Physical receive first** (only move stock after receiving scan).

### D. Deliveries / Incoming Stock
- Create delivery record manually (MVP).
- Fields: supplier, item list, quantity, cost, received date, receiving store.
- Automatically increases available stock after approval.

### E. Outgoing / Store Transfers
- Transfer request, approval, dispatch, receive workflow.
- Track transfer cost and transfer reason.
- Dashboard section: total transfers per day/week and value moved.

### F. Repairs Module
Two streams:
1. **Store-owned defective stock**
   - Fault found after purchase from supplier.
   - Move item to `repair_in_house` or `repair_vendor`.
   - Track status and return-to-stock or write-off.

2. **Customer repairs**
   - Intake form (customer, device, issue, date received, expected collection date).
   - Status timeline: `received` → `diagnosis` → `repairing` → `ready` → `collected`.
   - Notifications for overdue pickups.

### G. Dashboard & Reporting
Global and per-store widgets:
- Total stock count by category.
- Stock valuation (cost and potential sell value).
- Daily sales count/value.
- Deliveries (count, qty, cost).
- Transfers in/out.
- Repair queue and SLA overdue counts.

---

## 4) Suggested System Architecture

### Frontend
- Web app first (responsive): React + Next.js.
- Optional mobile app later (React Native / Flutter).

### Backend
- REST API (or GraphQL) with event-driven inventory updates.
- Node.js (NestJS/Express) or Python (FastAPI) are both strong options.

### Database
- PostgreSQL for transactional data.
- Redis for caching and real-time counters (optional).

### Integration Layer
- `POS Connector` service for terminal events.
- `Online Sales Connector` service for e-commerce sync.
- Queue (RabbitMQ/SQS/Kafka-lite) for reliable async processing.

### Real-time Updates
- WebSockets or server-sent events (SSE) to update dashboard/stock instantly.

---

## 5) Data Model (MVP entities)
- `users`
- `stores`
- `products`
- `inventory_items` (serialized or batched stock)
- `inventory_movements` (immutable ledger)
- `sales_orders`
- `sales_order_lines`
- `store_transfers`
- `transfer_lines`
- `deliveries`
- `delivery_lines`
- `repair_jobs`
- `audit_logs`

Important principle:
> Never “overwrite silently.” Every stock change must create an `inventory_movement` record.

---

## 6) API Surface (Example)

### Auth
- `POST /auth/login`
- `POST /auth/logout`
- `GET /me`

### Inventory
- `GET /inventory?storeId=...&category=...`
- `POST /inventory/add`
- `POST /inventory/adjust`
- `POST /inventory/remove`
- `GET /inventory/movements`

### Transfers
- `POST /transfers`
- `POST /transfers/{id}/approve`
- `POST /transfers/{id}/dispatch`
- `POST /transfers/{id}/receive`

### Sales
- `POST /sales` (manual or POS-driven)
- `POST /sales/online/webhook`

### Deliveries
- `POST /deliveries`
- `POST /deliveries/{id}/receive`

### Repairs
- `POST /repairs/customer`
- `POST /repairs/store-defect`
- `PATCH /repairs/{id}/status`

### Dashboard
- `GET /dashboard/summary?storeId=...&date=...`

---

## 7) Terminal/POS Connection Strategy (for point #6)

Because terminal integration varies, use a phased approach:

### Phase 1 (fastest MVP)
- Keep POS separate.
- Staff records sales in this app manually.
- Optional CSV import at end of day.

### Phase 2
- Build connector for your main POS/terminal.
- POS sends sale webhooks to app in near real time.

### Phase 3
- Bi-directional sync:
  - App can push price/stock updates to POS.
  - POS confirms sale and returns receipt reference.

This avoids blocking MVP while still preparing for automation.

---

## 8) Non-Functional Requirements
- **Reliability:** No stock loss; idempotent sale/transfer endpoints.
- **Security:** RBAC + encrypted data in transit (HTTPS/TLS).
- **Auditability:** Full action logs (who changed what/when).
- **Performance:** Inventory lookup under 1 second for common filters.
- **Scalability:** Multi-store ready, category growth, high-value item tracking.

---

## 9) MVP Scope Recommendation (6–10 weeks)

### In Scope (v1)
- Login + role permissions.
- Multi-store stock view.
- Add/remove/adjust stock.
- Manual sales and online-sale manual entry.
- Inter-store transfer workflow.
- Deliveries (manual).
- Repairs module basic flow.
- Dashboard summary.

### Out of Scope (v1, for later)
- Full accounting integration.
- Advanced forecasting/AI reorder recommendations.
- Native mobile app.
- Supplier portal.

---

## 10) Suggested Build Order
1. Auth + RBAC + store management.
2. Core inventory ledger and stock views.
3. Sales flow + automatic stock decrement.
4. Inter-store transfer lifecycle.
5. Delivery intake and costs.
6. Repairs workflows.
7. Dashboard metrics.
8. POS/online connectors.

---

## 11) Open Decisions Needed From You
1. Do you want serialized tracking (IMEI per phone) for all phones only, or also laptops/watches?
2. Which online platform(s) should sync first (Shopify, WooCommerce, Jumia, etc.)?
3. What POS/terminal brand/software is currently used in stores?
4. Should transfers require approval from source manager always, or only over a value threshold?
5. Do you want customer SMS/WhatsApp notifications for repair updates in MVP?

---

## 12) What I recommend next
- Start with a **web MVP** and one central database.
- Pilot with **2 stores + expensive items only** (as you suggested).
- Validate transfer and repair workflows before scaling to all categories.
- Add POS automation after manual flow is stable.

If you want, next step I can generate:
1) a full clickable screen map (login, dashboard, inventory, transfers, repairs), and
2) the exact PostgreSQL schema + starter API contract so development can begin immediately.
