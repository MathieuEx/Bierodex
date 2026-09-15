import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @authPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit faire au moins {min} caractères.'**
  String authPasswordTooShort(int min);

  /// No description provided for @authPasswordTooLong.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe est trop long.'**
  String get authPasswordTooLong;

  /// No description provided for @authPasswordNeedsLettersAndDigits.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir des lettres et des chiffres.'**
  String get authPasswordNeedsLettersAndDigits;

  /// No description provided for @authInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get authInvalidEmail;

  /// No description provided for @errorServerUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de contacter le serveur. Vérifie ta connexion internet.'**
  String get errorServerUnreachable;

  /// No description provided for @authEnterPassword.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton mot de passe.'**
  String get authEnterPassword;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authWeakPasswordChooseAnother.
  ///
  /// In fr, this message translates to:
  /// **'Ce mot de passe est trop faible ou a déjà fuité ailleurs. Choisis-en un autre.'**
  String get authWeakPasswordChooseAnother;

  /// No description provided for @authUserAlreadyExists.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cette adresse. Connecte-toi.'**
  String get authUserAlreadyExists;

  /// No description provided for @authWeakPassword.
  ///
  /// In fr, this message translates to:
  /// **'Ce mot de passe est trop faible ou a déjà fuité ailleurs.'**
  String get authWeakPassword;

  /// No description provided for @authSamePassword.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un mot de passe différent de l\'ancien.'**
  String get authSamePassword;

  /// No description provided for @authResendWait.
  ///
  /// In fr, this message translates to:
  /// **'Patiente {seconds} s avant de redemander un code.'**
  String authResendWait(int seconds);

  /// No description provided for @authTooManyCodeAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Demande un nouveau code.'**
  String get authTooManyCodeAttempts;

  /// No description provided for @authCodeLength.
  ///
  /// In fr, this message translates to:
  /// **'Le code contient {length} chiffres.'**
  String authCodeLength(int length);

  /// No description provided for @authGoogleUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Connexion Google impossible pour le moment.'**
  String get authGoogleUnavailable;

  /// No description provided for @authGoogleCannotOpen.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir la connexion Google. Vérifie ta connexion internet.'**
  String get authGoogleCannotOpen;

  /// No description provided for @authDeleteFailed.
  ///
  /// In fr, this message translates to:
  /// **'La suppression a échoué. Réessaie plus tard ; tes données sont intactes.'**
  String get authDeleteFailed;

  /// No description provided for @authRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessaie dans quelques minutes.'**
  String get authRateLimited;

  /// No description provided for @authInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide ou expiré.'**
  String get authInvalidCode;

  /// No description provided for @authSignInUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible pour le moment. Réessaie plus tard.'**
  String get authSignInUnavailable;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirme d\'abord ton adresse e-mail avec le code reçu.'**
  String get authEmailNotConfirmed;

  /// No description provided for @usernameLength.
  ///
  /// In fr, this message translates to:
  /// **'Entre {min} et {max} caractères.'**
  String usernameLength(int min, int max);

  /// No description provided for @usernameCharacters.
  ///
  /// In fr, this message translates to:
  /// **'Lettres minuscules, chiffres et _ uniquement.'**
  String get usernameCharacters;

  /// No description provided for @errorSignInRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connexion requise.'**
  String get errorSignInRequired;

  /// No description provided for @displayNameTooLong.
  ///
  /// In fr, this message translates to:
  /// **'Le nom affiché est trop long.'**
  String get displayNameTooLong;

  /// No description provided for @socialUsernameTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce pseudo est déjà pris.'**
  String get socialUsernameTaken;

  /// No description provided for @socialInvalidProfile.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo ou nom affiché invalide.'**
  String get socialInvalidProfile;

  /// No description provided for @socialProfileRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisis d\'abord ton pseudo.'**
  String get socialProfileRequired;

  /// No description provided for @socialProfileNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun profil ne porte ce pseudo.'**
  String get socialProfileNotFound;

  /// No description provided for @socialCannotAddSelf.
  ///
  /// In fr, this message translates to:
  /// **'C\'est ton propre pseudo.'**
  String get socialCannotAddSelf;

  /// No description provided for @socialTooManyRequests.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes en attente. Réessaie plus tard.'**
  String get socialTooManyRequests;

  /// No description provided for @socialRequestNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande n\'existe plus.'**
  String get socialRequestNotFound;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessaie plus tard.'**
  String get errorGeneric;

  /// No description provided for @submissionAlreadySubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Cette bière a déjà été proposée.'**
  String get submissionAlreadySubmitted;

  /// No description provided for @submissionAlreadyInCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Une bière avec ce code-barres existe déjà dans le catalogue.'**
  String get submissionAlreadyInCatalog;

  /// No description provided for @submissionTooMany.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà beaucoup de propositions en attente.'**
  String get submissionTooMany;

  /// No description provided for @submissionBeerNotSynced.
  ///
  /// In fr, this message translates to:
  /// **'Cette bière n\'est pas encore synchronisée. Réessaie dans un instant.'**
  String get submissionBeerNotSynced;

  /// No description provided for @submissionNotModerator.
  ///
  /// In fr, this message translates to:
  /// **'Action réservée aux modérateurs.'**
  String get submissionNotModerator;

  /// No description provided for @submissionAlreadyReviewed.
  ///
  /// In fr, this message translates to:
  /// **'Cette proposition a déjà été traitée.'**
  String get submissionAlreadyReviewed;

  /// No description provided for @familyAle.
  ///
  /// In fr, this message translates to:
  /// **'Fermentation haute (Ale)'**
  String get familyAle;

  /// No description provided for @familyLager.
  ///
  /// In fr, this message translates to:
  /// **'Fermentation basse (Lager)'**
  String get familyLager;

  /// No description provided for @familySpontaneous.
  ///
  /// In fr, this message translates to:
  /// **'Fermentation spontanée'**
  String get familySpontaneous;

  /// No description provided for @familyMixed.
  ///
  /// In fr, this message translates to:
  /// **'Fermentation mixte'**
  String get familyMixed;

  /// No description provided for @familySpontaneousShort.
  ///
  /// In fr, this message translates to:
  /// **'Spontanée'**
  String get familySpontaneousShort;

  /// No description provided for @familyMixedShort.
  ///
  /// In fr, this message translates to:
  /// **'Mixte'**
  String get familyMixedShort;

  /// No description provided for @visibilityPrivate.
  ///
  /// In fr, this message translates to:
  /// **'Privé'**
  String get visibilityPrivate;

  /// No description provided for @visibilityFriends.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get visibilityFriends;

  /// No description provided for @visibilityPublic.
  ///
  /// In fr, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// No description provided for @visibilityPrivateDescription.
  ///
  /// In fr, this message translates to:
  /// **'Personne d\'autre que toi.'**
  String get visibilityPrivateDescription;

  /// No description provided for @visibilityFriendsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Tes amis acceptés uniquement.'**
  String get visibilityFriendsDescription;

  /// No description provided for @visibilityPublicDescription.
  ///
  /// In fr, this message translates to:
  /// **'Toute personne ayant le lien, même sans compte.'**
  String get visibilityPublicDescription;

  /// No description provided for @aromaAgrumes.
  ///
  /// In fr, this message translates to:
  /// **'Agrumes'**
  String get aromaAgrumes;

  /// No description provided for @aromaFruitsRouges.
  ///
  /// In fr, this message translates to:
  /// **'Fruits rouges'**
  String get aromaFruitsRouges;

  /// No description provided for @aromaFruitsExotiques.
  ///
  /// In fr, this message translates to:
  /// **'Fruits exotiques'**
  String get aromaFruitsExotiques;

  /// No description provided for @aromaFloral.
  ///
  /// In fr, this message translates to:
  /// **'Floral'**
  String get aromaFloral;

  /// No description provided for @aromaHerbace.
  ///
  /// In fr, this message translates to:
  /// **'Herbacé'**
  String get aromaHerbace;

  /// No description provided for @aromaResineux.
  ///
  /// In fr, this message translates to:
  /// **'Résineux'**
  String get aromaResineux;

  /// No description provided for @aromaEpices.
  ///
  /// In fr, this message translates to:
  /// **'Épices'**
  String get aromaEpices;

  /// No description provided for @aromaBananeClou.
  ///
  /// In fr, this message translates to:
  /// **'Banane / clou de girofle'**
  String get aromaBananeClou;

  /// No description provided for @aromaMiel.
  ///
  /// In fr, this message translates to:
  /// **'Miel'**
  String get aromaMiel;

  /// No description provided for @aromaBiscuit.
  ///
  /// In fr, this message translates to:
  /// **'Biscuit / céréale'**
  String get aromaBiscuit;

  /// No description provided for @aromaCaramel.
  ///
  /// In fr, this message translates to:
  /// **'Caramel'**
  String get aromaCaramel;

  /// No description provided for @aromaTorrefie.
  ///
  /// In fr, this message translates to:
  /// **'Torréfié'**
  String get aromaTorrefie;

  /// No description provided for @aromaChocolat.
  ///
  /// In fr, this message translates to:
  /// **'Chocolat'**
  String get aromaChocolat;

  /// No description provided for @aromaCafe.
  ///
  /// In fr, this message translates to:
  /// **'Café'**
  String get aromaCafe;

  /// No description provided for @aromaBoise.
  ///
  /// In fr, this message translates to:
  /// **'Boisé'**
  String get aromaBoise;

  /// No description provided for @aromaAcidule.
  ///
  /// In fr, this message translates to:
  /// **'Acidulé'**
  String get aromaAcidule;

  /// No description provided for @aromaFunky.
  ///
  /// In fr, this message translates to:
  /// **'Funky / Brett'**
  String get aromaFunky;

  /// No description provided for @achievementFirstTastingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Première gorgée'**
  String get achievementFirstTastingTitle;

  /// No description provided for @achievementFirstTastingDescription.
  ///
  /// In fr, this message translates to:
  /// **'Déguster une première bière.'**
  String get achievementFirstTastingDescription;

  /// No description provided for @achievementTasted10Title.
  ///
  /// In fr, this message translates to:
  /// **'Carnet entamé'**
  String get achievementTasted10Title;

  /// No description provided for @achievementTasted10Description.
  ///
  /// In fr, this message translates to:
  /// **'Déguster 10 bières.'**
  String get achievementTasted10Description;

  /// No description provided for @achievementTasted25Title.
  ///
  /// In fr, this message translates to:
  /// **'Amateur éclairé'**
  String get achievementTasted25Title;

  /// No description provided for @achievementTasted25Description.
  ///
  /// In fr, this message translates to:
  /// **'Déguster 25 bières.'**
  String get achievementTasted25Description;

  /// No description provided for @achievementTasted50Title.
  ///
  /// In fr, this message translates to:
  /// **'Connaisseur'**
  String get achievementTasted50Title;

  /// No description provided for @achievementTasted50Description.
  ///
  /// In fr, this message translates to:
  /// **'Déguster 50 bières.'**
  String get achievementTasted50Description;

  /// No description provided for @achievementStyles10Title.
  ///
  /// In fr, this message translates to:
  /// **'Palette de styles'**
  String get achievementStyles10Title;

  /// No description provided for @achievementStyles10Description.
  ///
  /// In fr, this message translates to:
  /// **'Goûter 10 styles différents.'**
  String get achievementStyles10Description;

  /// No description provided for @achievementEuropeTourTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tour d\'Europe'**
  String get achievementEuropeTourTitle;

  /// No description provided for @achievementEuropeTourDescription.
  ///
  /// In fr, this message translates to:
  /// **'Goûter des bières de 10 pays européens.'**
  String get achievementEuropeTourDescription;

  /// No description provided for @achievementWorldTourTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tour du monde'**
  String get achievementWorldTourTitle;

  /// No description provided for @achievementWorldTourDescription.
  ///
  /// In fr, this message translates to:
  /// **'Goûter des bières des 5 continents.'**
  String get achievementWorldTourDescription;

  /// No description provided for @achievementSpontaneousTitle.
  ///
  /// In fr, this message translates to:
  /// **'Explorateur des fermentations spontanées'**
  String get achievementSpontaneousTitle;

  /// No description provided for @achievementSpontaneousDescription.
  ///
  /// In fr, this message translates to:
  /// **'Déguster 3 bières à fermentation spontanée (lambic, gueuze, kriek...).'**
  String get achievementSpontaneousDescription;

  /// No description provided for @achievementFourFamiliesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les quatre fermentations'**
  String get achievementFourFamiliesTitle;

  /// No description provided for @achievementFourFamiliesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Goûter au moins une bière de chaque famille.'**
  String get achievementFourFamiliesDescription;

  /// No description provided for @achievementStreak3Title.
  ///
  /// In fr, this message translates to:
  /// **'Régulier'**
  String get achievementStreak3Title;

  /// No description provided for @achievementStreak3Description.
  ///
  /// In fr, this message translates to:
  /// **'Au moins une dégustation 3 mois d\'affilée.'**
  String get achievementStreak3Description;

  /// No description provided for @achievementStreak6Title.
  ///
  /// In fr, this message translates to:
  /// **'Fidèle au carnet'**
  String get achievementStreak6Title;

  /// No description provided for @achievementStreak6Description.
  ///
  /// In fr, this message translates to:
  /// **'Au moins une dégustation 6 mois d\'affilée.'**
  String get achievementStreak6Description;

  /// No description provided for @achievementDetailed5Title.
  ///
  /// In fr, this message translates to:
  /// **'Palais aiguisé'**
  String get achievementDetailed5Title;

  /// No description provided for @achievementDetailed5Description.
  ///
  /// In fr, this message translates to:
  /// **'Remplir 5 fiches de dégustation détaillées.'**
  String get achievementDetailed5Description;

  /// No description provided for @achievementPhotos5Title.
  ///
  /// In fr, this message translates to:
  /// **'Photographe'**
  String get achievementPhotos5Title;

  /// No description provided for @achievementPhotos5Description.
  ///
  /// In fr, this message translates to:
  /// **'Photographier 5 dégustations.'**
  String get achievementPhotos5Description;

  /// No description provided for @recommendationLikedStyle.
  ///
  /// In fr, this message translates to:
  /// **'Tu as aimé tes {style} ({average}/5)'**
  String recommendationLikedStyle(String style, String average);

  /// No description provided for @recommendationLikedFamily.
  ///
  /// In fr, this message translates to:
  /// **'Tu apprécies la {family} : découvre le style {style}'**
  String recommendationLikedFamily(String family, String style);

  /// No description provided for @reminderInactivityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une petite soif ?'**
  String get reminderInactivityTitle;

  /// No description provided for @reminderInactivityBody.
  ///
  /// In fr, this message translates to:
  /// **'Ça fait {days} jours que tu n\'as rien goûté. Une nouvelle bière à découvrir ?'**
  String reminderInactivityBody(int days);

  /// No description provided for @reminderWishlistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ta wishlist t\'attend'**
  String get reminderWishlistTitle;

  /// No description provided for @reminderWishlistBody.
  ///
  /// In fr, this message translates to:
  /// **'Toujours envie de goûter {beer} ({brewery}) ?'**
  String reminderWishlistBody(String beer, String brewery);

  /// No description provided for @reminderChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Rappels'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de dégustation et de wishlist'**
  String get reminderChannelDescription;

  /// No description provided for @catalogLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement du catalogue...'**
  String get catalogLoading;

  /// No description provided for @catalogLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le catalogue.'**
  String get catalogLoadError;

  /// No description provided for @checkInternetConnection.
  ///
  /// In fr, this message translates to:
  /// **'Vérifie ta connexion internet.'**
  String get checkInternetConnection;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @accountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get accountTitle;

  /// No description provided for @accountSignedIn.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get accountSignedIn;

  /// No description provided for @accountSyncedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ta collection (bières bues et notées) est synchronisée avec ce compte et accessible depuis n\'importe quel appareil.'**
  String get accountSyncedDescription;

  /// No description provided for @accountPendingChanges.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 modification en attente} other{{count} modifications en attente}}'**
  String accountPendingChanges(int count);

  /// No description provided for @accountPendingChangesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrées sur cet appareil, elles seront envoyées dès le retour de la connexion.'**
  String get accountPendingChangesDescription;

  /// No description provided for @retryNow.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer maintenant'**
  String get retryNow;

  /// No description provided for @reminderInactivitySetting.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de dégustation'**
  String get reminderInactivitySetting;

  /// No description provided for @reminderInactivitySettingDescription.
  ///
  /// In fr, this message translates to:
  /// **'Si tu n\'as rien goûté depuis un mois'**
  String get reminderInactivitySettingDescription;

  /// No description provided for @reminderWishlistSetting.
  ///
  /// In fr, this message translates to:
  /// **'Rappel de wishlist'**
  String get reminderWishlistSetting;

  /// No description provided for @reminderWishlistSettingDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une bière à goûter, toutes les deux semaines'**
  String get reminderWishlistSettingDescription;

  /// No description provided for @accountFriendsAndProfile.
  ///
  /// In fr, this message translates to:
  /// **'Amis et profil'**
  String get accountFriendsAndProfile;

  /// No description provided for @accountFriendsAndProfileDescription.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo, amis, lien de profil public'**
  String get accountFriendsAndProfileDescription;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @signOutEverywhere.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter de tous les appareils'**
  String get signOutEverywhere;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicyTitle;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In fr, this message translates to:
  /// **'Efface définitivement toutes tes données.'**
  String get deleteAccountDescription;

  /// No description provided for @moderationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modération'**
  String get moderationTitle;

  /// No description provided for @moderationDescription.
  ///
  /// In fr, this message translates to:
  /// **'Bières proposées par la communauté'**
  String get moderationDescription;

  /// No description provided for @signOutEverywhereTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tous les appareils ?'**
  String get signOutEverywhereTitle;

  /// No description provided for @signOutEverywhereDescription.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les sessions ouvertes avec ce compte (téléphone, tablette, navigateur...) seront fermées. À faire en cas de perte ou de vol d\'un appareil.'**
  String get signOutEverywhereDescription;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @signOutEverywhereConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Tout déconnecter'**
  String get signOutEverywhereConfirm;

  /// No description provided for @deleteAccountInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Suppression en cours...'**
  String get deleteAccountInProgress;

  /// No description provided for @deleteAccountDone.
  ///
  /// In fr, this message translates to:
  /// **'Ton compte a été supprimé.'**
  String get deleteAccountDone;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ton compte ?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In fr, this message translates to:
  /// **'Ta collection, tes notes, tes commentaires et les bières que tu as ajoutées seront effacés définitivement, sur tous tes appareils. Cette action est irréversible.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountTypeToConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Tape {word} pour confirmer :'**
  String deleteAccountTypeToConfirm(String word);

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountConfirmationWord.
  ///
  /// In fr, this message translates to:
  /// **'SUPPRIMER'**
  String get deleteAccountConfirmationWord;

  /// No description provided for @privacyWhoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Qui est responsable ?'**
  String get privacyWhoTitle;

  /// No description provided for @privacyWhoParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'Le Bierodex est édité par {publisher}, responsable du traitement de tes données. Contact : {contact}.'**
  String privacyWhoParagraph1(String publisher, String contact);

  /// No description provided for @privacyDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données collectées'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'Compte : ton adresse e-mail, ton mot de passe (conservé uniquement sous forme hachée, illisible même pour nous) et un identifiant technique. Si tu te connectes avec Google, Google nous transmet aussi ton nom et ta photo de profil ; nous ne recevons jamais ton mot de passe Google.'**
  String get privacyDataParagraph1;

  /// No description provided for @privacyDataParagraph2.
  ///
  /// In fr, this message translates to:
  /// **'Collection : les bières marquées comme bues ou à goûter, tes notes, dates de dégustation, commentaires et fiches de dégustation (couleur, amertume, douceur, corps, arômes), ainsi que les bières que tu ajoutes toi-même (nom, brasserie, code-barres, photo).'**
  String get privacyDataParagraph2;

  /// No description provided for @privacyDataParagraph3.
  ///
  /// In fr, this message translates to:
  /// **'Profil et amis (facultatifs) : ton pseudo, un nom affiché si tu en choisis un, la visibilité de ta collection et la liste de tes amis et demandes d\'amis.'**
  String get privacyDataParagraph3;

  /// No description provided for @privacyDataParagraph4.
  ///
  /// In fr, this message translates to:
  /// **'Photos de dégustation : uniquement celles que tu choisis de prendre ou d\'importer. Elles sont stockées dans un espace privé accessible à ton seul compte, jamais publiées. Si ton appareil enregistre la position dans ses photos, cette information peut rester dans le fichier : l\'app ne la lit ni ne l\'exploite.'**
  String get privacyDataParagraph4;

  /// No description provided for @privacyDataParagraph5.
  ///
  /// In fr, this message translates to:
  /// **'Aucune localisation collectée par l\'app, aucun contact, aucune publicité, aucun traceur publicitaire.'**
  String get privacyDataParagraph5;

  /// No description provided for @privacyWhyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi ?'**
  String get privacyWhyTitle;

  /// No description provided for @privacyWhyParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'Uniquement pour faire fonctionner l\'app : te connecter et synchroniser ta collection entre tes appareils (base légale : exécution du service que tu demandes). Tes données ne sont ni vendues, ni partagées à des fins commerciales.'**
  String get privacyWhyParagraph1;

  /// No description provided for @privacySharingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partage et communauté'**
  String get privacySharingTitle;

  /// No description provided for @privacySharingParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut, ta collection est privée. Si tu rends ton profil visible par tes amis ou public, les personnes concernées (ou toute personne ayant ton lien, pour un profil public) voient ton pseudo, ton nom affiché, les bières bues et à goûter, leur note sur 5 et leur date. Jamais tes notes écrites, fiches de dégustation, photos ni ton adresse e-mail. Tu peux revenir en privé à tout moment.'**
  String get privacySharingParagraph1;

  /// No description provided for @privacySharingParagraph2.
  ///
  /// In fr, this message translates to:
  /// **'Tes amis voient ton pseudo et ton nom affiché, même si ta collection est privée.'**
  String get privacySharingParagraph2;

  /// No description provided for @privacySharingParagraph3.
  ///
  /// In fr, this message translates to:
  /// **'Proposer une bière au catalogue commun transmet ses informations (nom, brasserie, pays, style, degré, description, code-barres, photo) à un modérateur. Une fois acceptée, elle devient publique, sans mention de ton compte.'**
  String get privacySharingParagraph3;

  /// No description provided for @privacySharingParagraph4.
  ///
  /// In fr, this message translates to:
  /// **'Les cartes de dégustation sont générées sur ton appareil : elles ne sont partagées que si tu choisis de les envoyer.'**
  String get privacySharingParagraph4;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Où sont-elles stockées ?'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'Chez Supabase (hébergement {region}), avec un accès limité à ton seul compte (sauf ce que tu choisis de partager, voir ci-dessus). Une copie est gardée sur ton appareil pour un usage hors-ligne ; la session de connexion y est chiffrée par le système (Keychain / Keystore). Les modifications faites hors-ligne y attendent le retour du réseau avant d\'être envoyées.'**
  String privacyStorageParagraph1(String region);

  /// No description provided for @privacyThirdPartiesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Services tiers'**
  String get privacyThirdPartiesTitle;

  /// No description provided for @privacyThirdPartiesParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'Open Food Facts : quand tu scannes un code-barres inconnu, ce code est envoyé à Open Food Facts pour retrouver le produit.'**
  String get privacyThirdPartiesParagraph1;

  /// No description provided for @privacyThirdPartiesParagraph2.
  ///
  /// In fr, this message translates to:
  /// **'OpenStreetMap et Wikimedia Commons : fonds de carte et photos, chargés directement depuis leurs serveurs (ton adresse IP leur est donc visible).'**
  String get privacyThirdPartiesParagraph2;

  /// No description provided for @privacyThirdPartiesParagraph3.
  ///
  /// In fr, this message translates to:
  /// **'Google : uniquement si tu choisis \"Continuer avec Google\".'**
  String get privacyThirdPartiesParagraph3;

  /// No description provided for @privacyThirdPartiesParagraph4.
  ///
  /// In fr, this message translates to:
  /// **'Sentry : en cas de plantage, un rapport technique (message d\'erreur, modèle d\'appareil, version du système et de l\'app) est envoyé pour corriger le problème. Il ne contient ni ton adresse e-mail, ni ton identifiant, ni ton adresse IP, ni le contenu de ta collection (base légale : intérêt légitime à faire fonctionner l\'app).'**
  String get privacyThirdPartiesParagraph4;

  /// No description provided for @privacyThirdPartiesParagraph5.
  ///
  /// In fr, this message translates to:
  /// **'Les rappels (notifications) sont programmés sur ton appareil, sans aucun serveur. Tu peux les couper dans \"Mon compte\".'**
  String get privacyThirdPartiesParagraph5;

  /// No description provided for @privacyRetentionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Durée de conservation'**
  String get privacyRetentionTitle;

  /// No description provided for @privacyRetentionParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'Tant que ton compte existe. La suppression du compte efface immédiatement et définitivement toutes tes données de nos serveurs et de l\'appareil utilisé (profil, amis et propositions compris). Les bières déjà acceptées au catalogue commun, qui ne contiennent aucune donnée personnelle, y restent.'**
  String get privacyRetentionParagraph1;

  /// No description provided for @privacyRightsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tes droits'**
  String get privacyRightsTitle;

  /// No description provided for @privacyRightsParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'Tu peux accéder à tes données, les corriger, les exporter ou demander leur suppression, et t\'opposer à leur traitement. La suppression est disponible directement dans \"Mon compte\" ; pour le reste, écris à {contact}.'**
  String privacyRightsParagraph1(String contact);

  /// No description provided for @privacyRightsParagraph2.
  ///
  /// In fr, this message translates to:
  /// **'Tu peux aussi introduire une réclamation auprès de la CNIL (www.cnil.fr).'**
  String get privacyRightsParagraph2;

  /// No description provided for @privacyAgeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get privacyAgeTitle;

  /// No description provided for @privacyAgeParagraph1.
  ///
  /// In fr, this message translates to:
  /// **'L\'app présente des boissons alcoolisées et est réservée aux personnes majeures.'**
  String get privacyAgeParagraph1;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour : {date}'**
  String privacyLastUpdated(String date);

  /// No description provided for @privacyScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacyScreenTitle;

  /// No description provided for @socialReceivedRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes reçues'**
  String get socialReceivedRequests;

  /// No description provided for @socialMyFriends.
  ///
  /// In fr, this message translates to:
  /// **'Mes amis'**
  String get socialMyFriends;

  /// No description provided for @socialSentRequests.
  ///
  /// In fr, this message translates to:
  /// **'Demandes envoyées'**
  String get socialSentRequests;

  /// No description provided for @socialNoFriends.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore d\'amis. Ajoute-les avec leur pseudo.'**
  String get socialNoFriends;

  /// No description provided for @socialShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Ma collection sur le Bierodex'**
  String get socialShareSubject;

  /// No description provided for @socialCreateProfile.
  ///
  /// In fr, this message translates to:
  /// **'Crée ton profil'**
  String get socialCreateProfile;

  /// No description provided for @socialCreateProfileDescription.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un pseudo pour ajouter des amis et, si tu le souhaites, partager ta collection. Ton profil reste privé tant que tu ne changes pas sa visibilité.'**
  String get socialCreateProfileDescription;

  /// No description provided for @socialChooseUsername.
  ///
  /// In fr, this message translates to:
  /// **'Choisir mon pseudo'**
  String get socialChooseUsername;

  /// No description provided for @socialEditProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get socialEditProfile;

  /// No description provided for @socialCollectionVisibility.
  ///
  /// In fr, this message translates to:
  /// **'Collection : {visibility} · {description}'**
  String socialCollectionVisibility(String visibility, String description);

  /// No description provided for @socialViewAsOthers.
  ///
  /// In fr, this message translates to:
  /// **'Voir comme les autres'**
  String get socialViewAsOthers;

  /// No description provided for @socialShareLink.
  ///
  /// In fr, this message translates to:
  /// **'Partager le lien'**
  String get socialShareLink;

  /// No description provided for @copy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copy;

  /// No description provided for @socialLinkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié.'**
  String get socialLinkCopied;

  /// No description provided for @socialMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get socialMyProfile;

  /// No description provided for @socialUsername.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo'**
  String get socialUsername;

  /// No description provided for @socialUsernameHelper.
  ///
  /// In fr, this message translates to:
  /// **'Visible par tes amis et dans ton lien public.'**
  String get socialUsernameHelper;

  /// No description provided for @socialDisplayNameOptional.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché (optionnel)'**
  String get socialDisplayNameOptional;

  /// No description provided for @socialWhoCanSee.
  ///
  /// In fr, this message translates to:
  /// **'Qui peut voir ma collection ?'**
  String get socialWhoCanSee;

  /// No description provided for @socialSharedDataNotice.
  ///
  /// In fr, this message translates to:
  /// **'Sont partagés : bières bues et à goûter, notes sur 5 et dates. Jamais tes notes écrites, fiches de dégustation, photos ni ton adresse e-mail.'**
  String get socialSharedDataNotice;

  /// No description provided for @saving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement...'**
  String get saving;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @socialNowFriends.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes maintenant amis avec @{username}.'**
  String socialNowFriends(String username);

  /// No description provided for @socialRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée à @{username}.'**
  String socialRequestSent(String username);

  /// No description provided for @socialAddFriend.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un ami'**
  String get socialAddFriend;

  /// No description provided for @socialAddFriendHint.
  ///
  /// In fr, this message translates to:
  /// **'Son pseudo exact'**
  String get socialAddFriendHint;

  /// No description provided for @socialSendRequest.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get socialSendRequest;

  /// No description provided for @socialRemoveFriendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {name} ?'**
  String socialRemoveFriendTitle(String name);

  /// No description provided for @socialRemoveFriendDescription.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne verrez plus vos collections respectives si elles sont réservées aux amis.'**
  String get socialRemoveFriendDescription;

  /// No description provided for @remove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get remove;

  /// No description provided for @socialRemoveFriend.
  ///
  /// In fr, this message translates to:
  /// **'Retirer cet ami'**
  String get socialRemoveFriend;

  /// No description provided for @decline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get accept;

  /// No description provided for @statsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes statistiques'**
  String get statsTitle;

  /// No description provided for @statsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Marque tes premières bières comme bues pour voir tes statistiques prendre forme.'**
  String get statsEmpty;

  /// No description provided for @statsByMonth.
  ///
  /// In fr, this message translates to:
  /// **'Dégustations par mois'**
  String get statsByMonth;

  /// No description provided for @statsLast12Months.
  ///
  /// In fr, this message translates to:
  /// **'12 derniers mois'**
  String get statsLast12Months;

  /// No description provided for @statsByFamily.
  ///
  /// In fr, this message translates to:
  /// **'Par famille de fermentation'**
  String get statsByFamily;

  /// No description provided for @statsByStyle.
  ///
  /// In fr, this message translates to:
  /// **'Par style'**
  String get statsByStyle;

  /// No description provided for @statsAverageByStyle.
  ///
  /// In fr, this message translates to:
  /// **'Note moyenne par style'**
  String get statsAverageByStyle;

  /// No description provided for @statsCountries.
  ///
  /// In fr, this message translates to:
  /// **'Pays goûtés'**
  String get statsCountries;

  /// No description provided for @statsCountriesHint.
  ///
  /// In fr, this message translates to:
  /// **'Plus le cercle est grand et foncé, plus tu as goûté de bières de ce pays.'**
  String get statsCountriesHint;

  /// No description provided for @statsForYou.
  ///
  /// In fr, this message translates to:
  /// **'Pour toi'**
  String get statsForYou;

  /// No description provided for @statsForYouHint.
  ///
  /// In fr, this message translates to:
  /// **'D\'après tes styles les mieux notés.'**
  String get statsForYouHint;

  /// No description provided for @statsBadges.
  ///
  /// In fr, this message translates to:
  /// **'Badges'**
  String get statsBadges;

  /// No description provided for @statsTileBeers.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{bière} other{bières}}'**
  String statsTileBeers(int count);

  /// No description provided for @statsTileStyles.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{style} other{styles}}'**
  String statsTileStyles(int count);

  /// No description provided for @statsTileCountries.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{pays} other{pays}}'**
  String statsTileCountries(int count);

  /// No description provided for @statsTileAverage.
  ///
  /// In fr, this message translates to:
  /// **'note moy.'**
  String get statsTileAverage;

  /// No description provided for @showLess.
  ///
  /// In fr, this message translates to:
  /// **'Voir moins'**
  String get showLess;

  /// No description provided for @showAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout ({count})'**
  String showAll(int count);

  /// No description provided for @statsMonthTooltip.
  ///
  /// In fr, this message translates to:
  /// **'{month} : {count, plural, =0{aucune dégustation} =1{1 dégustation} other{{count} dégustations}}'**
  String statsMonthTooltip(String month, int count);

  /// No description provided for @statsNoRecommendations.
  ///
  /// In fr, this message translates to:
  /// **'Note quelques bières (au moins 4 étoiles) pour recevoir des suggestions.'**
  String get statsNoRecommendations;

  /// No description provided for @achievementUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Débloqué'**
  String get achievementUnlocked;

  /// No description provided for @stylesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Styles de bières'**
  String get stylesTitle;

  /// No description provided for @collectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ma collection'**
  String get collectionTitle;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @scanBeer.
  ///
  /// In fr, this message translates to:
  /// **'Scanner une bière'**
  String get scanBeer;

  /// No description provided for @styles.
  ///
  /// In fr, this message translates to:
  /// **'Styles'**
  String get styles;

  /// No description provided for @beerDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette bière ?'**
  String get beerDeleteTitle;

  /// No description provided for @beerDeleteDescription.
  ///
  /// In fr, this message translates to:
  /// **'\"{name}\" sera retirée de ton carnet personnel. Cette action est définitive.'**
  String beerDeleteDescription(String name);

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @beerNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Bière introuvable'**
  String get beerNotFound;

  /// No description provided for @shareMyTasting.
  ///
  /// In fr, this message translates to:
  /// **'Partager ma dégustation'**
  String get shareMyTasting;

  /// No description provided for @beerDeleteFromNotebook.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer de mon carnet'**
  String get beerDeleteFromNotebook;

  /// No description provided for @beerAddedByYou.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutée par toi'**
  String get beerAddedByYou;

  /// No description provided for @beerStyle.
  ///
  /// In fr, this message translates to:
  /// **'Style : {style}'**
  String beerStyle(String style);

  /// No description provided for @photoCredit.
  ///
  /// In fr, this message translates to:
  /// **'Photo : {credit}'**
  String photoCredit(String credit);

  /// No description provided for @freeLicense.
  ///
  /// In fr, this message translates to:
  /// **'licence libre'**
  String get freeLicense;

  /// No description provided for @beerMyReview.
  ///
  /// In fr, this message translates to:
  /// **'Mon avis'**
  String get beerMyReview;

  /// No description provided for @wishlistLabel.
  ///
  /// In fr, this message translates to:
  /// **'À goûter'**
  String get wishlistLabel;

  /// No description provided for @beerTried.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai bu cette bière'**
  String get beerTried;

  /// No description provided for @beerMyRating.
  ///
  /// In fr, this message translates to:
  /// **'Ma note :'**
  String get beerMyRating;

  /// No description provided for @beerClearRating.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la note'**
  String get beerClearRating;

  /// No description provided for @tastedOn.
  ///
  /// In fr, this message translates to:
  /// **'Dégustée le {date}'**
  String tastedOn(String date);

  /// No description provided for @dateUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Date non renseignée'**
  String get dateUnknown;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @tastingNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de dégustation'**
  String get tastingNotes;

  /// No description provided for @tastingNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Arômes, contexte, avec qui...'**
  String get tastingNotesHint;

  /// No description provided for @moderationEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune proposition en attente.'**
  String get moderationEmpty;

  /// No description provided for @moderationPossibleDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Doublon possible : {beers}'**
  String moderationPossibleDuplicate(String beers);

  /// No description provided for @invalidAbv.
  ///
  /// In fr, this message translates to:
  /// **'Degré invalide.'**
  String get invalidAbv;

  /// No description provided for @moderationApproved.
  ///
  /// In fr, this message translates to:
  /// **'Bière ajoutée au catalogue. Pense à renseigner la position de la brasserie si elle est nouvelle.'**
  String get moderationApproved;

  /// No description provided for @submissionRejected.
  ///
  /// In fr, this message translates to:
  /// **'Proposition refusée.'**
  String get submissionRejected;

  /// No description provided for @moderationReview.
  ///
  /// In fr, this message translates to:
  /// **'Relire la proposition'**
  String get moderationReview;

  /// No description provided for @barcodeValue.
  ///
  /// In fr, this message translates to:
  /// **'Code-barres : {barcode}'**
  String barcodeValue(String barcode);

  /// No description provided for @fieldName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get fieldName;

  /// No description provided for @fieldBrewery.
  ///
  /// In fr, this message translates to:
  /// **'Brasserie'**
  String get fieldBrewery;

  /// No description provided for @fieldCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get fieldCountry;

  /// No description provided for @fieldStyle.
  ///
  /// In fr, this message translates to:
  /// **'Style'**
  String get fieldStyle;

  /// No description provided for @fieldAbv.
  ///
  /// In fr, this message translates to:
  /// **'ABV (%)'**
  String get fieldAbv;

  /// No description provided for @fieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// No description provided for @moderationNote.
  ///
  /// In fr, this message translates to:
  /// **'Message à l\'auteur (optionnel)'**
  String get moderationNote;

  /// No description provided for @moderationNoteHelper.
  ///
  /// In fr, this message translates to:
  /// **'Affiché en cas de refus.'**
  String get moderationNoteHelper;

  /// No description provided for @submissionConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Proposer au catalogue ?'**
  String get submissionConfirmTitle;

  /// No description provided for @submissionConfirmDescription.
  ///
  /// In fr, this message translates to:
  /// **'Le nom, la brasserie, le pays, le style, le degré, la description, le code-barres et la photo seront relus par un modérateur. Une fois acceptée, la bière sera visible par tous, et ta dégustation sera rattachée à la fiche commune. Ton pseudo n\'est pas publié.'**
  String get submissionConfirmDescription;

  /// No description provided for @submit.
  ///
  /// In fr, this message translates to:
  /// **'Proposer'**
  String get submit;

  /// No description provided for @submissionThanks.
  ///
  /// In fr, this message translates to:
  /// **'Merci ! Ta proposition sera relue par un modérateur.'**
  String get submissionThanks;

  /// No description provided for @submissionSharedCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue commun'**
  String get submissionSharedCatalog;

  /// No description provided for @submissionSharedCatalogDescription.
  ///
  /// In fr, this message translates to:
  /// **'Cette bière manque au catalogue ? Propose-la pour que tout le monde puisse la retrouver.'**
  String get submissionSharedCatalogDescription;

  /// No description provided for @submissionPending.
  ///
  /// In fr, this message translates to:
  /// **'Proposition en attente'**
  String get submissionPending;

  /// No description provided for @submissionPendingDescription.
  ///
  /// In fr, this message translates to:
  /// **'Un modérateur va relire cette bière.'**
  String get submissionPendingDescription;

  /// No description provided for @submissionApproved.
  ///
  /// In fr, this message translates to:
  /// **'Acceptée au catalogue'**
  String get submissionApproved;

  /// No description provided for @submissionApprovedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ta dégustation sera rattachée à la fiche commune au prochain lancement de l\'app.'**
  String get submissionApprovedDescription;

  /// No description provided for @submissionRejectedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Elle ne correspond pas au catalogue (doublon, informations incomplètes...).'**
  String get submissionRejectedDescription;

  /// No description provided for @submissionSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Proposer au catalogue'**
  String get submissionSubmit;

  /// No description provided for @submissionResubmit.
  ///
  /// In fr, this message translates to:
  /// **'Proposer à nouveau'**
  String get submissionResubmit;

  /// No description provided for @submissionWithdrawn.
  ///
  /// In fr, this message translates to:
  /// **'Proposition retirée.'**
  String get submissionWithdrawn;

  /// No description provided for @submissionWithdraw.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ma proposition'**
  String get submissionWithdraw;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @submissionRejectedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Proposition refusée'**
  String get submissionRejectedTitle;

  /// No description provided for @sharedProfileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Ce profil n\'existe pas ou sa collection n\'est pas partagée avec toi.'**
  String get sharedProfileUnavailable;

  /// No description provided for @sharedProfileTastedStat.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{bue} other{bues}}'**
  String sharedProfileTastedStat(int count);

  /// No description provided for @sharedProfileInCommon.
  ///
  /// In fr, this message translates to:
  /// **'en commun'**
  String get sharedProfileInCommon;

  /// No description provided for @sharedProfilePreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de ce que voient les autres ({visibility}).'**
  String sharedProfilePreview(String visibility);

  /// No description provided for @tastedSection.
  ///
  /// In fr, this message translates to:
  /// **'Bues'**
  String get tastedSection;

  /// No description provided for @noBeersYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune bière pour l\'instant.'**
  String get noBeersYet;

  /// No description provided for @colorStraw.
  ///
  /// In fr, this message translates to:
  /// **'Paille'**
  String get colorStraw;

  /// No description provided for @colorGolden.
  ///
  /// In fr, this message translates to:
  /// **'Dorée'**
  String get colorGolden;

  /// No description provided for @colorAmber.
  ///
  /// In fr, this message translates to:
  /// **'Ambrée'**
  String get colorAmber;

  /// No description provided for @colorBrown.
  ///
  /// In fr, this message translates to:
  /// **'Brune'**
  String get colorBrown;

  /// No description provided for @colorBlack.
  ///
  /// In fr, this message translates to:
  /// **'Noire'**
  String get colorBlack;

  /// No description provided for @tastingProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche de dégustation'**
  String get tastingProfileTitle;

  /// No description provided for @tastingProfileHint.
  ///
  /// In fr, this message translates to:
  /// **'Touche un niveau pour le choisir, retouche-le pour l\'effacer.'**
  String get tastingProfileHint;

  /// No description provided for @criterionBitterness.
  ///
  /// In fr, this message translates to:
  /// **'Amertume'**
  String get criterionBitterness;

  /// No description provided for @bitternessLow.
  ///
  /// In fr, this message translates to:
  /// **'Légère'**
  String get bitternessLow;

  /// No description provided for @bitternessHigh.
  ///
  /// In fr, this message translates to:
  /// **'Intense'**
  String get bitternessHigh;

  /// No description provided for @criterionSweetness.
  ///
  /// In fr, this message translates to:
  /// **'Douceur'**
  String get criterionSweetness;

  /// No description provided for @sweetnessLow.
  ///
  /// In fr, this message translates to:
  /// **'Sèche'**
  String get sweetnessLow;

  /// No description provided for @sweetnessHigh.
  ///
  /// In fr, this message translates to:
  /// **'Sucrée'**
  String get sweetnessHigh;

  /// No description provided for @criterionBody.
  ///
  /// In fr, this message translates to:
  /// **'Corps'**
  String get criterionBody;

  /// No description provided for @bodyLow.
  ///
  /// In fr, this message translates to:
  /// **'Léger'**
  String get bodyLow;

  /// No description provided for @bodyHigh.
  ///
  /// In fr, this message translates to:
  /// **'Rond'**
  String get bodyHigh;

  /// No description provided for @aromas.
  ///
  /// In fr, this message translates to:
  /// **'Arômes'**
  String get aromas;

  /// No description provided for @compareWithAnother.
  ///
  /// In fr, this message translates to:
  /// **'Comparer avec une autre bière'**
  String get compareWithAnother;

  /// No description provided for @levelOutOfFive.
  ///
  /// In fr, this message translates to:
  /// **'{criterion} {level} sur 5'**
  String levelOutOfFive(String criterion, int level);

  /// No description provided for @criterionColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get criterionColor;

  /// No description provided for @sortRelevance.
  ///
  /// In fr, this message translates to:
  /// **'Pertinence'**
  String get sortRelevance;

  /// No description provided for @sortNameAsc.
  ///
  /// In fr, this message translates to:
  /// **'Nom (A→Z)'**
  String get sortNameAsc;

  /// No description provided for @sortAbvAsc.
  ///
  /// In fr, this message translates to:
  /// **'ABV croissant'**
  String get sortAbvAsc;

  /// No description provided for @sortAbvDesc.
  ///
  /// In fr, this message translates to:
  /// **'ABV décroissant'**
  String get sortAbvDesc;

  /// No description provided for @filterAndSort.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer et trier'**
  String get filterAndSort;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Cherche une bière, une brasserie, un style ou un pays'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResults;

  /// No description provided for @reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reset;

  /// No description provided for @sortBy.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get sortBy;

  /// No description provided for @family.
  ///
  /// In fr, this message translates to:
  /// **'Famille'**
  String get family;

  /// No description provided for @apply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// No description provided for @collectionEmptyTasted.
  ///
  /// In fr, this message translates to:
  /// **'Aucune bière essayée pour l\'instant.\nOuvre une bière et coche \"J\'ai bu cette bière\" pour commencer ta collection.'**
  String get collectionEmptyTasted;

  /// No description provided for @collectionEmptyWishlist.
  ///
  /// In fr, this message translates to:
  /// **'Aucune bière à goûter pour l\'instant.\nOuvre une bière et coche \"À goûter\" pour la garder sous le coude.'**
  String get collectionEmptyWishlist;

  /// No description provided for @collectionProgress.
  ///
  /// In fr, this message translates to:
  /// **'{count} / {total} bières essayées'**
  String collectionProgress(int count, int total);

  /// No description provided for @collectionAverageRating.
  ///
  /// In fr, this message translates to:
  /// **'Note moyenne donnée : {average} / 5'**
  String collectionAverageRating(String average);

  /// No description provided for @collectionLastTasting.
  ///
  /// In fr, this message translates to:
  /// **'Dernière dégustation : {beer}'**
  String collectionLastTasting(String beer);

  /// No description provided for @collectionStatsButton.
  ///
  /// In fr, this message translates to:
  /// **'Mes statistiques et recommandations'**
  String get collectionStatsButton;

  /// No description provided for @addBeerChooseStyle.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un style de bière.'**
  String get addBeerChooseStyle;

  /// No description provided for @addBeerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une bière'**
  String get addBeerTitle;

  /// No description provided for @addBeerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la bière'**
  String get addBeerName;

  /// No description provided for @required.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get required;

  /// No description provided for @fieldDescriptionOptional.
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnel)'**
  String get fieldDescriptionOptional;

  /// No description provided for @addBeerSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à mon carnet'**
  String get addBeerSubmit;

  /// No description provided for @addBeerPrivateNotice.
  ///
  /// In fr, this message translates to:
  /// **'Cette bière n\'est visible que dans ton carnet. Tu pourras ensuite la proposer au catalogue commun depuis sa fiche.'**
  String get addBeerPrivateNotice;

  /// No description provided for @emailAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get hidePassword;

  /// No description provided for @emailCode.
  ///
  /// In fr, this message translates to:
  /// **'Code reçu par e-mail'**
  String get emailCode;

  /// No description provided for @resendCodeWait.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code ({seconds} s)'**
  String resendCodeWait(int seconds);

  /// No description provided for @resendCode.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get resendCode;

  /// No description provided for @or.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continueWithGoogle;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux mots de passe ne correspondent pas.'**
  String get passwordsDoNotMatch;

  /// No description provided for @signUpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Crée ton compte pour sauvegarder ta collection et la retrouver sur tous tes appareils.'**
  String get signUpSubtitle;

  /// No description provided for @signUpCodeSent.
  ///
  /// In fr, this message translates to:
  /// **'Si l\'adresse {email} n\'est pas déjà inscrite, un code à {length} chiffres vient d\'y être envoyé pour la confirmer.'**
  String signUpCodeSent(String email, int length);

  /// No description provided for @passwordHelper.
  ///
  /// In fr, this message translates to:
  /// **'Au moins {min} caractères, avec des lettres et des chiffres.'**
  String passwordHelper(int min);

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @signUpSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get signUpSubmit;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @confirmEmail.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer mon adresse'**
  String get confirmEmail;

  /// No description provided for @changeEmail.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'adresse'**
  String get changeEmail;

  /// No description provided for @passwordResetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Indique l\'adresse de ton compte : tu y recevras un code pour choisir un nouveau mot de passe.'**
  String get passwordResetSubtitle;

  /// No description provided for @passwordResetCodeSent.
  ///
  /// In fr, this message translates to:
  /// **'Si un compte existe pour {email}, un code à {length} chiffres vient d\'y être envoyé.'**
  String passwordResetCodeSent(String email, int length);

  /// No description provided for @getCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir un code'**
  String get getCode;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi pour retrouver ta collection sur tous tes appareils.'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @noAccountYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccountYet;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @ageGateRefused.
  ///
  /// In fr, this message translates to:
  /// **'Le Bierodex est réservé aux personnes ayant l\'âge légal de consommer de l\'alcool. Reviens nous voir dans quelques années !'**
  String get ageGateRefused;

  /// No description provided for @ageGateQuestion.
  ///
  /// In fr, this message translates to:
  /// **'As-tu {age} ans ou plus ?'**
  String ageGateQuestion(int age);

  /// No description provided for @ageGateNotice.
  ///
  /// In fr, this message translates to:
  /// **'Cette application présente des boissons alcoolisées. Elle est réservée aux personnes majeures.'**
  String get ageGateNotice;

  /// No description provided for @ageGateYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui, j\'ai {age} ans ou plus'**
  String ageGateYes(int age);

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @shareCardFileName.
  ///
  /// In fr, this message translates to:
  /// **'bierodex-degustation.png'**
  String get shareCardFileName;

  /// No description provided for @shareCardText.
  ///
  /// In fr, this message translates to:
  /// **'{beer} · via le Bierodex'**
  String shareCardText(String beer);

  /// No description provided for @shareFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le partage n\'a pas pu s\'ouvrir.'**
  String get shareFailed;

  /// No description provided for @shareCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte de dégustation'**
  String get shareCardTitle;

  /// No description provided for @shareCardShowUsername.
  ///
  /// In fr, this message translates to:
  /// **'Afficher mon pseudo'**
  String get shareCardShowUsername;

  /// No description provided for @shareCardPrivacyNotice.
  ///
  /// In fr, this message translates to:
  /// **'Seules la note et les arômes cochés apparaissent : tes notes écrites et ta photo restent privées.'**
  String get shareCardPrivacyNotice;

  /// No description provided for @preparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation...'**
  String get preparing;

  /// No description provided for @shareImage.
  ///
  /// In fr, this message translates to:
  /// **'Partager l\'image'**
  String get shareImage;

  /// No description provided for @tasted.
  ///
  /// In fr, this message translates to:
  /// **'Dégustée'**
  String get tasted;

  /// No description provided for @compare.
  ///
  /// In fr, this message translates to:
  /// **'Comparer'**
  String get compare;

  /// No description provided for @compareEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Remplis la fiche de dégustation d\'une autre bière pour la comparer à celle-ci.'**
  String get compareEmpty;

  /// No description provided for @compareWith.
  ///
  /// In fr, this message translates to:
  /// **'Comparer avec'**
  String get compareWith;

  /// No description provided for @commonAromas.
  ///
  /// In fr, this message translates to:
  /// **'Arômes en commun'**
  String get commonAromas;

  /// No description provided for @noCommonAromas.
  ///
  /// In fr, this message translates to:
  /// **'Aucun arôme en commun.'**
  String get noCommonAromas;

  /// No description provided for @criterionRating.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get criterionRating;

  /// No description provided for @notSet.
  ///
  /// In fr, this message translates to:
  /// **'non renseigné'**
  String get notSet;

  /// No description provided for @photoSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'La photo n\'a pas pu être enregistrée. Vérifie ta connexion et l\'accès à l\'appareil photo.'**
  String get photoSaveFailed;

  /// No description provided for @photoDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo ?'**
  String get photoDeleteTitle;

  /// No description provided for @myPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ma photo'**
  String get myPhoto;

  /// No description provided for @photoPrivate.
  ///
  /// In fr, this message translates to:
  /// **'Visible par toi seul.'**
  String get photoPrivate;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get chooseFromGallery;

  /// No description provided for @deletePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get deletePhoto;

  /// No description provided for @photoUnavailableRetry.
  ///
  /// In fr, this message translates to:
  /// **'Photo indisponible · Réessayer'**
  String get photoUnavailableRetry;

  /// No description provided for @breweryCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune brasserie} =1{1 brasserie} other{{count} brasseries}}'**
  String breweryCount(int count);

  /// No description provided for @noBreweryLocated.
  ///
  /// In fr, this message translates to:
  /// **'Aucune brasserie localisée pour {country}.'**
  String noBreweryLocated(String country);

  /// No description provided for @styleNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Style introuvable'**
  String get styleNotFound;

  /// No description provided for @styleOrigin.
  ///
  /// In fr, this message translates to:
  /// **'Origine : {origin}'**
  String styleOrigin(String origin);

  /// No description provided for @styleExamples.
  ///
  /// In fr, this message translates to:
  /// **'Exemples de bières'**
  String get styleExamples;

  /// No description provided for @styleNoExamples.
  ///
  /// In fr, this message translates to:
  /// **'Aucun exemple pour ce style pour le moment.'**
  String get styleNoExamples;

  /// No description provided for @torch.
  ///
  /// In fr, this message translates to:
  /// **'Lampe torche'**
  String get torch;

  /// No description provided for @scannerHint.
  ///
  /// In fr, this message translates to:
  /// **'Vise le code-barres de l\'étiquette'**
  String get scannerHint;

  /// No description provided for @achievementUnlockedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Badge débloqué'**
  String get achievementUnlockedTitle;

  /// No description provided for @cheers.
  ///
  /// In fr, this message translates to:
  /// **'Santé !'**
  String get cheers;

  /// No description provided for @healthNotice.
  ///
  /// In fr, this message translates to:
  /// **'L\'abus d\'alcool est dangereux pour la santé. À consommer avec modération.'**
  String get healthNotice;

  /// No description provided for @abvValue.
  ///
  /// In fr, this message translates to:
  /// **'ABV : {value}'**
  String abvValue(String value);
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
