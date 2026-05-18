// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ELED';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get languageSettingSubtitle => 'App language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageSystem => 'System default';

  @override
  String get today => 'Today';

  @override
  String get todaySessionLabel => 'Today\'s session';

  @override
  String todaySessionCountSingular(int count) {
    return '$count word';
  }

  @override
  String todaySessionCountPlural(int count) {
    return '$count words';
  }

  @override
  String todayPillReview(int count) {
    return '$count review';
  }

  @override
  String todayPillNew(int count) {
    return '$count new';
  }

  @override
  String get todayStartSession => 'Start session';

  @override
  String get todayMatchGameTitle => 'Match game';

  @override
  String get todayMatchGameSubtitle => 'Pair words with their meanings';

  @override
  String get todayMatchGameNotEnough =>
      'Need at least 4 new or learning words for the game';

  @override
  String get todayAllCaughtUp => 'All caught up';

  @override
  String get todayAllCaughtUpSubtitle =>
      'No reviews are due right now. Browse a topic or check back later.';

  @override
  String get todayStatKnown => 'Known';

  @override
  String get todayStatToLearn => 'To learn';

  @override
  String get todayStreak => 'Streak';

  @override
  String get todayStreakNone => 'Start one today';

  @override
  String todayStreakDaysSingular(int count) {
    return '$count day';
  }

  @override
  String todayStreakDaysPlural(int count) {
    return '$count days';
  }

  @override
  String get todayTooltipSearch => 'Search';

  @override
  String get todayTooltipBrowse => 'Browse';

  @override
  String get todayTooltipSettings => 'Settings';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get syncPreparing => 'Preparing your vocabulary…';

  @override
  String get syncLoading => 'Loading vocabulary…';

  @override
  String get syncErrorTitle => 'Couldn\'t load vocabulary';

  @override
  String get syncTryAgain => 'Try again';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSubtitle => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Vocabulary reminders';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsDataSubtitle => 'Backup and reset';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'Version and credits';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get appearanceThemeSubtitle =>
      'Choose a colour scheme. Changes apply instantly.';

  @override
  String get appearanceMatchSystem => 'Match system';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClose => 'Close';

  @override
  String get commonOk => 'OK';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonAllow => 'Allow';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonCheck => 'Check';

  @override
  String get menuTitle => 'Browse';

  @override
  String get menuPopularity => 'By level';

  @override
  String get menuTopic => 'By topic';

  @override
  String get menuCollections => 'My collections';

  @override
  String get menuKnownWords => 'Known words';

  @override
  String get menuChooseModeLabel => 'Choose a mode';

  @override
  String get menuChooseModeQuestion => 'How do you want\nto learn today?';

  @override
  String get menuContinueLearning => 'Continue learning';

  @override
  String menuContinueProgress(String label, int current, int total) {
    return '$label · $current of $total';
  }

  @override
  String get menuCardPopularityTitle => 'Popularity';

  @override
  String get menuCardPopularitySubtitle => 'Learn words from A1 to C1 level';

  @override
  String get menuCardTopicsTitle => 'Topics';

  @override
  String get menuCardTopicsSubtitle => 'By category: animals, travel…';

  @override
  String get menuCardCollectionsTitle => 'My Collections';

  @override
  String get menuCardCollectionsSubtitle => 'Your custom word lists';

  @override
  String get menuCardKnownTitle => 'Known Words';

  @override
  String get menuCardKnownSubtitle => 'Review words you already know';

  @override
  String get menuCardHistoryTitle => 'History';

  @override
  String get menuCardHistorySubtitle => 'Words via notifications';

  @override
  String get menuCouldNotResume => 'Couldn\'t resume — vocabulary changed';

  @override
  String menuMarkedKnownToast(String word) {
    return '\"$word\" added to your known words';
  }

  @override
  String get homeSearchHint => 'Search a word';

  @override
  String get homeNoResults => 'No results';

  @override
  String get homeNoResultsHint =>
      'Try a different spelling or browse by level / topic.';

  @override
  String get homeTitleKnown => 'Known words';

  @override
  String get homeTitleHistory => 'History';

  @override
  String get homeTitleCollection => 'Collection';

  @override
  String get homeTitleTopic => 'Topic';

  @override
  String get homeTitleSearch => 'Search';

  @override
  String get homeTitlePopularity => 'Popularity';

  @override
  String get homeSearchFieldHint => 'Type a word or translation…';

  @override
  String get homeClearHistoryTitle => 'Clear history?';

  @override
  String get homeClearHistoryBody =>
      'This will erase all notification history. This action cannot be undone.';

  @override
  String get homeHistoryCleared => 'History cleared';

  @override
  String get homeWordAddedToCollection => 'Word added to collection';

  @override
  String get homeRemoveFromCollectionTitle => 'Remove from collection?';

  @override
  String homeRemoveFromCollectionBody(String word) {
    return 'Remove \"$word\" from this collection?';
  }

  @override
  String homeRemovedWord(String word) {
    return 'Removed \"$word\"';
  }

  @override
  String get homeSearchPromptTitle => 'Search the entire vocabulary';

  @override
  String get homeSearchPromptSubtitle =>
      'Type a word or its translation to begin.';

  @override
  String get homeNoWordsTitle => 'No words to show yet';

  @override
  String get homeNoWordsPopularitySubtitle =>
      'Try selecting a different level above, or come back after you sync vocabulary.';

  @override
  String get homeNoWordsGenericSubtitle =>
      'Try adjusting your filters or come back after the next vocabulary sync.';

  @override
  String get homeEmptyCollectionTitle => 'This collection is empty';

  @override
  String get homeEmptyCollectionSubtitle =>
      'Tap the + button above to add your first word.';

  @override
  String get homeEmptyHistoryTitle => 'No notification history yet';

  @override
  String get homeEmptyHistorySubtitle =>
      'Words sent to you as reminders will appear here.';

  @override
  String get homeEmptyKnownTitle => 'No known words yet';

  @override
  String get homeEmptyKnownSubtitle =>
      'Mark words as known while you study to see them here.';

  @override
  String get homeNoMatchesTitle => 'No matches';

  @override
  String get homeNoMatchesSubtitle => 'Try a different keyword.';

  @override
  String homeDayLabel(int day) {
    return 'Day $day';
  }

  @override
  String homeWordsCount(int count) {
    return '$count words';
  }

  @override
  String learningProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get learningKnowThis => 'I already know this';

  @override
  String get learningAgain => 'Again';

  @override
  String get learningHard => 'Hard';

  @override
  String get learningGood => 'Easy';

  @override
  String get learningEasy => 'Easy';

  @override
  String get learningTapToSpeak => 'Tap to hear';

  @override
  String get learningTypeWhatYouHear => 'Type what you hear';

  @override
  String get learningFillInBlank => 'Fill in the blank';

  @override
  String get learningChooseMeaning => 'Choose the meaning';

  @override
  String get learningCheck => 'Check';

  @override
  String get learningSearchTitle => 'Search';

  @override
  String learningDayTitle(int day) {
    return 'Day $day';
  }

  @override
  String get learningTooltipKnown => 'I already know this';

  @override
  String get learningTooltipDetails => 'Word details';

  @override
  String get learningSkipTitle => 'Skip this word from now on?';

  @override
  String learningSkipBody(String word) {
    return '\"$word\" will be marked as mastered and won\'t appear in your daily sessions for a long time.';
  }

  @override
  String get learningSkipAction => 'Skip';

  @override
  String learningWordOfTotal(int current, int total) {
    return 'Word $current of $total';
  }

  @override
  String get learningDefinition => 'Definition';

  @override
  String get learningDefinitionEnglish => 'English';

  @override
  String get learningDefinitionVietnamese => 'Tiếng Việt';

  @override
  String get learningMarkedKnown => 'Marked as known';

  @override
  String get learningRemovedFromKnown => 'Removed from known words';

  @override
  String get learningCouldntOpenLink => 'Couldn\'t open link';

  @override
  String get learningLastSession => 'Last session';

  @override
  String learningSessionLabelDay(int day) {
    return 'Day $day';
  }

  @override
  String get resultsTitle => 'Session complete';

  @override
  String get resultsReviewed => 'Reviewed';

  @override
  String get resultsAccuracy => 'Accuracy';

  @override
  String get resultsTimeSpent => 'Time';

  @override
  String get resultsFinish => 'Finish';

  @override
  String get resultsReviewMistakes => 'Review mistakes';

  @override
  String get resultsHeadlineEnded => 'Session ended';

  @override
  String get resultsHeadlineOutstanding => 'Outstanding';

  @override
  String get resultsHeadlineNice => 'Nice work';

  @override
  String get resultsHeadlineKeepGoing => 'Keep going';

  @override
  String get resultsHeadlineTough => 'Tough round — that\'s the point';

  @override
  String get resultsNoCardsRated => 'No cards rated.';

  @override
  String resultsReviewedSingular(int count) {
    return 'You reviewed $count word.';
  }

  @override
  String resultsReviewedPlural(int count) {
    return 'You reviewed $count words.';
  }

  @override
  String get resultsCorrect => 'Correct';

  @override
  String get resultsStruggled => 'Struggled';

  @override
  String get resultsStreakExtended => 'Streak extended';

  @override
  String get resultsStreak => 'Streak';

  @override
  String resultsStreakDaysSingular(int count) {
    return '$count day';
  }

  @override
  String resultsStreakDaysPlural(int count) {
    return '$count days';
  }

  @override
  String get resultsAnotherSession => 'Another session';

  @override
  String get resultsBackToToday => 'Back to Today';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboarding1Title => 'Learn smarter, not harder';

  @override
  String get onboarding1Body =>
      'ELED uses spaced repetition — you see each word again right before you\'d forget it. Hundreds of words stick in your head with just a few minutes a day.';

  @override
  String get onboarding2Title => 'One session a day';

  @override
  String get onboarding2Body =>
      'Each morning the app picks the words you\'re closest to forgetting plus a few new ones. Tap Start session — usually ~20 words, ~5 minutes.';

  @override
  String get onboarding3Title => 'Rate as you go';

  @override
  String get onboarding3Body =>
      'After each card tell us how it went: Again / Hard / Good / Easy. We use your rating to decide when the word reappears — Easy disappears for a month, Again comes back tomorrow.';

  @override
  String get onboarding4Title => 'Variety beats grind';

  @override
  String get onboarding4Body =>
      'As you learn, sessions mix flashcards with multiple choice, listen-and-type, fill-in-context, and a 4-pair match game. Same vocabulary, fresh angle every time.';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpAppBarTitle => 'How to use';

  @override
  String get helpTopic1Title => 'How learning works';

  @override
  String get helpTopic1Body =>
      'ELED uses spaced repetition. Every time you rate a word, the app computes when you\'re most likely to forget it, and surfaces it again right before that — so you spend time only on what\'s about to slip away, not on words you\'ve already nailed.';

  @override
  String get helpTopic2Title => 'What is Today\'s session?';

  @override
  String get helpTopic2Body =>
      'The big card on the home screen is your queue for the day. It contains:\n• Words due for review (their interval has expired)\n• A few brand-new words to keep growing your vocabulary\n\nSessions cap around 20 words. Tap Start session to begin. When you have enough fresh / learning words you also see Match game (calm 4-6 pair puzzle) and Speed match (30-second arcade) cards below.';

  @override
  String get helpTopic3Title => 'The three rating buttons';

  @override
  String get helpTopic3Body =>
      'After every flashcard you rate how it went. The app uses that rating to schedule the word\'s next appearance:\n\n• Again — \"I forgot\". Comes back tomorrow.\n• Hard — \"I knew it, but barely\". Slightly shorter interval than last time.\n• Easy — \"I knew it\". Standard schedule (each Easy multiplies the interval).\n\nIf a word feels too easy to even bother scheduling, tap the ✓ icon on the toolbar to mark it known and skip it for a long time.';

  @override
  String get helpTopic4Title => 'Many ways to study';

  @override
  String get helpTopic4Body =>
      'Cards inside a session rotate between six exercise styles so practice never gets repetitive: Recognize, Multiple choice, Listen and type, Fill in context, Anagram, First letter, and Reverse typing. See \"Mini games & exercises\" below for what each one does.\n\nOnce you have shown you know a word, sessions ease off to the gentle Recognize card — no more guessing puzzles on words you have already mastered.';

  @override
  String get helpTopic5Title => 'The match game';

  @override
  String get helpTopic5Body =>
      'A tap-to-match mini game with up to 6 pairs (4 minimum), shown below Start session when you have at least 4 new or learning words queued. Tap a word, then its translation; correct pairs fade green, wrong picks flash red. Your accuracy auto-rates each word in the same SRS schedule as the main flow.';

  @override
  String get helpTopic6Title => 'Mark a word as known';

  @override
  String get helpTopic6Body =>
      'On any learning card, tap the ✓ icon in the top bar. The word is promoted to mastered (wont reappear in daily sessions for a long stretch) and the next card slides in. A snackbar with Undo gives you a few seconds to take it back if you tapped by mistake. Tapping ✓ again on a word thats already known removes it from the known list.';

  @override
  String get helpTopic7Title => 'Streak & active days';

  @override
  String get helpTopic7Body =>
      'Each day you rate at least one card counts toward your streak. The 28-day heatmap on Today shows which of the last four weeks you practised. Miss one day and the streak survives; miss two and it resets to 0.';

  @override
  String get helpTopic8Title => 'Notifications';

  @override
  String get helpTopic8Body =>
      'Settings → Notifications lets you choose how often a vocabulary reminder fires and your active hours. The reminders pick words from your due queue first, so each tap is a real review — not a random word you already know.\n\nOn some Android phones you\'ll need to allow background activity for ELED so the reminders keep firing past a day. The settings screen prompts you the first time.';

  @override
  String get helpTopic9Title => 'Browse the dictionary';

  @override
  String get helpTopic9Body =>
      'The apps icon on Today opens Browse — the older mode-by-mode view. Useful when you want to look at all words at a specific level, or pull from a collection. The day grouping there is shuffled per level so it stays varied.';

  @override
  String get helpTopic10Title => 'Search';

  @override
  String get helpTopic10Body =>
      'The magnifier icon searches the entire vocabulary by word or translation. Use it for ad-hoc look-ups; tapping a result opens its full Recognize card with the audio, IPA, and definitions.';

  @override
  String get helpTopic11Title => 'Backup & sync';

  @override
  String get helpTopic11Body =>
      'Settings → Account & data lets you Export your known words + collections to a JSON file via the system share sheet, and Import the same shape back. Sign in with Google to sync the knownWords + collections across devices automatically.';

  @override
  String get matchGameTitle => 'Match game';

  @override
  String get matchGameCongrats => 'Nice match!';

  @override
  String get matchGamePlayAgain => 'Play again';

  @override
  String get matchGameDone => 'Done';

  @override
  String matchGameProgress(int matched, int total) {
    return '$matched / $total';
  }

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get collectionsEmpty => 'No collections yet';

  @override
  String get collectionsEmptyHint => 'Tap a word\'s bookmark to add it here.';

  @override
  String get collectionsNewCollection => 'New collection';

  @override
  String get collectionsNameHint => 'Name';

  @override
  String get collectionsCreate => 'Create';

  @override
  String get collectionsDelete => 'Delete collection';

  @override
  String get collectionsDeleteConfirm =>
      'Delete this collection? Words inside stay in the library.';

  @override
  String get collectionsAddTo => 'Add to collection';

  @override
  String get collectionsCreateNew => '+ CREATE NEW';

  @override
  String get collectionsEmptyUppercase => 'NO COLLECTIONS YET.';

  @override
  String get collectionsNamePlaceholder => 'e.g. TOEFL Words...';

  @override
  String collectionsDeleteTitle(String name) {
    return 'DELETE $name?';
  }

  @override
  String get collectionsDeleteBody =>
      'Are you sure you want to delete this collection?';

  @override
  String collectionsWordsCount(int count) {
    return '$count words';
  }

  @override
  String get topicsTitle => 'Topics';

  @override
  String get topicsEmptyTitle => 'No topics in the selected levels';

  @override
  String get topicsEmptyHint => 'Pick more levels above to see topics.';

  @override
  String topicsCategorySummarySingular(int topicCount, int wordCount) {
    return '$topicCount topic · $wordCount words';
  }

  @override
  String topicsCategorySummaryPlural(int topicCount, int wordCount) {
    return '$topicCount topics · $wordCount words';
  }

  @override
  String topicCategoryWordSingular(int count) {
    return '$count word';
  }

  @override
  String topicCategoryWordPlural(int count) {
    return '$count words';
  }

  @override
  String topicCategoryTitle(String category) {
    return '$category';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEnable => 'Vocabulary reminders';

  @override
  String get notificationsEnableSubtitle =>
      'Get a new word periodically while the app is closed.';

  @override
  String get notificationsInterval => 'Interval';

  @override
  String notificationsIntervalMinutes(int count) {
    return '$count min';
  }

  @override
  String get notificationsActiveHours => 'Active hours';

  @override
  String get notificationsFrom => 'From';

  @override
  String get notificationsTo => 'To';

  @override
  String get notificationsLevels => 'Levels';

  @override
  String get notificationsTopics => 'Topics';

  @override
  String get notificationsAll => 'All';

  @override
  String get notificationsFrequency => 'Frequency';

  @override
  String get notificationsFrequencySubtitle =>
      'How often to send a new vocabulary word';

  @override
  String get notificationsActiveHoursSubtitle =>
      'Reminders only fire inside this window';

  @override
  String get notificationsDifficultyLevels => 'Difficulty levels';

  @override
  String get notificationsDifficultyLevelsSubtitle =>
      'Choose which CEFR levels to include';

  @override
  String get notificationsTopicsSubtitle =>
      'Optional — leave empty to use all topics';

  @override
  String get notificationsUntil => 'Until';

  @override
  String get notificationsOff => 'Off';

  @override
  String get notificationsSaved => 'Notification preferences saved';

  @override
  String get notificationsBatteryTitle => 'Keep notifications running';

  @override
  String get notificationsBatteryBody =>
      'Android may pause ELED notifications after a day to save battery. Allow ELED to run unrestricted so vocabulary reminders keep firing.';

  @override
  String get notificationsBatteryCardTitle => 'Allow background activity';

  @override
  String get notificationsBatteryCardSubtitle =>
      'Tap to keep notifications firing past 1 day';

  @override
  String get dataTitle => 'Data';

  @override
  String get dataBackup => 'Backup';

  @override
  String get dataExport => 'Export';

  @override
  String get dataImport => 'Import';

  @override
  String get dataResetTitle => 'Reset progress';

  @override
  String get dataResetSubtitle =>
      'Clears SRS state and known words. Vocabulary library stays.';

  @override
  String get dataResetConfirmTitle => 'Reset all progress?';

  @override
  String get dataResetConfirmBody =>
      'This wipes your SRS history, streaks, and known-words list. Cannot be undone.';

  @override
  String get dataClearCache => 'Clear cache';

  @override
  String get dataScreenTitle => 'Account & data';

  @override
  String get dataAccountTitle => 'Account';

  @override
  String get dataAccountSubtitle =>
      'Sign in to sync known words and collections across devices';

  @override
  String get dataBackupSubtitle =>
      'Save your known words and collections as a JSON file';

  @override
  String get dataFeedback => 'Feedback';

  @override
  String get dataSignedIn => 'Signed in';

  @override
  String get dataSignedOut => 'Signed out';

  @override
  String dataSignInFailed(String error) {
    return 'Sign-in failed: $error';
  }

  @override
  String get dataExportFailed => 'Export failed';

  @override
  String get dataBackupReady => 'Backup ready to share';

  @override
  String get dataImportCancelled => 'Import cancelled or failed';

  @override
  String dataImportResult(int knownAdded, int collectionsAdded) {
    return 'Added $knownAdded known words and $collectionsAdded new collections';
  }

  @override
  String get dataSignInWithGoogle => 'Sign in with Google';

  @override
  String get dataSignInWithGoogleSubtitle =>
      'Sync known words, collections & history';

  @override
  String get dataGoogleUser => 'Google user';

  @override
  String get dataSignOut => 'Sign out';

  @override
  String get dataRateApp => 'Rate ELED';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutRateApp => 'Rate the app';

  @override
  String get aboutCheckUpdate => 'Check for update';

  @override
  String get aboutSource => 'Source code';

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutLicenses => 'Open-source licenses';

  @override
  String get aboutBuiltBy => 'Built by';

  @override
  String get aboutCurrentVersion => 'Current version';

  @override
  String aboutVersionPrefix(String version) {
    return 'v$version';
  }

  @override
  String get aboutCheckButton => 'Check';

  @override
  String get aboutAutoCheckOnStartup => 'Auto-check on startup';

  @override
  String aboutNewVersionAvailable(String version) {
    return 'v$version available';
  }

  @override
  String get aboutUpdateNow => 'Update now';

  @override
  String get aboutOpen => 'Open';

  @override
  String get aboutUpToDate => 'You\'re up to date';

  @override
  String aboutDownloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String get exerciseCorrect => 'Correct';

  @override
  String get exerciseIncorrect => 'Not quite';

  @override
  String get exerciseAnswerLabel => 'Answer';

  @override
  String get exerciseWhatDoesItMean => 'What does this mean?';

  @override
  String get exerciseListenAndType => 'Listen and type';

  @override
  String get exerciseTypeTheWord => 'Type the word';

  @override
  String get exerciseFillInBlank => 'Fill in the blank';

  @override
  String get exerciseMissingWord => 'Missing word';

  @override
  String get exerciseSkip => 'Skip';

  @override
  String get exerciseCheck => 'Check';

  @override
  String popularityLevelLabel(String level) {
    return 'Level $level';
  }

  @override
  String get bulkImportTitle => 'Import words';

  @override
  String get bulkImportTargetLabel => 'Target collection';

  @override
  String get bulkImportPickCollection => 'Pick a collection';

  @override
  String get bulkImportCreateNew => 'Create new collection…';

  @override
  String get bulkImportNewNameHint => 'Collection name';

  @override
  String get bulkImportPasteLabel => 'Paste words';

  @override
  String get bulkImportPasteHint => 'One word per line. Commas also work.';

  @override
  String get bulkImportPreview => 'Preview';

  @override
  String bulkImportPreviewMatched(int count) {
    return '$count will be added';
  }

  @override
  String bulkImportPreviewSkipped(int count) {
    return '$count skipped (not in vocabulary)';
  }

  @override
  String get bulkImportShowSkipped => 'Show skipped';

  @override
  String get bulkImportHideSkipped => 'Hide';

  @override
  String bulkImportAlreadyIn(int count) {
    return '$count already in collection';
  }

  @override
  String bulkImportConfirmAdd(int count) {
    return 'Add $count words';
  }

  @override
  String get bulkImportNoMatches => 'No matching words found';

  @override
  String get bulkImportEmptyInput => 'Paste at least one word';

  @override
  String get bulkImportNeedCollection => 'Pick or create a collection first';

  @override
  String bulkImportDoneToast(int count, String name) {
    return 'Added $count to \"$name\"';
  }

  @override
  String bulkImportPreviewCustom(int count) {
    return '$count custom (will be auto-translated)';
  }

  @override
  String get bulkImportTranslating => 'Translating custom words…';

  @override
  String get bulkImportCustomBadge => 'custom';

  @override
  String searchAddCustomCta(String word) {
    return 'Use \"$word\" as a custom word';
  }

  @override
  String get helpTopic12Title => 'Import a word list';

  @override
  String get helpTopic12Body =>
      'Open Browse → My collections → tap the upload icon in the top bar. Paste your list (one word per line, or comma-separated), pick a destination collection or create a new one, then Preview. The app shows which words match the bundled dictionary, which are \"custom\" (auto-translated via Google), and which already exist. Confirm and they are added in one go. Custom words show a small CUSTOM badge in the list and carry the translated meaning — they stay out of exercises and SRS since they have no IPA or audio.';

  @override
  String get exerciseTypeEnglishFor =>
      'Type the English word for the meaning below';

  @override
  String get exerciseAnagramTitle => 'Unscramble the word';

  @override
  String get exerciseAnagramClear => 'Clear';

  @override
  String get exerciseFirstLetterTitle => 'Type the rest of the word';

  @override
  String get exerciseReverseTypingTitle => 'Type the meaning';

  @override
  String get exerciseReverseTypingHint => 'Vietnamese meaning';

  @override
  String get speedMatchTitle => 'Speed match';

  @override
  String speedMatchSubtitle(int seconds) {
    return 'Match as many as you can in ${seconds}s';
  }

  @override
  String get speedMatchStart => 'Start';

  @override
  String speedMatchScore(int count) {
    return '$count matched';
  }

  @override
  String get speedMatchTimeUp => 'Times up';

  @override
  String get speedMatchPlayAgain => 'Play again';

  @override
  String get speedMatchNeedMore => 'Need at least 6 new or learning words';

  @override
  String get speedMatchToday => 'Speed match';

  @override
  String get helpTopic13Title => 'Mini games & exercises';

  @override
  String get helpTopic13Body =>
      'Each card uses one of several exercise styles to keep practice varied:\n\n• Recognize — classic flashcard.\n• Multiple choice — pick the right meaning.\n• Listen and type — hear the word, type it.\n• Fill in context — Oxford sentence with the word blanked out. If no sentence exists, youll see the meaning and type the English word.\n• Anagram — drag-tap the scrambled letters into order.\n• First letter — meaning + first letter, type the rest.\n• Reverse typing — see the English word, type the meaning.\n\nThe Today screen also offers two standalone games when you have enough fresh words: Match game (4–6 calm pairs) and Speed match (30-second timer).';
}
