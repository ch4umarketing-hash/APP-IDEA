# Screen Map (MVP v1)

This maps the first clickable web MVP screens and navigation.

## 1) Authentication
1. **Login**
   - Fields: email, password
   - Actions: Sign in, Forgot password
2. **2FA Verify (optional)**
   - Fields: OTP code

## 2) Global Layout
- Top nav: store selector, global search, notifications, profile
- Sidebar:
  - Dashboard
  - Inventory
  - Sales
  - Transfers
  - Deliveries
  - Repairs
  - Reports
  - Admin (role-based)

## 3) Dashboard
1. **Global Dashboard**
   - KPIs: stock qty, stock value, daily sales, transfers, repair backlog
   - Charts: sales/day, transfers/day, category split
2. **Store Dashboard**
   - Same widgets filtered by selected store

## 4) Inventory
1. **Inventory List**
   - Filters: store, category, brand, model, status, low-stock
   - Columns: SKU/IMEI, product, store, qty, cost, price, status
   - Actions: Add stock, Adjust, Remove, Transfer
2. **Add Stock**
   - Product, store, qty, unit cost, selling price, serial/IMEI (optional)
3. **Adjust Stock**
   - Adjustment type: increase/decrease
   - Reason code + notes
4. **Item Detail**
   - Current state + movement timeline

## 5) Sales
1. **Sales List**
   - Filters: date range, store, channel (in-store/online)
2. **Create Sale (manual)**
   - Product search, qty, customer (optional), payment ref
3. **Sale Detail**
   - Items, totals, channel, source store, destination store (if transfer fulfillment)

## 6) Transfers
1. **Transfers List**
   - Status tabs: Draft, Pending Approval, Approved, In Transit, Received, Cancelled
2. **Create Transfer Request**
   - Source store, destination store, items, reason
3. **Transfer Detail**
   - Approval, dispatch, receive actions
   - Event timeline + stock impact

## 7) Deliveries
1. **Delivery List**
   - Filters: supplier, date, store, status
2. **Create Delivery**
   - Supplier, store, line items, unit cost, invoice ref
3. **Delivery Detail**
   - Receive action + generated inventory movements

## 8) Repairs
1. **Repairs Board**
   - Tabs: Store Defects, Customer Repairs
   - Status columns: Received, Diagnosis, Repairing, Ready, Collected
2. **Create Store Defect Repair**
   - Inventory item, fault, vendor/internal repair route
3. **Create Customer Repair Ticket**
   - Customer, device, issue, intake date, expected collection date
4. **Repair Detail**
   - Status updates, notes, costs, due/overdue indicators

## 9) Admin
1. **Stores Management**
2. **Users & Roles**
3. **Categories/Products Settings**
4. **Audit Logs**

## 10) Core user journey example (iPhone unavailable)
1. Staff searches inventory globally from Inventory List.
2. Finds iPhone in another store.
3. Creates transfer request from source store to current store.
4. Source store approves/dispatches.
5. Destination store receives.
6. Sale is completed and stock auto-updates to sold.
