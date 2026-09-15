// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String authPasswordTooShort(int min) {
    return 'Le mot de passe doit faire au moins $min caractères.';
  }

  @override
  String get authPasswordTooLong => 'Le mot de passe est trop long.';

  @override
  String get authPasswordNeedsLettersAndDigits =>
      'Le mot de passe doit contenir des lettres et des chiffres.';

  @override
  String get authInvalidEmail => 'Adresse e-mail invalide.';

  @override
  String get errorServerUnreachable =>
      'Impossible de contacter le serveur. Vérifie ta connexion internet.';

  @override
  String get authEnterPassword => 'Saisis ton mot de passe.';

  @override
  String get authInvalidCredentials => 'E-mail ou mot de passe incorrect.';

  @override
  String get authWeakPasswordChooseAnother =>
      'Ce mot de passe est trop faible ou a déjà fuité ailleurs. Choisis-en un autre.';

  @override
  String get authUserAlreadyExists =>
      'Un compte existe déjà avec cette adresse. Connecte-toi.';

  @override
  String get authWeakPassword =>
      'Ce mot de passe est trop faible ou a déjà fuité ailleurs.';

  @override
  String get authSamePassword =>
      'Choisis un mot de passe différent de l\'ancien.';

  @override
  String authResendWait(int seconds) {
    return 'Patiente $seconds s avant de redemander un code.';
  }

  @override
  String get authTooManyCodeAttempts =>
      'Trop de tentatives. Demande un nouveau code.';

  @override
  String authCodeLength(int length) {
    return 'Le code contient $length chiffres.';
  }

  @override
  String get authGoogleUnavailable =>
      'Connexion Google impossible pour le moment.';

  @override
  String get authGoogleCannotOpen =>
      'Impossible d\'ouvrir la connexion Google. Vérifie ta connexion internet.';

  @override
  String get authDeleteFailed =>
      'La suppression a échoué. Réessaie plus tard ; tes données sont intactes.';

  @override
  String get authRateLimited =>
      'Trop de tentatives. Réessaie dans quelques minutes.';

  @override
  String get authInvalidCode => 'Code invalide ou expiré.';

  @override
  String get authSignInUnavailable =>
      'Connexion impossible pour le moment. Réessaie plus tard.';

  @override
  String get authEmailNotConfirmed =>
      'Confirme d\'abord ton adresse e-mail avec le code reçu.';

  @override
  String usernameLength(int min, int max) {
    return 'Entre $min et $max caractères.';
  }

  @override
  String get usernameCharacters =>
      'Lettres minuscules, chiffres et _ uniquement.';

  @override
  String get errorSignInRequired => 'Connexion requise.';

  @override
  String get displayNameTooLong => 'Le nom affiché est trop long.';

  @override
  String get socialUsernameTaken => 'Ce pseudo est déjà pris.';

  @override
  String get socialInvalidProfile => 'Pseudo ou nom affiché invalide.';

  @override
  String get socialProfileRequired => 'Choisis d\'abord ton pseudo.';

  @override
  String get socialProfileNotFound => 'Aucun profil ne porte ce pseudo.';

  @override
  String get socialCannotAddSelf => 'C\'est ton propre pseudo.';

  @override
  String get socialTooManyRequests =>
      'Trop de demandes en attente. Réessaie plus tard.';

  @override
  String get socialRequestNotFound => 'Cette demande n\'existe plus.';

  @override
  String get errorGeneric => 'Une erreur est survenue. Réessaie plus tard.';

  @override
  String get submissionAlreadySubmitted => 'Cette bière a déjà été proposée.';

  @override
  String get submissionAlreadyInCatalog =>
      'Une bière avec ce code-barres existe déjà dans le catalogue.';

  @override
  String get submissionTooMany =>
      'Tu as déjà beaucoup de propositions en attente.';

  @override
  String get submissionBeerNotSynced =>
      'Cette bière n\'est pas encore synchronisée. Réessaie dans un instant.';

  @override
  String get submissionNotModerator => 'Action réservée aux modérateurs.';

  @override
  String get submissionAlreadyReviewed =>
      'Cette proposition a déjà été traitée.';

  @override
  String get familyAle => 'Fermentation haute (Ale)';

  @override
  String get familyLager => 'Fermentation basse (Lager)';

  @override
  String get familySpontaneous => 'Fermentation spontanée';

  @override
  String get familyMixed => 'Fermentation mixte';

  @override
  String get familySpontaneousShort => 'Spontanée';

  @override
  String get familyMixedShort => 'Mixte';

  @override
  String get visibilityPrivate => 'Privé';

  @override
  String get visibilityFriends => 'Amis';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityPrivateDescription => 'Personne d\'autre que toi.';

  @override
  String get visibilityFriendsDescription => 'Tes amis acceptés uniquement.';

  @override
  String get visibilityPublicDescription =>
      'Toute personne ayant le lien, même sans compte.';

  @override
  String get aromaAgrumes => 'Agrumes';

  @override
  String get aromaFruitsRouges => 'Fruits rouges';

  @override
  String get aromaFruitsExotiques => 'Fruits exotiques';

  @override
  String get aromaFloral => 'Floral';

  @override
  String get aromaHerbace => 'Herbacé';

  @override
  String get aromaResineux => 'Résineux';

  @override
  String get aromaEpices => 'Épices';

  @override
  String get aromaBananeClou => 'Banane / clou de girofle';

  @override
  String get aromaMiel => 'Miel';

  @override
  String get aromaBiscuit => 'Biscuit / céréale';

  @override
  String get aromaCaramel => 'Caramel';

  @override
  String get aromaTorrefie => 'Torréfié';

  @override
  String get aromaChocolat => 'Chocolat';

  @override
  String get aromaCafe => 'Café';

  @override
  String get aromaBoise => 'Boisé';

  @override
  String get aromaAcidule => 'Acidulé';

  @override
  String get aromaFunky => 'Funky / Brett';

  @override
  String get achievementFirstTastingTitle => 'Première gorgée';

  @override
  String get achievementFirstTastingDescription =>
      'Déguster une première bière.';

  @override
  String get achievementTasted10Title => 'Carnet entamé';

  @override
  String get achievementTasted10Description => 'Déguster 10 bières.';

  @override
  String get achievementTasted25Title => 'Amateur éclairé';

  @override
  String get achievementTasted25Description => 'Déguster 25 bières.';

  @override
  String get achievementTasted50Title => 'Connaisseur';

  @override
  String get achievementTasted50Description => 'Déguster 50 bières.';

  @override
  String get achievementStyles10Title => 'Palette de styles';

  @override
  String get achievementStyles10Description => 'Goûter 10 styles différents.';

  @override
  String get achievementEuropeTourTitle => 'Tour d\'Europe';

  @override
  String get achievementEuropeTourDescription =>
      'Goûter des bières de 10 pays européens.';

  @override
  String get achievementWorldTourTitle => 'Tour du monde';

  @override
  String get achievementWorldTourDescription =>
      'Goûter des bières des 5 continents.';

  @override
  String get achievementSpontaneousTitle =>
      'Explorateur des fermentations spontanées';

  @override
  String get achievementSpontaneousDescription =>
      'Déguster 3 bières à fermentation spontanée (lambic, gueuze, kriek...).';

  @override
  String get achievementFourFamiliesTitle => 'Les quatre fermentations';

  @override
  String get achievementFourFamiliesDescription =>
      'Goûter au moins une bière de chaque famille.';

  @override
  String get achievementStreak3Title => 'Régulier';

  @override
  String get achievementStreak3Description =>
      'Au moins une dégustation 3 mois d\'affilée.';

  @override
  String get achievementStreak6Title => 'Fidèle au carnet';

  @override
  String get achievementStreak6Description =>
      'Au moins une dégustation 6 mois d\'affilée.';

  @override
  String get achievementDetailed5Title => 'Palais aiguisé';

  @override
  String get achievementDetailed5Description =>
      'Remplir 5 fiches de dégustation détaillées.';

  @override
  String get achievementPhotos5Title => 'Photographe';

  @override
  String get achievementPhotos5Description => 'Photographier 5 dégustations.';

  @override
  String recommendationLikedStyle(String style, String average) {
    return 'Tu as aimé tes $style ($average/5)';
  }

  @override
  String recommendationLikedFamily(String family, String style) {
    return 'Tu apprécies la $family : découvre le style $style';
  }

  @override
  String get reminderInactivityTitle => 'Une petite soif ?';

  @override
  String reminderInactivityBody(int days) {
    return 'Ça fait $days jours que tu n\'as rien goûté. Une nouvelle bière à découvrir ?';
  }

  @override
  String get reminderWishlistTitle => 'Ta wishlist t\'attend';

  @override
  String reminderWishlistBody(String beer, String brewery) {
    return 'Toujours envie de goûter $beer ($brewery) ?';
  }

  @override
  String get reminderChannelName => 'Rappels';

  @override
  String get reminderChannelDescription =>
      'Rappels de dégustation et de wishlist';

  @override
  String get catalogLoading => 'Chargement du catalogue...';

  @override
  String get catalogLoadError => 'Impossible de charger le catalogue.';

  @override
  String get checkInternetConnection => 'Vérifie ta connexion internet.';

  @override
  String get retry => 'Réessayer';

  @override
  String get accountTitle => 'Mon compte';

  @override
  String get accountSignedIn => 'Connecté';

  @override
  String get accountSyncedDescription =>
      'Ta collection (bières bues et notées) est synchronisée avec ce compte et accessible depuis n\'importe quel appareil.';

  @override
  String accountPendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications en attente',
      one: '1 modification en attente',
    );
    return '$_temp0';
  }

  @override
  String get accountPendingChangesDescription =>
      'Enregistrées sur cet appareil, elles seront envoyées dès le retour de la connexion.';

  @override
  String get retryNow => 'Réessayer maintenant';

  @override
  String get reminderInactivitySetting => 'Rappel de dégustation';

  @override
  String get reminderInactivitySettingDescription =>
      'Si tu n\'as rien goûté depuis un mois';

  @override
  String get reminderWishlistSetting => 'Rappel de wishlist';

  @override
  String get reminderWishlistSettingDescription =>
      'Une bière à goûter, toutes les deux semaines';

  @override
  String get accountFriendsAndProfile => 'Amis et profil';

  @override
  String get accountFriendsAndProfileDescription =>
      'Pseudo, amis, lien de profil public';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutEverywhere => 'Se déconnecter de tous les appareils';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get deleteAccount => 'Supprimer mon compte';

  @override
  String get deleteAccountDescription =>
      'Efface définitivement toutes tes données.';

  @override
  String get moderationTitle => 'Modération';

  @override
  String get moderationDescription => 'Bières proposées par la communauté';

  @override
  String get signOutEverywhereTitle => 'Tous les appareils ?';

  @override
  String get signOutEverywhereDescription =>
      'Toutes les sessions ouvertes avec ce compte (téléphone, tablette, navigateur...) seront fermées. À faire en cas de perte ou de vol d\'un appareil.';

  @override
  String get cancel => 'Annuler';

  @override
  String get signOutEverywhereConfirm => 'Tout déconnecter';

  @override
  String get deleteAccountInProgress => 'Suppression en cours...';

  @override
  String get deleteAccountDone => 'Ton compte a été supprimé.';

  @override
  String get deleteAccountTitle => 'Supprimer ton compte ?';

  @override
  String get deleteAccountWarning =>
      'Ta collection, tes notes, tes commentaires et les bières que tu as ajoutées seront effacés définitivement, sur tous tes appareils. Cette action est irréversible.';

  @override
  String deleteAccountTypeToConfirm(String word) {
    return 'Tape $word pour confirmer :';
  }

  @override
  String get deleteAccountConfirm => 'Supprimer définitivement';

  @override
  String get deleteAccountConfirmationWord => 'SUPPRIMER';

  @override
  String get privacyWhoTitle => 'Qui est responsable ?';

  @override
  String privacyWhoParagraph1(String publisher, String contact) {
    return 'Le Bierodex est édité par $publisher, responsable du traitement de tes données. Contact : $contact.';
  }

  @override
  String get privacyDataTitle => 'Données collectées';

  @override
  String get privacyDataParagraph1 =>
      'Compte : ton adresse e-mail, ton mot de passe (conservé uniquement sous forme hachée, illisible même pour nous) et un identifiant technique. Si tu te connectes avec Google, Google nous transmet aussi ton nom et ta photo de profil ; nous ne recevons jamais ton mot de passe Google.';

  @override
  String get privacyDataParagraph2 =>
      'Collection : les bières marquées comme bues ou à goûter, tes notes, dates de dégustation, commentaires et fiches de dégustation (couleur, amertume, douceur, corps, arômes), ainsi que les bières que tu ajoutes toi-même (nom, brasserie, code-barres, photo).';

  @override
  String get privacyDataParagraph3 =>
      'Profil et amis (facultatifs) : ton pseudo, un nom affiché si tu en choisis un, la visibilité de ta collection et la liste de tes amis et demandes d\'amis.';

  @override
  String get privacyDataParagraph4 =>
      'Photos de dégustation : uniquement celles que tu choisis de prendre ou d\'importer. Elles sont stockées dans un espace privé accessible à ton seul compte, jamais publiées. Si ton appareil enregistre la position dans ses photos, cette information peut rester dans le fichier : l\'app ne la lit ni ne l\'exploite.';

  @override
  String get privacyDataParagraph5 =>
      'Aucune localisation collectée par l\'app, aucun contact, aucune publicité, aucun traceur publicitaire.';

  @override
  String get privacyWhyTitle => 'Pourquoi ?';

  @override
  String get privacyWhyParagraph1 =>
      'Uniquement pour faire fonctionner l\'app : te connecter et synchroniser ta collection entre tes appareils (base légale : exécution du service que tu demandes). Tes données ne sont ni vendues, ni partagées à des fins commerciales.';

  @override
  String get privacySharingTitle => 'Partage et communauté';

  @override
  String get privacySharingParagraph1 =>
      'Par défaut, ta collection est privée. Si tu rends ton profil visible par tes amis ou public, les personnes concernées (ou toute personne ayant ton lien, pour un profil public) voient ton pseudo, ton nom affiché, les bières bues et à goûter, leur note sur 5 et leur date. Jamais tes notes écrites, fiches de dégustation, photos ni ton adresse e-mail. Tu peux revenir en privé à tout moment.';

  @override
  String get privacySharingParagraph2 =>
      'Tes amis voient ton pseudo et ton nom affiché, même si ta collection est privée.';

  @override
  String get privacySharingParagraph3 =>
      'Proposer une bière au catalogue commun transmet ses informations (nom, brasserie, pays, style, degré, description, code-barres, photo) à un modérateur. Une fois acceptée, elle devient publique, sans mention de ton compte.';

  @override
  String get privacySharingParagraph4 =>
      'Les cartes de dégustation sont générées sur ton appareil : elles ne sont partagées que si tu choisis de les envoyer.';

  @override
  String get privacyStorageTitle => 'Où sont-elles stockées ?';

  @override
  String privacyStorageParagraph1(String region) {
    return 'Chez Supabase (hébergement $region), avec un accès limité à ton seul compte (sauf ce que tu choisis de partager, voir ci-dessus). Une copie est gardée sur ton appareil pour un usage hors-ligne ; la session de connexion y est chiffrée par le système (Keychain / Keystore). Les modifications faites hors-ligne y attendent le retour du réseau avant d\'être envoyées.';
  }

  @override
  String get privacyThirdPartiesTitle => 'Services tiers';

  @override
  String get privacyThirdPartiesParagraph1 =>
      'Open Food Facts : quand tu scannes un code-barres inconnu, ce code est envoyé à Open Food Facts pour retrouver le produit.';

  @override
  String get privacyThirdPartiesParagraph2 =>
      'OpenStreetMap et Wikimedia Commons : fonds de carte et photos, chargés directement depuis leurs serveurs (ton adresse IP leur est donc visible).';

  @override
  String get privacyThirdPartiesParagraph3 =>
      'Google : uniquement si tu choisis \"Continuer avec Google\".';

  @override
  String get privacyThirdPartiesParagraph4 =>
      'Sentry : en cas de plantage, un rapport technique (message d\'erreur, modèle d\'appareil, version du système et de l\'app) est envoyé pour corriger le problème. Il ne contient ni ton adresse e-mail, ni ton identifiant, ni ton adresse IP, ni le contenu de ta collection (base légale : intérêt légitime à faire fonctionner l\'app).';

  @override
  String get privacyThirdPartiesParagraph5 =>
      'Les rappels (notifications) sont programmés sur ton appareil, sans aucun serveur. Tu peux les couper dans \"Mon compte\".';

  @override
  String get privacyRetentionTitle => 'Durée de conservation';

  @override
  String get privacyRetentionParagraph1 =>
      'Tant que ton compte existe. La suppression du compte efface immédiatement et définitivement toutes tes données de nos serveurs et de l\'appareil utilisé (profil, amis et propositions compris). Les bières déjà acceptées au catalogue commun, qui ne contiennent aucune donnée personnelle, y restent.';

  @override
  String get privacyRightsTitle => 'Tes droits';

  @override
  String privacyRightsParagraph1(String contact) {
    return 'Tu peux accéder à tes données, les corriger, les exporter ou demander leur suppression, et t\'opposer à leur traitement. La suppression est disponible directement dans \"Mon compte\" ; pour le reste, écris à $contact.';
  }

  @override
  String get privacyRightsParagraph2 =>
      'Tu peux aussi introduire une réclamation auprès de la CNIL (www.cnil.fr).';

  @override
  String get privacyAgeTitle => 'Âge';

  @override
  String get privacyAgeParagraph1 =>
      'L\'app présente des boissons alcoolisées et est réservée aux personnes majeures.';

  @override
  String privacyLastUpdated(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get privacyScreenTitle => 'Confidentialité';

  @override
  String get socialReceivedRequests => 'Demandes reçues';

  @override
  String get socialMyFriends => 'Mes amis';

  @override
  String get socialSentRequests => 'Demandes envoyées';

  @override
  String get socialNoFriends =>
      'Pas encore d\'amis. Ajoute-les avec leur pseudo.';

  @override
  String get socialShareSubject => 'Ma collection sur le Bierodex';

  @override
  String get socialCreateProfile => 'Crée ton profil';

  @override
  String get socialCreateProfileDescription =>
      'Choisis un pseudo pour ajouter des amis et, si tu le souhaites, partager ta collection. Ton profil reste privé tant que tu ne changes pas sa visibilité.';

  @override
  String get socialChooseUsername => 'Choisir mon pseudo';

  @override
  String get socialEditProfile => 'Modifier le profil';

  @override
  String socialCollectionVisibility(String visibility, String description) {
    return 'Collection : $visibility · $description';
  }

  @override
  String get socialViewAsOthers => 'Voir comme les autres';

  @override
  String get socialShareLink => 'Partager le lien';

  @override
  String get copy => 'Copier';

  @override
  String get socialLinkCopied => 'Lien copié.';

  @override
  String get socialMyProfile => 'Mon profil';

  @override
  String get socialUsername => 'Pseudo';

  @override
  String get socialUsernameHelper =>
      'Visible par tes amis et dans ton lien public.';

  @override
  String get socialDisplayNameOptional => 'Nom affiché (optionnel)';

  @override
  String get socialWhoCanSee => 'Qui peut voir ma collection ?';

  @override
  String get socialSharedDataNotice =>
      'Sont partagés : bières bues et à goûter, notes sur 5 et dates. Jamais tes notes écrites, fiches de dégustation, photos ni ton adresse e-mail.';

  @override
  String get saving => 'Enregistrement...';

  @override
  String get save => 'Enregistrer';

  @override
  String socialNowFriends(String username) {
    return 'Vous êtes maintenant amis avec @$username.';
  }

  @override
  String socialRequestSent(String username) {
    return 'Demande envoyée à @$username.';
  }

  @override
  String get socialAddFriend => 'Ajouter un ami';

  @override
  String get socialAddFriendHint => 'Son pseudo exact';

  @override
  String get socialSendRequest => 'Envoyer la demande';

  @override
  String socialRemoveFriendTitle(String name) {
    return 'Retirer $name ?';
  }

  @override
  String get socialRemoveFriendDescription =>
      'Vous ne verrez plus vos collections respectives si elles sont réservées aux amis.';

  @override
  String get remove => 'Retirer';

  @override
  String get socialRemoveFriend => 'Retirer cet ami';

  @override
  String get decline => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get statsTitle => 'Mes statistiques';

  @override
  String get statsEmpty =>
      'Marque tes premières bières comme bues pour voir tes statistiques prendre forme.';

  @override
  String get statsByMonth => 'Dégustations par mois';

  @override
  String get statsLast12Months => '12 derniers mois';

  @override
  String get statsByFamily => 'Par famille de fermentation';

  @override
  String get statsByStyle => 'Par style';

  @override
  String get statsAverageByStyle => 'Note moyenne par style';

  @override
  String get statsCountries => 'Pays goûtés';

  @override
  String get statsCountriesHint =>
      'Plus le cercle est grand et foncé, plus tu as goûté de bières de ce pays.';

  @override
  String get statsForYou => 'Pour toi';

  @override
  String get statsForYouHint => 'D\'après tes styles les mieux notés.';

  @override
  String get statsBadges => 'Badges';

  @override
  String statsTileBeers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bières',
      one: 'bière',
    );
    return '$_temp0';
  }

  @override
  String statsTileStyles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'styles',
      one: 'style',
    );
    return '$_temp0';
  }

  @override
  String statsTileCountries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pays',
      one: 'pays',
    );
    return '$_temp0';
  }

  @override
  String get statsTileAverage => 'note moy.';

  @override
  String get showLess => 'Voir moins';

  @override
  String showAll(int count) {
    return 'Voir tout ($count)';
  }

  @override
  String statsMonthTooltip(String month, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dégustations',
      one: '1 dégustation',
      zero: 'aucune dégustation',
    );
    return '$month : $_temp0';
  }

  @override
  String get statsNoRecommendations =>
      'Note quelques bières (au moins 4 étoiles) pour recevoir des suggestions.';

  @override
  String get achievementUnlocked => 'Débloqué';

  @override
  String get stylesTitle => 'Styles de bières';

  @override
  String get collectionTitle => 'Ma collection';

  @override
  String get search => 'Rechercher';

  @override
  String get scanBeer => 'Scanner une bière';

  @override
  String get styles => 'Styles';

  @override
  String get navMap => 'Carte';

  @override
  String get navCollection => 'Collection';

  @override
  String get navScan => 'Scanner';

  @override
  String get navProfile => 'Profil';

  @override
  String get searchBeerHint => 'Rechercher une bière, une brasserie…';

  @override
  String get beerDeleteTitle => 'Supprimer cette bière ?';

  @override
  String beerDeleteDescription(String name) {
    return '\"$name\" sera retirée de ton carnet personnel. Cette action est définitive.';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get beerNotFound => 'Bière introuvable';

  @override
  String get shareMyTasting => 'Partager ma dégustation';

  @override
  String get beerDeleteFromNotebook => 'Supprimer de mon carnet';

  @override
  String get beerAddedByYou => 'Ajoutée par toi';

  @override
  String beerStyle(String style) {
    return 'Style : $style';
  }

  @override
  String photoCredit(String credit) {
    return 'Photo : $credit';
  }

  @override
  String get freeLicense => 'licence libre';

  @override
  String get beerMyReview => 'Mon avis';

  @override
  String get wishlistLabel => 'À goûter';

  @override
  String get beerTried => 'J\'ai bu cette bière';

  @override
  String get beerMyRating => 'Ma note :';

  @override
  String get beerClearRating => 'Effacer la note';

  @override
  String tastedOn(String date) {
    return 'Dégustée le $date';
  }

  @override
  String get dateUnknown => 'Date non renseignée';

  @override
  String get edit => 'Modifier';

  @override
  String get tastingNotes => 'Notes de dégustation';

  @override
  String get tastingNotesHint => 'Arômes, contexte, avec qui...';

  @override
  String get moderationEmpty => 'Aucune proposition en attente.';

  @override
  String moderationPossibleDuplicate(String beers) {
    return 'Doublon possible : $beers';
  }

  @override
  String get invalidAbv => 'Degré invalide.';

  @override
  String get moderationApproved =>
      'Bière ajoutée au catalogue. Pense à renseigner la position de la brasserie si elle est nouvelle.';

  @override
  String get submissionRejected => 'Proposition refusée.';

  @override
  String get moderationReview => 'Relire la proposition';

  @override
  String barcodeValue(String barcode) {
    return 'Code-barres : $barcode';
  }

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldBrewery => 'Brasserie';

  @override
  String get fieldCountry => 'Pays';

  @override
  String get fieldStyle => 'Style';

  @override
  String get fieldAbv => 'ABV (%)';

  @override
  String get fieldDescription => 'Description';

  @override
  String get moderationNote => 'Message à l\'auteur (optionnel)';

  @override
  String get moderationNoteHelper => 'Affiché en cas de refus.';

  @override
  String get submissionConfirmTitle => 'Proposer au catalogue ?';

  @override
  String get submissionConfirmDescription =>
      'Le nom, la brasserie, le pays, le style, le degré, la description, le code-barres et la photo seront relus par un modérateur. Une fois acceptée, la bière sera visible par tous, et ta dégustation sera rattachée à la fiche commune. Ton pseudo n\'est pas publié.';

  @override
  String get submit => 'Proposer';

  @override
  String get submissionThanks =>
      'Merci ! Ta proposition sera relue par un modérateur.';

  @override
  String get submissionSharedCatalog => 'Catalogue commun';

  @override
  String get submissionSharedCatalogDescription =>
      'Cette bière manque au catalogue ? Propose-la pour que tout le monde puisse la retrouver.';

  @override
  String get submissionPending => 'Proposition en attente';

  @override
  String get submissionPendingDescription =>
      'Un modérateur va relire cette bière.';

  @override
  String get submissionApproved => 'Acceptée au catalogue';

  @override
  String get submissionApprovedDescription =>
      'Ta dégustation sera rattachée à la fiche commune au prochain lancement de l\'app.';

  @override
  String get submissionRejectedDescription =>
      'Elle ne correspond pas au catalogue (doublon, informations incomplètes...).';

  @override
  String get submissionSubmit => 'Proposer au catalogue';

  @override
  String get submissionResubmit => 'Proposer à nouveau';

  @override
  String get submissionWithdrawn => 'Proposition retirée.';

  @override
  String get submissionWithdraw => 'Retirer ma proposition';

  @override
  String get loading => 'Chargement...';

  @override
  String get submissionRejectedTitle => 'Proposition refusée';

  @override
  String get sharedProfileUnavailable =>
      'Ce profil n\'existe pas ou sa collection n\'est pas partagée avec toi.';

  @override
  String sharedProfileTastedStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bues',
      one: 'bue',
    );
    return '$_temp0';
  }

  @override
  String get sharedProfileInCommon => 'en commun';

  @override
  String sharedProfilePreview(String visibility) {
    return 'Aperçu de ce que voient les autres ($visibility).';
  }

  @override
  String get tastedSection => 'Bues';

  @override
  String get noBeersYet => 'Aucune bière pour l\'instant.';

  @override
  String get colorStraw => 'Paille';

  @override
  String get colorGolden => 'Dorée';

  @override
  String get colorAmber => 'Ambrée';

  @override
  String get colorBrown => 'Brune';

  @override
  String get colorBlack => 'Noire';

  @override
  String get tastingProfileTitle => 'Fiche de dégustation';

  @override
  String get tastingProfileHint =>
      'Touche un niveau pour le choisir, retouche-le pour l\'effacer.';

  @override
  String get criterionBitterness => 'Amertume';

  @override
  String get bitternessLow => 'Légère';

  @override
  String get bitternessHigh => 'Intense';

  @override
  String get criterionSweetness => 'Douceur';

  @override
  String get sweetnessLow => 'Sèche';

  @override
  String get sweetnessHigh => 'Sucrée';

  @override
  String get criterionBody => 'Corps';

  @override
  String get bodyLow => 'Léger';

  @override
  String get bodyHigh => 'Rond';

  @override
  String get aromas => 'Arômes';

  @override
  String get compareWithAnother => 'Comparer avec une autre bière';

  @override
  String levelOutOfFive(String criterion, int level) {
    return '$criterion $level sur 5';
  }

  @override
  String get criterionColor => 'Couleur';

  @override
  String get sortRelevance => 'Pertinence';

  @override
  String get sortNameAsc => 'Nom (A→Z)';

  @override
  String get sortAbvAsc => 'ABV croissant';

  @override
  String get sortAbvDesc => 'ABV décroissant';

  @override
  String get filterAndSort => 'Filtrer et trier';

  @override
  String get searchHint =>
      'Cherche une bière, une brasserie, un style ou un pays';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get sortBy => 'Trier par';

  @override
  String get family => 'Famille';

  @override
  String get apply => 'Appliquer';

  @override
  String get collectionEmptyTasted =>
      'Aucune bière essayée pour l\'instant.\nOuvre une bière et coche \"J\'ai bu cette bière\" pour commencer ta collection.';

  @override
  String get collectionEmptyWishlist =>
      'Aucune bière à goûter pour l\'instant.\nOuvre une bière et coche \"À goûter\" pour la garder sous le coude.';

  @override
  String collectionProgress(int count, int total) {
    return '$count / $total bières essayées';
  }

  @override
  String collectionAverageRating(String average) {
    return 'Note moyenne donnée : $average / 5';
  }

  @override
  String collectionLastTasting(String beer) {
    return 'Dernière dégustation : $beer';
  }

  @override
  String get collectionStatsButton => 'Mes statistiques et recommandations';

  @override
  String get addBeerChooseStyle => 'Choisis un style de bière.';

  @override
  String get addBeerTitle => 'Ajouter une bière';

  @override
  String get addBeerName => 'Nom de la bière';

  @override
  String get required => 'Requis';

  @override
  String get fieldDescriptionOptional => 'Description (optionnel)';

  @override
  String get addBeerSubmit => 'Ajouter à mon carnet';

  @override
  String get addBeerPrivateNotice =>
      'Cette bière n\'est visible que dans ton carnet. Tu pourras ensuite la proposer au catalogue commun depuis sa fiche.';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get emailCode => 'Code reçu par e-mail';

  @override
  String resendCodeWait(int seconds) {
    return 'Renvoyer le code ($seconds s)';
  }

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get or => 'ou';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get passwordsDoNotMatch =>
      'Les deux mots de passe ne correspondent pas.';

  @override
  String get signUpSubtitle =>
      'Crée ton compte pour sauvegarder ta collection et la retrouver sur tous tes appareils.';

  @override
  String signUpCodeSent(String email, int length) {
    return 'Si l\'adresse $email n\'est pas déjà inscrite, un code à $length chiffres vient d\'y être envoyé pour la confirmer.';
  }

  @override
  String passwordHelper(int min) {
    return 'Au moins $min caractères, avec des lettres et des chiffres.';
  }

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get signUpSubmit => 'Créer mon compte';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get confirmEmail => 'Confirmer mon adresse';

  @override
  String get changeEmail => 'Changer d\'adresse';

  @override
  String get passwordResetSubtitle =>
      'Indique l\'adresse de ton compte : tu y recevras un code pour choisir un nouveau mot de passe.';

  @override
  String passwordResetCodeSent(String email, int length) {
    return 'Si un compte existe pour $email, un code à $length chiffres vient d\'y être envoyé.';
  }

  @override
  String get getCode => 'Recevoir un code';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get loginSubtitle =>
      'Connecte-toi pour retrouver ta collection sur tous tes appareils.';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get noAccountYet => 'Pas encore de compte ?';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get ageGateRefused =>
      'Le Bierodex est réservé aux personnes ayant l\'âge légal de consommer de l\'alcool. Reviens nous voir dans quelques années !';

  @override
  String ageGateQuestion(int age) {
    return 'As-tu $age ans ou plus ?';
  }

  @override
  String get ageGateNotice =>
      'Cette application présente des boissons alcoolisées. Elle est réservée aux personnes majeures.';

  @override
  String ageGateYes(int age) {
    return 'Oui, j\'ai $age ans ou plus';
  }

  @override
  String get no => 'Non';

  @override
  String get shareCardFileName => 'bierodex-degustation.png';

  @override
  String shareCardText(String beer) {
    return '$beer · via le Bierodex';
  }

  @override
  String get shareFailed => 'Le partage n\'a pas pu s\'ouvrir.';

  @override
  String get shareCardTitle => 'Carte de dégustation';

  @override
  String get shareCardShowUsername => 'Afficher mon pseudo';

  @override
  String get shareCardPrivacyNotice =>
      'Seules la note et les arômes cochés apparaissent : tes notes écrites et ta photo restent privées.';

  @override
  String get preparing => 'Préparation...';

  @override
  String get shareImage => 'Partager l\'image';

  @override
  String get tasted => 'Dégustée';

  @override
  String get compare => 'Comparer';

  @override
  String get compareEmpty =>
      'Remplis la fiche de dégustation d\'une autre bière pour la comparer à celle-ci.';

  @override
  String get compareWith => 'Comparer avec';

  @override
  String get commonAromas => 'Arômes en commun';

  @override
  String get noCommonAromas => 'Aucun arôme en commun.';

  @override
  String get criterionRating => 'Note';

  @override
  String get notSet => 'non renseigné';

  @override
  String get photoSaveFailed =>
      'La photo n\'a pas pu être enregistrée. Vérifie ta connexion et l\'accès à l\'appareil photo.';

  @override
  String get photoDeleteTitle => 'Supprimer la photo ?';

  @override
  String get myPhoto => 'Ma photo';

  @override
  String get photoPrivate => 'Visible par toi seul.';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get deletePhoto => 'Supprimer la photo';

  @override
  String get photoUnavailableRetry => 'Photo indisponible · Réessayer';

  @override
  String breweryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brasseries',
      one: '1 brasserie',
      zero: 'aucune brasserie',
    );
    return '$_temp0';
  }

  @override
  String noBreweryLocated(String country) {
    return 'Aucune brasserie localisée pour $country.';
  }

  @override
  String get styleNotFound => 'Style introuvable';

  @override
  String styleOrigin(String origin) {
    return 'Origine : $origin';
  }

  @override
  String get styleExamples => 'Exemples de bières';

  @override
  String get styleNoExamples => 'Aucun exemple pour ce style pour le moment.';

  @override
  String get torch => 'Lampe torche';

  @override
  String get scannerHint => 'Vise le code-barres de l\'étiquette';

  @override
  String get achievementUnlockedTitle => 'Badge débloqué';

  @override
  String get cheers => 'Santé !';

  @override
  String get healthNotice =>
      'L\'abus d\'alcool est dangereux pour la santé. À consommer avec modération.';

  @override
  String abvValue(String value) {
    return 'ABV : $value';
  }
}
