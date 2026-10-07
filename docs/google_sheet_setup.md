# Google Sheet of the shop: setup guide

This guide connects the app to a Google Sheet in **your own Gmail account**.
You do it once, on a computer, in about 15 minutes.

What you get:
- every sale, return, stock delivery, loss, supplier payment and customer
  debt copied into the sheet;
- "Ventes en direct" and a notification for each sale on your phone;
- the evening report (sales, revenue, profit, cash, returns);
- a backup in your Google Drive every day (the last 30 are kept).

The script you install is in this project: `tool/google_sheet/Code.gs`.

---

## Part 1: create the sheet and paste the script (on the computer)

1. Open **https://sheets.google.com** and sign in with the shop owner's Gmail.
2. Click **Blank spreadsheet** (the big "+").
3. Click the title "Untitled spreadsheet" at the top left. Type a name,
   for example `Boutique El Baraka`. Press Enter.
4. In the menu, click **Extensions → Apps Script**. A new tab opens with
   a file called `Code.gs` that contains a few lines.
5. Click inside that code, press **Ctrl+A** (select all), then **Delete**.
6. On your computer, open the file `tool\google_sheet\Code.gs` of the
   project with Notepad. Press **Ctrl+A**, then **Ctrl+C** (copy).
7. Go back to the Apps Script tab, click in the empty code area and press
   **Ctrl+V** (paste).
8. Click the **Save** icon (the disk), or press **Ctrl+S**.
9. At the top left, click "Untitled project" and name it `Boutique`.
   Click **Rename**.

## Part 2: publish the script as a "web app"

1. At the top right of Apps Script, click the blue **Deploy** button →
   **New deployment**.
2. Next to "Select type", click the **gear icon** → **Web app**.
3. Fill in:
   - **Description**: `Boutique`
   - **Execute as**: **Me (your Gmail address)**
   - **Who has access**: **Anyone**

   "Anyone" is needed so the phones can reach the script without signing
   in. They still need the secret keys: without them the script refuses
   everything.
4. Click **Deploy**.
5. Google asks for permission: click **Authorize access**.

### The Google warning screens (this is normal)

Google shows these screens because **you** wrote this script and Google
has not reviewed it. It runs only in your own account.

1. **"Choose an account"**: click the shop owner's Gmail.
2. **"Google hasn't verified this app"**: click **Advanced** (small link at
   the bottom left), then **Go to Boutique (unsafe)**.
   "Unsafe" only means "not checked by Google". The script is the one you
   pasted from the project.
3. **"Boutique wants to access your Google Account"**: you see two
   permissions:
   - *See, edit, create and delete your spreadsheets... this document*:
     to write the rows in this sheet only.
   - *See, edit, create and delete all of your Google Drive files*: to
     put the backups in the folder "Sauvegardes Boutique". The script
     only uses that folder.
   - *Display and run third-party web content in prompts and sidebars*:
     for the window that draws the QR code.

   Click **Allow** (or **Continue**). On some accounts you must tick the
   boxes first ("Select all").
4. Back in Apps Script, a window shows **Web app URL**, ending in `/exec`.
   Click **Copy**. Keep it: you paste it in Part 3.
5. Click **Done**.

## Part 3: install the tabs and show the code

1. Go back to the **sheet** tab and **reload the page** (F5).
2. After a few seconds a new menu **Boutique** appears at the right of
   "Help". Click **Boutique → 1. Installer**.
3. The first time, Google may ask for permission again: same screens as
   above (Advanced → Go to Boutique → Allow). Then click
   **Boutique → 1. Installer** again.
4. A box asks for the web app address: press **Ctrl+V** to paste the
   address copied in Part 2 (ending in `/exec`). Click **OK**.
5. The script creates the tabs (Sales, Sale items, Stock deliveries,
   Current stock, Losses, Supplier payments, Customer credit,
   Daily summary, Stats per worker), creates the **keys** by itself and
   shows the **QR code**.

To see the code again later: **Boutique → Afficher le code de configuration**.

## Part 4: connect the owner's phone

1. On the owner's phone (or the emulator), log in as the **owner**.
2. Open **Plus → Google Sheet**.
3. Tap **Scanner le code de configuration** and scan the QR code on the
   computer screen.
   - **Emulator (no camera)**: in the QR window on the computer, click
     **"Pas de caméra (émulateur) ? Copier le code"**, then **Copier**.
     In the app, tap **Coller le code**, long-press the field →
     **Paste**, then **Continuer**. (The emulator shares the computer's
     clipboard.)
4. The app checks the keys with Google, then shows
   **"Connecté à « Boutique El Baraka »"**. Everything already in the
   shop is sent to the sheet.
5. The worker phones receive the address and the **write key** at their
   next Wi-Fi sync. They never receive the read key.

---

## Updating the script later

If a new version of `Code.gs` comes with the app:
1. Apps Script → select all → paste the new code → Save.
2. **Deploy → Manage deployments** → the pencil (Edit) → **Version:
   New version** → **Deploy**.
   This keeps the same address, so the phones keep working.
   (A "New deployment" would create a new address: then use
   **Boutique → Changer l'adresse de l'application Web** and scan again.)

## If a phone is lost or stolen

In the sheet: **Boutique → Changer les clés (téléphone perdu)**. The old
keys stop working at once. Scan the new code on the owner's phone; the
worker phones get the new write key by Wi-Fi.
Also remove the lost phone in **Plus → Synchronisation Wi-Fi**.

## Restoring a backup on a new phone

1. Install the app on the new phone (`adb install -r ...`).
2. On the new phone, open the **Google Drive** app with the owner's Gmail.
   The backups are in the folder **Sauvegardes Boutique**, one per day:
   `sauvegarde_<shop>_<date>.zip`.
3. Open the app. On the first screen, tap
   **Restaurer une sauvegarde (nouveau téléphone)**.
4. Tap **Choisir le fichier de sauvegarde**. In the file window, open the
   menu (☰) → **Drive** → **Sauvegardes Boutique** and pick the newest
   file. (Or download it from Drive first, then pick it in Downloads.)
5. Check the shop name and date, tap **Restaurer**, type the **owner
   PIN**.
6. The app closes. Open it again: everything is back. Log in, then scan
   the Google Sheet code again (Plus → Google Sheet). For safety, the
   read key is not stored inside backups.

Do not keep using the old phone at the same time: two phones would act
as the same main phone.
