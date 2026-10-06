import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion Boutique'**
  String get appTitle;

  /// No description provided for @navSell.
  ///
  /// In fr, this message translates to:
  /// **'Vendre'**
  String get navSell;

  /// No description provided for @navStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock'**
  String get navStock;

  /// No description provided for @navStats.
  ///
  /// In fr, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get navAlerts;

  /// No description provided for @navMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navMore;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get commonRequired;

  /// No description provided for @errorWithDetail.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {detail}'**
  String errorWithDetail(String detail);

  /// No description provided for @comingSoonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonStats.
  ///
  /// In fr, this message translates to:
  /// **'Les statistiques arrivent dans une prochaine étape.'**
  String get comingSoonStats;

  /// No description provided for @comingSoonAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Les alertes et notifications arrivent dans une prochaine étape.'**
  String get comingSoonAlerts;

  /// No description provided for @priceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un prix'**
  String get priceRequired;

  /// No description provided for @priceInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Prix invalide (ex : 1250 ou 1250,50)'**
  String get priceInvalid;

  /// No description provided for @priceNegative.
  ///
  /// In fr, this message translates to:
  /// **'Le prix ne peut pas être négatif'**
  String get priceNegative;

  /// No description provided for @cartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get cartTitle;

  /// No description provided for @itemCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun article} =1{1 article} other{{count} articles}}'**
  String itemCount(int count);

  /// No description provided for @totalLabel.
  ///
  /// In fr, this message translates to:
  /// **'TOTAL'**
  String get totalLabel;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Panier vide'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Scannez un code-barres avec la caméra pour ajouter des articles.'**
  String get cartEmptyBody;

  /// No description provided for @goToCheckout.
  ///
  /// In fr, this message translates to:
  /// **'Passer à l\'encaissement'**
  String get goToCheckout;

  /// No description provided for @cameraOffTitle.
  ///
  /// In fr, this message translates to:
  /// **'Caméra éteinte'**
  String get cameraOffTitle;

  /// No description provided for @cameraOffBody.
  ///
  /// In fr, this message translates to:
  /// **'Allumez la caméra pour scanner les codes-barres.'**
  String get cameraOffBody;

  /// No description provided for @turnOnCamera.
  ///
  /// In fr, this message translates to:
  /// **'Allumer la caméra'**
  String get turnOnCamera;

  /// No description provided for @productNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Produit introuvable : {barcode}'**
  String productNotFound(String barcode);

  /// No description provided for @checkoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Encaissement'**
  String get checkoutTitle;

  /// No description provided for @columnProduct.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get columnProduct;

  /// No description provided for @columnPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get columnPrice;

  /// No description provided for @columnTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get columnTotal;

  /// No description provided for @amountToPay.
  ///
  /// In fr, this message translates to:
  /// **'TOTAL À PAYER'**
  String get amountToPay;

  /// No description provided for @confirmWithoutPrint.
  ///
  /// In fr, this message translates to:
  /// **'Valider sans imprimer'**
  String get confirmWithoutPrint;

  /// No description provided for @confirmAndPrint.
  ///
  /// In fr, this message translates to:
  /// **'Valider et imprimer'**
  String get confirmAndPrint;

  /// No description provided for @saleSaved.
  ///
  /// In fr, this message translates to:
  /// **'Vente n°{number} enregistrée'**
  String saleSaved(int number);

  /// No description provided for @saleSavedAndPrinted.
  ///
  /// In fr, this message translates to:
  /// **'Vente n°{number} enregistrée et imprimée'**
  String saleSavedAndPrinted(int number);

  /// No description provided for @saleSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'La vente n\'a pas pu être enregistrée.'**
  String get saleSaveFailed;

  /// No description provided for @printNoPrinter.
  ///
  /// In fr, this message translates to:
  /// **'Aucune imprimante enregistrée. Connectez-en une dans Plus.'**
  String get printNoPrinter;

  /// No description provided for @printConnectFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de se connecter à l\'imprimante.'**
  String get printConnectFailed;

  /// No description provided for @printFailed.
  ///
  /// In fr, this message translates to:
  /// **'L\'impression a échoué.'**
  String get printFailed;

  /// No description provided for @printReprintHint.
  ///
  /// In fr, this message translates to:
  /// **'La vente est enregistrée : réimprimez-la depuis l\'historique.'**
  String get printReprintHint;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des ventes'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Les ventes validées apparaîtront ici.'**
  String get historyEmptyBody;

  /// No description provided for @saleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vente n°{number}'**
  String saleTitle(int number);

  /// No description provided for @salesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune vente} =1{1 vente} other{{count} ventes}}'**
  String salesCount(int count);

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// No description provided for @reprint.
  ///
  /// In fr, this message translates to:
  /// **'Réimprimer'**
  String get reprint;

  /// No description provided for @receiptPrinted.
  ///
  /// In fr, this message translates to:
  /// **'Ticket imprimé'**
  String get receiptPrinted;

  /// No description provided for @productsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get productsTitle;

  /// No description provided for @productSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou code-barres'**
  String get productSearchHint;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier produit avec le bouton +.'**
  String get productsEmptyBody;

  /// No description provided for @productsNoMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit ne correspond à la recherche.'**
  String get productsNoMatch;

  /// No description provided for @addProduct.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le produit'**
  String get editProduct;

  /// No description provided for @barcodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres'**
  String get barcodeLabel;

  /// No description provided for @barcodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Scannez ou tapez le code-barres'**
  String get barcodeHint;

  /// No description provided for @barcodeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un code-barres'**
  String get barcodeRequired;

  /// No description provided for @scanHelp.
  ///
  /// In fr, this message translates to:
  /// **'Touchez l\'icône pour scanner avec la caméra'**
  String get scanHelp;

  /// No description provided for @productNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du produit (en français)'**
  String get productNameLabel;

  /// No description provided for @productNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Jus Rouiba 1L'**
  String get productNameHint;

  /// No description provided for @productNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un nom'**
  String get productNameRequired;

  /// No description provided for @sellPriceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente'**
  String get sellPriceLabel;

  /// No description provided for @barcodeExists.
  ///
  /// In fr, this message translates to:
  /// **'Un produit avec le code-barres « {barcode} » existe déjà.'**
  String barcodeExists(String barcode);

  /// No description provided for @productAdded.
  ///
  /// In fr, this message translates to:
  /// **'Produit ajouté'**
  String get productAdded;

  /// No description provided for @productUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Produit modifié'**
  String get productUpdated;

  /// No description provided for @productArchived.
  ///
  /// In fr, this message translates to:
  /// **'Produit archivé'**
  String get productArchived;

  /// No description provided for @archiveProductTitle.
  ///
  /// In fr, this message translates to:
  /// **'Archiver ce produit ?'**
  String get archiveProductTitle;

  /// No description provided for @archiveProductBody.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » ne sera plus proposé à la vente. L\'historique des ventes est conservé.'**
  String archiveProductBody(String name);

  /// No description provided for @archive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver'**
  String get archive;

  /// No description provided for @saveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveChanges;

  /// No description provided for @scanBarcodeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner un code-barres'**
  String get scanBarcodeTitle;

  /// No description provided for @alignBarcode.
  ///
  /// In fr, this message translates to:
  /// **'Placez le code-barres dans le cadre'**
  String get alignBarcode;

  /// No description provided for @moreTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get moreTitle;

  /// No description provided for @shopNameFallback.
  ///
  /// In fr, this message translates to:
  /// **'Ma boutique'**
  String get shopNameFallback;

  /// No description provided for @sectionShop.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get sectionShop;

  /// No description provided for @shopDetails.
  ///
  /// In fr, this message translates to:
  /// **'Informations de la boutique'**
  String get shopDetails;

  /// No description provided for @shopDetailsSub.
  ///
  /// In fr, this message translates to:
  /// **'Nom, adresse, téléphone, bas du ticket'**
  String get shopDetailsSub;

  /// No description provided for @sectionPreferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get sectionPreferences;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Langue du téléphone'**
  String get languageSystem;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Comme le téléphone'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @sectionPrinter.
  ///
  /// In fr, this message translates to:
  /// **'Imprimante'**
  String get sectionPrinter;

  /// No description provided for @printerDevice.
  ///
  /// In fr, this message translates to:
  /// **'Imprimante Bluetooth'**
  String get printerDevice;

  /// No description provided for @printerNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune imprimante connectée'**
  String get printerNone;

  /// No description provided for @printerConnectedBadge.
  ///
  /// In fr, this message translates to:
  /// **'CONNECTÉE'**
  String get printerConnectedBadge;

  /// No description provided for @printerConnected.
  ///
  /// In fr, this message translates to:
  /// **'Imprimante connectée'**
  String get printerConnected;

  /// No description provided for @printerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle imprimante : touchez l\'engrenage pour l\'appairer dans les réglages Bluetooth du téléphone, revenez, puis touchez Actualiser.'**
  String get printerHelp;

  /// No description provided for @printerErrNoPaired.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil appairé trouvé.'**
  String get printerErrNoPaired;

  /// No description provided for @printerErrConnectAll.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de se connecter à un appareil appairé.'**
  String get printerErrConnectAll;

  /// No description provided for @printerErrConnect.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à l\'imprimante impossible.'**
  String get printerErrConnect;

  /// No description provided for @printerErrPermission.
  ///
  /// In fr, this message translates to:
  /// **'Autorisation Bluetooth refusée.'**
  String get printerErrPermission;

  /// No description provided for @testPrint.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer un ticket test'**
  String get testPrint;

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @bluetoothSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages Bluetooth'**
  String get bluetoothSettings;

  /// No description provided for @shopInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations générales'**
  String get shopInfoTitle;

  /// No description provided for @shopInfoHint.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations apparaissent sur les tickets imprimés.'**
  String get shopInfoHint;

  /// No description provided for @shopNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la boutique'**
  String get shopNameLabel;

  /// No description provided for @shopNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Épicerie El Baraka'**
  String get shopNameHint;

  /// No description provided for @address1Label.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address1Label;

  /// No description provided for @address1Hint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Rue 5, Bab Ezzouar'**
  String get address1Hint;

  /// No description provided for @address2Label.
  ///
  /// In fr, this message translates to:
  /// **'Adresse, suite (facultatif)'**
  String get address2Label;

  /// No description provided for @address2Hint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Alger 16000'**
  String get address2Hint;

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : 0555 12 34 56'**
  String get phoneHint;

  /// No description provided for @footerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Message en bas du ticket'**
  String get footerLabel;

  /// No description provided for @footerHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Merci, à bientôt !'**
  String get footerHint;

  /// No description provided for @maxChars.
  ///
  /// In fr, this message translates to:
  /// **'{count} caractères max'**
  String maxChars(int count);

  /// No description provided for @shopSaved.
  ///
  /// In fr, this message translates to:
  /// **'Informations enregistrées'**
  String get shopSaved;

  /// No description provided for @commonYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get commonNo;

  /// No description provided for @commonAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get commonAdd;

  /// No description provided for @unknownUser.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get unknownUser;

  /// No description provided for @nameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get nameLabel;

  /// No description provided for @phoneOptionalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (facultatif)'**
  String get phoneOptionalLabel;

  /// No description provided for @setupWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue !'**
  String get setupWelcomeTitle;

  /// No description provided for @setupWelcomeBody.
  ///
  /// In fr, this message translates to:
  /// **'Configurons votre boutique en 3 étapes.'**
  String get setupWelcomeBody;

  /// No description provided for @setupExistingBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez le compte du propriétaire pour continuer. Vos produits et vos ventes sont conservés.'**
  String get setupExistingBody;

  /// No description provided for @setupStepShop.
  ///
  /// In fr, this message translates to:
  /// **'Votre boutique'**
  String get setupStepShop;

  /// No description provided for @setupStepOwner.
  ///
  /// In fr, this message translates to:
  /// **'Le propriétaire'**
  String get setupStepOwner;

  /// No description provided for @setupStepPin.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN'**
  String get setupStepPin;

  /// No description provided for @ownerNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get ownerNameLabel;

  /// No description provided for @ownerNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Karim Benali'**
  String get ownerNameHint;

  /// No description provided for @pinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN (4 chiffres)'**
  String get pinLabel;

  /// No description provided for @pinConfirmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez le code PIN'**
  String get pinConfirmLabel;

  /// No description provided for @pinInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN doit avoir 4 chiffres'**
  String get pinInvalid;

  /// No description provided for @pinMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux codes PIN ne sont pas identiques'**
  String get pinMismatch;

  /// No description provided for @pinHelp.
  ///
  /// In fr, this message translates to:
  /// **'Vous taperez ce code pour ouvrir l\'application. Ne le partagez pas.'**
  String get pinHelp;

  /// No description provided for @nextStep.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get nextStep;

  /// No description provided for @previousStep.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get previousStep;

  /// No description provided for @finishSetup.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finishSetup;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Qui êtes-vous ?'**
  String get loginTitle;

  /// No description provided for @loginEnterPin.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code PIN'**
  String get loginEnterPin;

  /// No description provided for @loginWrongPin.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN incorrect. {left, plural, =1{Encore 1 essai.} other{Encore {left} essais.}}'**
  String loginWrongPin(int left);

  /// No description provided for @roleOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire'**
  String get roleOwner;

  /// No description provided for @roleWorker.
  ///
  /// In fr, this message translates to:
  /// **'Employé'**
  String get roleWorker;

  /// No description provided for @teamSection.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get teamSection;

  /// No description provided for @workersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Employés'**
  String get workersTitle;

  /// No description provided for @workersSub.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter, modifier, désactiver'**
  String get workersSub;

  /// No description provided for @addWorker.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un employé'**
  String get addWorker;

  /// No description provided for @editAccount.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le compte'**
  String get editAccount;

  /// No description provided for @workerNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Amine Kaci'**
  String get workerNameHint;

  /// No description provided for @newPinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code PIN (4 chiffres)'**
  String get newPinLabel;

  /// No description provided for @pinKeepHint.
  ///
  /// In fr, this message translates to:
  /// **'Laissez vide pour garder le code actuel'**
  String get pinKeepHint;

  /// No description provided for @activeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Compte actif'**
  String get activeLabel;

  /// No description provided for @activeHelp.
  ///
  /// In fr, this message translates to:
  /// **'Un compte désactivé ne peut plus se connecter. Son historique est conservé.'**
  String get activeHelp;

  /// No description provided for @inactiveBadge.
  ///
  /// In fr, this message translates to:
  /// **'DÉSACTIVÉ'**
  String get inactiveBadge;

  /// No description provided for @accountSaved.
  ///
  /// In fr, this message translates to:
  /// **'Compte enregistré'**
  String get accountSaved;

  /// No description provided for @noWorkersBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos employés : chacun aura son propre code PIN.'**
  String get noWorkersBody;

  /// No description provided for @myProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get myProfile;

  /// No description provided for @myStatsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes ventes'**
  String get myStatsTitle;

  /// No description provided for @periodWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get periodMonth;

  /// No description provided for @statRevenue.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires'**
  String get statRevenue;

  /// No description provided for @statSales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get statSales;

  /// No description provided for @statItems.
  ///
  /// In fr, this message translates to:
  /// **'Articles vendus'**
  String get statItems;

  /// No description provided for @statLosses.
  ///
  /// In fr, this message translates to:
  /// **'Pertes enregistrées'**
  String get statLosses;

  /// No description provided for @lossesComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Le suivi des pertes arrive à l\'étape 3.'**
  String get lossesComingSoon;

  /// No description provided for @changePin.
  ///
  /// In fr, this message translates to:
  /// **'Changer mon code PIN'**
  String get changePin;

  /// No description provided for @currentPinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN actuel'**
  String get currentPinLabel;

  /// No description provided for @currentPinWrong.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN actuel est incorrect'**
  String get currentPinWrong;

  /// No description provided for @pinChanged.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN modifié'**
  String get pinChanged;

  /// No description provided for @switchUser.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'utilisateur'**
  String get switchUser;

  /// No description provided for @switchUserSub.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'écran des codes PIN'**
  String get switchUserSub;

  /// No description provided for @buyPriceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat (facultatif)'**
  String get buyPriceLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get categoryLabel;

  /// No description provided for @noCategory.
  ///
  /// In fr, this message translates to:
  /// **'Sans catégorie'**
  String get noCategory;

  /// No description provided for @newCategory.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie…'**
  String get newCategory;

  /// No description provided for @categoryNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Boissons'**
  String get categoryNameHint;

  /// No description provided for @lowStockLabel.
  ///
  /// In fr, this message translates to:
  /// **'Alerte stock bas à partir de'**
  String get lowStockLabel;

  /// No description provided for @lowStockHelp.
  ///
  /// In fr, this message translates to:
  /// **'0 = pas d\'alerte. Les alertes arrivent à l\'étape 5.'**
  String get lowStockHelp;

  /// No description provided for @quantityInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un nombre entier'**
  String get quantityInvalid;

  /// No description provided for @historySection.
  ///
  /// In fr, this message translates to:
  /// **'Historique des modifications'**
  String get historySection;

  /// No description provided for @historyNoChanges.
  ///
  /// In fr, this message translates to:
  /// **'Aucune modification pour l\'instant.'**
  String get historyNoChanges;

  /// No description provided for @fieldBuyPrice.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat'**
  String get fieldBuyPrice;

  /// No description provided for @fieldLowStock.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de stock bas'**
  String get fieldLowStock;

  /// No description provided for @fieldArchived.
  ///
  /// In fr, this message translates to:
  /// **'Archivé'**
  String get fieldArchived;

  /// No description provided for @soldBy.
  ///
  /// In fr, this message translates to:
  /// **'Vendu par {name}'**
  String soldBy(String name);

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @continueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueLabel;

  /// No description provided for @pinLengthLabel.
  ///
  /// In fr, this message translates to:
  /// **'Longueur du code PIN'**
  String get pinLengthLabel;

  /// No description provided for @pinDigits.
  ///
  /// In fr, this message translates to:
  /// **'{count} chiffres'**
  String pinDigits(int count);

  /// No description provided for @pinLabelN.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN ({count} chiffres)'**
  String pinLabelN(int count);

  /// No description provided for @newPinLabelN.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code PIN ({count} chiffres)'**
  String newPinLabelN(int count);

  /// No description provided for @pinInvalidN.
  ///
  /// In fr, this message translates to:
  /// **'Le code PIN doit avoir {count} chiffres'**
  String pinInvalidN(int count);

  /// No description provided for @pinInvalidAny.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN invalide'**
  String get pinInvalidAny;

  /// No description provided for @loginWait.
  ///
  /// In fr, this message translates to:
  /// **'Trop de codes faux. Réessayez dans {time}.'**
  String loginWait(String time);

  /// No description provided for @loginWaitPaused.
  ///
  /// In fr, this message translates to:
  /// **'Le décompte avance seulement quand l\'application est ouverte.'**
  String get loginWaitPaused;

  /// No description provided for @loginLockedWorker.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est verrouillé après trop de codes faux. Demandez au propriétaire de le débloquer.'**
  String get loginLockedWorker;

  /// No description provided for @loginLockedOwner.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est verrouillé après trop de codes faux. Utilisez votre code de récupération.'**
  String get loginLockedOwner;

  /// No description provided for @forgotPin.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN oublié ?'**
  String get forgotPin;

  /// No description provided for @recoveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Récupérer le compte'**
  String get recoveryTitle;

  /// No description provided for @recoveryIntro.
  ///
  /// In fr, this message translates to:
  /// **'Tapez le code de récupération noté lors de la création du compte, puis choisissez un nouveau code PIN.'**
  String get recoveryIntro;

  /// No description provided for @recoveryCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code de récupération'**
  String get recoveryCodeLabel;

  /// No description provided for @recoveryCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : K7QM-3WZD-HP9X'**
  String get recoveryCodeHint;

  /// No description provided for @recoveryCodeWrong.
  ///
  /// In fr, this message translates to:
  /// **'Code de récupération incorrect. La tentative est enregistrée.'**
  String get recoveryCodeWrong;

  /// No description provided for @recoveryShowTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre code de récupération'**
  String get recoveryShowTitle;

  /// No description provided for @recoveryShowBody.
  ///
  /// In fr, this message translates to:
  /// **'Notez ce code sur papier et gardez-le en lieu sûr. Il permet de changer le code PIN du propriétaire s\'il est oublié ou bloqué. Il ne sera plus jamais affiché.'**
  String get recoveryShowBody;

  /// No description provided for @recoveryOldCodeUsed.
  ///
  /// In fr, this message translates to:
  /// **'L\'ancien code a été utilisé : il ne fonctionne plus. Voici le nouveau.'**
  String get recoveryOldCodeUsed;

  /// No description provided for @recoveryNoted.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai noté ce code'**
  String get recoveryNoted;

  /// No description provided for @recoveryTile.
  ///
  /// In fr, this message translates to:
  /// **'Code de récupération'**
  String get recoveryTile;

  /// No description provided for @recoveryMissing.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore créé : créez-le maintenant'**
  String get recoveryMissing;

  /// No description provided for @recoveryExists.
  ///
  /// In fr, this message translates to:
  /// **'Créé. Touchez pour en créer un nouveau (l\'ancien ne marchera plus).'**
  String get recoveryExists;

  /// No description provided for @recoveryMissingBanner.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre code de récupération : sans lui, un code PIN propriétaire oublié ou bloqué ne pourra pas être changé.'**
  String get recoveryMissingBanner;

  /// No description provided for @confirmWithPin.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code PIN actuel pour continuer'**
  String get confirmWithPin;

  /// No description provided for @lockedBadge.
  ///
  /// In fr, this message translates to:
  /// **'VERROUILLÉ'**
  String get lockedBadge;

  /// No description provided for @lockedWorkerCard.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est verrouillé après trop de codes PIN faux.'**
  String get lockedWorkerCard;

  /// No description provided for @unlockAccount.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer le compte'**
  String get unlockAccount;

  /// No description provided for @accountUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Compte débloqué'**
  String get accountUnlocked;

  /// No description provided for @resetPinLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code PIN (pour le réinitialiser)'**
  String get resetPinLabel;

  /// No description provided for @ownerPinFromProfile.
  ///
  /// In fr, this message translates to:
  /// **'Changez votre propre code PIN depuis votre profil.'**
  String get ownerPinFromProfile;

  /// No description provided for @failedLoginsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tentatives de connexion échouées'**
  String get failedLoginsTitle;

  /// No description provided for @failedLoginsSub.
  ///
  /// In fr, this message translates to:
  /// **'Codes faux tapés, par compte'**
  String get failedLoginsSub;

  /// No description provided for @failedLoginsWarning.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 code faux a été tapé depuis votre dernière connexion.} other{{count} codes faux ont été tapés depuis votre dernière connexion.}}'**
  String failedLoginsWarning(int count);

  /// No description provided for @failedLoginsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tentative échouée.'**
  String get failedLoginsEmpty;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get seeAll;

  /// No description provided for @securitySection.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get securitySection;

  /// No description provided for @kindPin.
  ///
  /// In fr, this message translates to:
  /// **'Code PIN'**
  String get kindPin;

  /// No description provided for @accountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Compte : {name}'**
  String accountLabel(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
