/**
 * Gestion Boutique : la Google Sheet de la boutique (Phase 8).
 *
 * The shop phones send their new records here (sales, returns, stock
 * deliveries, losses, supplier payments, customer credit). The sheet is a
 * copy for viewing and reports: changing it never changes the app.
 *
 * Every request is signed with a secret key (HMAC-SHA256) and a time:
 * - the WRITE key (all the shop phones) can only add records;
 * - the READ key (owner's phone only) can also read the live sales and the
 *   day's figures, and save the backups to Google Drive.
 * Requests without the right signature, too old, or sent twice are refused.
 *
 * Installation: see docs/google_sheet_setup.md (menu "Boutique" →
 * "1. Installer"). Updating: paste the new code, save, then "Déployer →
 * Gérer les déploiements → Modifier → Nouvelle version", then run
 * "1. Installer" again: it adds the new tabs and keeps every row.
 *
 * The tabs "Customer credit" and "Produits" (debts, buying prices) can
 * only be written with the READ key, so only by the owner's phone.
 *
 * @OnlyCurrentDoc
 */

var VERSION = 2; // 2: Produits, Historique produits, Google account

// The tabs that receive rows from the phones. The phones send the short
// code (S, I...) to keep mobile data small. Columns: see the app
// (lib/features/sheet/data/sheet_records.dart).
var TABS = {
  S: {
    name: 'Sales',
    headers: ['ID', 'Date', 'Heure', 'Ticket', 'Vendeur', 'Téléphone', 'Type',
      'Paiement', 'Client', 'Ventes', 'Sous-total', 'Remise', 'Total',
      'Bénéfice', 'Retours', 'Encaissé'],
    dates: ['B'], texts: ['C', 'D'], money: ['K', 'L', 'M', 'N', 'O', 'P']
  },
  I: {
    name: 'Sale items',
    headers: ['ID', 'Date', 'Ticket', 'Produit', 'Quantité', 'Prix',
      'Montant', 'Coût unitaire', 'Bénéfice', 'Vendeur', 'Sortie de stock',
      'Type'],
    dates: ['B'], texts: ['C'], money: ['F', 'G', 'H', 'I']
  },
  D: {
    name: 'Stock deliveries',
    headers: ['ID', 'Date', 'Heure', 'Produit', 'Quantité', "Prix d'achat",
      'Total', 'Fournisseur', 'Expiration', 'Par', 'Téléphone'],
    dates: ['B', 'I'], texts: ['C'], money: ['F', 'G']
  },
  L: {
    name: 'Losses',
    headers: ['ID', 'Date', 'Heure', 'Produit', 'Quantité', 'Raison',
      'Coût unitaire', 'Valeur', 'Note', 'Par', 'Téléphone',
      'Sortie de stock'],
    dates: ['B'], texts: ['C'], money: ['G', 'H']
  },
  P: {
    name: 'Supplier payments', upsert: true,
    headers: ['ID', 'Date', 'Heure', 'Fournisseur', 'Montant', 'Statut',
      'Payé par', 'Validé par', 'Note', 'Téléphone'],
    dates: ['B'], texts: ['C'], money: ['E']
  },
  C: {
    name: 'Customer credit', upsert: true, ownerOnly: true,
    headers: ['ID', 'Client', 'Dette actuelle', 'Dernier paiement'],
    dates: ['D'], texts: [], money: ['C']
  },
  // Version 2.
  H: {
    name: 'Historique produits',
    headers: ['ID', 'Date', 'Heure', 'Produit', 'Changement', 'Avant',
      'Après', 'Par', 'Téléphone'],
    dates: ['B'], texts: ['C'], money: []
  },
  R: {
    name: 'Produits', upsert: true, ownerOnly: true,
    headers: ['ID', 'Produit', 'Code-barres', 'Catégorie', 'Prix de vente',
      "Prix d'achat", 'Stock', 'Expiration la plus proche', 'Archivé'],
    dates: ['H'], texts: ['C'], money: ['E', 'F']
  }
};

var SEEN_TAB = '_recus'; // hidden: the records already written
var FOLDER_NAME = 'Sauvegardes Boutique';
var KEEP_BACKUPS = 30;
var MAX_CLOCK_GAP_MS = 10 * 60 * 1000;
var MONEY_FORMAT = '#,##0.00 "DA"';
var DATE_FORMAT = 'dd/MM/yyyy';

// ------------------------------------------------------------------ menu

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Boutique')
    .addItem('1. Installer', 'installer')
    .addItem('Afficher le code de configuration', 'afficherCode')
    .addSeparator()
    .addItem("Changer l'adresse de l'application Web", 'changerAdresse')
    .addItem('Changer les clés (téléphone perdu)', 'changerCles')
    .addToUi();
}

/** Creates the tabs, the formulas and the keys, then shows the code. */
function installer() {
  var ss = SpreadsheetApp.getActive();
  ss.setSpreadsheetTimeZone('Africa/Algiers');
  Object.keys(TABS).forEach(function (code) {
    prepareTab_(ss, TABS[code]);
  });
  var seen = ss.getSheetByName(SEEN_TAB) || ss.insertSheet(SEEN_TAB);
  seen.hideSheet();
  writeFormulas_(ss);
  // The empty first tab Google creates ("Feuille 1", "Sheet1"...).
  ss.getSheets().forEach(function (sheet) {
    if (!isOurTab_(sheet.getName()) && sheet.getLastRow() === 0 &&
        ss.getSheets().length > 1) {
      ss.deleteSheet(sheet);
    }
  });
  var props = PropertiesService.getScriptProperties();
  if (!props.getProperty('WRITE_KEY')) props.setProperty('WRITE_KEY', newKey_());
  if (!props.getProperty('READ_KEY')) props.setProperty('READ_KEY', newKey_());
  afficherCode();
}

/** Shows the QR code the owner scans in the app. */
function afficherCode() {
  var ui = SpreadsheetApp.getUi();
  var props = PropertiesService.getScriptProperties();
  var write = props.getProperty('WRITE_KEY');
  var read = props.getProperty('READ_KEY');
  if (!write || !read) {
    ui.alert('Choisissez d\'abord « Boutique » → « 1. Installer ».');
    return;
  }
  var url = props.getProperty('URL') || askUrl_();
  if (!url) return;
  var code = JSON.stringify({ t: 'gb-sheet', v: VERSION, u: url, w: write, r: read });
  var html =
    '<!DOCTYPE html><html><head><base target="_top">' +
    '<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcode-generator/1.4.4/qrcode.min.js"></script>' +
    '<style>body{font-family:Arial,sans-serif;text-align:center;margin:8px}' +
    '#qr img{width:300px;height:300px;image-rendering:pixelated}' +
    'textarea{width:95%;height:80px;font-size:11px}' +
    '.warn{color:#b00020;font-weight:bold}</style></head><body>' +
    '<p>Sur le téléphone du patron :<br><b>Plus → Google Sheet → Scanner le code de configuration</b></p>' +
    '<div id="qr"></div>' +
    '<p class="warn">Ne montrez ce code à personne : il donne accès aux chiffres de la boutique.</p>' +
    '<details><summary>Pas de caméra (émulateur) ? Copier le code</summary>' +
    '<textarea id="t" readonly></textarea><br>' +
    '<button onclick="var t=document.getElementById(\'t\');t.select();document.execCommand(\'copy\');">Copier</button>' +
    '</details>' +
    '<script>var CODE=' + JSON.stringify(code).replace(/</g, '\\u003c') + ';' +
    'document.getElementById("t").value=CODE;' +
    'var qr=qrcode(0,"M");qr.addData(CODE);qr.make();' +
    'document.getElementById("qr").innerHTML=qr.createImgTag(6,8);</script>' +
    '</body></html>';
  ui.showModalDialog(
    HtmlService.createHtmlOutput(html).setWidth(440).setHeight(600),
    'Code de configuration');
}

/** After "Déployer → Nouveau déploiement", the address changes. */
function changerAdresse() {
  PropertiesService.getScriptProperties().deleteProperty('URL');
  afficherCode();
}

/** A phone was lost: new keys. Every phone must get the new code. */
function changerCles() {
  var ui = SpreadsheetApp.getUi();
  var answer = ui.alert('Changer les clés',
    'Les téléphones ne pourront plus écrire dans cette feuille ' +
    'tant que le patron n\'aura pas scanné le nouveau code. ' +
    'Les téléphones des employés recevront la nouvelle clé par Wi-Fi.\n\n' +
    'Continuer ?', ui.ButtonSet.YES_NO);
  if (answer !== ui.Button.YES) return;
  var props = PropertiesService.getScriptProperties();
  props.setProperty('WRITE_KEY', newKey_());
  props.setProperty('READ_KEY', newKey_());
  afficherCode();
}

function askUrl_() {
  var ui = SpreadsheetApp.getUi();
  var result = ui.prompt("Adresse de l'application Web",
    "Collez l'adresse copiée après « Déployer » (elle finit par /exec) :",
    ui.ButtonSet.OK_CANCEL);
  if (result.getSelectedButton() !== ui.Button.OK) return null;
  var url = result.getResponseText().trim();
  if (!/^https:\/\/script\.google\.com\/.*\/exec$/.test(url)) {
    ui.alert("Cette adresse ne finit pas par /exec. Recommencez avec " +
      "l'adresse de l'application Web (Déployer → Gérer les déploiements).");
    return null;
  }
  PropertiesService.getScriptProperties().setProperty('URL', url);
  return url;
}

function newKey_() {
  return Utilities.getUuid().replace(/-/g, '') +
    Utilities.getUuid().replace(/-/g, '').slice(0, 8);
}

// -------------------------------------------------------- tabs, formulas

function isOurTab_(name) {
  if (name === SEEN_TAB || name === 'Current stock' ||
      name === 'Daily summary' || name === 'Stats per worker') return true;
  return Object.keys(TABS).some(function (code) {
    return TABS[code].name === name;
  });
}

function prepareTab_(ss, tab) {
  var sheet = ss.getSheetByName(tab.name) || ss.insertSheet(tab.name);
  var width = tab.headers.length;
  sheet.getRange(1, 1, 1, width).setValues([tab.headers])
    .setFontWeight('bold').setBackground('#e8f0fe');
  sheet.setFrozenRows(1);
  tab.dates.forEach(function (col) {
    sheet.getRange(col + '2:' + col).setNumberFormat(DATE_FORMAT);
  });
  tab.texts.forEach(function (col) {
    sheet.getRange(col + '2:' + col).setNumberFormat('@');
  });
  tab.money.forEach(function (col) {
    sheet.getRange(col + '2:' + col).setNumberFormat(MONEY_FORMAT);
  });
  return sheet;
}

function formulaTab_(ss, name) {
  var sheet = ss.getSheetByName(name) || ss.insertSheet(name);
  sheet.clear();
  return sheet;
}

/** Tabs calculated inside the sheet: the phones never send them. */
function writeFormulas_(ss) {
  // Current stock = delivered - left the stock (sales, returns put back,
  // losses that touch the stock).
  var stock = formulaTab_(ss, 'Current stock');
  stock.getRange('A1').setFormula(
    "=QUERY({'Stock deliveries'!D2:E; 'Sale items'!D2:D, " +
    "ARRAYFORMULA(-'Sale items'!K2:K); Losses!D2:D, ARRAYFORMULA(-Losses!L2:L)}, " +
    "\"select Col1, sum(Col2) where Col1 is not null group by Col1 " +
    "order by Col1 label Col1 'Produit', sum(Col2) 'Stock'\", 0)");
  stock.getRange('A1:B1').setFontWeight('bold');

  // One line per day: number of sales, revenue, profit, cash, returns,
  // discounts. Returns are negative in "Total" and "Bénéfice".
  var daily = formulaTab_(ss, 'Daily summary');
  daily.getRange('A1').setFormula(
    "=QUERY(Sales!A2:P, \"select B, sum(J), sum(M), sum(N), sum(P), " +
    "sum(O), sum(L) where B is not null group by B order by B desc " +
    "label B 'Date', sum(J) 'Ventes', sum(M) \"\"Chiffre d'affaires\"\", " +
    "sum(N) 'Bénéfice', sum(P) 'Argent en caisse', sum(O) 'Retours', " +
    "sum(L) 'Remises'\", 0)");
  daily.getRange('A2:A').setNumberFormat(DATE_FORMAT);
  daily.getRange('C2:G').setNumberFormat(MONEY_FORMAT);
  daily.getRange('A1:G1').setFontWeight('bold');
  daily.setFrozenRows(1);

  // Per person: today, this month, since the start. Columns E..P of
  // Sales are Col1..Col12.
  var workers = formulaTab_(ss, 'Stats per worker');
  var select = "\"select Col1, sum(Col6), sum(Col9), sum(Col10), " +
    "sum(Col11) where Col1 is not null group by Col1 order by sum(Col9) desc " +
    "label Col1 'Vendeur', sum(Col6) 'Ventes', sum(Col9) \"\"Chiffre d'affaires\"\", " +
    "sum(Col10) 'Bénéfice', sum(Col11) 'Retours'\"";
  var blocks = [
    ['A', "Aujourd'hui", 'FILTER(Sales!E2:P, Sales!B2:B=TODAY())'],
    ['G', 'Ce mois-ci', 'FILTER(Sales!E2:P, Sales!B2:B>=EOMONTH(TODAY(),-1)+1)'],
    ['M', 'Depuis le début', '{Sales!E2:P}']
  ];
  blocks.forEach(function (block) {
    var col = block[0];
    workers.getRange(col + '1').setValue(block[1]).setFontWeight('bold');
    workers.getRange(col + '2').setFormula(
      '=IFERROR(QUERY(' + block[2] + ', ' + select + ', 0), "Aucune vente")');
    var first = workers.getRange(col + '2').getColumn();
    workers.getRange(3, first + 2, 1000, 3).setNumberFormat(MONEY_FORMAT);
  });
}

// ------------------------------------------------- requests from phones

function doGet() {
  return ContentService.createTextOutput('Boutique : le script fonctionne.');
}

function doPost(e) {
  var now = Date.now();
  try {
    var req = JSON.parse(e.postData.contents);
    var props = PropertiesService.getScriptProperties();
    var keyName = req.k === 'r' ? 'READ_KEY' : (req.k === 'w' ? 'WRITE_KEY' : null);
    var key = keyName ? props.getProperty(keyName) : null;
    if (!key) return reply_({ ok: false, err: 'setup' });
    var message = [req.v, req.op, req.ts, req.n, req.k, req.b].join('\n');
    if (!sameText_(hmacHex_(message, key), String(req.s))) {
      return reply_({ ok: false, err: 'sig' });
    }
    // The phone's clock may be wrong: it corrects itself with "now".
    if (Math.abs(now - Number(req.ts)) > MAX_CLOCK_GAP_MS) {
      return reply_({ ok: false, err: 'time', now: now });
    }
    // The same signed request sent again (copied by someone) is refused.
    var cache = CacheService.getScriptCache();
    var nonce = 'n' + String(req.n).slice(0, 64);
    if (cache.get(nonce)) return reply_({ ok: false, err: 'replay' });
    cache.put(nonce, '1', 1500);

    var body = JSON.parse(req.b);
    var ownerOnly = { live: true, summary: true, backup: true };
    if (ownerOnly[req.op] && req.k !== 'r') {
      return reply_({ ok: false, err: 'sig' });
    }
    switch (req.op) {
      case 'ping':
        var info = { ok: true, name: SpreadsheetApp.getActive().getName(), v: VERSION };
        // The owner's phone shows "Compte Google : ...".
        if (req.k === 'r') info.email = Session.getEffectiveUser().getEmail();
        return reply_(info);
      case 'push':
        return reply_(push_(body, req.k === 'r'));
      case 'live':
        return reply_(live_(body));
      case 'summary':
        return reply_(summary_(body));
      case 'backup':
        return reply_(backup_(body));
    }
    return reply_({ ok: false, err: 'op' });
  } catch (err) {
    return reply_({ ok: false, err: 'server', msg: String(err).slice(0, 200) });
  }
}

function reply_(answer) {
  return ContentService.createTextOutput(JSON.stringify(answer))
    .setMimeType(ContentService.MimeType.JSON);
}

function hmacHex_(message, key) {
  var bytes = Utilities.computeHmacSha256Signature(message, key,
    Utilities.Charset.UTF_8);
  var hex = '';
  for (var i = 0; i < bytes.length; i++) {
    var b = bytes[i] < 0 ? bytes[i] + 256 : bytes[i];
    hex += (b < 16 ? '0' : '') + b.toString(16);
  }
  return hex;
}

/** Compares every character, so the time taken reveals nothing. */
function sameText_(a, b) {
  if (a.length !== b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/**
 * A cell value from a phone, made safe: a text starting with = + - @
 * would be run as a formula, so it is kept as plain text.
 */
function clean_(row, tab) {
  var out = [];
  for (var i = 0; i < tab.headers.length; i++) {
    var v = row && i < row.length ? row[i] : '';
    if (v === null || v === undefined) v = '';
    if (typeof v === 'string') {
      v = v.slice(0, 300);
      if (/^[=+\-@]/.test(v)) v = "'" + v;
    } else if (typeof v !== 'number' || !isFinite(v)) {
      v = String(v).slice(0, 300);
    }
    out.push(v);
  }
  return out;
}

function tab_(ss, code) {
  return ss.getSheetByName(TABS[code].name) || prepareTab_(ss, TABS[code]);
}

/**
 * Writes the records. A record already written (same id) is skipped, so
 * the same sale sent by a worker phone and by the owner's phone appears
 * once. Supplier payments and customer credit are updated in place.
 */
function push_(body, owner) {
  var records = (body.r || []).slice(0, 500);
  var lock = LockService.getScriptLock();
  lock.waitLock(30000);
  try {
    var ss = SpreadsheetApp.getActive();
    var seenSheet = ss.getSheetByName(SEEN_TAB) || ss.insertSheet(SEEN_TAB);
    var seen = {};
    var last = seenSheet.getLastRow();
    if (last > 0) {
      seenSheet.getRange(1, 1, last, 1).getValues().forEach(function (r) {
        seen[r[0]] = true;
      });
    }
    var append = {};
    var upserts = {};
    var newSeen = [];
    records.forEach(function (record) {
      var tabs = record.t || {};
      var tag = String(record.k) + ':' + String(record.id);
      if (!record.u) {
        if (seen[tag]) return;
        seen[tag] = true;
        newSeen.push([tag]);
      }
      Object.keys(tabs).forEach(function (code) {
        var tab = TABS[code];
        if (!tab || !!tab.upsert !== !!record.u) return;
        if (tab.ownerOnly && !owner) return; // needs the read key
        var target = tab.upsert ? upserts : append;
        (tabs[code] || []).forEach(function (row) {
          (target[code] = target[code] || []).push(clean_(row, tab));
        });
      });
    });
    Object.keys(append).forEach(function (code) {
      var sheet = tab_(ss, code);
      var rows = append[code];
      sheet.getRange(sheet.getLastRow() + 1, 1, rows.length, rows[0].length)
        .setValues(rows);
    });
    Object.keys(upserts).forEach(function (code) {
      upsertRows_(tab_(ss, code), upserts[code]);
    });
    // Marked as written last: if something fails before, the phone sends
    // the record again.
    if (newSeen.length) {
      seenSheet.getRange(seenSheet.getLastRow() + 1, 1, newSeen.length, 1)
        .setValues(newSeen);
    }
    SpreadsheetApp.flush();
    return { ok: true, added: newSeen.length };
  } finally {
    lock.releaseLock();
  }
}

function upsertRows_(sheet, rows) {
  var last = sheet.getLastRow();
  var where = {};
  if (last > 1) {
    sheet.getRange(2, 1, last - 1, 1).getValues().forEach(function (r, i) {
      where[r[0]] = i + 2;
    });
  }
  rows.forEach(function (row) {
    var line = where[row[0]];
    if (!line) {
      line = sheet.getLastRow() + 1;
      where[row[0]] = line;
    }
    sheet.getRange(line, 1, 1, row.length).setValues([row]);
  });
}

function dayText_(value, tz) {
  return value instanceof Date ? Utilities.formatDate(value, tz, 'yyyy-MM-dd') : '';
}

/**
 * "Ventes en direct": the Sales rows after row number body.c. The first
 * time (no number), only today's rows (body.d, "yyyy-MM-dd").
 */
function live_(body) {
  var ss = SpreadsheetApp.getActive();
  var tz = ss.getSpreadsheetTimeZone();
  var sheet = ss.getSheetByName(TABS.S.name);
  var last = sheet ? sheet.getLastRow() : 1;
  var cursor = body.c;
  var fresh = !(typeof cursor === 'number' && cursor >= 1 && cursor <= last);
  var start = fresh ? Math.max(2, last - 1999) : cursor + 1;
  var rows = [];
  var end = fresh ? Math.max(1, start - 1) : cursor;
  if (sheet && last >= start) {
    var count = Math.min(last - start + 1, fresh ? 2000 : 500);
    var values = sheet.getRange(start, 1, count, 16).getValues();
    values.forEach(function (v) {
      var day = dayText_(v[1], tz);
      if (fresh && day !== body.d) return;
      if (v[6] === 'Paiement client') return;
      rows.push([String(v[0]), day, String(v[2]), String(v[3]), String(v[4]),
        String(v[5]), String(v[6]), Number(v[12]) || 0]);
    });
    end = start + count - 1;
  }
  return { ok: true, c: end, r: rows, m: end < last };
}

/** The figures of one day (body.d, "yyyy-MM-dd"), for the evening report. */
function summary_(body) {
  var ss = SpreadsheetApp.getActive();
  var tz = ss.getSpreadsheetTimeZone();
  var sheet = ss.getSheetByName(TABS.S.name);
  var result = { ok: true, sales: 0, revenue: 0, profit: 0, cash: 0, returns: 0, discounts: 0 };
  if (!sheet || sheet.getLastRow() < 2) return result;
  var last = sheet.getLastRow();
  var start = Math.max(2, last - 19999);
  sheet.getRange(start, 1, last - start + 1, 16).getValues().forEach(function (v) {
    if (dayText_(v[1], tz) !== body.d) return;
    result.sales += Number(v[9]) || 0;
    result.discounts += Number(v[11]) || 0;
    result.revenue += Number(v[12]) || 0;
    result.profit += Number(v[13]) || 0;
    result.returns += Number(v[14]) || 0;
    result.cash += Number(v[15]) || 0;
  });
  return result;
}

/** Saves a backup in "Sauvegardes Boutique" and keeps the last 30. */
function backup_(body) {
  var name = String(body.name || 'sauvegarde.zip')
    .replace(/[^\w.\-]/g, '_').slice(0, 120);
  var blob = Utilities.newBlob(Utilities.base64Decode(String(body.data)),
    'application/zip', name);
  var folder = backupFolder_();
  folder.createFile(blob);
  var files = [];
  var it = folder.getFiles();
  while (it.hasNext()) files.push(it.next());
  files.sort(function (a, b) { return b.getDateCreated() - a.getDateCreated(); });
  for (var i = KEEP_BACKUPS; i < files.length; i++) files[i].setTrashed(true);
  return { ok: true, kept: Math.min(files.length, KEEP_BACKUPS) };
}

function backupFolder_() {
  var props = PropertiesService.getScriptProperties();
  var id = props.getProperty('BACKUP_FOLDER');
  if (id) {
    try {
      var existing = DriveApp.getFolderById(id);
      if (!existing.isTrashed()) return existing;
    } catch (err) {
      // Deleted: a new folder is made below.
    }
  }
  var folder = DriveApp.createFolder(FOLDER_NAME);
  props.setProperty('BACKUP_FOLDER', folder.getId());
  return folder;
}
