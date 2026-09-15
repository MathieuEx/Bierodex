// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String authPasswordTooShort(int min) {
    return 'The password must be at least $min characters long.';
  }

  @override
  String get authPasswordTooLong => 'The password is too long.';

  @override
  String get authPasswordNeedsLettersAndDigits =>
      'The password must contain both letters and numbers.';

  @override
  String get authInvalidEmail => 'Invalid email address.';

  @override
  String get errorServerUnreachable =>
      'Unable to reach the server. Check your internet connection.';

  @override
  String get authEnterPassword => 'Enter your password.';

  @override
  String get authInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authWeakPasswordChooseAnother =>
      'This password is too weak or has leaked elsewhere. Choose another one.';

  @override
  String get authUserAlreadyExists =>
      'An account already exists with this address. Sign in.';

  @override
  String get authWeakPassword =>
      'This password is too weak or has leaked elsewhere.';

  @override
  String get authSamePassword =>
      'Choose a password different from the old one.';

  @override
  String authResendWait(int seconds) {
    return 'Wait $seconds s before requesting a new code.';
  }

  @override
  String get authTooManyCodeAttempts =>
      'Too many attempts. Request a new code.';

  @override
  String authCodeLength(int length) {
    return 'The code has $length digits.';
  }

  @override
  String get authGoogleUnavailable =>
      'Google sign-in is unavailable right now.';

  @override
  String get authGoogleCannotOpen =>
      'Unable to open Google sign-in. Check your internet connection.';

  @override
  String get authDeleteFailed =>
      'Deletion failed. Try again later; your data is intact.';

  @override
  String get authRateLimited =>
      'Too many attempts. Try again in a few minutes.';

  @override
  String get authInvalidCode => 'Invalid or expired code.';

  @override
  String get authSignInUnavailable =>
      'Unable to sign in right now. Try again later.';

  @override
  String get authEmailNotConfirmed =>
      'First confirm your email address with the code you received.';

  @override
  String usernameLength(int min, int max) {
    return 'Between $min and $max characters.';
  }

  @override
  String get usernameCharacters => 'Lowercase letters, numbers and _ only.';

  @override
  String get errorSignInRequired => 'Sign-in required.';

  @override
  String get displayNameTooLong => 'The display name is too long.';

  @override
  String get socialUsernameTaken => 'This username is already taken.';

  @override
  String get socialInvalidProfile => 'Invalid username or display name.';

  @override
  String get socialProfileRequired => 'Choose your username first.';

  @override
  String get socialProfileNotFound => 'No profile has this username.';

  @override
  String get socialCannotAddSelf => 'That is your own username.';

  @override
  String get socialTooManyRequests =>
      'Too many pending requests. Try again later.';

  @override
  String get socialRequestNotFound => 'This request no longer exists.';

  @override
  String get errorGeneric => 'Something went wrong. Try again later.';

  @override
  String get submissionAlreadySubmitted =>
      'This beer has already been submitted.';

  @override
  String get submissionAlreadyInCatalog =>
      'A beer with this barcode already exists in the catalog.';

  @override
  String get submissionTooMany => 'You already have many pending submissions.';

  @override
  String get submissionBeerNotSynced =>
      'This beer is not synced yet. Try again in a moment.';

  @override
  String get submissionNotModerator => 'Moderators only.';

  @override
  String get submissionAlreadyReviewed =>
      'This submission has already been reviewed.';

  @override
  String get familyAle => 'Top fermentation (Ale)';

  @override
  String get familyLager => 'Bottom fermentation (Lager)';

  @override
  String get familySpontaneous => 'Spontaneous fermentation';

  @override
  String get familyMixed => 'Mixed fermentation';

  @override
  String get familySpontaneousShort => 'Spontaneous';

  @override
  String get familyMixedShort => 'Mixed';

  @override
  String get visibilityPrivate => 'Private';

  @override
  String get visibilityFriends => 'Friends';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityPrivateDescription => 'No one but you.';

  @override
  String get visibilityFriendsDescription => 'Only your accepted friends.';

  @override
  String get visibilityPublicDescription =>
      'Anyone with the link, even without an account.';

  @override
  String get aromaAgrumes => 'Citrus';

  @override
  String get aromaFruitsRouges => 'Red fruits';

  @override
  String get aromaFruitsExotiques => 'Tropical fruits';

  @override
  String get aromaFloral => 'Floral';

  @override
  String get aromaHerbace => 'Grassy';

  @override
  String get aromaResineux => 'Resinous';

  @override
  String get aromaEpices => 'Spices';

  @override
  String get aromaBananeClou => 'Banana / clove';

  @override
  String get aromaMiel => 'Honey';

  @override
  String get aromaBiscuit => 'Biscuit / grain';

  @override
  String get aromaCaramel => 'Caramel';

  @override
  String get aromaTorrefie => 'Roasted';

  @override
  String get aromaChocolat => 'Chocolate';

  @override
  String get aromaCafe => 'Coffee';

  @override
  String get aromaBoise => 'Woody';

  @override
  String get aromaAcidule => 'Tart';

  @override
  String get aromaFunky => 'Funky / Brett';

  @override
  String get achievementFirstTastingTitle => 'First sip';

  @override
  String get achievementFirstTastingDescription => 'Taste your first beer.';

  @override
  String get achievementTasted10Title => 'Notebook started';

  @override
  String get achievementTasted10Description => 'Taste 10 beers.';

  @override
  String get achievementTasted25Title => 'Enlightened amateur';

  @override
  String get achievementTasted25Description => 'Taste 25 beers.';

  @override
  String get achievementTasted50Title => 'Connoisseur';

  @override
  String get achievementTasted50Description => 'Taste 50 beers.';

  @override
  String get achievementStyles10Title => 'Style palette';

  @override
  String get achievementStyles10Description => 'Try 10 different styles.';

  @override
  String get achievementEuropeTourTitle => 'European tour';

  @override
  String get achievementEuropeTourDescription =>
      'Try beers from 10 European countries.';

  @override
  String get achievementWorldTourTitle => 'World tour';

  @override
  String get achievementWorldTourDescription =>
      'Try beers from all 5 continents.';

  @override
  String get achievementSpontaneousTitle => 'Spontaneous fermentation explorer';

  @override
  String get achievementSpontaneousDescription =>
      'Taste 3 spontaneously fermented beers (lambic, gueuze, kriek...).';

  @override
  String get achievementFourFamiliesTitle => 'The four fermentations';

  @override
  String get achievementFourFamiliesDescription =>
      'Try at least one beer from each family.';

  @override
  String get achievementStreak3Title => 'Regular';

  @override
  String get achievementStreak3Description =>
      'At least one tasting 3 months in a row.';

  @override
  String get achievementStreak6Title => 'Faithful to the notebook';

  @override
  String get achievementStreak6Description =>
      'At least one tasting 6 months in a row.';

  @override
  String get achievementDetailed5Title => 'Sharp palate';

  @override
  String get achievementDetailed5Description =>
      'Fill in 5 detailed tasting notes.';

  @override
  String get achievementPhotos5Title => 'Photographer';

  @override
  String get achievementPhotos5Description => 'Photograph 5 tastings.';

  @override
  String recommendationLikedStyle(String style, String average) {
    return 'You enjoyed your $style beers ($average/5)';
  }

  @override
  String recommendationLikedFamily(String family, String style) {
    return 'You like $family: discover the $style style';
  }

  @override
  String get reminderInactivityTitle => 'Feeling thirsty?';

  @override
  String reminderInactivityBody(int days) {
    return 'You haven\'t tasted anything in $days days. Time to discover a new beer?';
  }

  @override
  String get reminderWishlistTitle => 'Your wishlist is waiting';

  @override
  String reminderWishlistBody(String beer, String brewery) {
    return 'Still want to try $beer ($brewery)?';
  }

  @override
  String get reminderChannelName => 'Reminders';

  @override
  String get reminderChannelDescription => 'Tasting and wishlist reminders';

  @override
  String get catalogLoading => 'Loading the catalog...';

  @override
  String get catalogLoadError => 'Unable to load the catalog.';

  @override
  String get checkInternetConnection => 'Check your internet connection.';

  @override
  String get retry => 'Retry';

  @override
  String get accountTitle => 'My account';

  @override
  String get accountSignedIn => 'Signed in';

  @override
  String get accountSyncedDescription =>
      'Your collection (tasted and rated beers) is synced with this account and available on any device.';

  @override
  String accountPendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending changes',
      one: '1 pending change',
    );
    return '$_temp0';
  }

  @override
  String get accountPendingChangesDescription =>
      'Saved on this device, they will be sent as soon as you are back online.';

  @override
  String get retryNow => 'Retry now';

  @override
  String get reminderInactivitySetting => 'Tasting reminder';

  @override
  String get reminderInactivitySettingDescription =>
      'If you haven\'t tasted anything for a month';

  @override
  String get reminderWishlistSetting => 'Wishlist reminder';

  @override
  String get reminderWishlistSettingDescription =>
      'A beer to try, every two weeks';

  @override
  String get accountFriendsAndProfile => 'Friends and profile';

  @override
  String get accountFriendsAndProfileDescription =>
      'Username, friends, public profile link';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutEverywhere => 'Sign out of all devices';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountDescription => 'Permanently erases all your data.';

  @override
  String get moderationTitle => 'Moderation';

  @override
  String get moderationDescription => 'Beers submitted by the community';

  @override
  String get signOutEverywhereTitle => 'All devices?';

  @override
  String get signOutEverywhereDescription =>
      'All sessions open with this account (phone, tablet, browser...) will be closed. Use this if a device is lost or stolen.';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOutEverywhereConfirm => 'Sign out everywhere';

  @override
  String get deleteAccountInProgress => 'Deleting...';

  @override
  String get deleteAccountDone => 'Your account has been deleted.';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountWarning =>
      'Your collection, ratings, comments and the beers you added will be permanently erased from all your devices. This cannot be undone.';

  @override
  String deleteAccountTypeToConfirm(String word) {
    return 'Type $word to confirm:';
  }

  @override
  String get deleteAccountConfirm => 'Delete permanently';

  @override
  String get deleteAccountConfirmationWord => 'DELETE';

  @override
  String get privacyWhoTitle => 'Who is responsible?';

  @override
  String privacyWhoParagraph1(String publisher, String contact) {
    return 'Bierodex is published by $publisher, the controller of your data. Contact: $contact.';
  }

  @override
  String get privacyDataTitle => 'Data collected';

  @override
  String get privacyDataParagraph1 =>
      'Account: your email address, your password (stored only in hashed form, unreadable even to us) and a technical identifier. If you sign in with Google, Google also sends us your name and profile picture; we never receive your Google password.';

  @override
  String get privacyDataParagraph2 =>
      'Collection: beers marked as tasted or to try, your ratings, tasting dates, comments and tasting notes (color, bitterness, sweetness, body, aromas), as well as beers you add yourself (name, brewery, barcode, photo).';

  @override
  String get privacyDataParagraph3 =>
      'Profile and friends (optional): your username, a display name if you choose one, your collection\'s visibility and your list of friends and friend requests.';

  @override
  String get privacyDataParagraph4 =>
      'Tasting photos: only those you choose to take or import. They are stored in a private space accessible only to your account, never published. If your device records location in its photos, this information may remain in the file: the app neither reads nor uses it.';

  @override
  String get privacyDataParagraph5 =>
      'No location collected by the app, no contacts, no ads, no advertising trackers.';

  @override
  String get privacyWhyTitle => 'Why?';

  @override
  String get privacyWhyParagraph1 =>
      'Only to make the app work: signing you in and syncing your collection across your devices (legal basis: performance of the service you request). Your data is never sold or shared for commercial purposes.';

  @override
  String get privacySharingTitle => 'Sharing and community';

  @override
  String get privacySharingParagraph1 =>
      'By default, your collection is private. If you make your profile visible to friends or public, those people (or anyone with your link, for a public profile) see your username, display name, tasted and to-try beers, their rating out of 5 and their date. Never your written notes, tasting notes, photos or email address. You can switch back to private at any time.';

  @override
  String get privacySharingParagraph2 =>
      'Your friends see your username and display name, even if your collection is private.';

  @override
  String get privacySharingParagraph3 =>
      'Submitting a beer to the shared catalog sends its details (name, brewery, country, style, ABV, description, barcode, photo) to a moderator. Once approved, it becomes public, without any mention of your account.';

  @override
  String get privacySharingParagraph4 =>
      'Tasting cards are generated on your device: they are only shared if you choose to send them.';

  @override
  String get privacyStorageTitle => 'Where is it stored?';

  @override
  String privacyStorageParagraph1(String region) {
    return 'With Supabase (hosted in $region), with access limited to your account only (except what you choose to share, see above). A copy is kept on your device for offline use; the sign-in session is encrypted there by the system (Keychain / Keystore). Changes made offline wait there until the network is back before being sent.';
  }

  @override
  String get privacyThirdPartiesTitle => 'Third-party services';

  @override
  String get privacyThirdPartiesParagraph1 =>
      'Open Food Facts: when you scan an unknown barcode, the code is sent to Open Food Facts to look up the product.';

  @override
  String get privacyThirdPartiesParagraph2 =>
      'OpenStreetMap and Wikimedia Commons: map tiles and photos, loaded directly from their servers (so your IP address is visible to them).';

  @override
  String get privacyThirdPartiesParagraph3 =>
      'Google: only if you choose \"Continue with Google\".';

  @override
  String get privacyThirdPartiesParagraph4 =>
      'Sentry: if the app crashes, a technical report (error message, device model, system and app version) is sent so the problem can be fixed. It contains neither your email address, nor your identifier, nor your IP address, nor the content of your collection (legal basis: legitimate interest in keeping the app working).';

  @override
  String get privacyThirdPartiesParagraph5 =>
      'Reminders (notifications) are scheduled on your device, without any server. You can turn them off in \"My account\".';

  @override
  String get privacyRetentionTitle => 'Retention period';

  @override
  String get privacyRetentionParagraph1 =>
      'As long as your account exists. Deleting your account immediately and permanently erases all your data from our servers and from the device used (profile, friends and submissions included). Beers already approved into the shared catalog, which contain no personal data, remain there.';

  @override
  String get privacyRightsTitle => 'Your rights';

  @override
  String privacyRightsParagraph1(String contact) {
    return 'You can access, correct, export or request deletion of your data, and object to its processing. Deletion is available directly in \"My account\"; for anything else, write to $contact.';
  }

  @override
  String get privacyRightsParagraph2 =>
      'You can also lodge a complaint with the CNIL, the French data protection authority (www.cnil.fr).';

  @override
  String get privacyAgeTitle => 'Age';

  @override
  String get privacyAgeParagraph1 =>
      'The app features alcoholic beverages and is intended for adults of legal drinking age only.';

  @override
  String privacyLastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get privacyScreenTitle => 'Privacy';

  @override
  String get socialReceivedRequests => 'Requests received';

  @override
  String get socialMyFriends => 'My friends';

  @override
  String get socialSentRequests => 'Requests sent';

  @override
  String get socialNoFriends => 'No friends yet. Add them with their username.';

  @override
  String get socialShareSubject => 'My collection on Bierodex';

  @override
  String get socialCreateProfile => 'Create your profile';

  @override
  String get socialCreateProfileDescription =>
      'Choose a username to add friends and, if you like, share your collection. Your profile stays private until you change its visibility.';

  @override
  String get socialChooseUsername => 'Choose my username';

  @override
  String get socialEditProfile => 'Edit profile';

  @override
  String socialCollectionVisibility(String visibility, String description) {
    return 'Collection: $visibility · $description';
  }

  @override
  String get socialViewAsOthers => 'View as others';

  @override
  String get socialShareLink => 'Share link';

  @override
  String get copy => 'Copy';

  @override
  String get socialLinkCopied => 'Link copied.';

  @override
  String get socialMyProfile => 'My profile';

  @override
  String get socialUsername => 'Username';

  @override
  String get socialUsernameHelper =>
      'Visible to your friends and in your public link.';

  @override
  String get socialDisplayNameOptional => 'Display name (optional)';

  @override
  String get socialWhoCanSee => 'Who can see my collection?';

  @override
  String get socialSharedDataNotice =>
      'Shared: tasted and to-try beers, ratings out of 5 and dates. Never your written notes, tasting notes, photos or email address.';

  @override
  String get saving => 'Saving...';

  @override
  String get save => 'Save';

  @override
  String socialNowFriends(String username) {
    return 'You are now friends with @$username.';
  }

  @override
  String socialRequestSent(String username) {
    return 'Request sent to @$username.';
  }

  @override
  String get socialAddFriend => 'Add a friend';

  @override
  String get socialAddFriendHint => 'Their exact username';

  @override
  String get socialSendRequest => 'Send request';

  @override
  String socialRemoveFriendTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get socialRemoveFriendDescription =>
      'You will no longer see each other\'s collections if they are friends-only.';

  @override
  String get remove => 'Remove';

  @override
  String get socialRemoveFriend => 'Remove this friend';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get statsTitle => 'My statistics';

  @override
  String get statsEmpty =>
      'Mark your first beers as tasted to see your statistics take shape.';

  @override
  String get statsByMonth => 'Tastings per month';

  @override
  String get statsLast12Months => 'Last 12 months';

  @override
  String get statsByFamily => 'By fermentation family';

  @override
  String get statsByStyle => 'By style';

  @override
  String get statsAverageByStyle => 'Average rating by style';

  @override
  String get statsCountries => 'Countries tasted';

  @override
  String get statsCountriesHint =>
      'The bigger and darker the circle, the more beers you have tasted from that country.';

  @override
  String get statsForYou => 'For you';

  @override
  String get statsForYouHint => 'Based on your best-rated styles.';

  @override
  String get statsBadges => 'Badges';

  @override
  String statsTileBeers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'beers',
      one: 'beer',
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
      other: 'countries',
      one: 'country',
    );
    return '$_temp0';
  }

  @override
  String get statsTileAverage => 'avg. rating';

  @override
  String get showLess => 'Show less';

  @override
  String showAll(int count) {
    return 'Show all ($count)';
  }

  @override
  String statsMonthTooltip(String month, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tastings',
      one: '1 tasting',
      zero: 'no tastings',
    );
    return '$month: $_temp0';
  }

  @override
  String get statsNoRecommendations =>
      'Rate a few beers (at least 4 stars) to get suggestions.';

  @override
  String get achievementUnlocked => 'Unlocked';

  @override
  String get stylesTitle => 'Beer styles';

  @override
  String get collectionTitle => 'My collection';

  @override
  String get search => 'Search';

  @override
  String get scanBeer => 'Scan a beer';

  @override
  String get styles => 'Styles';

  @override
  String get navMap => 'Map';

  @override
  String get navCollection => 'Collection';

  @override
  String get navScan => 'Scan';

  @override
  String get navProfile => 'Profile';

  @override
  String get searchBeerHint => 'Search a beer, a brewery…';

  @override
  String get beerDeleteTitle => 'Delete this beer?';

  @override
  String beerDeleteDescription(String name) {
    return '\"$name\" will be removed from your personal notebook. This cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get beerNotFound => 'Beer not found';

  @override
  String get shareMyTasting => 'Share my tasting';

  @override
  String get beerDeleteFromNotebook => 'Remove from my notebook';

  @override
  String get beerAddedByYou => 'Added by you';

  @override
  String beerStyle(String style) {
    return 'Style: $style';
  }

  @override
  String photoCredit(String credit) {
    return 'Photo: $credit';
  }

  @override
  String get freeLicense => 'free license';

  @override
  String get beerMyReview => 'My review';

  @override
  String get wishlistLabel => 'Want to try';

  @override
  String get beerTried => 'I had this beer';

  @override
  String get beerMyRating => 'My rating:';

  @override
  String get beerClearRating => 'Clear rating';

  @override
  String tastedOn(String date) {
    return 'Tasted on $date';
  }

  @override
  String get dateUnknown => 'No date set';

  @override
  String get edit => 'Edit';

  @override
  String get tastingNotes => 'Tasting notes';

  @override
  String get tastingNotesHint => 'Aromas, setting, who with...';

  @override
  String get moderationEmpty => 'No pending submissions.';

  @override
  String moderationPossibleDuplicate(String beers) {
    return 'Possible duplicate: $beers';
  }

  @override
  String get invalidAbv => 'Invalid ABV.';

  @override
  String get moderationApproved =>
      'Beer added to the catalog. Remember to set the brewery\'s location if it is new.';

  @override
  String get submissionRejected => 'Submission declined.';

  @override
  String get moderationReview => 'Review submission';

  @override
  String barcodeValue(String barcode) {
    return 'Barcode: $barcode';
  }

  @override
  String get fieldName => 'Name';

  @override
  String get fieldBrewery => 'Brewery';

  @override
  String get fieldCountry => 'Country';

  @override
  String get fieldStyle => 'Style';

  @override
  String get fieldAbv => 'ABV (%)';

  @override
  String get fieldDescription => 'Description';

  @override
  String get moderationNote => 'Message to the author (optional)';

  @override
  String get moderationNoteHelper => 'Shown if declined.';

  @override
  String get submissionConfirmTitle => 'Submit to the catalog?';

  @override
  String get submissionConfirmDescription =>
      'The name, brewery, country, style, ABV, description, barcode and photo will be reviewed by a moderator. Once approved, the beer will be visible to everyone and your tasting will be linked to the shared entry. Your username is not published.';

  @override
  String get submit => 'Submit';

  @override
  String get submissionThanks =>
      'Thanks! Your submission will be reviewed by a moderator.';

  @override
  String get submissionSharedCatalog => 'Shared catalog';

  @override
  String get submissionSharedCatalogDescription =>
      'Is this beer missing from the catalog? Submit it so everyone can find it.';

  @override
  String get submissionPending => 'Submission pending';

  @override
  String get submissionPendingDescription =>
      'A moderator will review this beer.';

  @override
  String get submissionApproved => 'Approved into the catalog';

  @override
  String get submissionApprovedDescription =>
      'Your tasting will be linked to the shared entry the next time the app starts.';

  @override
  String get submissionRejectedDescription =>
      'It doesn\'t fit the catalog (duplicate, incomplete information...).';

  @override
  String get submissionSubmit => 'Submit to the catalog';

  @override
  String get submissionResubmit => 'Submit again';

  @override
  String get submissionWithdrawn => 'Submission withdrawn.';

  @override
  String get submissionWithdraw => 'Withdraw my submission';

  @override
  String get loading => 'Loading...';

  @override
  String get submissionRejectedTitle => 'Submission declined';

  @override
  String get sharedProfileUnavailable =>
      'This profile doesn\'t exist or its collection isn\'t shared with you.';

  @override
  String sharedProfileTastedStat(int count) {
    return 'tasted';
  }

  @override
  String get sharedProfileInCommon => 'in common';

  @override
  String sharedProfilePreview(String visibility) {
    return 'Preview of what others see ($visibility).';
  }

  @override
  String get tastedSection => 'Tasted';

  @override
  String get noBeersYet => 'No beers yet.';

  @override
  String get colorStraw => 'Straw';

  @override
  String get colorGolden => 'Golden';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorBlack => 'Black';

  @override
  String get tastingProfileTitle => 'Tasting notes';

  @override
  String get tastingProfileHint =>
      'Tap a level to select it, tap it again to clear it.';

  @override
  String get criterionBitterness => 'Bitterness';

  @override
  String get bitternessLow => 'Light';

  @override
  String get bitternessHigh => 'Intense';

  @override
  String get criterionSweetness => 'Sweetness';

  @override
  String get sweetnessLow => 'Dry';

  @override
  String get sweetnessHigh => 'Sweet';

  @override
  String get criterionBody => 'Body';

  @override
  String get bodyLow => 'Light';

  @override
  String get bodyHigh => 'Full';

  @override
  String get aromas => 'Aromas';

  @override
  String get compareWithAnother => 'Compare with another beer';

  @override
  String levelOutOfFive(String criterion, int level) {
    return '$criterion $level out of 5';
  }

  @override
  String get criterionColor => 'Color';

  @override
  String get sortRelevance => 'Relevance';

  @override
  String get sortNameAsc => 'Name (A→Z)';

  @override
  String get sortAbvAsc => 'ABV ascending';

  @override
  String get sortAbvDesc => 'ABV descending';

  @override
  String get filterAndSort => 'Filter and sort';

  @override
  String get searchHint => 'Search for a beer, brewery, style or country';

  @override
  String get noResults => 'No results';

  @override
  String get reset => 'Reset';

  @override
  String get sortBy => 'Sort by';

  @override
  String get family => 'Family';

  @override
  String get apply => 'Apply';

  @override
  String get collectionEmptyTasted =>
      'No beers tried yet.\nOpen a beer and tick \"I had this beer\" to start your collection.';

  @override
  String get collectionEmptyWishlist =>
      'No beers to try yet.\nOpen a beer and tick \"Want to try\" to keep it in mind.';

  @override
  String collectionProgress(int count, int total) {
    return '$count / $total beers tried';
  }

  @override
  String collectionAverageRating(String average) {
    return 'Average rating given: $average / 5';
  }

  @override
  String collectionLastTasting(String beer) {
    return 'Last tasting: $beer';
  }

  @override
  String get collectionStatsButton => 'My statistics and recommendations';

  @override
  String get addBeerChooseStyle => 'Choose a beer style.';

  @override
  String get addBeerTitle => 'Add a beer';

  @override
  String get addBeerName => 'Beer name';

  @override
  String get required => 'Required';

  @override
  String get fieldDescriptionOptional => 'Description (optional)';

  @override
  String get addBeerSubmit => 'Add to my notebook';

  @override
  String get addBeerPrivateNotice =>
      'This beer is only visible in your notebook. You can then submit it to the shared catalog from its page.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get emailCode => 'Code received by email';

  @override
  String resendCodeWait(int seconds) {
    return 'Resend code ($seconds s)';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get passwordsDoNotMatch => 'The two passwords don\'t match.';

  @override
  String get signUpSubtitle =>
      'Create your account to save your collection and access it on all your devices.';

  @override
  String signUpCodeSent(String email, int length) {
    return 'If $email is not already registered, a $length-digit code has just been sent to confirm it.';
  }

  @override
  String passwordHelper(int min) {
    return 'At least $min characters, with letters and numbers.';
  }

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get signUpSubmit => 'Create my account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign in';

  @override
  String get confirmEmail => 'Confirm my address';

  @override
  String get changeEmail => 'Change address';

  @override
  String get passwordResetSubtitle =>
      'Enter your account\'s email address: you\'ll receive a code there to choose a new password.';

  @override
  String passwordResetCodeSent(String email, int length) {
    return 'If an account exists for $email, a $length-digit code has just been sent to it.';
  }

  @override
  String get getCode => 'Get a code';

  @override
  String get newPassword => 'New password';

  @override
  String get changePassword => 'Change password';

  @override
  String get loginSubtitle =>
      'Sign in to access your collection on all your devices.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccountYet => 'Don\'t have an account yet?';

  @override
  String get createAccount => 'Create an account';

  @override
  String get ageGateRefused =>
      'Bierodex is only for people of legal drinking age. Come back and see us in a few years!';

  @override
  String ageGateQuestion(int age) {
    return 'Are you $age or older?';
  }

  @override
  String get ageGateNotice =>
      'This app features alcoholic beverages. It is intended for adults only.';

  @override
  String ageGateYes(int age) {
    return 'Yes, I\'m $age or older';
  }

  @override
  String get no => 'No';

  @override
  String get shareCardFileName => 'bierodex-tasting.png';

  @override
  String shareCardText(String beer) {
    return '$beer · via Bierodex';
  }

  @override
  String get shareFailed => 'Sharing could not be opened.';

  @override
  String get shareCardTitle => 'Tasting card';

  @override
  String get shareCardShowUsername => 'Show my username';

  @override
  String get shareCardPrivacyNotice =>
      'Only the rating and ticked aromas appear: your written notes and photo stay private.';

  @override
  String get preparing => 'Preparing...';

  @override
  String get shareImage => 'Share image';

  @override
  String get tasted => 'Tasted';

  @override
  String get compare => 'Compare';

  @override
  String get compareEmpty =>
      'Fill in the tasting notes of another beer to compare it with this one.';

  @override
  String get compareWith => 'Compare with';

  @override
  String get commonAromas => 'Aromas in common';

  @override
  String get noCommonAromas => 'No aromas in common.';

  @override
  String get criterionRating => 'Rating';

  @override
  String get notSet => 'not set';

  @override
  String get photoSaveFailed =>
      'The photo could not be saved. Check your connection and camera access.';

  @override
  String get photoDeleteTitle => 'Delete the photo?';

  @override
  String get myPhoto => 'My photo';

  @override
  String get photoPrivate => 'Visible only to you.';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get photoUnavailableRetry => 'Photo unavailable · Retry';

  @override
  String breweryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count breweries',
      one: '1 brewery',
      zero: 'no breweries',
    );
    return '$_temp0';
  }

  @override
  String noBreweryLocated(String country) {
    return 'No brewery located for $country.';
  }

  @override
  String get styleNotFound => 'Style not found';

  @override
  String styleOrigin(String origin) {
    return 'Origin: $origin';
  }

  @override
  String get styleExamples => 'Example beers';

  @override
  String get styleNoExamples => 'No examples for this style yet.';

  @override
  String get torch => 'Flashlight';

  @override
  String get scannerHint => 'Aim at the label\'s barcode';

  @override
  String get achievementUnlockedTitle => 'Badge unlocked';

  @override
  String get cheers => 'Cheers!';

  @override
  String get healthNotice =>
      'Alcohol abuse is dangerous for your health. Please drink responsibly.';

  @override
  String abvValue(String value) {
    return 'ABV: $value';
  }
}
