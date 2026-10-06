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
  /// **'Alerte dans l\'onglet Alertes à ce niveau. 0 = seulement si des articles sont vendus sans stock.'**
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

  /// No description provided for @stockLabel.
  ///
  /// In fr, this message translates to:
  /// **'Stock : {count}'**
  String stockLabel(int count);

  /// No description provided for @outOfStock.
  ///
  /// In fr, this message translates to:
  /// **'Rupture'**
  String get outOfStock;

  /// No description provided for @lowStockBadge.
  ///
  /// In fr, this message translates to:
  /// **'Stock bas'**
  String get lowStockBadge;

  /// No description provided for @expiresOn.
  ///
  /// In fr, this message translates to:
  /// **'Exp. {date}'**
  String expiresOn(String date);

  /// No description provided for @expiredBadge.
  ///
  /// In fr, this message translates to:
  /// **'Périmé'**
  String get expiredBadge;

  /// No description provided for @expiresSoonBadge.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt périmé'**
  String get expiresSoonBadge;

  /// No description provided for @noExpiry.
  ///
  /// In fr, this message translates to:
  /// **'Sans date de péremption'**
  String get noExpiry;

  /// No description provided for @addDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Réception de stock'**
  String get addDelivery;

  /// No description provided for @recordLoss.
  ///
  /// In fr, this message translates to:
  /// **'Déclarer une perte'**
  String get recordLoss;

  /// No description provided for @lossesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pertes'**
  String get lossesTitle;

  /// No description provided for @inStockLabel.
  ///
  /// In fr, this message translates to:
  /// **'En stock'**
  String get inStockLabel;

  /// No description provided for @batchesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lots'**
  String get batchesTitle;

  /// No description provided for @batchesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun stock pour l\'instant. Ajoutez une réception de stock.'**
  String get batchesEmpty;

  /// No description provided for @batchRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{remaining} sur {quantity}'**
  String batchRemaining(int remaining, int quantity);

  /// No description provided for @receivedBy.
  ///
  /// In fr, this message translates to:
  /// **'Reçu le {date} par {name}'**
  String receivedBy(String date, String name);

  /// No description provided for @receivedOn.
  ///
  /// In fr, this message translates to:
  /// **'Reçu le {date}'**
  String receivedOn(String date);

  /// No description provided for @showEmptyBatches.
  ///
  /// In fr, this message translates to:
  /// **'Voir aussi les lots épuisés'**
  String get showEmptyBatches;

  /// No description provided for @missingStock.
  ///
  /// In fr, this message translates to:
  /// **'{count} vendu(s) sans stock enregistré : ajoutez la réception oubliée.'**
  String missingStock(int count);

  /// No description provided for @chooseProduct.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un produit'**
  String get chooseProduct;

  /// No description provided for @quantityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get quantityLabel;

  /// No description provided for @quantityRequired.
  ///
  /// In fr, this message translates to:
  /// **'Entrez une quantité (au moins 1)'**
  String get quantityRequired;

  /// No description provided for @buyPriceUnitLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat par article'**
  String get buyPriceUnitLabel;

  /// No description provided for @expiryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de péremption (facultatif)'**
  String get expiryLabel;

  /// No description provided for @pickDate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date'**
  String get pickDate;

  /// No description provided for @noExpiryHelp.
  ///
  /// In fr, this message translates to:
  /// **'Laissez vide pour les produits qui ne périment pas.'**
  String get noExpiryHelp;

  /// No description provided for @updateBuyPrice.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ce prix comme prix d\'achat du produit'**
  String get updateBuyPrice;

  /// No description provided for @noteOptional.
  ///
  /// In fr, this message translates to:
  /// **'Note (facultatif)'**
  String get noteOptional;

  /// No description provided for @deliverySaved.
  ///
  /// In fr, this message translates to:
  /// **'{count} × {name} ajouté(s) au stock'**
  String deliverySaved(int count, String name);

  /// No description provided for @saveDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au stock'**
  String get saveDelivery;

  /// No description provided for @lossReasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Raison'**
  String get lossReasonLabel;

  /// No description provided for @reasonDamaged.
  ///
  /// In fr, this message translates to:
  /// **'Abîmé'**
  String get reasonDamaged;

  /// No description provided for @reasonExpired.
  ///
  /// In fr, this message translates to:
  /// **'Périmé'**
  String get reasonExpired;

  /// No description provided for @reasonStaff.
  ///
  /// In fr, this message translates to:
  /// **'Consommé par le personnel'**
  String get reasonStaff;

  /// No description provided for @reasonStolen.
  ///
  /// In fr, this message translates to:
  /// **'Volé'**
  String get reasonStolen;

  /// No description provided for @reasonOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get reasonOther;

  /// No description provided for @lossBatchLabel.
  ///
  /// In fr, this message translates to:
  /// **'Lot concerné'**
  String get lossBatchLabel;

  /// No description provided for @lossBatchAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique (celui qui expire en premier)'**
  String get lossBatchAuto;

  /// No description provided for @batchOption.
  ///
  /// In fr, this message translates to:
  /// **'Exp. {date} · reste {remaining}'**
  String batchOption(String date, int remaining);

  /// No description provided for @batchOptionNoDate.
  ///
  /// In fr, this message translates to:
  /// **'Reçu le {date} · reste {remaining}'**
  String batchOptionNoDate(String date, int remaining);

  /// No description provided for @lossValuePreview.
  ///
  /// In fr, this message translates to:
  /// **'Valeur perdue estimée : {amount}'**
  String lossValuePreview(String amount);

  /// No description provided for @lossSaved.
  ///
  /// In fr, this message translates to:
  /// **'Perte enregistrée : {amount}'**
  String lossSaved(String amount);

  /// No description provided for @saveLoss.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer la perte'**
  String get saveLoss;

  /// No description provided for @lossesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune perte enregistrée.'**
  String get lossesEmpty;

  /// No description provided for @lossesTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total perdu : {amount}'**
  String lossesTotal(String amount);

  /// No description provided for @lossFromReturn.
  ///
  /// In fr, this message translates to:
  /// **'Retour client'**
  String get lossFromReturn;

  /// No description provided for @moreThanStock.
  ///
  /// In fr, this message translates to:
  /// **'Il n\'en reste que {count} en stock. Ce sera quand même enregistré.'**
  String moreThanStock(int count);

  /// No description provided for @discountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Remise'**
  String get discountLabel;

  /// No description provided for @addDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une remise'**
  String get addDiscount;

  /// No description provided for @discountAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get discountAmount;

  /// No description provided for @discountPercent.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage'**
  String get discountPercent;

  /// No description provided for @removeDiscount.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la remise'**
  String get removeDiscount;

  /// No description provided for @subtotalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get subtotalLabel;

  /// No description provided for @discountTooHigh.
  ///
  /// In fr, this message translates to:
  /// **'Remise trop élevée : maximum {max} % pour les employés.'**
  String discountTooHigh(int max);

  /// No description provided for @discountInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Remise invalide'**
  String get discountInvalid;

  /// No description provided for @applyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get applyLabel;

  /// No description provided for @stockWarningTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stock insuffisant'**
  String get stockWarningTitle;

  /// No description provided for @stockWarningBody.
  ///
  /// In fr, this message translates to:
  /// **'La vente sera quand même enregistrée.'**
  String get stockWarningBody;

  /// No description provided for @searchTicketHint.
  ///
  /// In fr, this message translates to:
  /// **'N° de ticket'**
  String get searchTicketHint;

  /// No description provided for @noSaleFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente trouvée.'**
  String get noSaleFound;

  /// No description provided for @returnButton.
  ///
  /// In fr, this message translates to:
  /// **'Retour client'**
  String get returnButton;

  /// No description provided for @refundedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Déjà remboursé'**
  String get refundedLabel;

  /// No description provided for @returnedQty.
  ///
  /// In fr, this message translates to:
  /// **'{count} retourné(s)'**
  String returnedQty(int count);

  /// No description provided for @returnTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retour du ticket n°{number}'**
  String returnTitle(int number);

  /// No description provided for @returnIntro.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez les articles rapportés et dites s\'ils retournent en rayon ou s\'ils sont abîmés.'**
  String get returnIntro;

  /// No description provided for @backOnShelf.
  ///
  /// In fr, this message translates to:
  /// **'Remis en rayon'**
  String get backOnShelf;

  /// No description provided for @returnReasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Raison du retour (facultatif)'**
  String get returnReasonLabel;

  /// No description provided for @refundToGive.
  ///
  /// In fr, this message translates to:
  /// **'À rendre au client : {amount}'**
  String refundToGive(String amount);

  /// No description provided for @confirmReturn.
  ///
  /// In fr, this message translates to:
  /// **'Valider le retour'**
  String get confirmReturn;

  /// No description provided for @returnSaved.
  ///
  /// In fr, this message translates to:
  /// **'Retour enregistré. Rendez {amount} au client.'**
  String returnSaved(String amount);

  /// No description provided for @returnNothing.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un article.'**
  String get returnNothing;

  /// No description provided for @rulesSection.
  ///
  /// In fr, this message translates to:
  /// **'Règles de la boutique'**
  String get rulesSection;

  /// No description provided for @maxDiscountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Remise maximale des employés (%)'**
  String get maxDiscountLabel;

  /// No description provided for @expiryWarnLabel.
  ///
  /// In fr, this message translates to:
  /// **'Alerte péremption : jours avant'**
  String get expiryWarnLabel;

  /// No description provided for @percentInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Entre 0 et 100'**
  String get percentInvalid;

  /// No description provided for @daysInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Entre 0 et 60'**
  String get daysInvalid;

  /// No description provided for @creditSection.
  ///
  /// In fr, this message translates to:
  /// **'Carnet et fournisseurs'**
  String get creditSection;

  /// No description provided for @customersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Clients (carnet)'**
  String get customersTitle;

  /// No description provided for @customersSub.
  ///
  /// In fr, this message translates to:
  /// **'Crédits et paiements des clients'**
  String get customersSub;

  /// No description provided for @suppliersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs'**
  String get suppliersTitle;

  /// No description provided for @suppliersSub.
  ///
  /// In fr, this message translates to:
  /// **'Livraisons, paiements, reste à payer'**
  String get suppliersSub;

  /// No description provided for @pendingPaymentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiements à valider'**
  String get pendingPaymentsTitle;

  /// No description provided for @pendingPaymentsSub.
  ///
  /// In fr, this message translates to:
  /// **'{count} en attente'**
  String pendingPaymentsSub(int count);

  /// No description provided for @newCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client'**
  String get newCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le client'**
  String get editCustomer;

  /// No description provided for @customerNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Mohamed Saidi'**
  String get customerNameHint;

  /// No description provided for @nameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un nom'**
  String get nameRequired;

  /// No description provided for @creditLimitLabel.
  ///
  /// In fr, this message translates to:
  /// **'Limite de crédit (facultatif)'**
  String get creditLimitLabel;

  /// No description provided for @creditLimitHelp.
  ///
  /// In fr, this message translates to:
  /// **'Vide = pas de limite'**
  String get creditLimitHelp;

  /// No description provided for @creditLimitOwnerOnly.
  ///
  /// In fr, this message translates to:
  /// **'Seul le patron fixe la limite de crédit.'**
  String get creditLimitOwnerOnly;

  /// No description provided for @totalOwedByCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Total dû par les clients'**
  String get totalOwedByCustomers;

  /// No description provided for @debtLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dette'**
  String get debtLabel;

  /// No description provided for @noDebt.
  ///
  /// In fr, this message translates to:
  /// **'Rien à payer'**
  String get noDebt;

  /// No description provided for @advanceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Avance : {amount}'**
  String advanceLabel(String amount);

  /// No description provided for @overLimitBadge.
  ///
  /// In fr, this message translates to:
  /// **'Limite dépassée'**
  String get overLimitBadge;

  /// No description provided for @creditLimitShort.
  ///
  /// In fr, this message translates to:
  /// **'Limite : {amount}'**
  String creditLimitShort(String amount);

  /// No description provided for @noCustomers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun client. Ajoutez-en un avec le bouton +.'**
  String get noCustomers;

  /// No description provided for @searchCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou téléphone'**
  String get searchCustomer;

  /// No description provided for @receivePayment.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser un paiement'**
  String get receivePayment;

  /// No description provided for @paymentAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get paymentAmountLabel;

  /// No description provided for @amountInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un montant valide'**
  String get amountInvalid;

  /// No description provided for @paymentTooHigh.
  ///
  /// In fr, this message translates to:
  /// **'Plus que la dette ({amount})'**
  String paymentTooHigh(String amount);

  /// No description provided for @paymentSaved.
  ///
  /// In fr, this message translates to:
  /// **'Paiement enregistré'**
  String get paymentSaved;

  /// No description provided for @customerHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique du compte'**
  String get customerHistory;

  /// No description provided for @entryCreditSale.
  ///
  /// In fr, this message translates to:
  /// **'Vente à crédit n°{number}'**
  String entryCreditSale(int number);

  /// No description provided for @entryPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement reçu'**
  String get entryPayment;

  /// No description provided for @entryRefund.
  ///
  /// In fr, this message translates to:
  /// **'Retour du ticket n°{number}'**
  String entryRefund(int number);

  /// No description provided for @entrySaleDetail.
  ///
  /// In fr, this message translates to:
  /// **'Total {total} · payé {paid}'**
  String entrySaleDetail(String total, String paid);

  /// No description provided for @recordedBy.
  ///
  /// In fr, this message translates to:
  /// **'par {name}'**
  String recordedBy(String name);

  /// No description provided for @noHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucune opération pour l\'instant.'**
  String get noHistory;

  /// No description provided for @archiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Archiver {name} ?'**
  String archiveTitle(String name);

  /// No description provided for @archiveBody.
  ///
  /// In fr, this message translates to:
  /// **'Il ne sera plus proposé dans les listes. Son historique est conservé.'**
  String get archiveBody;

  /// No description provided for @archivedDone.
  ///
  /// In fr, this message translates to:
  /// **'Archivé'**
  String get archivedDone;

  /// No description provided for @paymentMode.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get paymentMode;

  /// No description provided for @payCash.
  ///
  /// In fr, this message translates to:
  /// **'Comptant'**
  String get payCash;

  /// No description provided for @payCredit.
  ///
  /// In fr, this message translates to:
  /// **'Crédit'**
  String get payCredit;

  /// No description provided for @chooseCustomer.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un client'**
  String get chooseCustomer;

  /// No description provided for @currentDebt.
  ///
  /// In fr, this message translates to:
  /// **'Dette actuelle : {amount}'**
  String currentDebt(String amount);

  /// No description provided for @paidNowLabel.
  ///
  /// In fr, this message translates to:
  /// **'Payé maintenant'**
  String get paidNowLabel;

  /// No description provided for @leftOnCredit.
  ///
  /// In fr, this message translates to:
  /// **'Reste à crédit'**
  String get leftOnCredit;

  /// No description provided for @newDebtLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle dette du client'**
  String get newDebtLabel;

  /// No description provided for @overLimitWarning.
  ///
  /// In fr, this message translates to:
  /// **'Dépasse la limite de crédit ({limit})'**
  String overLimitWarning(String limit);

  /// No description provided for @customerRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un client pour une vente à crédit.'**
  String get customerRequired;

  /// No description provided for @creditLimitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Limite de crédit dépassée'**
  String get creditLimitTitle;

  /// No description provided for @creditLimitAsk.
  ///
  /// In fr, this message translates to:
  /// **'{name} devra {debt}, plus que sa limite de {limit}. Autoriser quand même ?'**
  String creditLimitAsk(String name, String debt, String limit);

  /// No description provided for @creditLimitWorker.
  ///
  /// In fr, this message translates to:
  /// **'Limite de crédit dépassée ({limit}). Demandez au patron.'**
  String creditLimitWorker(String limit);

  /// No description provided for @allowAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get allowAnyway;

  /// No description provided for @saleSavedCredit.
  ///
  /// In fr, this message translates to:
  /// **'Vente n°{number} enregistrée · {amount} sur le compte de {name}'**
  String saleSavedCredit(int number, String amount, String name);

  /// No description provided for @customerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get customerLabel;

  /// No description provided for @paidLabel.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paidLabel;

  /// No description provided for @onCreditLabel.
  ///
  /// In fr, this message translates to:
  /// **'À crédit'**
  String get onCreditLabel;

  /// No description provided for @creditChip.
  ///
  /// In fr, this message translates to:
  /// **'Crédit'**
  String get creditChip;

  /// No description provided for @refundModeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Remboursement'**
  String get refundModeLabel;

  /// No description provided for @refundToCredit.
  ///
  /// In fr, this message translates to:
  /// **'Déduire de la dette'**
  String get refundToCredit;

  /// No description provided for @refundCash.
  ///
  /// In fr, this message translates to:
  /// **'Rendre en espèces'**
  String get refundCash;

  /// No description provided for @refundToAccount.
  ///
  /// In fr, this message translates to:
  /// **'À déduire du compte de {name} : {amount}'**
  String refundToAccount(String name, String amount);

  /// No description provided for @returnSavedCredit.
  ///
  /// In fr, this message translates to:
  /// **'Retour enregistré. {amount} déduit du compte du client.'**
  String returnSavedCredit(String amount);

  /// No description provided for @newSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau fournisseur'**
  String get newSupplier;

  /// No description provided for @editSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le fournisseur'**
  String get editSupplier;

  /// No description provided for @supplierNameHint.
  ///
  /// In fr, this message translates to:
  /// **'ex : Hamoud Boualem'**
  String get supplierNameHint;

  /// No description provided for @noSuppliers.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fournisseur. Ajoutez-en un avec le bouton +.'**
  String get noSuppliers;

  /// No description provided for @totalOwedToSuppliers.
  ///
  /// In fr, this message translates to:
  /// **'Total à payer aux fournisseurs'**
  String get totalOwedToSuppliers;

  /// No description provided for @supplierOwes.
  ///
  /// In fr, this message translates to:
  /// **'Reste à payer : {amount}'**
  String supplierOwes(String amount);

  /// No description provided for @supplierAdvance.
  ///
  /// In fr, this message translates to:
  /// **'Payé d\'avance : {amount}'**
  String supplierAdvance(String amount);

  /// No description provided for @pendingAmount.
  ///
  /// In fr, this message translates to:
  /// **'En attente : {amount}'**
  String pendingAmount(String amount);

  /// No description provided for @deliveredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Livré'**
  String get deliveredLabel;

  /// No description provided for @paidValidatedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Payé (validé)'**
  String get paidValidatedLabel;

  /// No description provided for @leftToPayLabel.
  ///
  /// In fr, this message translates to:
  /// **'Reste à payer'**
  String get leftToPayLabel;

  /// No description provided for @recordSupplierPayment.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer un paiement'**
  String get recordSupplierPayment;

  /// No description provided for @workerPaymentNotice.
  ///
  /// In fr, this message translates to:
  /// **'Le patron devra valider ce paiement avant qu\'il soit compté.'**
  String get workerPaymentNotice;

  /// No description provided for @paymentPendingSaved.
  ///
  /// In fr, this message translates to:
  /// **'Paiement envoyé au patron pour validation'**
  String get paymentPendingSaved;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusValidated.
  ///
  /// In fr, this message translates to:
  /// **'Validé'**
  String get statusValidated;

  /// No description provided for @statusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Refusé'**
  String get statusRejected;

  /// No description provided for @paymentsSection.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get paymentsSection;

  /// No description provided for @deliveriesSection.
  ///
  /// In fr, this message translates to:
  /// **'Livraisons'**
  String get deliveriesSection;

  /// No description provided for @noPayments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement.'**
  String get noPayments;

  /// No description provided for @noDeliveries.
  ///
  /// In fr, this message translates to:
  /// **'Aucune livraison. Choisissez ce fournisseur lors d\'une réception de stock.'**
  String get noDeliveries;

  /// No description provided for @paidBy.
  ///
  /// In fr, this message translates to:
  /// **'Payé par {name}'**
  String paidBy(String name);

  /// No description provided for @validatedBy.
  ///
  /// In fr, this message translates to:
  /// **'validé par {name}'**
  String validatedBy(String name);

  /// No description provided for @rejectedBy.
  ///
  /// In fr, this message translates to:
  /// **'refusé par {name}'**
  String rejectedBy(String name);

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @reject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get reject;

  /// No description provided for @rejectPaymentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Refuser ce paiement ?'**
  String get rejectPaymentTitle;

  /// No description provided for @rejectPaymentBody.
  ///
  /// In fr, this message translates to:
  /// **'Le paiement de {amount} à {name} ne sera pas compté.'**
  String rejectPaymentBody(String amount, String name);

  /// No description provided for @paymentValidated.
  ///
  /// In fr, this message translates to:
  /// **'Paiement validé'**
  String get paymentValidated;

  /// No description provided for @paymentRejected.
  ///
  /// In fr, this message translates to:
  /// **'Paiement refusé'**
  String get paymentRejected;

  /// No description provided for @noPendingPayments.
  ///
  /// In fr, this message translates to:
  /// **'Aucun paiement en attente.'**
  String get noPendingPayments;

  /// No description provided for @supplierOptional.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur (facultatif)'**
  String get supplierOptional;

  /// No description provided for @noSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fournisseur'**
  String get noSupplier;

  /// No description provided for @searchSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un fournisseur'**
  String get searchSupplier;

  /// No description provided for @savedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré'**
  String get savedLabel;

  /// No description provided for @alertsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes'**
  String get alertsTitle;

  /// No description provided for @alertsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte. Tout va bien !'**
  String get alertsEmpty;

  /// No description provided for @markAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get markAllRead;

  /// No description provided for @markRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme lu'**
  String get markRead;

  /// No description provided for @alertsUnread.
  ///
  /// In fr, this message translates to:
  /// **'{count} non lue(s)'**
  String alertsUnread(int count);

  /// No description provided for @alertsReadSection.
  ///
  /// In fr, this message translates to:
  /// **'Déjà lues'**
  String get alertsReadSection;

  /// No description provided for @alertLowStockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stock bas : {product}'**
  String alertLowStockTitle(String product);

  /// No description provided for @alertLowStockBody.
  ///
  /// In fr, this message translates to:
  /// **'Il reste {quantity} (alerte à {threshold}).'**
  String alertLowStockBody(int quantity, int threshold);

  /// No description provided for @alertOutOfStockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rupture : {product}'**
  String alertOutOfStockTitle(String product);

  /// No description provided for @alertOutOfStockBody.
  ///
  /// In fr, this message translates to:
  /// **'Plus aucun article en stock.'**
  String get alertOutOfStockBody;

  /// No description provided for @alertNegativeStockTitle.
  ///
  /// In fr, this message translates to:
  /// **'Stock négatif : {product}'**
  String alertNegativeStockTitle(String product);

  /// No description provided for @alertNegativeStockBody.
  ///
  /// In fr, this message translates to:
  /// **'{count} vendu(s) sans stock enregistré : ajoutez la réception oubliée.'**
  String alertNegativeStockBody(int count);

  /// No description provided for @alertExpiringTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt périmé : {product}'**
  String alertExpiringTitle(String product);

  /// No description provided for @alertExpiringBody.
  ///
  /// In fr, this message translates to:
  /// **'{remaining} article(s) expirent le {date}.'**
  String alertExpiringBody(int remaining, String date);

  /// No description provided for @alertExpiredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Périmé : {product}'**
  String alertExpiredTitle(String product);

  /// No description provided for @alertExpiredBody.
  ///
  /// In fr, this message translates to:
  /// **'{remaining} article(s) périmé(s) depuis le {date}. Déclarez une perte.'**
  String alertExpiredBody(int remaining, String date);

  /// No description provided for @alertPaymentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement à valider'**
  String get alertPaymentTitle;

  /// No description provided for @alertPaymentBody.
  ///
  /// In fr, this message translates to:
  /// **'{by} a payé {amount} à {supplier}.'**
  String alertPaymentBody(String by, String amount, String supplier);

  /// No description provided for @alertDeliveryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réception de stock'**
  String get alertDeliveryTitle;

  /// No description provided for @alertDeliveryBody.
  ///
  /// In fr, this message translates to:
  /// **'{by} a reçu {quantity} × {product}.'**
  String alertDeliveryBody(String by, int quantity, String product);

  /// No description provided for @alertCreditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Limite de crédit dépassée : {customer}'**
  String alertCreditTitle(String customer);

  /// No description provided for @alertCreditBody.
  ///
  /// In fr, this message translates to:
  /// **'Doit {debt} (limite {limit}).'**
  String alertCreditBody(String debt, String limit);

  /// No description provided for @alertPinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Codes PIN faux'**
  String get alertPinTitle;

  /// No description provided for @alertPinBody.
  ///
  /// In fr, this message translates to:
  /// **'{count} code(s) faux sur le compte de {name}.'**
  String alertPinBody(int count, String name);

  /// No description provided for @alertReturnTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retour client'**
  String get alertReturnTitle;

  /// No description provided for @alertReturnBody.
  ///
  /// In fr, this message translates to:
  /// **'{by} a fait un retour sur le ticket n°{number} : {amount}.'**
  String alertReturnBody(String by, int number, String amount);

  /// No description provided for @alertsSummaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} nouvelles alertes'**
  String alertsSummaryTitle(int count);

  /// No description provided for @alertsSummaryBody.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez l\'onglet Alertes pour les voir.'**
  String get alertsSummaryBody;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications du téléphone'**
  String get notificationsTitle;

  /// No description provided for @notificationsSub.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les alertes qui sonnent'**
  String get notificationsSub;

  /// No description provided for @notificationsIntro.
  ///
  /// In fr, this message translates to:
  /// **'Les alertes restent toujours visibles dans l\'onglet Alertes. Ici, vous choisissez celles qui apparaissent aussi en notification sur ce téléphone.'**
  String get notificationsIntro;

  /// No description provided for @workersSeeNote.
  ///
  /// In fr, this message translates to:
  /// **'Les employés voient seulement le stock bas et les dates de péremption.'**
  String get workersSeeNote;

  /// No description provided for @typeLowStock.
  ///
  /// In fr, this message translates to:
  /// **'Stock bas et ruptures'**
  String get typeLowStock;

  /// No description provided for @typeExpiringSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt périmés'**
  String get typeExpiringSoon;

  /// No description provided for @typeExpired.
  ///
  /// In fr, this message translates to:
  /// **'Périmés'**
  String get typeExpired;

  /// No description provided for @typeNewDelivery.
  ///
  /// In fr, this message translates to:
  /// **'Réceptions de stock des employés'**
  String get typeNewDelivery;

  /// No description provided for @typeOverCreditLimit.
  ///
  /// In fr, this message translates to:
  /// **'Clients au-dessus de leur limite'**
  String get typeOverCreditLimit;

  /// No description provided for @typeReturnMade.
  ///
  /// In fr, this message translates to:
  /// **'Retours faits par les employés'**
  String get typeReturnMade;

  /// No description provided for @notificationsBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications sont bloquées sur ce téléphone.'**
  String get notificationsBlocked;

  /// No description provided for @openPhoneSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get openPhoneSettings;

  /// No description provided for @sendTestNotification.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une notification de test'**
  String get sendTestNotification;

  /// No description provided for @testNotificationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notification de test'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications fonctionnent.'**
  String get testNotificationBody;

  /// No description provided for @notificationChannel.
  ///
  /// In fr, this message translates to:
  /// **'Alertes de la boutique'**
  String get notificationChannel;

  /// No description provided for @statsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statsTitle;

  /// No description provided for @periodCustom.
  ///
  /// In fr, this message translates to:
  /// **'Choisir…'**
  String get periodCustom;

  /// No description provided for @everyone.
  ///
  /// In fr, this message translates to:
  /// **'Tout le monde'**
  String get everyone;

  /// No description provided for @statProfit.
  ///
  /// In fr, this message translates to:
  /// **'Bénéfice'**
  String get statProfit;

  /// No description provided for @statAverageTicket.
  ///
  /// In fr, this message translates to:
  /// **'Panier moyen'**
  String get statAverageTicket;

  /// No description provided for @statDiscounts.
  ///
  /// In fr, this message translates to:
  /// **'Remises accordées'**
  String get statDiscounts;

  /// No description provided for @statReturns.
  ///
  /// In fr, this message translates to:
  /// **'Retours'**
  String get statReturns;

  /// No description provided for @returnsCountSub.
  ///
  /// In fr, this message translates to:
  /// **'{count} retour(s)'**
  String returnsCountSub(int count);

  /// No description provided for @statLossesValue.
  ///
  /// In fr, this message translates to:
  /// **'Pertes'**
  String get statLossesValue;

  /// No description provided for @revenuePerDay.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires par jour'**
  String get revenuePerDay;

  /// No description provided for @revenuePerMonth.
  ///
  /// In fr, this message translates to:
  /// **'Chiffre d\'affaires par mois'**
  String get revenuePerMonth;

  /// No description provided for @salesPerWorker.
  ///
  /// In fr, this message translates to:
  /// **'Ventes par personne'**
  String get salesPerWorker;

  /// No description provided for @workerLine.
  ///
  /// In fr, this message translates to:
  /// **'{count} vente(s) · remises {discounts} · reçu des clients {collected}'**
  String workerLine(int count, String discounts, String collected);

  /// No description provided for @costLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prix d\'achat des articles vendus'**
  String get costLabel;

  /// No description provided for @grossProfitLabel.
  ///
  /// In fr, this message translates to:
  /// **'Bénéfice brut'**
  String get grossProfitLabel;

  /// No description provided for @stockLossesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pertes de stock'**
  String get stockLossesLabel;

  /// No description provided for @netProfitLabel.
  ///
  /// In fr, this message translates to:
  /// **'Bénéfice net'**
  String get netProfitLabel;

  /// No description provided for @cashSection.
  ///
  /// In fr, this message translates to:
  /// **'Caisse'**
  String get cashSection;

  /// No description provided for @paidAtCounterLabel.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé au comptoir'**
  String get paidAtCounterLabel;

  /// No description provided for @customerPaymentsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Payé par les clients (carnet)'**
  String get customerPaymentsLabel;

  /// No description provided for @cashRefundsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rendu en espèces (retours)'**
  String get cashRefundsLabel;

  /// No description provided for @cashInHandLabel.
  ///
  /// In fr, this message translates to:
  /// **'Argent en caisse'**
  String get cashInHandLabel;

  /// No description provided for @supplierPaidLabel.
  ///
  /// In fr, this message translates to:
  /// **'Payé aux fournisseurs : {amount}'**
  String supplierPaidLabel(String amount);

  /// No description provided for @creditStatsSection.
  ///
  /// In fr, this message translates to:
  /// **'Crédit'**
  String get creditStatsSection;

  /// No description provided for @cashSalesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Payé comptant'**
  String get cashSalesLabel;

  /// No description provided for @topDebtors.
  ///
  /// In fr, this message translates to:
  /// **'Plus gros débiteurs'**
  String get topDebtors;

  /// No description provided for @lossesByReason.
  ///
  /// In fr, this message translates to:
  /// **'Pertes par raison'**
  String get lossesByReason;

  /// No description provided for @topProducts.
  ///
  /// In fr, this message translates to:
  /// **'Meilleures ventes'**
  String get topProducts;

  /// No description provided for @productSoldQty.
  ///
  /// In fr, this message translates to:
  /// **'{quantity} vendu(s)'**
  String productSoldQty(int quantity);

  /// No description provided for @noSalesPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Aucune vente sur cette période.'**
  String get noSalesPeriod;

  /// No description provided for @myStatsNote.
  ///
  /// In fr, this message translates to:
  /// **'Vous voyez seulement vos propres chiffres.'**
  String get myStatsNote;

  /// No description provided for @noReceiptReturn.
  ///
  /// In fr, this message translates to:
  /// **'Retour sans ticket'**
  String get noReceiptReturn;

  /// No description provided for @noReceiptExchange.
  ///
  /// In fr, this message translates to:
  /// **'Échange sans ticket'**
  String get noReceiptExchange;

  /// No description provided for @exchangeButton.
  ///
  /// In fr, this message translates to:
  /// **'Échange'**
  String get exchangeButton;

  /// No description provided for @exchangeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Échange du ticket n°{number}'**
  String exchangeTitle(int number);

  /// No description provided for @exchangeSwitch.
  ///
  /// In fr, this message translates to:
  /// **'Le client prend d\'autres articles (échange)'**
  String get exchangeSwitch;

  /// No description provided for @returnedItemsSection.
  ///
  /// In fr, this message translates to:
  /// **'Articles rendus'**
  String get returnedItemsSection;

  /// No description provided for @takenItemsSection.
  ///
  /// In fr, this message translates to:
  /// **'Articles pris par le client'**
  String get takenItemsSection;

  /// No description provided for @addReturnedProduct.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit rendu'**
  String get addReturnedProduct;

  /// No description provided for @addTakenProduct.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un article pris'**
  String get addTakenProduct;

  /// No description provided for @noReceiptPriceNote.
  ///
  /// In fr, this message translates to:
  /// **'Sans ticket, le remboursement se fait au prix de vente actuel.'**
  String get noReceiptPriceNote;

  /// No description provided for @returnValueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Valeur des articles rendus'**
  String get returnValueLabel;

  /// No description provided for @takenValueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Valeur des articles pris'**
  String get takenValueLabel;

  /// No description provided for @customerPays.
  ///
  /// In fr, this message translates to:
  /// **'Le client paie : {amount}'**
  String customerPays(String amount);

  /// No description provided for @giveBack.
  ///
  /// In fr, this message translates to:
  /// **'À rendre au client : {amount}'**
  String giveBack(String amount);

  /// No description provided for @nothingToSettle.
  ///
  /// In fr, this message translates to:
  /// **'Rien à payer, rien à rendre.'**
  String get nothingToSettle;

  /// No description provided for @debtReduced.
  ///
  /// In fr, this message translates to:
  /// **'{amount} déduit de la dette du client'**
  String debtReduced(String amount);

  /// No description provided for @confirmExchange.
  ///
  /// In fr, this message translates to:
  /// **'Valider l\'échange'**
  String get confirmExchange;

  /// No description provided for @exchangeNothingTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les articles pris par le client.'**
  String get exchangeNothingTaken;

  /// No description provided for @exchangeSaved.
  ///
  /// In fr, this message translates to:
  /// **'Échange enregistré : ticket n°{number}.'**
  String exchangeSaved(int number);

  /// No description provided for @ownerApprovalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accord du patron'**
  String get ownerApprovalTitle;

  /// No description provided for @ownerApprovalBody.
  ///
  /// In fr, this message translates to:
  /// **'Un retour sans ticket doit être accepté par {name}. {name}, tapez votre code PIN :'**
  String ownerApprovalBody(String name);

  /// No description provided for @ownerApprovalRefused.
  ///
  /// In fr, this message translates to:
  /// **'Le patron doit accepter ce retour.'**
  String get ownerApprovalRefused;

  /// No description provided for @exchangeCreditLabel.
  ///
  /// In fr, this message translates to:
  /// **'Avoir (articles rendus)'**
  String get exchangeCreditLabel;

  /// No description provided for @fromExchangeNote.
  ///
  /// In fr, this message translates to:
  /// **'Ticket d\'un échange'**
  String get fromExchangeNote;

  /// No description provided for @alertReturnNoReceiptBody.
  ///
  /// In fr, this message translates to:
  /// **'{by} a repris des articles sans ticket : {amount}.'**
  String alertReturnNoReceiptBody(String by, String amount);

  /// No description provided for @alertExchangeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Échange'**
  String get alertExchangeTitle;

  /// No description provided for @alertExchangeBody.
  ///
  /// In fr, this message translates to:
  /// **'{by} a fait un échange : rendu {amount}, pris {taken}.'**
  String alertExchangeBody(String by, String amount, String taken);
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
