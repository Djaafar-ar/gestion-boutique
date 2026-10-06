// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Gestion Boutique';

  @override
  String get navSell => 'Vendre';

  @override
  String get navStock => 'Stock';

  @override
  String get navStats => 'Stats';

  @override
  String get navAlerts => 'Alertes';

  @override
  String get navMore => 'Plus';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonRequired => 'Champ obligatoire';

  @override
  String errorWithDetail(String detail) {
    return 'Erreur : $detail';
  }

  @override
  String get priceRequired => 'Entrez un prix';

  @override
  String get priceInvalid => 'Prix invalide (ex : 1250 ou 1250,50)';

  @override
  String get priceNegative => 'Le prix ne peut pas être négatif';

  @override
  String get cartTitle => 'Panier';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String get totalLabel => 'TOTAL';

  @override
  String get cartEmptyTitle => 'Panier vide';

  @override
  String get cartEmptyBody =>
      'Scannez un code-barres avec la caméra pour ajouter des articles.';

  @override
  String get goToCheckout => 'Passer à l\'encaissement';

  @override
  String get cameraOffTitle => 'Caméra éteinte';

  @override
  String get cameraOffBody =>
      'Allumez la caméra pour scanner les codes-barres.';

  @override
  String get turnOnCamera => 'Allumer la caméra';

  @override
  String productNotFound(String barcode) {
    return 'Produit introuvable : $barcode';
  }

  @override
  String get checkoutTitle => 'Encaissement';

  @override
  String get columnProduct => 'Produit';

  @override
  String get columnPrice => 'Prix';

  @override
  String get columnTotal => 'Total';

  @override
  String get amountToPay => 'TOTAL À PAYER';

  @override
  String get confirmWithoutPrint => 'Valider sans imprimer';

  @override
  String get confirmAndPrint => 'Valider et imprimer';

  @override
  String saleSaved(String number) {
    return 'Vente n°$number enregistrée';
  }

  @override
  String saleSavedAndPrinted(String number) {
    return 'Vente n°$number enregistrée et imprimée';
  }

  @override
  String get saleSaveFailed => 'La vente n\'a pas pu être enregistrée.';

  @override
  String get printNoPrinter =>
      'Aucune imprimante enregistrée. Connectez-en une dans Plus.';

  @override
  String get printConnectFailed =>
      'Impossible de se connecter à l\'imprimante.';

  @override
  String get printFailed => 'L\'impression a échoué.';

  @override
  String get printReprintHint =>
      'La vente est enregistrée : réimprimez-la depuis l\'historique.';

  @override
  String get historyTitle => 'Historique des ventes';

  @override
  String get historyEmptyTitle => 'Aucune vente';

  @override
  String get historyEmptyBody => 'Les ventes validées apparaîtront ici.';

  @override
  String saleTitle(String number) {
    return 'Vente n°$number';
  }

  @override
  String salesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ventes',
      one: '1 vente',
      zero: 'Aucune vente',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get reprint => 'Réimprimer';

  @override
  String get receiptPrinted => 'Ticket imprimé';

  @override
  String get productsTitle => 'Produits';

  @override
  String get productSearchHint => 'Nom ou code-barres';

  @override
  String get productsEmptyTitle => 'Aucun produit';

  @override
  String get productsEmptyBody =>
      'Ajoutez votre premier produit avec le bouton +.';

  @override
  String get productsNoMatch => 'Aucun produit ne correspond à la recherche.';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get barcodeLabel => 'Code-barres';

  @override
  String get barcodeHint => 'Scannez ou tapez le code-barres';

  @override
  String get barcodeRequired => 'Entrez un code-barres';

  @override
  String get scanHelp => 'Touchez l\'icône pour scanner avec la caméra';

  @override
  String get productNameLabel => 'Nom du produit (en français)';

  @override
  String get productNameHint => 'ex : Jus Rouiba 1L';

  @override
  String get productNameRequired => 'Entrez un nom';

  @override
  String get sellPriceLabel => 'Prix de vente';

  @override
  String barcodeExists(String barcode) {
    return 'Un produit avec le code-barres « $barcode » existe déjà.';
  }

  @override
  String get productAdded => 'Produit ajouté';

  @override
  String get productUpdated => 'Produit modifié';

  @override
  String get productArchived => 'Produit archivé';

  @override
  String get archiveProductTitle => 'Archiver ce produit ?';

  @override
  String archiveProductBody(String name) {
    return '« $name » ne sera plus proposé à la vente. L\'historique des ventes est conservé.';
  }

  @override
  String get archive => 'Archiver';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get scanBarcodeTitle => 'Scanner un code-barres';

  @override
  String get alignBarcode => 'Placez le code-barres dans le cadre';

  @override
  String get moreTitle => 'Plus';

  @override
  String get shopNameFallback => 'Ma boutique';

  @override
  String get sectionShop => 'Boutique';

  @override
  String get shopDetails => 'Informations de la boutique';

  @override
  String get shopDetailsSub => 'Nom, adresse, téléphone, bas du ticket';

  @override
  String get sectionPreferences => 'Préférences';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Comme le téléphone';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get sectionPrinter => 'Imprimante';

  @override
  String get printerDevice => 'Imprimante Bluetooth';

  @override
  String get printerNone => 'Aucune imprimante connectée';

  @override
  String get printerConnectedBadge => 'CONNECTÉE';

  @override
  String get printerConnected => 'Imprimante connectée';

  @override
  String get printerHelp =>
      'Nouvelle imprimante : touchez l\'engrenage pour l\'appairer dans les réglages Bluetooth du téléphone, revenez, puis touchez Actualiser.';

  @override
  String get printerErrNoPaired => 'Aucun appareil appairé trouvé.';

  @override
  String get printerErrConnectAll =>
      'Impossible de se connecter à un appareil appairé.';

  @override
  String get printerErrConnect => 'Connexion à l\'imprimante impossible.';

  @override
  String get printerErrPermission => 'Autorisation Bluetooth refusée.';

  @override
  String get testPrint => 'Imprimer un ticket test';

  @override
  String get refresh => 'Actualiser';

  @override
  String get bluetoothSettings => 'Réglages Bluetooth';

  @override
  String get shopInfoTitle => 'Informations générales';

  @override
  String get shopInfoHint =>
      'Ces informations apparaissent sur les tickets imprimés.';

  @override
  String get shopNameLabel => 'Nom de la boutique';

  @override
  String get shopNameHint => 'ex : Épicerie El Baraka';

  @override
  String get address1Label => 'Adresse';

  @override
  String get address1Hint => 'ex : Rue 5, Bab Ezzouar';

  @override
  String get address2Label => 'Adresse, suite (facultatif)';

  @override
  String get address2Hint => 'ex : Alger 16000';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get phoneHint => 'ex : 0555 12 34 56';

  @override
  String get footerLabel => 'Message en bas du ticket';

  @override
  String get footerHint => 'ex : Merci, à bientôt !';

  @override
  String maxChars(int count) {
    return '$count caractères max';
  }

  @override
  String get shopSaved => 'Informations enregistrées';

  @override
  String get commonYes => 'Oui';

  @override
  String get commonNo => 'Non';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get unknownUser => 'Inconnu';

  @override
  String get nameLabel => 'Nom';

  @override
  String get phoneOptionalLabel => 'Téléphone (facultatif)';

  @override
  String get setupWelcomeTitle => 'Bienvenue !';

  @override
  String get setupWelcomeBody => 'Configurons votre boutique en 3 étapes.';

  @override
  String get setupExistingBody =>
      'Créez le compte du propriétaire pour continuer. Vos produits et vos ventes sont conservés.';

  @override
  String get setupStepShop => 'Votre boutique';

  @override
  String get setupStepOwner => 'Le propriétaire';

  @override
  String get setupStepPin => 'Code PIN';

  @override
  String get ownerNameLabel => 'Votre nom';

  @override
  String get ownerNameHint => 'ex : Karim Benali';

  @override
  String get pinLabel => 'Code PIN (4 chiffres)';

  @override
  String get pinConfirmLabel => 'Confirmez le code PIN';

  @override
  String get pinInvalid => 'Le code PIN doit avoir 4 chiffres';

  @override
  String get pinMismatch => 'Les deux codes PIN ne sont pas identiques';

  @override
  String get pinHelp =>
      'Vous taperez ce code pour ouvrir l\'application. Ne le partagez pas.';

  @override
  String get nextStep => 'Suivant';

  @override
  String get previousStep => 'Retour';

  @override
  String get finishSetup => 'Terminer';

  @override
  String get loginTitle => 'Qui êtes-vous ?';

  @override
  String get loginEnterPin => 'Entrez votre code PIN';

  @override
  String loginWrongPin(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Encore $left essais.',
      one: 'Encore 1 essai.',
    );
    return 'Code PIN incorrect. $_temp0';
  }

  @override
  String get roleOwner => 'Propriétaire';

  @override
  String get roleWorker => 'Employé';

  @override
  String get teamSection => 'Équipe';

  @override
  String get workersTitle => 'Employés';

  @override
  String get workersSub => 'Ajouter, modifier, désactiver';

  @override
  String get addWorker => 'Ajouter un employé';

  @override
  String get editAccount => 'Modifier le compte';

  @override
  String get workerNameHint => 'ex : Amine Kaci';

  @override
  String get newPinLabel => 'Nouveau code PIN (4 chiffres)';

  @override
  String get pinKeepHint => 'Laissez vide pour garder le code actuel';

  @override
  String get activeLabel => 'Compte actif';

  @override
  String get activeHelp =>
      'Un compte désactivé ne peut plus se connecter. Son historique est conservé.';

  @override
  String get inactiveBadge => 'DÉSACTIVÉ';

  @override
  String get accountSaved => 'Compte enregistré';

  @override
  String get noWorkersBody =>
      'Ajoutez vos employés : chacun aura son propre code PIN.';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get myStatsTitle => 'Mes ventes';

  @override
  String get periodWeek => 'Cette semaine';

  @override
  String get periodMonth => 'Ce mois-ci';

  @override
  String get statRevenue => 'Chiffre d\'affaires';

  @override
  String get statSales => 'Ventes';

  @override
  String get statItems => 'Articles vendus';

  @override
  String get statLosses => 'Pertes enregistrées';

  @override
  String get changePin => 'Changer mon code PIN';

  @override
  String get currentPinLabel => 'Code PIN actuel';

  @override
  String get currentPinWrong => 'Le code PIN actuel est incorrect';

  @override
  String get pinChanged => 'Code PIN modifié';

  @override
  String get switchUser => 'Changer d\'utilisateur';

  @override
  String get switchUserSub => 'Retour à l\'écran des codes PIN';

  @override
  String get buyPriceLabel => 'Prix d\'achat (facultatif)';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get noCategory => 'Sans catégorie';

  @override
  String get newCategory => 'Nouvelle catégorie…';

  @override
  String get categoryNameHint => 'ex : Boissons';

  @override
  String get lowStockLabel => 'Alerte stock bas à partir de';

  @override
  String get lowStockHelp =>
      'Alerte dans l\'onglet Alertes à ce niveau. 0 = seulement si des articles sont vendus sans stock.';

  @override
  String get quantityInvalid => 'Entrez un nombre entier';

  @override
  String get historySection => 'Historique des modifications';

  @override
  String get historyNoChanges => 'Aucune modification pour l\'instant.';

  @override
  String get fieldBuyPrice => 'Prix d\'achat';

  @override
  String get fieldLowStock => 'Seuil de stock bas';

  @override
  String get fieldArchived => 'Archivé';

  @override
  String soldBy(String name) {
    return 'Vendu par $name';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get pinLengthLabel => 'Longueur du code PIN';

  @override
  String pinDigits(int count) {
    return '$count chiffres';
  }

  @override
  String pinLabelN(int count) {
    return 'Code PIN ($count chiffres)';
  }

  @override
  String newPinLabelN(int count) {
    return 'Nouveau code PIN ($count chiffres)';
  }

  @override
  String pinInvalidN(int count) {
    return 'Le code PIN doit avoir $count chiffres';
  }

  @override
  String get pinInvalidAny => 'Code PIN invalide';

  @override
  String loginWait(String time) {
    return 'Trop de codes faux. Réessayez dans $time.';
  }

  @override
  String get loginWaitPaused =>
      'Le décompte avance seulement quand l\'application est ouverte.';

  @override
  String get loginLockedWorker =>
      'Ce compte est verrouillé après trop de codes faux. Demandez au propriétaire de le débloquer.';

  @override
  String get loginLockedOwner =>
      'Ce compte est verrouillé après trop de codes faux. Utilisez votre code de récupération.';

  @override
  String get forgotPin => 'Code PIN oublié ?';

  @override
  String get recoveryTitle => 'Récupérer le compte';

  @override
  String get recoveryIntro =>
      'Tapez le code de récupération noté lors de la création du compte, puis choisissez un nouveau code PIN.';

  @override
  String get recoveryCodeLabel => 'Code de récupération';

  @override
  String get recoveryCodeHint => 'ex : K7QM-3WZD-HP9X';

  @override
  String get recoveryCodeWrong =>
      'Code de récupération incorrect. La tentative est enregistrée.';

  @override
  String get recoveryShowTitle => 'Votre code de récupération';

  @override
  String get recoveryShowBody =>
      'Notez ce code sur papier et gardez-le en lieu sûr. Il permet de changer le code PIN du propriétaire s\'il est oublié ou bloqué. Il ne sera plus jamais affiché.';

  @override
  String get recoveryOldCodeUsed =>
      'L\'ancien code a été utilisé : il ne fonctionne plus. Voici le nouveau.';

  @override
  String get recoveryNoted => 'J\'ai noté ce code';

  @override
  String get recoveryTile => 'Code de récupération';

  @override
  String get recoveryMissing => 'Pas encore créé : créez-le maintenant';

  @override
  String get recoveryExists =>
      'Créé. Touchez pour en créer un nouveau (l\'ancien ne marchera plus).';

  @override
  String get recoveryMissingBanner =>
      'Créez votre code de récupération : sans lui, un code PIN propriétaire oublié ou bloqué ne pourra pas être changé.';

  @override
  String get confirmWithPin => 'Entrez votre code PIN actuel pour continuer';

  @override
  String get lockedBadge => 'VERROUILLÉ';

  @override
  String get lockedWorkerCard =>
      'Ce compte est verrouillé après trop de codes PIN faux.';

  @override
  String get unlockAccount => 'Débloquer le compte';

  @override
  String get accountUnlocked => 'Compte débloqué';

  @override
  String get resetPinLabel => 'Nouveau code PIN (pour le réinitialiser)';

  @override
  String get ownerPinFromProfile =>
      'Changez votre propre code PIN depuis votre profil.';

  @override
  String get failedLoginsTitle => 'Tentatives de connexion échouées';

  @override
  String get failedLoginsSub => 'Codes faux tapés, par compte';

  @override
  String failedLoginsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes faux ont été tapés depuis votre dernière connexion.',
      one: '1 code faux a été tapé depuis votre dernière connexion.',
    );
    return '$_temp0';
  }

  @override
  String get failedLoginsEmpty => 'Aucune tentative échouée.';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get securitySection => 'Sécurité';

  @override
  String get kindPin => 'Code PIN';

  @override
  String accountLabel(String name) {
    return 'Compte : $name';
  }

  @override
  String stockLabel(int count) {
    return 'Stock : $count';
  }

  @override
  String get outOfStock => 'Rupture';

  @override
  String get lowStockBadge => 'Stock bas';

  @override
  String expiresOn(String date) {
    return 'Exp. $date';
  }

  @override
  String get expiredBadge => 'Périmé';

  @override
  String get expiresSoonBadge => 'Bientôt périmé';

  @override
  String get noExpiry => 'Sans date de péremption';

  @override
  String get addDelivery => 'Réception de stock';

  @override
  String get recordLoss => 'Déclarer une perte';

  @override
  String get lossesTitle => 'Pertes';

  @override
  String get inStockLabel => 'En stock';

  @override
  String get batchesTitle => 'Lots';

  @override
  String get batchesEmpty =>
      'Aucun stock pour l\'instant. Ajoutez une réception de stock.';

  @override
  String batchRemaining(int remaining, int quantity) {
    return '$remaining sur $quantity';
  }

  @override
  String receivedBy(String date, String name) {
    return 'Reçu le $date par $name';
  }

  @override
  String receivedOn(String date) {
    return 'Reçu le $date';
  }

  @override
  String get showEmptyBatches => 'Voir aussi les lots épuisés';

  @override
  String missingStock(int count) {
    return '$count vendu(s) sans stock enregistré : ajoutez la réception oubliée.';
  }

  @override
  String get chooseProduct => 'Choisir un produit';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get quantityRequired => 'Entrez une quantité (au moins 1)';

  @override
  String get buyPriceUnitLabel => 'Prix d\'achat par article';

  @override
  String get expiryLabel => 'Date de péremption (facultatif)';

  @override
  String get pickDate => 'Choisir une date';

  @override
  String get noExpiryHelp =>
      'Laissez vide pour les produits qui ne périment pas.';

  @override
  String get updateBuyPrice =>
      'Utiliser ce prix comme prix d\'achat du produit';

  @override
  String get noteOptional => 'Note (facultatif)';

  @override
  String deliverySaved(int count, String name) {
    return '$count × $name ajouté(s) au stock';
  }

  @override
  String get saveDelivery => 'Ajouter au stock';

  @override
  String get lossReasonLabel => 'Raison';

  @override
  String get reasonDamaged => 'Abîmé';

  @override
  String get reasonExpired => 'Périmé';

  @override
  String get reasonStaff => 'Consommé par le personnel';

  @override
  String get reasonStolen => 'Volé';

  @override
  String get reasonOther => 'Autre';

  @override
  String get lossBatchLabel => 'Lot concerné';

  @override
  String get lossBatchAuto => 'Automatique (celui qui expire en premier)';

  @override
  String batchOption(String date, int remaining) {
    return 'Exp. $date · reste $remaining';
  }

  @override
  String batchOptionNoDate(String date, int remaining) {
    return 'Reçu le $date · reste $remaining';
  }

  @override
  String lossValuePreview(String amount) {
    return 'Valeur perdue estimée : $amount';
  }

  @override
  String lossSaved(String amount) {
    return 'Perte enregistrée : $amount';
  }

  @override
  String get saveLoss => 'Enregistrer la perte';

  @override
  String get lossesEmpty => 'Aucune perte enregistrée.';

  @override
  String lossesTotal(String amount) {
    return 'Total perdu : $amount';
  }

  @override
  String get lossFromReturn => 'Retour client';

  @override
  String moreThanStock(int count) {
    return 'Il n\'en reste que $count en stock. Ce sera quand même enregistré.';
  }

  @override
  String get discountLabel => 'Remise';

  @override
  String get addDiscount => 'Ajouter une remise';

  @override
  String get discountAmount => 'Montant';

  @override
  String get discountPercent => 'Pourcentage';

  @override
  String get removeDiscount => 'Retirer la remise';

  @override
  String get subtotalLabel => 'Sous-total';

  @override
  String discountTooHigh(int max) {
    return 'Remise trop élevée : maximum $max % pour les employés.';
  }

  @override
  String get discountInvalid => 'Remise invalide';

  @override
  String get applyLabel => 'Appliquer';

  @override
  String get stockWarningTitle => 'Stock insuffisant';

  @override
  String get stockWarningBody => 'La vente sera quand même enregistrée.';

  @override
  String get searchTicketHint => 'N° de ticket';

  @override
  String get noSaleFound => 'Aucune vente trouvée.';

  @override
  String get returnButton => 'Retour client';

  @override
  String get refundedLabel => 'Déjà remboursé';

  @override
  String returnedQty(int count) {
    return '$count retourné(s)';
  }

  @override
  String returnTitle(String number) {
    return 'Retour du ticket n°$number';
  }

  @override
  String get returnIntro =>
      'Choisissez les articles rapportés et dites s\'ils retournent en rayon ou s\'ils sont abîmés.';

  @override
  String get backOnShelf => 'Remis en rayon';

  @override
  String get returnReasonLabel => 'Raison du retour (facultatif)';

  @override
  String refundToGive(String amount) {
    return 'À rendre au client : $amount';
  }

  @override
  String get confirmReturn => 'Valider le retour';

  @override
  String returnSaved(String amount) {
    return 'Retour enregistré. Rendez $amount au client.';
  }

  @override
  String get returnNothing => 'Choisissez au moins un article.';

  @override
  String get rulesSection => 'Règles de la boutique';

  @override
  String get maxDiscountLabel => 'Remise maximale des employés (%)';

  @override
  String get expiryWarnLabel => 'Alerte péremption : jours avant';

  @override
  String get percentInvalid => 'Entre 0 et 100';

  @override
  String get daysInvalid => 'Entre 0 et 60';

  @override
  String get creditSection => 'Carnet et fournisseurs';

  @override
  String get customersTitle => 'Clients (carnet)';

  @override
  String get customersSub => 'Crédits et paiements des clients';

  @override
  String get suppliersTitle => 'Fournisseurs';

  @override
  String get suppliersSub => 'Livraisons, paiements, reste à payer';

  @override
  String get pendingPaymentsTitle => 'Paiements à valider';

  @override
  String pendingPaymentsSub(int count) {
    return '$count en attente';
  }

  @override
  String get newCustomer => 'Nouveau client';

  @override
  String get editCustomer => 'Modifier le client';

  @override
  String get customerNameHint => 'ex : Mohamed Saidi';

  @override
  String get nameRequired => 'Entrez un nom';

  @override
  String get creditLimitLabel => 'Limite de crédit (facultatif)';

  @override
  String get creditLimitHelp => 'Vide = pas de limite';

  @override
  String get creditLimitOwnerOnly => 'Seul le patron fixe la limite de crédit.';

  @override
  String get totalOwedByCustomers => 'Total dû par les clients';

  @override
  String get debtLabel => 'Dette';

  @override
  String get noDebt => 'Rien à payer';

  @override
  String advanceLabel(String amount) {
    return 'Avance : $amount';
  }

  @override
  String get overLimitBadge => 'Limite dépassée';

  @override
  String creditLimitShort(String amount) {
    return 'Limite : $amount';
  }

  @override
  String get noCustomers => 'Aucun client. Ajoutez-en un avec le bouton +.';

  @override
  String get searchCustomer => 'Nom ou téléphone';

  @override
  String get receivePayment => 'Encaisser un paiement';

  @override
  String get paymentAmountLabel => 'Montant';

  @override
  String get amountInvalid => 'Entrez un montant valide';

  @override
  String paymentTooHigh(String amount) {
    return 'Plus que la dette ($amount)';
  }

  @override
  String get paymentSaved => 'Paiement enregistré';

  @override
  String get customerHistory => 'Historique du compte';

  @override
  String entryCreditSale(String number) {
    return 'Vente à crédit n°$number';
  }

  @override
  String get entryPayment => 'Paiement reçu';

  @override
  String entryRefund(String number) {
    return 'Retour du ticket n°$number';
  }

  @override
  String entrySaleDetail(String total, String paid) {
    return 'Total $total · payé $paid';
  }

  @override
  String recordedBy(String name) {
    return 'par $name';
  }

  @override
  String get noHistory => 'Aucune opération pour l\'instant.';

  @override
  String archiveTitle(String name) {
    return 'Archiver $name ?';
  }

  @override
  String get archiveBody =>
      'Il ne sera plus proposé dans les listes. Son historique est conservé.';

  @override
  String get archivedDone => 'Archivé';

  @override
  String get paymentMode => 'Paiement';

  @override
  String get payCash => 'Comptant';

  @override
  String get payCredit => 'Crédit';

  @override
  String get chooseCustomer => 'Choisir un client';

  @override
  String currentDebt(String amount) {
    return 'Dette actuelle : $amount';
  }

  @override
  String get paidNowLabel => 'Payé maintenant';

  @override
  String get leftOnCredit => 'Reste à crédit';

  @override
  String get newDebtLabel => 'Nouvelle dette du client';

  @override
  String overLimitWarning(String limit) {
    return 'Dépasse la limite de crédit ($limit)';
  }

  @override
  String get customerRequired =>
      'Choisissez un client pour une vente à crédit.';

  @override
  String get creditLimitTitle => 'Limite de crédit dépassée';

  @override
  String creditLimitAsk(String name, String debt, String limit) {
    return '$name devra $debt, plus que sa limite de $limit. Autoriser quand même ?';
  }

  @override
  String creditLimitWorker(String limit) {
    return 'Limite de crédit dépassée ($limit). Demandez au patron.';
  }

  @override
  String get allowAnyway => 'Autoriser';

  @override
  String saleSavedCredit(String number, String amount, String name) {
    return 'Vente n°$number enregistrée · $amount sur le compte de $name';
  }

  @override
  String get customerLabel => 'Client';

  @override
  String get paidLabel => 'Payé';

  @override
  String get onCreditLabel => 'À crédit';

  @override
  String get creditChip => 'Crédit';

  @override
  String get refundModeLabel => 'Remboursement';

  @override
  String get refundToCredit => 'Déduire de la dette';

  @override
  String get refundCash => 'Rendre en espèces';

  @override
  String refundToAccount(String name, String amount) {
    return 'À déduire du compte de $name : $amount';
  }

  @override
  String returnSavedCredit(String amount) {
    return 'Retour enregistré. $amount déduit du compte du client.';
  }

  @override
  String get newSupplier => 'Nouveau fournisseur';

  @override
  String get editSupplier => 'Modifier le fournisseur';

  @override
  String get supplierNameHint => 'ex : Hamoud Boualem';

  @override
  String get noSuppliers =>
      'Aucun fournisseur. Ajoutez-en un avec le bouton +.';

  @override
  String get totalOwedToSuppliers => 'Total à payer aux fournisseurs';

  @override
  String supplierOwes(String amount) {
    return 'Reste à payer : $amount';
  }

  @override
  String supplierAdvance(String amount) {
    return 'Payé d\'avance : $amount';
  }

  @override
  String pendingAmount(String amount) {
    return 'En attente : $amount';
  }

  @override
  String get deliveredLabel => 'Livré';

  @override
  String get paidValidatedLabel => 'Payé (validé)';

  @override
  String get leftToPayLabel => 'Reste à payer';

  @override
  String get recordSupplierPayment => 'Enregistrer un paiement';

  @override
  String get workerPaymentNotice =>
      'Le patron devra valider ce paiement avant qu\'il soit compté.';

  @override
  String get paymentPendingSaved => 'Paiement envoyé au patron pour validation';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusValidated => 'Validé';

  @override
  String get statusRejected => 'Refusé';

  @override
  String get paymentsSection => 'Paiements';

  @override
  String get deliveriesSection => 'Livraisons';

  @override
  String get noPayments => 'Aucun paiement.';

  @override
  String get noDeliveries =>
      'Aucune livraison. Choisissez ce fournisseur lors d\'une réception de stock.';

  @override
  String paidBy(String name) {
    return 'Payé par $name';
  }

  @override
  String validatedBy(String name) {
    return 'validé par $name';
  }

  @override
  String rejectedBy(String name) {
    return 'refusé par $name';
  }

  @override
  String get validate => 'Valider';

  @override
  String get reject => 'Refuser';

  @override
  String get rejectPaymentTitle => 'Refuser ce paiement ?';

  @override
  String rejectPaymentBody(String amount, String name) {
    return 'Le paiement de $amount à $name ne sera pas compté.';
  }

  @override
  String get paymentValidated => 'Paiement validé';

  @override
  String get paymentRejected => 'Paiement refusé';

  @override
  String get noPendingPayments => 'Aucun paiement en attente.';

  @override
  String get supplierOptional => 'Fournisseur (facultatif)';

  @override
  String get noSupplier => 'Aucun fournisseur';

  @override
  String get searchSupplier => 'Rechercher un fournisseur';

  @override
  String get savedLabel => 'Enregistré';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get alertsEmpty => 'Aucune alerte. Tout va bien !';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get markRead => 'Marquer comme lu';

  @override
  String alertsUnread(int count) {
    return '$count non lue(s)';
  }

  @override
  String get alertsReadSection => 'Déjà lues';

  @override
  String alertLowStockTitle(String product) {
    return 'Stock bas : $product';
  }

  @override
  String alertLowStockBody(int quantity, int threshold) {
    return 'Il reste $quantity (alerte à $threshold).';
  }

  @override
  String alertOutOfStockTitle(String product) {
    return 'Rupture : $product';
  }

  @override
  String get alertOutOfStockBody => 'Plus aucun article en stock.';

  @override
  String alertNegativeStockTitle(String product) {
    return 'Stock négatif : $product';
  }

  @override
  String alertNegativeStockBody(int count) {
    return '$count vendu(s) sans stock enregistré : ajoutez la réception oubliée.';
  }

  @override
  String alertExpiringTitle(String product) {
    return 'Bientôt périmé : $product';
  }

  @override
  String alertExpiringBody(int remaining, String date) {
    return '$remaining article(s) expirent le $date.';
  }

  @override
  String alertExpiredTitle(String product) {
    return 'Périmé : $product';
  }

  @override
  String alertExpiredBody(int remaining, String date) {
    return '$remaining article(s) périmé(s) depuis le $date. Déclarez une perte.';
  }

  @override
  String get alertPaymentTitle => 'Paiement à valider';

  @override
  String alertPaymentBody(String by, String amount, String supplier) {
    return '$by a payé $amount à $supplier.';
  }

  @override
  String get alertDeliveryTitle => 'Réception de stock';

  @override
  String alertDeliveryBody(String by, int quantity, String product) {
    return '$by a reçu $quantity × $product.';
  }

  @override
  String alertCreditTitle(String customer) {
    return 'Limite de crédit dépassée : $customer';
  }

  @override
  String alertCreditBody(String debt, String limit) {
    return 'Doit $debt (limite $limit).';
  }

  @override
  String get alertPinTitle => 'Codes PIN faux';

  @override
  String alertPinBody(int count, String name) {
    return '$count code(s) faux sur le compte de $name.';
  }

  @override
  String get alertReturnTitle => 'Retour client';

  @override
  String alertReturnBody(String by, String number, String amount) {
    return '$by a fait un retour sur le ticket n°$number : $amount.';
  }

  @override
  String alertsSummaryTitle(int count) {
    return '$count nouvelles alertes';
  }

  @override
  String get alertsSummaryBody => 'Ouvrez l\'onglet Alertes pour les voir.';

  @override
  String get notificationsTitle => 'Notifications du téléphone';

  @override
  String get notificationsSub => 'Choisir les alertes qui sonnent';

  @override
  String get notificationsIntro =>
      'Les alertes restent toujours visibles dans l\'onglet Alertes. Ici, vous choisissez celles qui apparaissent aussi en notification sur ce téléphone.';

  @override
  String get workersSeeNote =>
      'Les employés voient seulement le stock bas et les dates de péremption.';

  @override
  String get typeLowStock => 'Stock bas et ruptures';

  @override
  String get typeExpiringSoon => 'Bientôt périmés';

  @override
  String get typeExpired => 'Périmés';

  @override
  String get typeNewDelivery => 'Réceptions de stock des employés';

  @override
  String get typeOverCreditLimit => 'Clients au-dessus de leur limite';

  @override
  String get typeReturnMade => 'Retours faits par les employés';

  @override
  String get notificationsBlocked =>
      'Les notifications sont bloquées sur ce téléphone.';

  @override
  String get openPhoneSettings => 'Ouvrir les réglages';

  @override
  String get sendTestNotification => 'Envoyer une notification de test';

  @override
  String get testNotificationTitle => 'Notification de test';

  @override
  String get testNotificationBody => 'Les notifications fonctionnent.';

  @override
  String get notificationChannel => 'Alertes de la boutique';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get periodCustom => 'Choisir…';

  @override
  String get everyone => 'Tout le monde';

  @override
  String get statProfit => 'Bénéfice';

  @override
  String get statAverageTicket => 'Panier moyen';

  @override
  String get statDiscounts => 'Remises accordées';

  @override
  String get statReturns => 'Retours';

  @override
  String returnsCountSub(int count) {
    return '$count retour(s)';
  }

  @override
  String get statLossesValue => 'Pertes';

  @override
  String get revenuePerDay => 'Chiffre d\'affaires par jour';

  @override
  String get revenuePerMonth => 'Chiffre d\'affaires par mois';

  @override
  String get salesPerWorker => 'Ventes par personne';

  @override
  String workerLine(int count, String discounts, String collected) {
    return '$count vente(s) · remises $discounts · reçu des clients $collected';
  }

  @override
  String get costLabel => 'Prix d\'achat des articles vendus';

  @override
  String get grossProfitLabel => 'Bénéfice brut';

  @override
  String get stockLossesLabel => 'Pertes de stock';

  @override
  String get netProfitLabel => 'Bénéfice net';

  @override
  String get cashSection => 'Caisse';

  @override
  String get paidAtCounterLabel => 'Encaissé au comptoir';

  @override
  String get customerPaymentsLabel => 'Payé par les clients (carnet)';

  @override
  String get cashRefundsLabel => 'Rendu en espèces (retours)';

  @override
  String get cashInHandLabel => 'Argent en caisse';

  @override
  String supplierPaidLabel(String amount) {
    return 'Payé aux fournisseurs : $amount';
  }

  @override
  String get creditStatsSection => 'Crédit';

  @override
  String get cashSalesLabel => 'Payé comptant';

  @override
  String get topDebtors => 'Plus gros débiteurs';

  @override
  String get lossesByReason => 'Pertes par raison';

  @override
  String get topProducts => 'Meilleures ventes';

  @override
  String productSoldQty(int quantity) {
    return '$quantity vendu(s)';
  }

  @override
  String get noSalesPeriod => 'Aucune vente sur cette période.';

  @override
  String get myStatsNote => 'Vous voyez seulement vos propres chiffres.';

  @override
  String get noReceiptReturn => 'Retour sans ticket';

  @override
  String get noReceiptExchange => 'Échange sans ticket';

  @override
  String get exchangeButton => 'Échange';

  @override
  String exchangeTitle(String number) {
    return 'Échange du ticket n°$number';
  }

  @override
  String get exchangeSwitch => 'Le client prend d\'autres articles (échange)';

  @override
  String get returnedItemsSection => 'Articles rendus';

  @override
  String get takenItemsSection => 'Articles pris par le client';

  @override
  String get addReturnedProduct => 'Ajouter un produit rendu';

  @override
  String get addTakenProduct => 'Ajouter un article pris';

  @override
  String get noReceiptPriceNote =>
      'Sans ticket, le remboursement se fait au prix de vente actuel.';

  @override
  String get returnValueLabel => 'Valeur des articles rendus';

  @override
  String get takenValueLabel => 'Valeur des articles pris';

  @override
  String customerPays(String amount) {
    return 'Le client paie : $amount';
  }

  @override
  String giveBack(String amount) {
    return 'À rendre au client : $amount';
  }

  @override
  String get nothingToSettle => 'Rien à payer, rien à rendre.';

  @override
  String debtReduced(String amount) {
    return '$amount déduit de la dette du client';
  }

  @override
  String get confirmExchange => 'Valider l\'échange';

  @override
  String get exchangeNothingTaken => 'Ajoutez les articles pris par le client.';

  @override
  String exchangeSaved(String number) {
    return 'Échange enregistré : ticket n°$number.';
  }

  @override
  String get ownerApprovalTitle => 'Accord du patron';

  @override
  String ownerApprovalBody(String name) {
    return 'Un retour sans ticket doit être accepté par $name. $name, tapez votre code PIN :';
  }

  @override
  String get ownerApprovalRefused => 'Le patron doit accepter ce retour.';

  @override
  String get exchangeCreditLabel => 'Avoir (articles rendus)';

  @override
  String get fromExchangeNote => 'Ticket d\'un échange';

  @override
  String alertReturnNoReceiptBody(String by, String amount) {
    return '$by a repris des articles sans ticket : $amount.';
  }

  @override
  String get alertExchangeTitle => 'Échange';

  @override
  String alertExchangeBody(String by, String amount, String taken) {
    return '$by a fait un échange : rendu $amount, pris $taken.';
  }

  @override
  String get syncTitle => 'Synchronisation Wi-Fi';

  @override
  String get syncSub => 'Relier les téléphones de la boutique';

  @override
  String get syncStandaloneTitle => 'Ce téléphone n\'est relié à aucun autre.';

  @override
  String get syncStandaloneBody =>
      'Sur le téléphone du patron, activez le hub : les téléphones des employés s\'y relient par le Wi-Fi de la boutique, sans internet.';

  @override
  String get becomeHub => 'Faire de ce téléphone le téléphone principal';

  @override
  String get hubActive => 'Hub actif';

  @override
  String get hubStopped => 'Hub arrêté';

  @override
  String hubAddress(String address) {
    return 'Adresse : $address';
  }

  @override
  String get hubNoWifi =>
      'Pas de Wi-Fi : connectez ce téléphone au Wi-Fi de la boutique.';

  @override
  String get hubKeepOpen =>
      'Gardez l\'application ouverte ou en arrière-plan sur ce téléphone (ne la fermez pas) pour que les autres puissent se synchroniser.';

  @override
  String get pairTitle => 'Relier un téléphone';

  @override
  String get pairBody =>
      'Sur le téléphone de l\'employé, choisissez « Rejoindre une boutique » et scannez ce code. Ne le montrez à personne d\'autre : il donne accès à la boutique.';

  @override
  String get showPairingCode => 'Afficher le code';

  @override
  String get linkedPhones => 'Téléphones reliés';

  @override
  String get noLinkedPhones => 'Aucun autre téléphone pour l\'instant.';

  @override
  String devicePhoneLabel(String code, String name) {
    return 'Téléphone $code · $name';
  }

  @override
  String get thisPhone => 'Ce téléphone';

  @override
  String lastSyncAt(String time) {
    return 'Dernière synchro : $time';
  }

  @override
  String get neverSynced => 'Jamais synchronisé';

  @override
  String get removePhone => 'Retirer ce téléphone';

  @override
  String removePhoneBody(String name) {
    return '$name ne pourra plus se synchroniser. Ce qu\'il a déjà envoyé est gardé.';
  }

  @override
  String get phoneRemoved => 'Téléphone retiré';

  @override
  String linkedTo(String shop, String code) {
    return 'Relié à $shop · téléphone $code';
  }

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncing => 'Synchronisation…';

  @override
  String syncDone(int sent, int received) {
    return 'Synchronisé : $sent envoyé(s), $received reçu(s)';
  }

  @override
  String get syncAuto =>
      'Synchronisation automatique toutes les 2 minutes et après chaque vente.';

  @override
  String get syncErrUnreachable =>
      'Hub introuvable. Le téléphone du patron est-il allumé, sur le même Wi-Fi, avec l\'application ouverte ?';

  @override
  String get syncErrSignature =>
      'Code de la boutique refusé. Reliez ce téléphone à nouveau avec le code du patron.';

  @override
  String get syncErrVersion =>
      'Versions différentes : installez la même version de l\'application sur les deux téléphones.';

  @override
  String get syncErrRemoved =>
      'Ce téléphone a été retiré de la boutique par le patron.';

  @override
  String get syncErrOther => 'La synchronisation a échoué. Réessayez.';

  @override
  String pendingChanges(int count) {
    return '$count changement(s) à envoyer';
  }

  @override
  String get joinShop => 'Rejoindre une boutique existante';

  @override
  String get joinTitle => 'Rejoindre une boutique';

  @override
  String get joinIntro =>
      'Sur le téléphone du patron : Plus → Synchronisation Wi-Fi → activez le hub et affichez le code. Puis scannez-le ici. Les deux téléphones doivent être sur le même Wi-Fi.';

  @override
  String get scanPairingCode => 'Scanner le code du patron';

  @override
  String get notPairingCode => 'Ce n\'est pas un code de la boutique.';

  @override
  String get deviceNameLabel => 'Nom de ce téléphone';

  @override
  String get deviceNameHint => 'ex : Caisse 2';

  @override
  String joinButton(String shop) {
    return 'Rejoindre $shop';
  }

  @override
  String get joining => 'Téléchargement de la boutique…';

  @override
  String joined(String code) {
    return 'Téléphone relié (téléphone $code). Connectez-vous avec votre code PIN.';
  }

  @override
  String get leaveShop => 'Rejoindre une autre boutique';

  @override
  String get leaveShopSub =>
      'Pour un téléphone d\'employé : efface ce téléphone';

  @override
  String get leaveShopBody =>
      'Toutes les données de ce téléphone (produits, ventes, comptes…) seront effacées. Ensuite, il pourra rejoindre la boutique du patron. À faire seulement sur un téléphone d\'employé.';

  @override
  String get leaveShopConfirm => 'Effacer ce téléphone';

  @override
  String alertDuplicateBarcodeTitle(String barcode) {
    return 'Code-barres en double : $barcode';
  }

  @override
  String alertDuplicateBarcodeBody(String names) {
    return 'Produits : $names. Fusionnez-les ou changez un code-barres.';
  }

  @override
  String alertDuplicateCustomerTitle(String phone) {
    return 'Client en double : $phone';
  }

  @override
  String alertDuplicateCustomerBody(String names) {
    return 'Clients : $names. Fusionnez-les depuis la fiche client.';
  }

  @override
  String get typeDuplicates => 'Doublons (produits, clients)';

  @override
  String get mergeInto => 'Fusionner avec…';

  @override
  String mergeTitle(String name) {
    return 'Fusionner dans $name ?';
  }

  @override
  String mergeCustomerBody(String from, String into) {
    return 'Les ventes, paiements et la dette de $from passent à $into, puis $from est archivé.';
  }

  @override
  String mergeProductBody(String from, String into) {
    return 'Les ventes, le stock et les pertes de $from passent à $into, puis $from est archivé.';
  }

  @override
  String get merge => 'Fusionner';

  @override
  String get merged => 'Fusionné';

  @override
  String get hubServiceTitle => 'Hub de la boutique actif';

  @override
  String get hubServiceText => 'Les autres téléphones peuvent se synchroniser.';

  @override
  String get stockShortBlocked =>
      'Stock insuffisant. Ajoutez d\'abord la réception de stock.';

  @override
  String stockShortDetail(String product, int count) {
    return '$product : il reste $count en stock.';
  }

  @override
  String get workersSellWithoutStock =>
      'Les employés peuvent vendre sans stock';

  @override
  String get workersSellWithoutStockHelp =>
      'Désactivé : un employé ne peut pas vendre plus que le stock enregistré. Le patron peut toujours vendre.';
}
