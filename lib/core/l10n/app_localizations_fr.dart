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
}
