import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ELED'**
  String get appTitle;

  /// No description provided for @languageSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// No description provided for @languageSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageSettingSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @todaySessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s session'**
  String get todaySessionLabel;

  /// No description provided for @todaySessionCountSingular.
  ///
  /// In en, this message translates to:
  /// **'{count} word'**
  String todaySessionCountSingular(int count);

  /// No description provided for @todaySessionCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String todaySessionCountPlural(int count);

  /// No description provided for @todayPillReview.
  ///
  /// In en, this message translates to:
  /// **'{count} review'**
  String todayPillReview(int count);

  /// No description provided for @todayPillNew.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String todayPillNew(int count);

  /// No description provided for @todayStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get todayStartSession;

  /// No description provided for @todayMatchGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Match game'**
  String get todayMatchGameTitle;

  /// No description provided for @todayMatchGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pair words with their meanings'**
  String get todayMatchGameSubtitle;

  /// No description provided for @todayMatchGameNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Need at least 4 new or learning words for the game'**
  String get todayMatchGameNotEnough;

  /// No description provided for @todayAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get todayAllCaughtUp;

  /// No description provided for @todayAllCaughtUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews are due right now. Browse a topic or check back later.'**
  String get todayAllCaughtUpSubtitle;

  /// No description provided for @todayStatKnown.
  ///
  /// In en, this message translates to:
  /// **'Known'**
  String get todayStatKnown;

  /// No description provided for @todayStatToLearn.
  ///
  /// In en, this message translates to:
  /// **'To learn'**
  String get todayStatToLearn;

  /// No description provided for @todayStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get todayStreak;

  /// No description provided for @todayStreakNone.
  ///
  /// In en, this message translates to:
  /// **'Start one today'**
  String get todayStreakNone;

  /// No description provided for @todayStreakDaysSingular.
  ///
  /// In en, this message translates to:
  /// **'{count} day'**
  String todayStreakDaysSingular(int count);

  /// No description provided for @todayStreakDaysPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String todayStreakDaysPlural(int count);

  /// No description provided for @todayTooltipSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get todayTooltipSearch;

  /// No description provided for @todayTooltipBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get todayTooltipBrowse;

  /// No description provided for @todayTooltipSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get todayTooltipSettings;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @syncPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your vocabulary…'**
  String get syncPreparing;

  /// No description provided for @syncLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading vocabulary…'**
  String get syncLoading;

  /// No description provided for @syncErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load vocabulary'**
  String get syncErrorTitle;

  /// No description provided for @syncTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get syncTryAgain;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary reminders'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and reset'**
  String get settingsDataSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version and credits'**
  String get settingsAboutSubtitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appearanceTheme;

  /// No description provided for @appearanceThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a colour scheme. Changes apply instantly.'**
  String get appearanceThemeSubtitle;

  /// No description provided for @appearanceMatchSystem.
  ///
  /// In en, this message translates to:
  /// **'Match system'**
  String get appearanceMatchSystem;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get commonAllow;

  /// No description provided for @commonNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get commonNotNow;

  /// No description provided for @commonOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonOpen;

  /// No description provided for @commonCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get commonCheck;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get menuTitle;

  /// No description provided for @menuPopularity.
  ///
  /// In en, this message translates to:
  /// **'By level'**
  String get menuPopularity;

  /// No description provided for @menuTopic.
  ///
  /// In en, this message translates to:
  /// **'By topic'**
  String get menuTopic;

  /// No description provided for @menuCollections.
  ///
  /// In en, this message translates to:
  /// **'My collections'**
  String get menuCollections;

  /// No description provided for @menuKnownWords.
  ///
  /// In en, this message translates to:
  /// **'Known words'**
  String get menuKnownWords;

  /// No description provided for @menuChooseModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode'**
  String get menuChooseModeLabel;

  /// No description provided for @menuChooseModeQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do you want\nto learn today?'**
  String get menuChooseModeQuestion;

  /// No description provided for @menuContinueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get menuContinueLearning;

  /// No description provided for @menuContinueProgress.
  ///
  /// In en, this message translates to:
  /// **'{label} · {current} of {total}'**
  String menuContinueProgress(String label, int current, int total);

  /// No description provided for @menuCardPopularityTitle.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get menuCardPopularityTitle;

  /// No description provided for @menuCardPopularitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn words from A1 to C1 level'**
  String get menuCardPopularitySubtitle;

  /// No description provided for @menuCardTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get menuCardTopicsTitle;

  /// No description provided for @menuCardTopicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By category: animals, travel…'**
  String get menuCardTopicsSubtitle;

  /// No description provided for @menuCardCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Collections'**
  String get menuCardCollectionsTitle;

  /// No description provided for @menuCardCollectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your custom word lists'**
  String get menuCardCollectionsSubtitle;

  /// No description provided for @menuCardKnownTitle.
  ///
  /// In en, this message translates to:
  /// **'Known Words'**
  String get menuCardKnownTitle;

  /// No description provided for @menuCardKnownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review words you already know'**
  String get menuCardKnownSubtitle;

  /// No description provided for @menuCardHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuCardHistoryTitle;

  /// No description provided for @menuCardHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Words via notifications'**
  String get menuCardHistorySubtitle;

  /// No description provided for @menuCouldNotResume.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t resume — vocabulary changed'**
  String get menuCouldNotResume;

  /// No description provided for @menuMarkedKnownToast.
  ///
  /// In en, this message translates to:
  /// **'\"{word}\" added to your known words'**
  String menuMarkedKnownToast(String word);

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a word'**
  String get homeSearchHint;

  /// No description provided for @homeNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get homeNoResults;

  /// No description provided for @homeNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different spelling or browse by level / topic.'**
  String get homeNoResultsHint;

  /// No description provided for @homeTitleKnown.
  ///
  /// In en, this message translates to:
  /// **'Known words'**
  String get homeTitleKnown;

  /// No description provided for @homeTitleHistory.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeTitleHistory;

  /// No description provided for @homeTitleCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get homeTitleCollection;

  /// No description provided for @homeTitleTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get homeTitleTopic;

  /// No description provided for @homeTitleSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeTitleSearch;

  /// No description provided for @homeTitlePopularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get homeTitlePopularity;

  /// No description provided for @homeSearchFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Type a word or translation…'**
  String get homeSearchFieldHint;

  /// No description provided for @homeClearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get homeClearHistoryTitle;

  /// No description provided for @homeClearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'This will erase all notification history. This action cannot be undone.'**
  String get homeClearHistoryBody;

  /// No description provided for @homeHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get homeHistoryCleared;

  /// No description provided for @homeWordAddedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Word added to collection'**
  String get homeWordAddedToCollection;

  /// No description provided for @homeRemoveFromCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from collection?'**
  String get homeRemoveFromCollectionTitle;

  /// No description provided for @homeRemoveFromCollectionBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{word}\" from this collection?'**
  String homeRemoveFromCollectionBody(String word);

  /// No description provided for @homeRemovedWord.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{word}\"'**
  String homeRemovedWord(String word);

  /// No description provided for @homeSearchPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Search the entire vocabulary'**
  String get homeSearchPromptTitle;

  /// No description provided for @homeSearchPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type a word or its translation to begin.'**
  String get homeSearchPromptSubtitle;

  /// No description provided for @homeNoWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No words to show yet'**
  String get homeNoWordsTitle;

  /// No description provided for @homeNoWordsPopularitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different level above, or come back after you sync vocabulary.'**
  String get homeNoWordsPopularitySubtitle;

  /// No description provided for @homeNoWordsGenericSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or come back after the next vocabulary sync.'**
  String get homeNoWordsGenericSubtitle;

  /// No description provided for @homeEmptyCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'This collection is empty'**
  String get homeEmptyCollectionTitle;

  /// No description provided for @homeEmptyCollectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button above to add your first word.'**
  String get homeEmptyCollectionSubtitle;

  /// No description provided for @homeEmptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No notification history yet'**
  String get homeEmptyHistoryTitle;

  /// No description provided for @homeEmptyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Words sent to you as reminders will appear here.'**
  String get homeEmptyHistorySubtitle;

  /// No description provided for @homeEmptyKnownTitle.
  ///
  /// In en, this message translates to:
  /// **'No known words yet'**
  String get homeEmptyKnownTitle;

  /// No description provided for @homeEmptyKnownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark words as known while you study to see them here.'**
  String get homeEmptyKnownSubtitle;

  /// No description provided for @homeNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get homeNoMatchesTitle;

  /// No description provided for @homeNoMatchesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword.'**
  String get homeNoMatchesSubtitle;

  /// No description provided for @searchTranslateCta.
  ///
  /// In en, this message translates to:
  /// **'Translate \"{query}\"'**
  String searchTranslateCta(String query);

  /// No description provided for @searchTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get searchTranslationLabel;

  /// No description provided for @searchTranslationError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t translate right now.'**
  String get searchTranslationError;

  /// No description provided for @homeDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String homeDayLabel(int day);

  /// No description provided for @homeWordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String homeWordsCount(int count);

  /// No description provided for @learningProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String learningProgress(int current, int total);

  /// No description provided for @learningKnowThis.
  ///
  /// In en, this message translates to:
  /// **'I already know this'**
  String get learningKnowThis;

  /// No description provided for @learningAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get learningAgain;

  /// No description provided for @learningHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get learningHard;

  /// No description provided for @learningGood.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get learningGood;

  /// No description provided for @learningEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get learningEasy;

  /// No description provided for @learningTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to hear'**
  String get learningTapToSpeak;

  /// No description provided for @learningTypeWhatYouHear.
  ///
  /// In en, this message translates to:
  /// **'Type what you hear'**
  String get learningTypeWhatYouHear;

  /// No description provided for @learningFillInBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get learningFillInBlank;

  /// No description provided for @learningChooseMeaning.
  ///
  /// In en, this message translates to:
  /// **'Choose the meaning'**
  String get learningChooseMeaning;

  /// No description provided for @learningCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get learningCheck;

  /// No description provided for @learningSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get learningSearchTitle;

  /// No description provided for @learningDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String learningDayTitle(int day);

  /// No description provided for @learningTooltipKnown.
  ///
  /// In en, this message translates to:
  /// **'I already know this'**
  String get learningTooltipKnown;

  /// No description provided for @learningTooltipDetails.
  ///
  /// In en, this message translates to:
  /// **'Word details'**
  String get learningTooltipDetails;

  /// No description provided for @learningSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip this word from now on?'**
  String get learningSkipTitle;

  /// No description provided for @learningSkipBody.
  ///
  /// In en, this message translates to:
  /// **'\"{word}\" will be marked as mastered and won\'t appear in your daily sessions for a long time.'**
  String learningSkipBody(String word);

  /// No description provided for @learningSkipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get learningSkipAction;

  /// No description provided for @learningWordOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Word {current} of {total}'**
  String learningWordOfTotal(int current, int total);

  /// No description provided for @learningDefinition.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get learningDefinition;

  /// No description provided for @learningDefinitionEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get learningDefinitionEnglish;

  /// No description provided for @learningDefinitionVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get learningDefinitionVietnamese;

  /// No description provided for @learningMarkedKnown.
  ///
  /// In en, this message translates to:
  /// **'Marked as known'**
  String get learningMarkedKnown;

  /// No description provided for @learningRemovedFromKnown.
  ///
  /// In en, this message translates to:
  /// **'Removed from known words'**
  String get learningRemovedFromKnown;

  /// No description provided for @learningCouldntOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open link'**
  String get learningCouldntOpenLink;

  /// No description provided for @learningLastSession.
  ///
  /// In en, this message translates to:
  /// **'Last session'**
  String get learningLastSession;

  /// No description provided for @learningSessionLabelDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String learningSessionLabelDay(int day);

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get resultsTitle;

  /// No description provided for @resultsReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get resultsReviewed;

  /// No description provided for @resultsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get resultsAccuracy;

  /// No description provided for @resultsTimeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get resultsTimeSpent;

  /// No description provided for @resultsFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get resultsFinish;

  /// No description provided for @resultsReviewMistakes.
  ///
  /// In en, this message translates to:
  /// **'Review mistakes'**
  String get resultsReviewMistakes;

  /// No description provided for @resultsHeadlineEnded.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get resultsHeadlineEnded;

  /// No description provided for @resultsHeadlineOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get resultsHeadlineOutstanding;

  /// No description provided for @resultsHeadlineNice.
  ///
  /// In en, this message translates to:
  /// **'Nice work'**
  String get resultsHeadlineNice;

  /// No description provided for @resultsHeadlineKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get resultsHeadlineKeepGoing;

  /// No description provided for @resultsHeadlineTough.
  ///
  /// In en, this message translates to:
  /// **'Tough round — that\'s the point'**
  String get resultsHeadlineTough;

  /// No description provided for @resultsNoCardsRated.
  ///
  /// In en, this message translates to:
  /// **'No cards rated.'**
  String get resultsNoCardsRated;

  /// No description provided for @resultsReviewedSingular.
  ///
  /// In en, this message translates to:
  /// **'You reviewed {count} word.'**
  String resultsReviewedSingular(int count);

  /// No description provided for @resultsReviewedPlural.
  ///
  /// In en, this message translates to:
  /// **'You reviewed {count} words.'**
  String resultsReviewedPlural(int count);

  /// No description provided for @resultsCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get resultsCorrect;

  /// No description provided for @resultsStruggled.
  ///
  /// In en, this message translates to:
  /// **'Struggled'**
  String get resultsStruggled;

  /// No description provided for @resultsStreakExtended.
  ///
  /// In en, this message translates to:
  /// **'Streak extended'**
  String get resultsStreakExtended;

  /// No description provided for @resultsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get resultsStreak;

  /// No description provided for @resultsStreakDaysSingular.
  ///
  /// In en, this message translates to:
  /// **'{count} day'**
  String resultsStreakDaysSingular(int count);

  /// No description provided for @resultsStreakDaysPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String resultsStreakDaysPlural(int count);

  /// No description provided for @resultsAnotherSession.
  ///
  /// In en, this message translates to:
  /// **'Another session'**
  String get resultsAnotherSession;

  /// No description provided for @resultsBackToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get resultsBackToToday;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Learn smarter, not harder'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'ELED uses spaced repetition — you see each word again right before you\'d forget it. Hundreds of words stick in your head with just a few minutes a day.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'One session a day'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Each morning the app picks the words you\'re closest to forgetting plus a few new ones. Tap Start session — usually ~20 words, ~5 minutes.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Rate as you go'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'After each card tell us how it went: Again / Hard / Good / Easy. We use your rating to decide when the word reappears — Easy disappears for a month, Again comes back tomorrow.'**
  String get onboarding3Body;

  /// No description provided for @onboarding4Title.
  ///
  /// In en, this message translates to:
  /// **'Variety beats grind'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Body.
  ///
  /// In en, this message translates to:
  /// **'As you learn, sessions mix flashcards with multiple choice, listen-and-type, fill-in-context, and a 4-pair match game. Same vocabulary, fresh angle every time.'**
  String get onboarding4Body;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @helpAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get helpAppBarTitle;

  /// No description provided for @helpTopic1Title.
  ///
  /// In en, this message translates to:
  /// **'How learning works'**
  String get helpTopic1Title;

  /// No description provided for @helpTopic1Body.
  ///
  /// In en, this message translates to:
  /// **'ELED uses spaced repetition. Every time you rate a word, the app computes when you\'re most likely to forget it, and surfaces it again right before that — so you spend time only on what\'s about to slip away, not on words you\'ve already nailed.'**
  String get helpTopic1Body;

  /// No description provided for @helpTopic2Title.
  ///
  /// In en, this message translates to:
  /// **'What is Today\'s session?'**
  String get helpTopic2Title;

  /// No description provided for @helpTopic2Body.
  ///
  /// In en, this message translates to:
  /// **'The big card on the home screen is your queue for the day. It contains:\n• Words due for review (their interval has expired)\n• A few brand-new words to keep growing your vocabulary\n\nSessions cap around 20 words. Tap Start session to begin. When you have enough fresh / learning words you also see Quiz (mini-quiz of 10 words, pick which exercise types to include before starting), Match game (calm 4-6 pair puzzle), and Speed match (30-second arcade) cards below. The same trio also surfaces on top of any collection you open.'**
  String get helpTopic2Body;

  /// No description provided for @helpTopic3Title.
  ///
  /// In en, this message translates to:
  /// **'The three rating buttons'**
  String get helpTopic3Title;

  /// No description provided for @helpTopic3Body.
  ///
  /// In en, this message translates to:
  /// **'After every flashcard you rate how it went. The app uses that rating to schedule the word\'s next appearance:\n\n• Again — \"I forgot\". Comes back tomorrow.\n• Hard — \"I knew it, but barely\". Slightly shorter interval than last time.\n• Easy — \"I knew it\". Standard schedule (each Easy multiplies the interval).\n\nIf a word feels too easy to even bother scheduling, tap the ✓ icon on the toolbar to mark it known and skip it for a long time.'**
  String get helpTopic3Body;

  /// No description provided for @helpTopic4Title.
  ///
  /// In en, this message translates to:
  /// **'Many ways to study'**
  String get helpTopic4Title;

  /// No description provided for @helpTopic4Body.
  ///
  /// In en, this message translates to:
  /// **'Cards inside a session rotate between five exercise styles so practice never gets repetitive: Recognize, Multiple choice, Listen and type, Fill in context, Anagram, and Type the English word. See \"Mini games & exercises\" below for what each one does.\n\nOnce you have shown you know a word, sessions ease off to the gentle Recognize card — no more guessing puzzles on words you have already mastered.'**
  String get helpTopic4Body;

  /// No description provided for @helpTopic5Title.
  ///
  /// In en, this message translates to:
  /// **'The match game'**
  String get helpTopic5Title;

  /// No description provided for @helpTopic5Body.
  ///
  /// In en, this message translates to:
  /// **'A tap-to-match mini game with up to 6 pairs (4 minimum), shown below Start session when you have at least 4 new or learning words queued. Tap a word, then its translation; correct pairs fade green, wrong picks flash red. Your accuracy auto-rates each word in the same SRS schedule as the main flow.'**
  String get helpTopic5Body;

  /// No description provided for @helpTopic6Title.
  ///
  /// In en, this message translates to:
  /// **'Mark a word as known'**
  String get helpTopic6Title;

  /// No description provided for @helpTopic6Body.
  ///
  /// In en, this message translates to:
  /// **'On any learning card, tap the ✓ icon in the top bar. The word is promoted to mastered (wont reappear in daily sessions for a long stretch) and the next card slides in. A snackbar with Undo gives you a few seconds to take it back if you tapped by mistake. Tapping ✓ again on a word thats already known removes it from the known list.'**
  String get helpTopic6Body;

  /// No description provided for @helpTopic7Title.
  ///
  /// In en, this message translates to:
  /// **'Streak & active days'**
  String get helpTopic7Title;

  /// No description provided for @helpTopic7Body.
  ///
  /// In en, this message translates to:
  /// **'Each day you rate at least one card counts toward your streak. The 28-day heatmap on Today shows which of the last four weeks you practised. Miss one day and the streak survives; miss two and it resets to 0.'**
  String get helpTopic7Body;

  /// No description provided for @helpTopic8Title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get helpTopic8Title;

  /// No description provided for @helpTopic8Body.
  ///
  /// In en, this message translates to:
  /// **'Settings → Notifications lets you choose how often a vocabulary reminder fires, how many fire in each active period (max 5), and your active hours. The reminders pick from the same word pool the Today screen uses. The level + topic filter for which words show up lives in Settings → Vocabulary preferences and is shared across the whole app.'**
  String get helpTopic8Body;

  /// No description provided for @helpTopic9Title.
  ///
  /// In en, this message translates to:
  /// **'Browse the dictionary'**
  String get helpTopic9Title;

  /// No description provided for @helpTopic9Body.
  ///
  /// In en, this message translates to:
  /// **'The apps icon on Today opens Browse — the older mode-by-mode view. Useful when you want to look at all words at a specific level, or pull from a collection. The day grouping there is shuffled per level so it stays varied.'**
  String get helpTopic9Body;

  /// No description provided for @helpTopic10Title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get helpTopic10Title;

  /// No description provided for @helpTopic10Body.
  ///
  /// In en, this message translates to:
  /// **'The magnifier icon searches the entire vocabulary by word or translation. Use it for ad-hoc look-ups; tapping a result opens its full Recognize card with the audio, IPA, and definitions.\n\nWhen a word or sentence isn\'t in the list, a Translate button appears — tap it to call Google Translate, auto-detecting English ↔ Vietnamese. Handy for sentences or words the app doesn\'t yet cover.'**
  String get helpTopic10Body;

  /// No description provided for @helpTopic11Title.
  ///
  /// In en, this message translates to:
  /// **'Backup & sync'**
  String get helpTopic11Title;

  /// No description provided for @helpTopic11Body.
  ///
  /// In en, this message translates to:
  /// **'Settings → Account & data lets you Export your known words + collections to a JSON file via the system share sheet, and Import the same shape back. Sign in with Google to sync the knownWords + collections across devices automatically.'**
  String get helpTopic11Body;

  /// No description provided for @matchGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Match game'**
  String get matchGameTitle;

  /// No description provided for @matchGameCongrats.
  ///
  /// In en, this message translates to:
  /// **'Nice match!'**
  String get matchGameCongrats;

  /// No description provided for @matchGamePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get matchGamePlayAgain;

  /// No description provided for @matchGameDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get matchGameDone;

  /// No description provided for @matchGameProgress.
  ///
  /// In en, this message translates to:
  /// **'{matched} / {total}'**
  String matchGameProgress(int matched, int total);

  /// No description provided for @collectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionsTitle;

  /// No description provided for @collectionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get collectionsEmpty;

  /// No description provided for @collectionsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a word\'s bookmark to add it here.'**
  String get collectionsEmptyHint;

  /// No description provided for @collectionsNewCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get collectionsNewCollection;

  /// No description provided for @collectionsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get collectionsNameHint;

  /// No description provided for @collectionsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get collectionsCreate;

  /// No description provided for @collectionsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete collection'**
  String get collectionsDelete;

  /// No description provided for @collectionsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this collection? Words inside stay in the library.'**
  String get collectionsDeleteConfirm;

  /// No description provided for @collectionsAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get collectionsAddTo;

  /// No description provided for @collectionsCreateNew.
  ///
  /// In en, this message translates to:
  /// **'+ CREATE NEW'**
  String get collectionsCreateNew;

  /// No description provided for @collectionsEmptyUppercase.
  ///
  /// In en, this message translates to:
  /// **'NO COLLECTIONS YET.'**
  String get collectionsEmptyUppercase;

  /// No description provided for @collectionsNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. TOEFL Words...'**
  String get collectionsNamePlaceholder;

  /// No description provided for @collectionsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'DELETE {name}?'**
  String collectionsDeleteTitle(String name);

  /// No description provided for @collectionsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this collection?'**
  String get collectionsDeleteBody;

  /// No description provided for @collectionsWordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String collectionsWordsCount(int count);

  /// No description provided for @topicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topicsTitle;

  /// No description provided for @topicsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No topics in the selected levels'**
  String get topicsEmptyTitle;

  /// No description provided for @topicsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Pick more levels above to see topics.'**
  String get topicsEmptyHint;

  /// No description provided for @topicsCategorySummarySingular.
  ///
  /// In en, this message translates to:
  /// **'{topicCount} topic · {wordCount} words'**
  String topicsCategorySummarySingular(int topicCount, int wordCount);

  /// No description provided for @topicsCategorySummaryPlural.
  ///
  /// In en, this message translates to:
  /// **'{topicCount} topics · {wordCount} words'**
  String topicsCategorySummaryPlural(int topicCount, int wordCount);

  /// No description provided for @topicCategoryWordSingular.
  ///
  /// In en, this message translates to:
  /// **'{count} word'**
  String topicCategoryWordSingular(int count);

  /// No description provided for @topicCategoryWordPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String topicCategoryWordPlural(int count);

  /// No description provided for @topicCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'{category}'**
  String topicCategoryTitle(String category);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEnable.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary reminders'**
  String get notificationsEnable;

  /// No description provided for @notificationsEnableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a new word periodically while the app is closed.'**
  String get notificationsEnableSubtitle;

  /// No description provided for @notificationsInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get notificationsInterval;

  /// No description provided for @notificationsIntervalMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String notificationsIntervalMinutes(int count);

  /// No description provided for @notificationsActiveHours.
  ///
  /// In en, this message translates to:
  /// **'Active hours'**
  String get notificationsActiveHours;

  /// No description provided for @notificationsFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get notificationsFrom;

  /// No description provided for @notificationsTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get notificationsTo;

  /// No description provided for @notificationsLevels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get notificationsLevels;

  /// No description provided for @notificationsTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get notificationsTopics;

  /// No description provided for @notificationsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsAll;

  /// No description provided for @notificationsFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get notificationsFrequency;

  /// No description provided for @notificationsFrequencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How often to send a new vocabulary word'**
  String get notificationsFrequencySubtitle;

  /// No description provided for @notificationsActiveHoursSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders only fire inside this window'**
  String get notificationsActiveHoursSubtitle;

  /// No description provided for @notificationsDifficultyLevels.
  ///
  /// In en, this message translates to:
  /// **'Difficulty levels'**
  String get notificationsDifficultyLevels;

  /// No description provided for @notificationsDifficultyLevelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which CEFR levels to include'**
  String get notificationsDifficultyLevelsSubtitle;

  /// No description provided for @notificationsTopicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — leave empty to use all topics'**
  String get notificationsTopicsSubtitle;

  /// No description provided for @notificationsUntil.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get notificationsUntil;

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get notificationsOff;

  /// No description provided for @notificationsSaved.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences saved'**
  String get notificationsSaved;

  /// No description provided for @notificationsBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep notifications running'**
  String get notificationsBatteryTitle;

  /// No description provided for @notificationsBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Android may pause ELED notifications after a day to save battery. Allow ELED to run unrestricted so vocabulary reminders keep firing.'**
  String get notificationsBatteryBody;

  /// No description provided for @notificationsBatteryCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow background activity'**
  String get notificationsBatteryCardTitle;

  /// No description provided for @notificationsBatteryCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to keep notifications firing past 1 day'**
  String get notificationsBatteryCardSubtitle;

  /// No description provided for @dataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataTitle;

  /// No description provided for @dataBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get dataBackup;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get dataExport;

  /// No description provided for @dataImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get dataImport;

  /// No description provided for @dataResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get dataResetTitle;

  /// No description provided for @dataResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clears SRS state and known words. Vocabulary library stays.'**
  String get dataResetSubtitle;

  /// No description provided for @dataResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get dataResetConfirmTitle;

  /// No description provided for @dataResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This wipes your SRS history, streaks, and known-words list. Cannot be undone.'**
  String get dataResetConfirmBody;

  /// No description provided for @dataClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get dataClearCache;

  /// No description provided for @dataScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Account & data'**
  String get dataScreenTitle;

  /// No description provided for @dataAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get dataAccountTitle;

  /// No description provided for @dataAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync known words and collections across devices'**
  String get dataAccountSubtitle;

  /// No description provided for @dataBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your known words and collections as a JSON file'**
  String get dataBackupSubtitle;

  /// No description provided for @dataFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get dataFeedback;

  /// No description provided for @dataSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get dataSignedIn;

  /// No description provided for @dataSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get dataSignedOut;

  /// No description provided for @dataSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String dataSignInFailed(String error);

  /// No description provided for @dataExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get dataExportFailed;

  /// No description provided for @dataBackupReady.
  ///
  /// In en, this message translates to:
  /// **'Backup ready to share'**
  String get dataBackupReady;

  /// No description provided for @dataImportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled or failed'**
  String get dataImportCancelled;

  /// No description provided for @dataImportResult.
  ///
  /// In en, this message translates to:
  /// **'Added {knownAdded} known words and {collectionsAdded} new collections'**
  String dataImportResult(int knownAdded, int collectionsAdded);

  /// No description provided for @dataSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get dataSignInWithGoogle;

  /// No description provided for @dataSignInWithGoogleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync known words, collections & history'**
  String get dataSignInWithGoogleSubtitle;

  /// No description provided for @dataGoogleUser.
  ///
  /// In en, this message translates to:
  /// **'Google user'**
  String get dataGoogleUser;

  /// No description provided for @dataSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get dataSignOut;

  /// No description provided for @dataRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate ELED'**
  String get dataRateApp;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get aboutRateApp;

  /// No description provided for @aboutCheckUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for update'**
  String get aboutCheckUpdate;

  /// No description provided for @aboutSource.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSource;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutBuiltBy.
  ///
  /// In en, this message translates to:
  /// **'Built by'**
  String get aboutBuiltBy;

  /// No description provided for @aboutCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get aboutCurrentVersion;

  /// No description provided for @aboutVersionPrefix.
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String aboutVersionPrefix(String version);

  /// No description provided for @aboutCheckButton.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get aboutCheckButton;

  /// No description provided for @aboutAutoCheckOnStartup.
  ///
  /// In en, this message translates to:
  /// **'Auto-check on startup'**
  String get aboutAutoCheckOnStartup;

  /// No description provided for @aboutNewVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'v{version} available'**
  String aboutNewVersionAvailable(String version);

  /// No description provided for @aboutUpdateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get aboutUpdateNow;

  /// No description provided for @aboutOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get aboutOpen;

  /// No description provided for @aboutUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get aboutUpToDate;

  /// No description provided for @aboutDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String aboutDownloadFailed(String error);

  /// No description provided for @exerciseCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get exerciseCorrect;

  /// No description provided for @exerciseIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get exerciseIncorrect;

  /// No description provided for @exerciseAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get exerciseAnswerLabel;

  /// No description provided for @exerciseWhatDoesItMean.
  ///
  /// In en, this message translates to:
  /// **'What does this mean?'**
  String get exerciseWhatDoesItMean;

  /// No description provided for @exerciseListenAndType.
  ///
  /// In en, this message translates to:
  /// **'Listen and type'**
  String get exerciseListenAndType;

  /// No description provided for @exerciseFillInBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get exerciseFillInBlank;

  /// No description provided for @exerciseSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get exerciseSkip;

  /// No description provided for @exerciseCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get exerciseCheck;

  /// No description provided for @popularityLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String popularityLevelLabel(String level);

  /// No description provided for @bulkImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import words'**
  String get bulkImportTitle;

  /// No description provided for @bulkImportTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target collection'**
  String get bulkImportTargetLabel;

  /// No description provided for @bulkImportPickCollection.
  ///
  /// In en, this message translates to:
  /// **'Pick a collection'**
  String get bulkImportPickCollection;

  /// No description provided for @bulkImportCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new collection…'**
  String get bulkImportCreateNew;

  /// No description provided for @bulkImportNewNameHint.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get bulkImportNewNameHint;

  /// No description provided for @bulkImportPasteLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste words'**
  String get bulkImportPasteLabel;

  /// No description provided for @bulkImportPasteHint.
  ///
  /// In en, this message translates to:
  /// **'One word per line. Commas also work.'**
  String get bulkImportPasteHint;

  /// No description provided for @bulkImportPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get bulkImportPreview;

  /// No description provided for @bulkImportPreviewMatched.
  ///
  /// In en, this message translates to:
  /// **'{count} will be added'**
  String bulkImportPreviewMatched(int count);

  /// No description provided for @bulkImportPreviewSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped (not in vocabulary)'**
  String bulkImportPreviewSkipped(int count);

  /// No description provided for @bulkImportShowSkipped.
  ///
  /// In en, this message translates to:
  /// **'Show skipped'**
  String get bulkImportShowSkipped;

  /// No description provided for @bulkImportHideSkipped.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get bulkImportHideSkipped;

  /// No description provided for @bulkImportAlreadyIn.
  ///
  /// In en, this message translates to:
  /// **'{count} already in collection'**
  String bulkImportAlreadyIn(int count);

  /// No description provided for @bulkImportConfirmAdd.
  ///
  /// In en, this message translates to:
  /// **'Add {count} words'**
  String bulkImportConfirmAdd(int count);

  /// No description provided for @bulkImportNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching words found'**
  String get bulkImportNoMatches;

  /// No description provided for @bulkImportEmptyInput.
  ///
  /// In en, this message translates to:
  /// **'Paste at least one word'**
  String get bulkImportEmptyInput;

  /// No description provided for @bulkImportNeedCollection.
  ///
  /// In en, this message translates to:
  /// **'Pick or create a collection first'**
  String get bulkImportNeedCollection;

  /// No description provided for @bulkImportDoneToast.
  ///
  /// In en, this message translates to:
  /// **'Added {count} to \"{name}\"'**
  String bulkImportDoneToast(int count, String name);

  /// No description provided for @bulkImportPreviewCustom.
  ///
  /// In en, this message translates to:
  /// **'{count} custom (will be auto-translated)'**
  String bulkImportPreviewCustom(int count);

  /// No description provided for @bulkImportTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating custom words…'**
  String get bulkImportTranslating;

  /// No description provided for @bulkImportCustomBadge.
  ///
  /// In en, this message translates to:
  /// **'custom'**
  String get bulkImportCustomBadge;

  /// No description provided for @searchAddCustomCta.
  ///
  /// In en, this message translates to:
  /// **'Use \"{word}\" as a custom word'**
  String searchAddCustomCta(String word);

  /// No description provided for @helpTopic12Title.
  ///
  /// In en, this message translates to:
  /// **'Import a word list'**
  String get helpTopic12Title;

  /// No description provided for @helpTopic12Body.
  ///
  /// In en, this message translates to:
  /// **'Open Browse → My collections → tap the upload icon in the top bar. Paste your list (one word per line, or comma-separated), pick a destination collection or create a new one, then Preview. The app shows which words match the bundled dictionary, which are \"custom\" (auto-translated via Google), and which already exist. Confirm and they are added in one go. Custom words show a small CUSTOM badge in the list and carry the translated meaning — they stay out of exercises and SRS since they have no IPA or audio.'**
  String get helpTopic12Body;

  /// No description provided for @exerciseTypeEnglishFor.
  ///
  /// In en, this message translates to:
  /// **'Type the English word for the meaning below'**
  String get exerciseTypeEnglishFor;

  /// No description provided for @exerciseAnagramTitle.
  ///
  /// In en, this message translates to:
  /// **'Unscramble the word'**
  String get exerciseAnagramTitle;

  /// No description provided for @exerciseAnagramClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get exerciseAnagramClear;

  /// No description provided for @exerciseReverseTypingTitle.
  ///
  /// In en, this message translates to:
  /// **'Type the English word'**
  String get exerciseReverseTypingTitle;

  /// No description provided for @exerciseHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get exerciseHint;

  /// No description provided for @exerciseHintStartsWith.
  ///
  /// In en, this message translates to:
  /// **'Starts with \"{letter}\"'**
  String exerciseHintStartsWith(String letter);

  /// No description provided for @quizPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose exercise types'**
  String get quizPickerTitle;

  /// No description provided for @quizPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one type for this quiz round.'**
  String get quizPickerSubtitle;

  /// No description provided for @quizPickerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get quizPickerStart;

  /// No description provided for @quizPickerSelectAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get quizPickerSelectAll;

  /// No description provided for @exerciseLabelMultipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get exerciseLabelMultipleChoice;

  /// No description provided for @exerciseLabelListenAndType.
  ///
  /// In en, this message translates to:
  /// **'Listen & type'**
  String get exerciseLabelListenAndType;

  /// No description provided for @exerciseLabelFillInContext.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get exerciseLabelFillInContext;

  /// No description provided for @exerciseLabelAnagram.
  ///
  /// In en, this message translates to:
  /// **'Unscramble'**
  String get exerciseLabelAnagram;

  /// No description provided for @exerciseLabelReverseTyping.
  ///
  /// In en, this message translates to:
  /// **'Type the English word'**
  String get exerciseLabelReverseTyping;

  /// No description provided for @speedMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed match'**
  String get speedMatchTitle;

  /// No description provided for @speedMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Match as many as you can in {seconds}s'**
  String speedMatchSubtitle(int seconds);

  /// No description provided for @speedMatchStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get speedMatchStart;

  /// No description provided for @speedMatchScore.
  ///
  /// In en, this message translates to:
  /// **'{count} matched'**
  String speedMatchScore(int count);

  /// No description provided for @speedMatchTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Times up'**
  String get speedMatchTimeUp;

  /// No description provided for @speedMatchPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get speedMatchPlayAgain;

  /// No description provided for @speedMatchNeedMore.
  ///
  /// In en, this message translates to:
  /// **'Need at least 6 new or learning words'**
  String get speedMatchNeedMore;

  /// No description provided for @speedMatchToday.
  ///
  /// In en, this message translates to:
  /// **'Speed match'**
  String get speedMatchToday;

  /// No description provided for @helpTopic13Title.
  ///
  /// In en, this message translates to:
  /// **'Mini games & exercises'**
  String get helpTopic13Title;

  /// No description provided for @helpTopic13Body.
  ///
  /// In en, this message translates to:
  /// **'Each card uses one of several exercise styles to keep practice varied:\n\n• Recognize — classic flashcard.\n• Multiple choice — pick the right meaning.\n• Listen and type — hear the word, type it.\n• Fill in context — Oxford sentence with the word blanked out. If no sentence exists, youll see the meaning and type the English word.\n• Anagram — drag-tap the scrambled letters into order.\n• Type the English word — see the Vietnamese meaning, type the English word.\n\nAll typing exercises use an IP-address-style slot input — one box per letter, with apostrophes and hyphens shown automatically. A free Hint button is available: Multiple choice removes one wrong option; typing exercises reveal the first letter.\n\nThe Today screen + each collection also offer three standalone activities: Quiz (mini-quiz round of 10, pick exercise types before starting), Match game (4-6 calm pairs), and Speed match (30-second timer).'**
  String get helpTopic13Body;

  /// No description provided for @posFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter by part of speech'**
  String get posFilterLabel;

  /// No description provided for @posFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get posFilterAll;

  /// No description provided for @posNoun.
  ///
  /// In en, this message translates to:
  /// **'Noun'**
  String get posNoun;

  /// No description provided for @posVerb.
  ///
  /// In en, this message translates to:
  /// **'Verb'**
  String get posVerb;

  /// No description provided for @posAdjective.
  ///
  /// In en, this message translates to:
  /// **'Adjective'**
  String get posAdjective;

  /// No description provided for @posAdverb.
  ///
  /// In en, this message translates to:
  /// **'Adverb'**
  String get posAdverb;

  /// No description provided for @posPreposition.
  ///
  /// In en, this message translates to:
  /// **'Preposition'**
  String get posPreposition;

  /// No description provided for @posConjunction.
  ///
  /// In en, this message translates to:
  /// **'Conjunction'**
  String get posConjunction;

  /// No description provided for @posPronoun.
  ///
  /// In en, this message translates to:
  /// **'Pronoun'**
  String get posPronoun;

  /// No description provided for @posDeterminer.
  ///
  /// In en, this message translates to:
  /// **'Determiner'**
  String get posDeterminer;

  /// No description provided for @posExclamation.
  ///
  /// In en, this message translates to:
  /// **'Exclamation'**
  String get posExclamation;

  /// No description provided for @posModal.
  ///
  /// In en, this message translates to:
  /// **'Modal verb'**
  String get posModal;

  /// No description provided for @posNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get posNumber;

  /// No description provided for @posArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get posArticle;

  /// No description provided for @notificationsMaxCount.
  ///
  /// In en, this message translates to:
  /// **'Words per notification'**
  String get notificationsMaxCount;

  /// No description provided for @notificationsMaxCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How many vocabulary words to bundle into each notification'**
  String get notificationsMaxCountSubtitle;

  /// No description provided for @notificationsMaxCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count} words'**
  String notificationsMaxCountValue(int count);

  /// No description provided for @settingsLearningPrefs.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary preferences'**
  String get settingsLearningPrefs;

  /// No description provided for @settingsLearningPrefsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Levels and topics'**
  String get settingsLearningPrefsSubtitle;

  /// No description provided for @learningPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary preferences'**
  String get learningPrefsTitle;

  /// No description provided for @learningPrefsLevelsHeader.
  ///
  /// In en, this message translates to:
  /// **'Difficulty levels'**
  String get learningPrefsLevelsHeader;

  /// No description provided for @learningPrefsLevelsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Which CEFR levels to include in sessions, games, and notifications'**
  String get learningPrefsLevelsSubtitle;

  /// No description provided for @learningPrefsTopicsHeader.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get learningPrefsTopicsHeader;

  /// No description provided for @learningPrefsTopicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restrict suggestions to specific topic categories. Leave empty for all.'**
  String get learningPrefsTopicsSubtitle;

  /// No description provided for @todayQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get todayQuizTitle;

  /// No description provided for @todayQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Six exercise styles, no scheduling'**
  String get todayQuizSubtitle;

  /// No description provided for @todayQuizNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Need at least 4 fresh / learning words for the quiz'**
  String get todayQuizNotEnough;

  /// No description provided for @helpTopic14Title.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary preferences'**
  String get helpTopic14Title;

  /// No description provided for @helpTopic14Body.
  ///
  /// In en, this message translates to:
  /// **'Settings → Vocabulary preferences controls which CEFR levels (A1-C1) and which topic categories the app draws from. The choices feed every word-picker: Todays session, all the games, and Notifications. Leave Topics empty to allow every category. Levels default to the full set.'**
  String get helpTopic14Body;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
