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
  String get comingSoonTitle => 'Bientôt disponible';

  @override
  String get comingSoonStats =>
      'Les statistiques arrivent dans une prochaine étape.';

  @override
  String get comingSoonAlerts =>
      'Les alertes et notifications arrivent dans une prochaine étape.';

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
  String saleSaved(int number) {
    return 'Vente n°$number enregistrée';
  }

  @override
  String saleSavedAndPrinted(int number) {
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
  String saleTitle(int number) {
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
      '0 = pas d\'alerte. Les alertes arrivent à l\'étape 5.';

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
  String returnTitle(int number) {
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
}
