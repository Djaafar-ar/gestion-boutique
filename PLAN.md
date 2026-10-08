# PLAN.md: From Billing App to Shop Manager

---

## 0. Context: what the app is today and why we change it

**What exists today (about 4,000 lines of code):**
- Scan barcodes, build a cart, print a receipt on a 58mm Bluetooth printer.
- Products have a name, barcode and price. There is also a `stock` number, but nothing updates it.
- One shop profile, which includes an Indian UPI field and a QR code.
- Data is stored in **Hive** (a simple key–value store) in 3 "boxes": `products`, `shop`, `settings` (see `lib/core/data/hive_database.dart`).
- Code organisation: `lib/features/<feature>/{data,domain,presentation}` with **BLoC** (screen logic), **get_it** (`lib/core/service_locator.dart`) and **go_router** (`lib/config/routes/app_routes.dart`).

**Big gap found:** the app **never saves a sale**. `BillingBloc._onPrintReceipt` (`lib/features/billing/presentation/bloc/billing_bloc.dart`) only prints. No sales history exists, stock is never reduced, and statistics have nothing to count. Saving sales comes first.

**Goal:** a complete offline shop manager. It has an owner and workers with PIN login, stock tracked per delivery with expiry dates, losses, suppliers and payments, **customer credit (carnet)**, **returns and discounts**, alerts, statistics, Arabic/French/English, prices in DA, phone-to-phone sync over local Wi-Fi with no internet, and **backup/restore to a file**.

**Decisions you made:**
- Selling a product at 0 stock is **allowed**. The app shows a warning and the owner gets an alert.
- Prices show as `1 250,00 DA` in **every** language.
- The foundation work is split into **two phases** (9 phases in total, after adding Google Sheets).
- Sync is tested on **2 real Android phones**.

---

## 1. Key technical choices (in simple words)

### 1.1 Database: switch from Hive to **SQLite with drift** (recommended)
Think of Hive as a set of drawers where each drawer holds one object. SQLite is a real database with tables, like Excel sheets the phone can search and add up very fast.

Why it is better for this app:
| Need | Hive | SQLite + drift |
|---|---|---|
| "Revenue this week per worker" | Load **every** sale into memory and add them up by hand | One query (`SUM ... GROUP BY`), fast even with 100,000 sales |
| A sale must save lines + stock + log together, or not at all | No real transactions | **Transactions**: all or nothing, so no half-saved sales |
| Links (delivery → supplier, sale → worker) | Done by hand | Built-in |
| Changing the data shape in future versions | Fragile | Official **migrations** with version numbers |
| Sync ("give me everything changed since X") | Hard | Easy, with indexed `updatedAt` columns |

**drift** is a Flutter package that makes SQLite type-safe: it checks the code before the app runs. It works with Java 21, needs no internet, and runs on Android normally.

**Keeping your products:** on the first launch after the update, the app opens the old Hive `products` box once and copies every product into SQLite. It keeps the same id, name, barcode and price. If an old product has `stock > 0`, the app creates an "Opening stock" delivery for it. It does the same for shop details and the saved printer. A flag (`migratedFromHive = true`) makes sure this happens only once. Hive stays in the app for one version as a read-only safety copy and is removed later.

### 1.2 Money stored as whole numbers (centimes)
`12,50 DA` is stored as `1250`. Decimal numbers (`double`) create small errors like `0.1 + 0.2 = 0.30000000000000004`, which cause wrong totals after thousands of sales. One helper, `formatDA(1250000)`, returns `"12 500,00 DA"`.

### 1.3 Every record is "sync-ready" from day one
Every table gets these columns:
- `id`: a **UUID**, a random unique code (the `uuid` package is already installed). Two phones can never create the same id.
- `createdAt`, `updatedAt`: timestamps.
- `deviceId`: which phone created the record.
- `userId`: who did it (worker or owner).
- `deleted`: a true/false flag. Nothing is truly erased, it is hidden, so a deletion can sync too.

Adding these now, in Phase 1, means Phase 7 (sync) needs no big rewrite.

### 1.4 Stock = calculated, never typed in
`stock of a product = deliveries − sales + returns put back on the shelf − losses`
The "stock" field disappears. Stock is always the result of the history, so it can never be wrong without leaving a trace.

### 1.5 Packages to add (all work offline)
| Package | What it does |
|---|---|
| `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `drift_dev` (dev) | Database |
| `flutter_localizations` + `intl` (already installed) | Arabic / French / English, right-to-left |
| `fl_chart` | Charts |
| `flutter_local_notifications`, `timezone` | Phone notifications without internet |
| `shelf`, `shelf_router` | Small web server on the owner's phone (sync hub) |
| `http` | Worker phone talks to the hub |
| `network_info_plus` | Finds the phone's Wi-Fi IP for the QR code |
| `connectivity_plus` | Detects when the phone joins Wi-Fi, to start a sync |
| `flutter_foreground_task` | Keeps the hub alive (Android foreground service) |
| `crypto` | Stores PINs safely as hashes, signs sync messages |
| `share_plus`, `file_picker` | Save a backup file (USB, WhatsApp, Drive...) and pick one to restore |
| `archive` | Packs the backup into one `.zip` file |

Already installed and reused: `mobile_scanner` (also scans the pairing QR), `pretty_qr_code` (now shows the **pairing QR** instead of the UPI QR), `uuid`, `flutter_bloc`, `go_router`, `get_it`, `print_bluetooth_thermal`.

**Fonts:** `google_fonts` normally **downloads** fonts from the internet. To stay offline, the IBM Plex Sans and IBM Plex Sans Arabic font files are bundled inside the app (`assets/fonts/`).

**Java 21 / Android:** the current Gradle 8.14 + AGP 8.11 + Kotlin 2.2 setup supports Java 21, and we keep the Java 17 target (works fine on JDK 21). The notifications package needs one extra setting (`coreLibraryDesugaring`), added in Phase 5. New Android permissions get added as needed: notifications, foreground service, Wi-Fi state.

---

## 2. The data model (tables)

| Table | Main columns |
|---|---|
| `shop` | name, address1, address2, phone, receipt footer, **shopSecret** (for sync), expiryWarnDays (default 3), language, theme |
| `users` | name, phone, role (`owner` / `worker`), pinHash + salt, active (true/false) |
| `categories` | name |
| `products` | name (French), barcode (unique), sellPrice, buyPrice, categoryId, lowStockThreshold, archived |
| `suppliers` | name, phone, note |
| `deliveries` (stock entries) | productId, quantity, buyPrice, expiryDate (optional), supplierId (optional), receivedAt, userId |
| `sales` | number, subtotal, **discount** (amount), total, **paidNow**, **customerId** (only for credit sales), userId, createdAt |
| `sale_items` | saleId, productId, **productName + sellPrice + unitCost copied at sale time**, quantity |
| `returns` | saleId, userId, refundMode (`cash` / `credit`: removes the amount from the customer's debt), total, reason, createdAt |
| `return_items` | returnId, saleItemId, quantity, **backToStock** (true = goes back on the shelf, false = becomes a loss "damaged") |
| `customers` | name, phone, note, creditLimit (optional), active |
| `customer_payments` | customerId, amount, note, userId (who received the money), createdAt |
| `losses` | productId, quantity, reason (`damaged` / `expired` / `staff` / `stolen` / `other`), note, unitCost, userId |
| `supplier_payments` | supplierId, amount, note, paidBy (userId), status (`pending` / `validated` / `rejected`), validatedBy, validatedAt |
| `change_log` (history) | entity (product), entityId, field (`price`, `name`...), oldValue, newValue, userId, at |
| `notifications` | type, title, body, refId, read, createdAt |
| `sync_state` | per peer: last sync time, last received change number |

Why copy name and price into `sale_items`? If the price changes tomorrow, yesterday's receipt and profit stay correct.

**Supplier balance** = total of deliveries from that supplier (quantity × buy price) − **validated** payments. Pending payments are shown separately ("pending: 5 000,00 DA") but do not reduce the balance until the owner validates them.

**Customer debt (carnet)** = unpaid part of their credit sales (`total − paidNow`) − returns refunded to credit − customer payments.

---

## 3. How the important rules work

### 3.1 First expiry, first out (FEFO)
Each delivery is a "batch" with its own expiry date. When selling or recording a loss, the app takes quantity from the batch that **expires first**. Batches with no expiry date come last, oldest first. Example: 10 Hamoud sodas expiring 12/10 and 24 expiring 30/11. Selling 12 takes 10 from the first batch and 2 from the second.

The cost of those exact units is saved on the sale line (`unitCost`), so **profit is accurate**.

"How many left in each batch" is **recalculated** by replaying the history in expiry order. So after a sync between phones, every phone computes exactly the same answer.

If stock is 0, the sale still goes through (your choice). The cost uses the product's current buy price, and an alert "Stock négatif" is created.

### 3.1b Discounts and returns
**Discount (simple):** at checkout, tap "Remise" and enter either an amount (`50 DA`) or a percentage (`10 %`) for the whole ticket.
- The owner sets a **maximum discount for workers** (default 10 %). The owner has no limit.
- The sale stores subtotal, discount and total. The receipt shows a "Remise" line.
- Profit statistics subtract discounts. Statistics show "total discounts given" per worker.

**Return:** open a past sale (Sales history), tap "Retour", choose which items and how many come back, and give a reason.
- For each item: **"Back on the shelf"** (stock goes up again, in the same batch it was taken from) or **"Damaged"** (recorded as a loss, so the money lost is visible).
- Refund: **cash** (money given back), or for a credit sale, **reduce the customer's debt**.
- You can never return more than was sold. A sale can have several partial returns.
- Workers can do returns. Each one records who did it, and the owner gets an alert "Retour effectué". Returns reduce revenue in statistics.
- Printing a small French "Ticket de retour" is optional.

### 3.1c Customer credit (carnet)
- A **Customers** list: name, phone, optional credit limit, and **current debt** shown in red.
- At checkout, choose "Paiement: Comptant / Crédit". Crédit → pick or quickly create a customer, and enter how much is paid now (0 = everything on credit).
- Customer page: debt, history of credit purchases, returns and payments, each with **who recorded it** and when.
- **"Record payment"** (customer pays back part of the debt): workers and the owner can do it. No validation is needed, because the money is in the drawer. It is logged with the person who received it.
- If a sale would push the debt above the credit limit: warning (the owner can still allow it). An alert lists customers over their limit.
- Receipt for a credit sale: "Client: Karim — Payé: 200,00 DA — Reste (crédit): 450,00 DA — Total dû: 1 650,00 DA".

### 3.2 Roles
| Action | Worker | Owner |
|---|---|---|
| Sell / checkout | ✅ | ✅ |
| Add a stock delivery | ✅ | ✅ |
| Record a loss | ✅ | ✅ |
| Add/edit products & prices (logged in history) | ✅ | ✅ |
| Record a supplier payment | ✅ (pending) | ✅ (validated directly) |
| Validate / reject payments | ❌ | ✅ |
| Discount at checkout | ✅ up to the max % | ✅ no limit |
| Returns | ✅ (owner alerted) | ✅ |
| Customer credit sale / record customer payment | ✅ | ✅ |
| Set customer credit limit, go above the limit | ❌ | ✅ |
| Backup & restore | ❌ | ✅ |
| Manage workers, settings, shop info | ❌ | ✅ |
| See statistics | own only | everyone, with filters |
| Run the sync hub / pairing QR | ❌ | ✅ |

Archiving (hiding) a product is owner-only. Products are never truly deleted, because old sales point to them.

### 3.3 PIN login
- PINs are stored as **salted hashes**, never in plain form.
- Login screen: tap your name, type a 4-digit PIN.
- A "Switch user" button in the Profile tab.
- After 5 wrong tries: wait 30 seconds.

### 3.4 Sync between phones (no internet)
In simple words, the owner's phone is the "post office". Each worker phone keeps an **outbox** of what it did, delivers it to the post office when it is on the same Wi-Fi, and picks up its mail (new prices, users, validations).

- **Hub:** a small web server inside the owner's app. It listens on port `8787` on the Wi-Fi network and is kept alive by an Android **foreground service**, which shows a permanent "Hub actif" notification.
- **Pairing:** the owner opens *Sync → Pair a phone*, and a QR code shows `{ip, port, shopId, shopSecret}`. The worker scans it once (first launch → "Join a shop"). The first sync then downloads users, products and settings, and the worker logs in with their PIN.
- **If the owner's IP changes** (routers do this): the worker tries the saved IP. If that fails, it sends a small "where is the hub of shop X?" broadcast on the Wi-Fi and the hub answers with its new IP.
- **Security:** every message is signed with the shop secret (HMAC). A phone that doesn't know the secret is ignored.
- **When it syncs:** automatically every 2 minutes while the app is open and on Wi-Fi, right after connecting to Wi-Fi, after each sale (in the background), and with the **"Sync now"** button. "Last sync: 14:32" is shown in the app.
- **Sending:** worker → hub: sales, returns, deliveries, losses, supplier payments, customers, customer payments, product edits, i.e. everything with `updatedAt` newer than the last successful sync. The hub replies "OK, received ids X, Y, Z". Only then does the worker mark them as sent. If Wi-Fi drops halfway, nothing is lost: the same items are re-sent next time and ignored if already received (same UUID).
- **Receiving:** hub → worker: products, prices, categories, users, suppliers, settings, payment validations. Workers also receive the other workers' sales and deliveries so their stock numbers stay correct.

**How conflicts are handled:**
1. **Sales, returns, deliveries, losses, supplier and customer payments** are *events*, things that happened. They are never edited, only added. Two phones can't conflict: everything is kept and merged by UUID. Nothing is duplicated (same UUID = same record) and nothing is lost.
2. **Stock** is calculated from events, so two phones selling the last soda at the same time simply gives stock −1 plus an alert. No data is lost.
3. **Product edits** (name, price...): **last change wins**, decided by the *hub's* clock. The worker sends its clock time and the hub corrects any difference, so a phone with the wrong date can't win unfairly. The losing value is **still saved in the history log**, so the owner can see it and change it back.
4. **Payment validation, users, settings:** only the owner can change them, so there is no conflict. The owner's version always wins.
5. **Same barcode created on two phones:** the hub keeps both and creates an alert "Code-barres en double" so the owner can merge them (sales move to the kept product).
6. **Same customer created on two phones** (same phone number): same idea. Alert "Client en double", and the owner merges them so debts and payments move to one customer and nothing is lost.
7. **Customer debt** is calculated from events (sales, returns, payments), like stock, so it is always correct once all phones have synced.

### 3.5 Alerts and notifications
| Alert | When it is checked |
|---|---|
| New stock entry (by a worker) | When it arrives on the owner's phone (sync) |
| Low stock (≤ threshold) | After every sale/loss and at app start |
| Expiring soon (≤ N days, default 3, owner sets N) | App start + every hour while open + **scheduled phone notifications** at 9:00 on the warning day |
| Expired | Same as above |
| Payment waiting for validation (owner only) | When a payment arrives |
| Negative stock / duplicate barcode / duplicate customer | When it happens |
| Return made (owner only) | When it happens or arrives by sync |
| Customer over credit limit | After a credit sale + app start |

Expiry dates are known in advance, so the phone **schedules** the notification as soon as the delivery is entered, without internet and without a background worker. Alerts are saved in the `notifications` table and shown in the **Alerts** tab with an unread badge.

### 3.6 Receipt (always French, 32 characters wide)
```
        ÉPICERIE EL BARAKA
        Rue 5, Bab Ezzouar
          0555 12 34 56
       06/10/2026  14:32
   Ticket n° 0042 - Vendeur: Amine
--------------------------------
Article          Qté     Montant
--------------------------------
Jus d'orange Rouiba 1L avec
pulpe
  2 x 180,00 DA        360,00 DA
Hamoud Boualem 33cl
  1 x 60,00 DA          60,00 DA
--------------------------------
Sous-total             420,00 DA
Remise (10 %)          -42,00 DA
TOTAL                  378,00 DA
--------------------------------
       Merci, à bientôt !
```
(Remise lines appear only when there is a discount. A credit sale adds Client / Payé / Reste / Total dû lines.)
- A long name **wraps** onto extra lines. Quantity, price and total go on their own line below, aligned to the right. It never breaks.
- French accents (é, à, ç): the printer is switched to the Western-European code page (ESC t), and text is encoded to match. A setting "Remove accents" covers cheap printers that don't support it.
- A "Print test receipt" button in Settings.

---

## 4. Screens and navigation

**Bottom bar** (Material 3 `NavigationBar`):
1. **Vendre (Sell):** scanner + cart (the existing screen, restyled) → checkout (discount, cash/credit) → print. A "History" button opens past sales → reprint / return.
2. **Stock:** product list with stock, expiry badges, search, categories. Actions: add product, add delivery, record loss, suppliers.
3. **Stats:** dashboard (owner: everyone with filters; worker: own stats only).
4. **Alertes:** notification list with badge.
5. **Plus (More):** my profile & stats, **customers (carnet)**, workers (owner), suppliers & payments, sync, **backup & restore (owner)**, settings (language, theme, expiry days, max worker discount, printer, shop info), switch user.

**Design:** Material 3, colours generated from one seed colour, light and dark (follows the phone, with a manual switch). Rounded cards, clear empty states ("Aucun produit — ajoutez-en un"). Every layout uses `start`/`end` instead of `left`/`right`, so Arabic mirrors correctly. The current theme (`lib/core/theme/app_theme.dart`) hard-codes white and black, so it gets rewritten for dark mode.

**Code organisation** (same style as today: `features/x/{data,domain,presentation}` + BLoC/Cubit + get_it + go_router):
```
lib/core/database/        drift database, tables, migrations, Hive importer
lib/core/l10n/            app_ar.arb, app_fr.arb, app_en.arb
lib/core/utils/money.dart formatDA, parse DA
lib/core/session/         current user, role checks
lib/features/auth/        setup wizard, login, PIN
lib/features/users/       workers management, profile
lib/features/product/     (existing, extended) + history
lib/features/stock/       deliveries, FEFO, losses
lib/features/suppliers/   suppliers, payments
lib/features/customers/   carnet: customers, credit, customer payments
lib/features/billing/     (existing) + saving sales, discounts, returns
lib/features/backup/      export / restore
lib/features/alerts/
lib/features/stats/
lib/features/sync/        hub server, client, pairing
lib/features/settings/    (existing) + language/theme
```

---

## 5. Phases

At the **end of every phase**:
1. `flutter analyze` → 0 problems.
2. `flutter test` → all green (new tests are added each phase).
3. A git commit with a clear message.
4. I explain in simple words **what to test on the emulator**, step by step.
5. **I stop and wait for your OK** before the next phase.

### Phase 1: New foundation (database, languages, design, DA, saving sales)
- Add drift. Create tables `shop`, `products`, `categories`, `sales`, `sale_items`, `settings`, all with the sync columns.
- **Hive → SQLite import** of existing products, shop details and saved printer (run once).
- Replace `ProductRepositoryImpl` / `ShopRepositoryImpl` internals with drift. Screens keep working.
- **Save every sale** at checkout, in one transaction, with a sale number. The `sales` table already has the discount / paidNow / customerId columns (empty for now), so later phases don't need to change it. The receipt prints after saving. If printing fails, the sale is still saved and can be reprinted.
- Money in centimes + `formatDA`. Replace every `₹`.
- **Remove UPI** completely: field, QR, `upiId` in entities/models.
- Languages: ARB files for ar/fr/en, a language switch in Settings, right-to-left in Arabic. Bundled fonts.
- New Material 3 theme with light/dark + switch.
- Bottom navigation shell with 5 tabs (unfinished tabs show a clean "coming soon" empty state).
- Tests: migration from Hive, `formatDA`, sale saving.
- **You test:** your old products are still there, a sale appears in the sales list, the language switch flips the layout in Arabic, dark mode works, no ₹ or UPI anywhere.

### Phase 2: Owner, workers, PIN login, profiles, history
- Tables `users`, `change_log`.
- First-launch wizard: shop info → owner name → PIN (twice). For an existing install: "Create the owner account" once after the update.
- Login screen (choose user + PIN), switch user, lockout after 5 wrong PINs.
- Owner: add / edit / disable workers (name, phone, 4-digit PIN).
- Every sale/edit records `userId`. Role checks hide owner-only screens from workers.
- Product edit history: who, when, old → new value (product detail screen).
- Profile page: sales today/week/month, number of sales, items sold, losses recorded (losses will show 0 until Phase 3).
- Products gain buy price, category, low-stock threshold.
- Tests: PIN hashing, role permissions, history logging.

### Phase 2b: Login security (added after Phase 2)
- Wrong-PIN protection per account, getting stronger: 5 wrong → wait 30 s, 10 wrong → wait 5 min, 15 wrong → account locked. A worker is unlocked by the owner; the owner unlocks with the recovery code. Waits count down only while the app is open, so closing the app or changing the phone's date/time doesn't shorten them.
- Every failed attempt is saved (account, date and time) and shown to the owner as a warning at login, with a full list in *Plus*.
- The owner can choose a 4- or 6-digit PIN. Workers can only change their own PIN; only the owner can reset a worker's PIN; PINs are never shown or stored as typed.
- Owner recovery code: shown once at setup (or created from the profile by existing owners). It resets the owner PIN, unlocks the account, and is then replaced by a new code.

### Phase 3: Stock deliveries, expiry, FEFO, losses
- Tables `deliveries`, `losses`.
- "Add delivery" screen: scan/choose product, quantity, buy price (pre-filled), optional expiry date, supplier (optional until Phase 4), received by (automatic).
- Stock calculated from movements. Batch list per product with expiry colours (green / orange / red).
- **(Requested after Phase 1)** The current quantity is shown on every product: in the Stock list, on the product screen and in the cart. Adding stock always asks for the quantity and lets you enter an expiry date.
- FEFO at checkout and for losses. `unitCost` saved for profit.
- Selling at 0 stock: allowed with a warning.
- "Record loss" screen: reason (damaged, expired, eaten/used by staff, stolen, other), quantity, note. It shows money lost at buy price.
- **Discounts** at checkout (amount or %, worker maximum set by owner).
- **Sales history** screen (today by default, search by number/date), with reprint.
- **Returns** (tables `returns`, `return_items`): back on shelf → same batch, or damaged → loss; cash refund (credit refund is added in Phase 4).
- Tests: FEFO with several batches, stock math with returns, loss value, discount limits, "cannot return more than sold".

### Phase 4: Suppliers, payments and customer credit (carnet)
- Tables `suppliers`, `supplier_payments`. Link deliveries to suppliers.
- Supplier list with balance owed. Supplier page: deliveries, payments, history.
- Record supplier payment: by the owner → validated. By a worker → **pending**.
- Owner: "Payments to validate" list with validate/reject.
- Tables `customers`, `customer_payments`. Customers list with debt, customer page with full history and who recorded each line.
- Checkout: Comptant / Crédit, pick or create a customer, amount paid now, credit-limit warning.
- Record customer payment. Returns on credit sales reduce the debt.
- Tests: supplier balance (pending not counted), validation rules, customer debt math (partial payment, payment, return), credit-limit check.
- **Rules chosen while building:** a customer can never pay back more than they owe. A return on a credit sale is taken off the debt by default (cash is still possible); if that makes the debt negative, it shows as an "Avance". Workers can add/edit customers and suppliers, but only the owner sets credit limits, archives, and validates or rejects payments (a decision is final). A worker can never go over a credit limit; the owner is asked to confirm. Credit receipts get Client / Payé / Reste (crédit) / Total dû lines.

### Phase 5: Alerts and notifications
- `notifications` table, Alerts tab with unread badge, mark as read.
- Checks: new stock entry, low stock, expiring soon (N days, setting), expired, pending payments, negative stock, return made, customer over credit limit.
- Phone notifications with `flutter_local_notifications` (Android 13+ permission request, desugaring setting). Expiry notifications scheduled ahead.
- Tests: each alert rule triggers correctly, no duplicate alerts.
- **(Requested before Phase 5)** Every alert reaches the owner in three places: a phone notification, the Alertes tab, and a number badge on the Alertes tab icon. Tapping a notification opens the page that deals with it (a payment → "Paiements à valider"). Also failed PIN attempts. Workers only get low stock, expiring soon and expired. Each alert can be marked as read (per person), and the owner can switch each type of phone notification on or off (Plus → Notifications du téléphone).
- **Rules chosen while building:** alerts are worked out on each phone from its own data (not synced), one alert per thing (a product, a batch, a payment...). A problem that is solved disappears; if it comes back, or gets worse (low → out of stock → sold without stock; more wrong PINs), it is unread again and rings again. Deliveries and returns by workers stay 30 days. Only things after the update count, so old deliveries do not flood the list. More than 3 new alerts at once give one summary notification. Expiry reminders are planned at 9:00 (warning day and the day after expiry) and ring even with the app closed.

### Phase 6: Statistics
- Owner dashboard: revenue (after discounts and returns), profit (sell − unitCost − discounts), number of sales, today/week/month, top products, sales per worker, loss value, discounts given, returns value.
- **Credit section:** total owed by all customers, credit sales vs cash sales, money collected from customers (per worker), top debtors.
- **Cash in hand** for a period = cash sales + customer payments − cash refunds (useful to check the drawer).
- Charts (`fl_chart`): revenue per day (bars), sales per worker, losses by reason, cash vs credit.
- Filters: date range picker + worker picker.
- Workers: same screen, locked to their own data.
- Tests: statistics queries against a known sample dataset.
- **Rules chosen while building:** returns count against the person who made the sale (as on the profile page); cash given back counts for the person who gave it. Net profit = revenue − buying price of items sold (items put back on the shelf are not counted) − stock losses (damaged returns are already in the buying price). Workers see their own figures without buying prices, profit or what all customers owe. Periods longer than 62 days are shown month by month. Supplier payments are shown under the cash drawer but not taken out of "Argent en caisse".

### Phase 6b: Returns without a receipt and exchanges (requested after Phase 6)
- **Return without a receipt:** pick or scan the products, back on the shelf or damaged, refunded at the product's current sell price. Owner only, or a worker with the owner typing their PIN on the same screen (same wrong-PIN rules as login; the PIN is checked again when saving). Items back on the shelf count as stock without a batch (nobody knows their expiry date).
- **Exchange:** from a ticket ("Échange" button) or without a receipt (switch on the return screen): items brought back + items taken, in one operation. The items taken become a new ticket; the app shows "Le client paie X" / "À rendre X". The new ticket and its receipt show "Avoir (échange)". On a credit ticket the refund can still go off the debt.
- Both count in the statistics like returns (a return without a ticket counts for whoever made it) and alert the owner when a worker does them. Database v7.
- **Workers never see profit or buying prices** (confirmed by the user after Phase 6).

### Phase 7: Wi-Fi sync
- First launch choice: "Create a new shop (owner)" / "Join a shop (worker) → scan QR".
- Hub: `shelf` server + foreground service + "Hub actif" notification. Pairing QR (reuses `pretty_qr_code`).
- Client: outbox push → pull changes → acknowledge. Retry, auto-sync on Wi-Fi, "Sync now", last sync time.
- IP-change discovery (UDP broadcast), HMAC signatures, hub clock correction.
- Conflict rules from §3.4, duplicate-barcode alert.
- Tests: two in-memory databases sync with each other (duplicates, conflicts, interrupted sync).
- **You test on your 2 real phones:** pair, sell on the worker phone, see the sale on the owner phone, change a price on the owner phone, see it on the worker phone, turn Wi-Fi off/on, sync resumes.
- **How it was built:**
  - **Change log:** database triggers write every insert or update of a shared row to a change log (`sync_log`, database v8). Existing data was added to it once, so a phone joining later receives everything.
  - **Server:** the hub is a plain `dart:io` HTTP server on port 8787, with no extra package. It runs in the app, kept alive by an Android foreground service (`specialUse`, with a Wi-Fi lock) that shows "Hub actif".
  - **Each sync:** the worker sends its own new changes, then receives every change after its last one, 500 rows at a time. If the answer is lost, the same rows are sent again; the hub keeps one copy of each, by record id.
  - **Security:** every request and answer is signed (HMAC-SHA256) with the shop secret, and the "where is the hub?" UDP answer (port 8788) is signed too. Data travels unencrypted but only on the local Wi-Fi.
  - **Conflicts:** the last change wins by the hub's clock. A worker clock that is more than 2 minutes off is corrected. A change made on the worker and not yet sent is never overwritten by an older version from the hub.
  - **Phone letters:** owner A, workers B, C… Each phone numbers its own tickets: `42` on the owner's phone, `B-42` on phone B. Search accepts "B-42".
  - **Joining:** a new phone uses "Rejoindre une boutique existante" on its first screen. A phone that already has its own data uses Plus → Synchronisation Wi-Fi → "Rejoindre une autre boutique", which erases it after the owner types their PIN.
  - **Duplicates:** the same barcode, or the same customer phone number, created on two phones raises an owner alert. "Fusionner avec…" moves sales, stock, payments and debt to the record kept and archives the other.
  - **Not done:** no automatic sync just because the phone connected to Wi-Fi (it syncs every 2 minutes, 5 seconds after a change, and on "Sync now").

### Phase 7b: Release key and stock rule (requested after Phase 7)
- **Selling without enough stock:**
  - **Workers are blocked.** In the data layer, inside the same transaction as the sale, a worker's sale (or the items taken in an exchange) is refused when a product has less stock than the quantity sold. All the cart lines of the same product count together.
  - **What the worker sees:** the checkout shows "Stock insuffisant. Ajoutez d'abord la réception de stock." with a "Réception de stock" button for that product. The red stock card already says so before they confirm.
  - **The owner can always sell,** with the red warning and the "Stock négatif" alert.
  - **The switch:** Plus → Informations de la boutique → Règles → "Les employés peuvent vendre sans stock", off by default. It is stored on the shop record (database v9), so it syncs to worker phones.
- **Release signing:**
  - **The key:** release APKs are signed with the app's own release key, kept outside the project in `C:\Users\Medvich\keys\` and set up in `android/key.properties` (never committed).
  - **Why rotation:** the phones already had the app signed with the old debug key, and Android only updates an app signed by the same key. Changing keys would have meant uninstalling and losing the data. So the old key is "rotated" to the new one: the APK carries the signed proof (`gestion-boutique-lineage.bin`), and `adb install -r` keeps working and keeps the data.
  - **How to build:** always with `.\tool\build_release.ps1`.
  - **▶ Run is safe too (added after Phase 8b):** `flutter run` (the ▶ Run button) would uninstall the app, erasing its data, if the debug build had another key. Gradle now signs every APK (debug, profile, release) with the release key and the rotation proof, passwords passed to `apksigner` through the environment. Without `key.properties`, a debug build stops instead of using another key. Tested on the emulator: debug over release and release over debug both update in place (same install date, data kept).
  - **What to keep safe:** both keystores, the lineage file and the password, on a USB stick.

### Phase 8: Google Sheets and live sales (added after Phase 2)
**Idea in simple words:** your Google Sheet becomes a live copy of the shop, for viewing and reports. Every phone with internet (mobile data) posts its own new records to a small Google Apps Script attached to the sheet, so you don't need your own server. Wi-Fi sync (Phase 7) stays the main way data reaches the owner's phone; the sheet is an extra.

- **Script:** a Google Apps Script web app attached to your sheet. In this phase I give you the full script code and step-by-step instructions with screenshots-style explanations (open the sheet → Extensions → Apps Script → paste → Deploy as web app → copy the URL). A one-time "Installer" function creates the tabs and their formulas.
- **Tabs:** Sales, Sale items, Stock deliveries, Current stock, Losses, Supplier payments, Customer credit, Daily summary, Stats per worker. Returns appear in Sales as "Retour" lines, and discounts as their own column.
  - Sales, Sale items, Stock deliveries, Losses, Supplier payments and Customer credit receive raw rows from the phones.
  - Current stock, Daily summary and Stats per worker are **calculated inside the sheet** with formulas, so phones never send them. That keeps mobile data small.
- **Sending (every phone, owner and workers):** each new sale, return, stock delivery, loss, supplier payment and customer credit or payment goes into a small "to send" queue, the moment it's saved.
  - With internet, the queue is sent at once in one small batch (only new records, compact JSON).
  - Without internet, records wait in the queue on the phone and are sent later. Nothing is lost when the app is closed or the phone restarts, because the queue lives in the database.
  - A **"Send now" button** and the **last send time** are shown in *Plus → Google Sheet*.
- **No duplicates:** every record keeps its unique id (UUID). The script records ids it has already written, and ignores a record it has seen before. This covers the same sale arriving from a worker's phone and later from the owner's phone after Wi-Fi sync. The script uses a lock (`LockService`) so two phones writing at the same moment can't create doubles.
- **One direction only:** app → sheet. Editing the sheet never changes the app.
- **Security:**
  - Every request is signed with a **secret key** (HMAC) plus a timestamp. The script rejects anything unsigned, signed with the wrong key, or replayed old requests.
  - Two keys: a **write key** that all phones have (to send records), and a **read key** that only the owner's phone has (for "Ventes en direct"). A worker's phone can add rows but can't read the shop's figures.
  - The owner types the script URL and keys in *Plus → Google Sheet*. Workers' phones receive the URL and write key automatically during Wi-Fi pairing (Phase 7).
- **"Ventes en direct" screen (owner, away from the shop):**
  - It reads only the sales added since its last check from the script, every **30 seconds while the screen is open**.
  - It shows the latest sales, who sold, and today's totals (revenue, number of sales, per worker).
  - **Phone notification for each new sale**, which the owner can turn off.
  - While the app is open or recently in the background, it checks every 30 s. When the app is fully closed, Android only allows a background check about **every 15 minutes**, so notifications then come in small groups. That's an Android rule, not a choice.
- **Data use:** only new records are sent, batched. Live polling asks "anything since X?" and usually gets an empty answer of a few bytes.
- Packages: `http`, `connectivity_plus` (already planned for Phase 7), `workmanager` for the 15-minute background check.
- Tests: queue keeps records until the script confirms them; duplicates are ignored; offline then online sends everything once; signatures are checked; a fake script server in tests.
- **You test:** install the script, sell on a worker phone with mobile data, see the row appear in the sheet, then sell offline and see it arrive when data comes back. Open "Ventes en direct" on the owner phone away from the shop's Wi-Fi.
- **How it was built (decisions made when starting Phase 8):**
  - **Setup in the owner's own Gmail:** `tool/google_sheet/Code.gs` + `docs/google_sheet_setup.md` (every click, and the "Google hasn't verified this app" screens). The sheet menu **Boutique → 1. Installer** creates the tabs and formulas, creates both keys by itself and shows a QR code (script URL + write key + read key). In the app: Plus → Google Sheet → "Scanner le code de configuration" (or "Coller le code" on the emulator). The keys are checked with Google before anything is saved.
  - **Where the keys live:** the address and the write key are on the shop record (database v10), so they reach the worker phones by Wi-Fi sync. The read key is a phone setting of the owner's phone only, never synced, never in a backup. A worker phone cannot set up the sheet. "Changer les clés (téléphone perdu)" in the sheet makes new keys.
  - **Queue:** `sheet_queue`, filled by database triggers when a sheet is set up (a worker phone queues only its own records). Sent 5 seconds after a change, every 2 minutes while the app is open, and about every 15 minutes by Android (`workmanager`) when it is closed. Batches of 100 records, compact rows, removed only once the script confirms.
  - **Sheet rows:** Sales (one row per sale, return, exchange or customer payment, with "Ventes", "Bénéfice", "Retours", "Encaissé" columns), Sale items (with "Sortie de stock"), Stock deliveries, Losses, Supplier payments (updated in place), Customer credit (name, current debt, last payment date; no phone numbers; sent by the owner's phone only). Current stock, Daily summary and Stats per worker are QUERY formulas in the sheet. The script stores ids already written (hidden tab `_recus`) and turns any text starting with = + - @ into plain text.
  - **Security:** HMAC-SHA256 with the key, a time (10 minutes allowed; a phone with the wrong time corrects itself) and a one-time number (replays refused). The write key can only add rows; reading (live sales, summary) and Drive backups need the read key.
  - **Ventes en direct (owner):** sales arrive by Wi-Fi sync and from the sheet; both go into `live_sales` by ticket id, so each sale is shown and announced once. One notification per new sale (ticket, seller, total; more than 5 at once: one summary), switch to turn it off, own sales never announced. Checks every 30 s while the screen is open.
  - **Evening report (owner's phone, never a worker phone):** at 21:00 by default (time can be changed), a notification with sales, revenue, profit, cash in the drawer and returns; it uses the sheet's figures or this phone's, whichever knows more sales. Notifications are "private" (hidden on the lock screen).
  - **Backups moved here from Phase 9:** backup file (VACUUM INTO + info.json, .zip, the last 10 kept on the phone), share it (Drive, WhatsApp, USB...), restore (owner only, owner PIN, same shop, not from a newer version, never on a worker phone, a backup of the current data first; the restored database is put in place when the app starts again). A new phone can restore from its first screen with the backup's owner PIN.
  - **Daily Google Drive backup:** once a day through the script, into "Sauvegardes Boutique", the last 30 kept; waits for Wi-Fi unless the last one is 3 days old; "Sauvegarder maintenant"; warning (Plus and Google Sheet page) when no backup left the phone for 7 days.
  - **Restored main phone:** after a restore the hub gets a new "epoch"; worker phones see it, send everything they have again, then download everything (nothing counted twice).
  - **Not done:** reading a backup straight from Drive inside the app (the Android file picker opens Drive instead); Customer credit is not split per worker.

### Phase 8b: Bluetooth scanner, never lose data, everything to the sheet (requested after Phase 8)
- **Bluetooth barcode scanner ("douchette"):**
  - **Keyboard mode (HID):** after pairing in the Android Bluetooth settings, the scanner types the barcode and Enter. One app-wide listener catches those keys when no text field is being typed in, and gives the barcode to the screen on top (`ScanListener`): Caisse, Réception de stock, Déclarer une perte, Retour sans ticket and Échange (a switch says whether the scan is an item brought back or taken), product search, the product picker, and the barcode of a new product. When a text field has the focus, the scanner types into it (the search field accepts the barcode with Enter).
  - **SPP mode:** Plus → Douchette lists the paired devices; the phone connects (Bluetooth serial, Kotlin `SppScanner.kt`), remembers it and reconnects every 15 seconds when it is lost.
  - **Feedback:** a short beep and vibration when a scan is accepted (can be turned off); "Code-barres inconnu" with a "Créer le produit" button that opens the new product form with the barcode filled in.
  - **Emulator:** click in the emulator window, type a barcode on the PC keyboard, then Enter. Plus → Douchette has a "Tester un scan" area.
- **Never lose data:**
  - The cart is saved in the database at every change and comes back after a crash or a power cut (with today's prices).
  - Database: every sale is one transaction; SQLite keeps a rollback journal (half-written changes are undone at the next start); `synchronous = FULL` is set at every opening (the phone answers "saved" only once the data is on the storage).
  - Tests: a crash in the middle of a sale (nothing half-saved), a power cut while a sale is written (the copy of the files taken at that moment opens fine, without the unfinished sale), a crash while receiving a sync (nothing half-applied), a lost answer while sending to the sheet (sent again, written once), the cart coming back.
- **Everything to the Google Sheet (script version 2, database v11):** sales, sale items, returns ("Retour", "Retour sans ticket"), exchanges ("Échange", "Échange sans ticket"), discounts, stock deliveries, losses, supplier payments with their status, credit sales and customer payments (were already sent), plus:
  - **Historique produits:** every change of a product (name, barcode, prices, category...), who and when.
  - **Produits** (owner's phone only): name, barcode, category, sell price, buying price, current stock, nearest expiry. Updated when the product or its stock changes.
  - "Customer credit" and "Produits" can only be written with the **read key** (owner's phone): a worker phone can never change them.
  - Still one direction only (app → sheet). Updating the script keeps every row: `docs/google_sheet_setup.md`, "Updating to script version 2".
- **Plus → Google Sheet** shows "Compte Google : ..." (asked to the script with the read key).
- **License check:** `docs/license_check.md`. About 9 % of `lib/` (about 2 660 lines, mostly 15 files: Caisse, product pages, shop details, printer, checkout parts, product/billing/shop BLoCs) plus the platform templates, icons and README still come from the original repository, which has no license. Replacement plan added to Phase 9.

### After Phase 8b: no GitHub, code backups, app ID
- **No GitHub:** the code is never pushed anywhere (no remote).
- **Code backup:** `.\tool\backup_code.ps1` makes `gestion-boutique-code_<date>.zip` (project files and git history, no build folders) and copies it to the folder chosen once (USB stick or Google Drive folder; `-Choose` to change it). It refuses to copy if a key file or a signing password is found inside. Run after every commit.
- **App ID:** `dz.gestionboutique.pos` (was `com.example.billing_app`), name on the phone "Gestion Boutique", same release key. Android sees it as a new app: the old one stays installed with its data; data moves with a backup restored on the new app's first screen.
- **Credits:** `CREDITS.md` thanks Dinesh Sowndar, the author of the original app.

### Phase 9: Printer and final polish
- **Replace the code from the original repository** (the author allowed free use, thanked in `CREDITS.md`; it is still rewritten because the owner wants to sell the app and own all the code; see `docs/license_check.md`): fresh platform templates and our own icon, a new README, then rewrite the Caisse, product, shop details and printer screens and their BLoCs one by one, with the tests as a safety net; remove the Hive importer; check again with `git blame` and add our own LICENSE.
- New receipt layout (§3.6): French always, DA, ticket number, worker name, wrapped names, accents/code page, "Remove accents" option, test print, reprint from the sales list.
- New receipt lines for discount and credit, plus an optional "Ticket de retour".
- **Backup & restore (owner only):** *done in Phase 8, except the automatic local backup kept 7 days on the phone.*
  - "Create backup" makes a safe copy of the database while the app runs (SQLite `VACUUM INTO`) and packs it with a small info file (shop name, date, app version, database version) into `sauvegarde_<shop>_<date>.zip`. Then you choose where it goes: Downloads, USB, WhatsApp, Bluetooth... via the Android share menu.
  - **Automatic local backup** once a day, keeping the last 7 days, in the app's folder (no internet).
  - "Restore": pick a `.zip`. The app checks it belongs to this shop and is not from a newer app version, shows its date, and asks for confirmation + the owner PIN. It makes a backup of the current data first ("just in case"), replaces the database, and restarts the app.
  - After a restore on the owner's phone: worker phones re-send anything newer at the next sync (same UUIDs, so no duplicates).
  - Tests: backup → restore round trip gives identical data; wrong-shop or newer-version files are refused.
- **Easy to send off the phone (requested after Phase 7):** *done in Phase 8 (share button, daily Drive backup, 7-day warning).*
  - Every backup can be sent off the phone in two taps: Google Drive, WhatsApp, e-mail, or copied to a USB stick or a computer.
  - The app remembers when a backup last left the phone. When that is more than 7 days ago, the owner sees a reminder (banner in Plus, plus an alert) until a new backup is sent.
- **"Remplacer le téléphone principal" (owner only, requested after Phase 7):** for when the owner's phone (the hub) is lost, stolen or broken.
  - **Way 1, from a backup:** install the app on a new phone, restore the last backup, and it becomes the new hub. The worker phones then send everything newer than the backup; records keep their ids, so nothing is counted twice.
  - **Way 2, from a worker phone:** make a worker phone the new main phone. It already holds every synced record; it gets the hub role, the old hub is marked as removed, and the other phones re-pair to it with a new QR code.
  - **Safety:** the owner PIN is required. The shop secret is renewed so the lost phone can no longer sync. Tickets keep their phone letters, so no number is reused.
  - **Tests:** a hub replaced by a backup or by a worker phone ends with the same sales, stock and debts as before, without duplicates.
- **16 KB pages (seen after Phase 8b on the Android 16 emulator):** Android warns "This app isn't 16 KB compatible" because two libraries of the camera scanner package (`mobile_scanner` 5: `libbarhopper_v3.so`, `libimage_processing_util_jni.so`) are not 16 KB aligned. The app still runs (compatibility mode); the APK itself is aligned. Fix: upgrade `mobile_scanner` to a version with aligned libraries (its API changes), with the build tools upgrade.
- **Build tools upgrade (requested after Phase 7):** move Gradle, the Android Gradle Plugin and Kotlin to the versions the current Flutter fully supports (today Flutter warns that 8.11.1 / 2.2.20 will soon be unsupported). Keep Java 21 working, keep the release key rotation, and check that a release APK still updates the phones with `adb install -r`.
- Final pass: Arabic right-to-left check on every screen, dark mode check, empty states, small-screen overflow check.
- Remove the old Hive code (the import stays one more version if you prefer).
- Update the README in simple words.

---

## 6. Not included (unless you ask)
Cloud backup, iPhone build, discounts on individual lines (only whole-ticket discounts are planned), product variants/sizes, multiple shops.

---

## 7. Verification (every phase)
- `flutter analyze` → no issues. `flutter test` → all pass.
- `flutter run` on the Android emulator, following the phase's "You test" checklist.
- Phase 1 specifically: install the **current** app version first, add some products, then install the new version and check that the products survived.
- Phase 7: two real phones on the same Wi-Fi.
- Phase 8: the Google Sheet receives sales from a phone on mobile data, without duplicates.
- Phase 9: a real print on your 58mm printer, and a backup made on one phone restored on the emulator.
