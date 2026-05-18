// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'ELED';

  @override
  String get languageSettingTitle => 'Ngôn ngữ';

  @override
  String get languageSettingSubtitle => 'Ngôn ngữ ứng dụng';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get today => 'Hôm nay';

  @override
  String get todaySessionLabel => 'Phiên hôm nay';

  @override
  String todaySessionCountSingular(int count) {
    return '$count từ';
  }

  @override
  String todaySessionCountPlural(int count) {
    return '$count từ';
  }

  @override
  String todayPillReview(int count) {
    return '$count ôn';
  }

  @override
  String todayPillNew(int count) {
    return '$count mới';
  }

  @override
  String get todayStartSession => 'Bắt đầu';

  @override
  String get todayMatchGameTitle => 'Ghép cặp';

  @override
  String get todayMatchGameSubtitle => 'Ghép từ với nghĩa';

  @override
  String get todayMatchGameNotEnough =>
      'Cần ít nhất 4 từ mới hoặc đang học để chơi';

  @override
  String get todayAllCaughtUp => 'Đã ôn hết';

  @override
  String get todayAllCaughtUpSubtitle =>
      'Không còn từ cần ôn. Hãy duyệt chủ đề hoặc quay lại sau.';

  @override
  String get todayStatKnown => 'Đã biết';

  @override
  String get todayStatToLearn => 'Cần học';

  @override
  String get todayStreak => 'Chuỗi';

  @override
  String get todayStreakNone => 'Bắt đầu chuỗi hôm nay';

  @override
  String todayStreakDaysSingular(int count) {
    return '$count ngày';
  }

  @override
  String todayStreakDaysPlural(int count) {
    return '$count ngày';
  }

  @override
  String get todayTooltipSearch => 'Tìm kiếm';

  @override
  String get todayTooltipBrowse => 'Duyệt';

  @override
  String get todayTooltipSettings => 'Cài đặt';

  @override
  String get weekdayMonday => 'Thứ Hai';

  @override
  String get weekdayTuesday => 'Thứ Ba';

  @override
  String get weekdayWednesday => 'Thứ Tư';

  @override
  String get weekdayThursday => 'Thứ Năm';

  @override
  String get weekdayFriday => 'Thứ Sáu';

  @override
  String get weekdaySaturday => 'Thứ Bảy';

  @override
  String get weekdaySunday => 'Chủ Nhật';

  @override
  String get monthJanuary => 'Tháng 1';

  @override
  String get monthFebruary => 'Tháng 2';

  @override
  String get monthMarch => 'Tháng 3';

  @override
  String get monthApril => 'Tháng 4';

  @override
  String get monthMay => 'Tháng 5';

  @override
  String get monthJune => 'Tháng 6';

  @override
  String get monthJuly => 'Tháng 7';

  @override
  String get monthAugust => 'Tháng 8';

  @override
  String get monthSeptember => 'Tháng 9';

  @override
  String get monthOctober => 'Tháng 10';

  @override
  String get monthNovember => 'Tháng 11';

  @override
  String get monthDecember => 'Tháng 12';

  @override
  String get syncPreparing => 'Đang chuẩn bị từ vựng…';

  @override
  String get syncLoading => 'Đang tải từ vựng…';

  @override
  String get syncErrorTitle => 'Không tải được từ vựng';

  @override
  String get syncTryAgain => 'Thử lại';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsAppearanceSubtitle => 'Chủ đề';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsNotificationsSubtitle => 'Nhắc học từ vựng';

  @override
  String get settingsData => 'Dữ liệu';

  @override
  String get settingsDataSubtitle => 'Sao lưu và đặt lại';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get settingsAboutSubtitle => 'Phiên bản và đóng góp';

  @override
  String get appearanceTitle => 'Giao diện';

  @override
  String get appearanceTheme => 'Chủ đề';

  @override
  String get appearanceThemeSubtitle => 'Chọn bảng màu. Thay đổi áp dụng ngay.';

  @override
  String get appearanceMatchSystem => 'Theo hệ thống';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get commonCancel => 'Huỷ';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonDone => 'Xong';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonOk => 'OK';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonNext => 'Tiếp';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonSkip => 'Bỏ qua';

  @override
  String get commonDelete => 'Xoá';

  @override
  String get commonReset => 'Đặt lại';

  @override
  String get commonError => 'Có lỗi xảy ra';

  @override
  String get commonRemove => 'Gỡ';

  @override
  String get commonUndo => 'Hoàn tác';

  @override
  String get commonAllow => 'Cho phép';

  @override
  String get commonNotNow => 'Để sau';

  @override
  String get commonOpen => 'Mở';

  @override
  String get commonCheck => 'Kiểm tra';

  @override
  String get menuTitle => 'Duyệt';

  @override
  String get menuPopularity => 'Theo cấp độ';

  @override
  String get menuTopic => 'Theo chủ đề';

  @override
  String get menuCollections => 'Bộ sưu tập';

  @override
  String get menuKnownWords => 'Từ đã biết';

  @override
  String get menuChooseModeLabel => 'Chọn chế độ';

  @override
  String get menuChooseModeQuestion => 'Hôm nay bạn muốn\nhọc thế nào?';

  @override
  String get menuContinueLearning => 'Tiếp tục học';

  @override
  String menuContinueProgress(String label, int current, int total) {
    return '$label · $current / $total';
  }

  @override
  String get menuCardPopularityTitle => 'Cấp độ';

  @override
  String get menuCardPopularitySubtitle => 'Học từ vựng từ A1 đến C1';

  @override
  String get menuCardTopicsTitle => 'Chủ đề';

  @override
  String get menuCardTopicsSubtitle => 'Theo nhóm: động vật, du lịch…';

  @override
  String get menuCardCollectionsTitle => 'Bộ sưu tập';

  @override
  String get menuCardCollectionsSubtitle => 'Danh sách từ của bạn';

  @override
  String get menuCardKnownTitle => 'Từ đã biết';

  @override
  String get menuCardKnownSubtitle => 'Ôn lại những từ bạn đã thuộc';

  @override
  String get menuCardHistoryTitle => 'Lịch sử';

  @override
  String get menuCardHistorySubtitle => 'Từ qua thông báo';

  @override
  String get menuCouldNotResume => 'Không thể tiếp tục — từ vựng đã thay đổi';

  @override
  String menuMarkedKnownToast(String word) {
    return 'Đã thêm \"$word\" vào danh sách từ đã biết';
  }

  @override
  String get homeSearchHint => 'Tìm một từ';

  @override
  String get homeNoResults => 'Không có kết quả';

  @override
  String get homeNoResultsHint =>
      'Thử chính tả khác hoặc duyệt theo cấp độ / chủ đề.';

  @override
  String get homeTitleKnown => 'Từ đã biết';

  @override
  String get homeTitleHistory => 'Lịch sử';

  @override
  String get homeTitleCollection => 'Bộ sưu tập';

  @override
  String get homeTitleTopic => 'Chủ đề';

  @override
  String get homeTitleSearch => 'Tìm kiếm';

  @override
  String get homeTitlePopularity => 'Cấp độ';

  @override
  String get homeSearchFieldHint => 'Nhập từ hoặc nghĩa…';

  @override
  String get homeClearHistoryTitle => 'Xoá lịch sử?';

  @override
  String get homeClearHistoryBody =>
      'Việc này sẽ xoá toàn bộ lịch sử thông báo. Không thể hoàn tác.';

  @override
  String get homeHistoryCleared => 'Đã xoá lịch sử';

  @override
  String get homeWordAddedToCollection => 'Đã thêm từ vào bộ sưu tập';

  @override
  String get homeRemoveFromCollectionTitle => 'Gỡ khỏi bộ sưu tập?';

  @override
  String homeRemoveFromCollectionBody(String word) {
    return 'Gỡ \"$word\" khỏi bộ sưu tập này?';
  }

  @override
  String homeRemovedWord(String word) {
    return 'Đã gỡ \"$word\"';
  }

  @override
  String get homeSearchPromptTitle => 'Tìm trong toàn bộ từ vựng';

  @override
  String get homeSearchPromptSubtitle => 'Nhập một từ hoặc nghĩa để bắt đầu.';

  @override
  String get homeNoWordsTitle => 'Chưa có từ nào để hiển thị';

  @override
  String get homeNoWordsPopularitySubtitle =>
      'Thử chọn cấp độ khác ở trên, hoặc quay lại sau khi đồng bộ từ vựng.';

  @override
  String get homeNoWordsGenericSubtitle =>
      'Thử điều chỉnh bộ lọc hoặc quay lại sau lần đồng bộ tiếp theo.';

  @override
  String get homeEmptyCollectionTitle => 'Bộ sưu tập này trống';

  @override
  String get homeEmptyCollectionSubtitle =>
      'Bấm nút + ở trên để thêm từ đầu tiên.';

  @override
  String get homeEmptyHistoryTitle => 'Chưa có lịch sử thông báo';

  @override
  String get homeEmptyHistorySubtitle =>
      'Những từ được gửi đến bạn qua thông báo sẽ hiện ở đây.';

  @override
  String get homeEmptyKnownTitle => 'Chưa có từ đã biết';

  @override
  String get homeEmptyKnownSubtitle =>
      'Đánh dấu từ là đã biết khi học để xem chúng ở đây.';

  @override
  String get homeNoMatchesTitle => 'Không tìm thấy';

  @override
  String get homeNoMatchesSubtitle => 'Thử từ khoá khác.';

  @override
  String homeDayLabel(int day) {
    return 'Ngày $day';
  }

  @override
  String homeWordsCount(int count) {
    return '$count từ';
  }

  @override
  String learningProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get learningKnowThis => 'Tôi đã biết từ này';

  @override
  String get learningAgain => 'Lại';

  @override
  String get learningHard => 'Khó';

  @override
  String get learningGood => 'Dễ';

  @override
  String get learningEasy => 'Dễ';

  @override
  String get learningTapToSpeak => 'Bấm để nghe';

  @override
  String get learningTypeWhatYouHear => 'Gõ lại từ bạn nghe';

  @override
  String get learningFillInBlank => 'Điền vào chỗ trống';

  @override
  String get learningChooseMeaning => 'Chọn nghĩa đúng';

  @override
  String get learningCheck => 'Kiểm tra';

  @override
  String get learningSearchTitle => 'Tìm kiếm';

  @override
  String learningDayTitle(int day) {
    return 'Ngày $day';
  }

  @override
  String get learningTooltipKnown => 'Tôi đã biết từ này';

  @override
  String get learningTooltipDetails => 'Chi tiết từ';

  @override
  String get learningSkipTitle => 'Bỏ qua từ này từ giờ?';

  @override
  String learningSkipBody(String word) {
    return '\"$word\" sẽ được đánh dấu là đã thuộc và không xuất hiện trong phiên học hằng ngày trong thời gian dài.';
  }

  @override
  String get learningSkipAction => 'Bỏ qua';

  @override
  String learningWordOfTotal(int current, int total) {
    return 'Từ $current / $total';
  }

  @override
  String get learningDefinition => 'Định nghĩa';

  @override
  String get learningDefinitionEnglish => 'English';

  @override
  String get learningDefinitionVietnamese => 'Tiếng Việt';

  @override
  String get learningMarkedKnown => 'Đã đánh dấu là đã biết';

  @override
  String get learningRemovedFromKnown => 'Đã gỡ khỏi danh sách từ đã biết';

  @override
  String get learningCouldntOpenLink => 'Không mở được liên kết';

  @override
  String get learningLastSession => 'Phiên gần nhất';

  @override
  String learningSessionLabelDay(int day) {
    return 'Ngày $day';
  }

  @override
  String get resultsTitle => 'Hoàn thành';

  @override
  String get resultsReviewed => 'Đã ôn';

  @override
  String get resultsAccuracy => 'Độ chính xác';

  @override
  String get resultsTimeSpent => 'Thời gian';

  @override
  String get resultsFinish => 'Kết thúc';

  @override
  String get resultsReviewMistakes => 'Xem từ sai';

  @override
  String get resultsHeadlineEnded => 'Phiên đã kết thúc';

  @override
  String get resultsHeadlineOutstanding => 'Xuất sắc';

  @override
  String get resultsHeadlineNice => 'Làm tốt lắm';

  @override
  String get resultsHeadlineKeepGoing => 'Cố gắng tiếp';

  @override
  String get resultsHeadlineTough => 'Khó nhằn — đúng ý đồ';

  @override
  String get resultsNoCardsRated => 'Chưa đánh giá thẻ nào.';

  @override
  String resultsReviewedSingular(int count) {
    return 'Bạn đã ôn $count từ.';
  }

  @override
  String resultsReviewedPlural(int count) {
    return 'Bạn đã ôn $count từ.';
  }

  @override
  String get resultsCorrect => 'Đúng';

  @override
  String get resultsStruggled => 'Khó nhớ';

  @override
  String get resultsStreakExtended => 'Chuỗi được nối dài';

  @override
  String get resultsStreak => 'Chuỗi';

  @override
  String resultsStreakDaysSingular(int count) {
    return '$count ngày';
  }

  @override
  String resultsStreakDaysPlural(int count) {
    return '$count ngày';
  }

  @override
  String get resultsAnotherSession => 'Phiên khác';

  @override
  String get resultsBackToToday => 'Về Hôm nay';

  @override
  String get onboardingNext => 'Tiếp';

  @override
  String get onboardingGetStarted => 'Bắt đầu';

  @override
  String get onboardingSkip => 'Bỏ qua';

  @override
  String get onboarding1Title => 'Học thông minh, không cần vất vả';

  @override
  String get onboarding1Body =>
      'ELED sử dụng phương pháp lặp lại ngắt quãng — bạn sẽ thấy lại mỗi từ ngay trước khi quên. Hàng trăm từ sẽ nhớ được chỉ với vài phút mỗi ngày.';

  @override
  String get onboarding2Title => 'Mỗi ngày một phiên học';

  @override
  String get onboarding2Body =>
      'Mỗi sáng, ứng dụng chọn ra những từ bạn sắp quên cùng vài từ mới. Bấm Bắt đầu — thường khoảng 20 từ, ~5 phút.';

  @override
  String get onboarding3Title => 'Đánh giá khi học';

  @override
  String get onboarding3Body =>
      'Sau mỗi thẻ, hãy đánh giá: Lại / Khó / Tốt / Dễ. Đánh giá của bạn quyết định khi nào từ đó xuất hiện lại — Dễ sẽ biến mất một tháng, Lại quay lại ngày mai.';

  @override
  String get onboarding4Title => 'Đa dạng hơn nhồi nhét';

  @override
  String get onboarding4Body =>
      'Khi học, các phiên kết hợp thẻ học, trắc nghiệm, nghe và gõ, điền vào ngữ cảnh, cùng trò ghép 4 cặp. Cùng từ vựng, mỗi lần một góc nhìn mới.';

  @override
  String get helpTitle => 'Trợ giúp';

  @override
  String get helpAppBarTitle => 'Hướng dẫn sử dụng';

  @override
  String get helpTopic1Title => 'Cách học hoạt động';

  @override
  String get helpTopic1Body =>
      'ELED dùng lặp lại ngắt quãng. Mỗi lần bạn đánh giá một từ, ứng dụng tính ra khi nào bạn dễ quên nhất và đưa từ đó ra ngay trước thời điểm ấy — nhờ vậy bạn chỉ tốn thời gian cho từ sắp tuột mất, không phải từ đã thuộc.';

  @override
  String get helpTopic2Title => 'Phiên Hôm nay là gì?';

  @override
  String get helpTopic2Body =>
      'Thẻ lớn trên màn chính là danh sách của bạn cho ngày hôm nay, gồm:\n• Từ đến hạn ôn (đã hết khoảng cách lịch học)\n• Vài từ mới hoàn toàn để mở rộng vốn từ\n\nMỗi phiên giới hạn ~20 từ. Bấm Bắt đầu để vào học. Khi đủ từ mới hoặc đang học, bạn sẽ thấy thêm thẻ Ghép cặp (4-6 cặp thư thái) và Match tốc độ (đồng hồ 30 giây) bên dưới.';

  @override
  String get helpTopic3Title => 'Ba nút đánh giá';

  @override
  String get helpTopic3Body =>
      'Sau mỗi thẻ, bạn đánh giá mức độ nắm từ. App dùng đánh giá đó để xếp lịch cho từ xuất hiện lần tiếp theo:\n\n• Lại — \"Quên rồi\". Từ quay lại vào ngày mai.\n• Khó — \"Biết, nhưng vất vả\". Khoảng cách ngắn hơn lần trước một chút.\n• Dễ — \"Biết\". Khoảng cách chuẩn (mỗi lần Dễ nhân khoảng cách lên).\n\nNếu từ quá dễ, không cần lên lịch nữa, bấm icon ✓ trên thanh trên cùng để đánh dấu đã biết và bỏ qua trong thời gian dài.';

  @override
  String get helpTopic4Title => 'Nhiều kiểu học';

  @override
  String get helpTopic4Body =>
      'Các thẻ trong một phiên luân phiên qua sáu kiểu bài tập để không bị nhàm chán: Nhận biết, Trắc nghiệm, Nghe và gõ, Điền vào câu, Anagram, Chữ cái đầu, và Gõ ngược. Xem \"Mini game & bài tập\" bên dưới để biết chi tiết mỗi kiểu.\n\nKhi bạn đã thuộc một từ, phiên học sẽ chuyển sang thẻ Nhận biết nhẹ nhàng — không còn câu đố trên những từ bạn đã nắm vững.';

  @override
  String get helpTopic5Title => 'Trò ghép cặp';

  @override
  String get helpTopic5Body =>
      'Mini game ghép cặp, tối đa 6 cặp (tối thiểu 4), hiện dưới Bắt đầu khi bạn có ít nhất 4 từ mới hoặc đang học trong hàng. Bấm vào từ rồi bấm nghĩa của nó; cặp đúng mờ xanh, sai nhấp nháy đỏ. Độ chính xác tự đánh giá mỗi từ theo cùng lịch SRS với luồng chính.';

  @override
  String get helpTopic6Title => 'Đánh dấu từ là đã biết';

  @override
  String get helpTopic6Body =>
      'Trên bất kỳ thẻ học nào, bấm icon ✓ ở thanh trên cùng. Từ sẽ được thăng cấp lên mức đã thuộc (không xuất hiện trong các phiên hằng ngày trong thời gian dài) và thẻ tiếp theo trượt vào. Snackbar với Hoàn tác cho bạn vài giây để rút lại nếu bấm nhầm. Bấm ✓ lần nữa trên một từ đã biết sẽ gỡ nó khỏi danh sách từ đã biết.';

  @override
  String get helpTopic7Title => 'Chuỗi & ngày hoạt động';

  @override
  String get helpTopic7Body =>
      'Mỗi ngày bạn đánh giá ít nhất một thẻ sẽ được tính vào chuỗi. Bản đồ nhiệt 28 ngày trên Hôm nay cho thấy bạn đã luyện những ngày nào trong 4 tuần qua. Bỏ một ngày, chuỗi vẫn còn; bỏ hai ngày, chuỗi về 0.';

  @override
  String get helpTopic8Title => 'Thông báo';

  @override
  String get helpTopic8Body =>
      'Cài đặt → Thông báo cho phép chọn tần suất nhắc từ vựng và khung giờ hoạt động. Thông báo ưu tiên từ trong hàng đợi đến hạn, nên mỗi lần bấm là một lần ôn thực sự — không phải từ ngẫu nhiên bạn đã biết.\n\nTrên một số máy Android, bạn cần cho phép ELED chạy nền để thông báo tiếp tục hoạt động sau 1 ngày. Màn hình cài đặt sẽ nhắc bạn lần đầu.';

  @override
  String get helpTopic9Title => 'Duyệt từ điển';

  @override
  String get helpTopic9Body =>
      'Biểu tượng ứng dụng trên Hôm nay mở Duyệt — chế độ xem theo từng chế độ kiểu cũ. Hữu ích khi bạn muốn xem mọi từ ở một cấp độ cụ thể, hoặc lấy từ một bộ sưu tập. Cách nhóm theo ngày ở đây được trộn theo cấp độ để giữ sự đa dạng.';

  @override
  String get helpTopic10Title => 'Tìm kiếm';

  @override
  String get helpTopic10Body =>
      'Biểu tượng kính lúp tìm trong toàn bộ từ vựng theo từ hoặc bản dịch. Dùng cho tra cứu nhanh; bấm vào kết quả mở thẻ Nhận diện đầy đủ với audio, IPA và định nghĩa.';

  @override
  String get helpTopic11Title => 'Sao lưu & đồng bộ';

  @override
  String get helpTopic11Body =>
      'Cài đặt → Tài khoản & dữ liệu cho phép Xuất từ đã biết + bộ sưu tập sang tệp JSON qua bảng chia sẻ hệ thống, và Nhập lại đúng định dạng đó. Đăng nhập Google để tự động đồng bộ danh sách từ đã biết và bộ sưu tập trên các thiết bị.';

  @override
  String get matchGameTitle => 'Ghép cặp';

  @override
  String get matchGameCongrats => 'Tuyệt!';

  @override
  String get matchGamePlayAgain => 'Chơi lại';

  @override
  String get matchGameDone => 'Xong';

  @override
  String matchGameProgress(int matched, int total) {
    return '$matched / $total';
  }

  @override
  String get collectionsTitle => 'Bộ sưu tập';

  @override
  String get collectionsEmpty => 'Chưa có bộ sưu tập nào';

  @override
  String get collectionsEmptyHint => 'Bấm dấu lưu trên một từ để thêm vào đây.';

  @override
  String get collectionsNewCollection => 'Bộ sưu tập mới';

  @override
  String get collectionsNameHint => 'Tên';

  @override
  String get collectionsCreate => 'Tạo';

  @override
  String get collectionsDelete => 'Xoá bộ sưu tập';

  @override
  String get collectionsDeleteConfirm =>
      'Xoá bộ sưu tập này? Các từ vẫn còn trong thư viện.';

  @override
  String get collectionsAddTo => 'Thêm vào bộ sưu tập';

  @override
  String get collectionsCreateNew => '+ TẠO MỚI';

  @override
  String get collectionsEmptyUppercase => 'CHƯA CÓ BỘ SƯU TẬP.';

  @override
  String get collectionsNamePlaceholder => 'ví dụ: Từ TOEFL...';

  @override
  String collectionsDeleteTitle(String name) {
    return 'XOÁ $name?';
  }

  @override
  String get collectionsDeleteBody => 'Bạn có chắc muốn xoá bộ sưu tập này?';

  @override
  String collectionsWordsCount(int count) {
    return '$count từ';
  }

  @override
  String get topicsTitle => 'Chủ đề';

  @override
  String get topicsEmptyTitle => 'Không có chủ đề ở các cấp đã chọn';

  @override
  String get topicsEmptyHint => 'Chọn thêm cấp độ ở trên để xem chủ đề.';

  @override
  String topicsCategorySummarySingular(int topicCount, int wordCount) {
    return '$topicCount chủ đề · $wordCount từ';
  }

  @override
  String topicsCategorySummaryPlural(int topicCount, int wordCount) {
    return '$topicCount chủ đề · $wordCount từ';
  }

  @override
  String topicCategoryWordSingular(int count) {
    return '$count từ';
  }

  @override
  String topicCategoryWordPlural(int count) {
    return '$count từ';
  }

  @override
  String topicCategoryTitle(String category) {
    return '$category';
  }

  @override
  String get notificationsTitle => 'Thông báo';

  @override
  String get notificationsEnable => 'Nhắc học từ';

  @override
  String get notificationsEnableSubtitle =>
      'Nhận một từ mới định kỳ khi không mở app.';

  @override
  String get notificationsInterval => 'Khoảng cách';

  @override
  String notificationsIntervalMinutes(int count) {
    return '$count phút';
  }

  @override
  String get notificationsActiveHours => 'Khung giờ hoạt động';

  @override
  String get notificationsFrom => 'Từ';

  @override
  String get notificationsTo => 'Đến';

  @override
  String get notificationsLevels => 'Cấp độ';

  @override
  String get notificationsTopics => 'Chủ đề';

  @override
  String get notificationsAll => 'Tất cả';

  @override
  String get notificationsFrequency => 'Tần suất';

  @override
  String get notificationsFrequencySubtitle => 'Tần suất gửi một từ mới';

  @override
  String get notificationsActiveHoursSubtitle => 'Chỉ nhắc trong khung giờ này';

  @override
  String get notificationsDifficultyLevels => 'Cấp độ';

  @override
  String get notificationsDifficultyLevelsSubtitle =>
      'Chọn các cấp CEFR bạn muốn';

  @override
  String get notificationsTopicsSubtitle =>
      'Tuỳ chọn — để trống để dùng mọi chủ đề';

  @override
  String get notificationsUntil => 'Đến';

  @override
  String get notificationsOff => 'Tắt';

  @override
  String get notificationsSaved => 'Đã lưu cài đặt thông báo';

  @override
  String get notificationsBatteryTitle => 'Giữ thông báo chạy đều';

  @override
  String get notificationsBatteryBody =>
      'Android có thể tạm dừng thông báo ELED sau một ngày để tiết kiệm pin. Cho phép ELED chạy không giới hạn để thông báo tiếp tục hoạt động.';

  @override
  String get notificationsBatteryCardTitle => 'Cho phép chạy nền';

  @override
  String get notificationsBatteryCardSubtitle =>
      'Bấm để thông báo tiếp tục sau 1 ngày';

  @override
  String get dataTitle => 'Dữ liệu';

  @override
  String get dataBackup => 'Sao lưu';

  @override
  String get dataExport => 'Xuất';

  @override
  String get dataImport => 'Nhập';

  @override
  String get dataResetTitle => 'Đặt lại tiến độ';

  @override
  String get dataResetSubtitle =>
      'Xoá trạng thái SRS và danh sách từ đã biết. Thư viện từ vựng giữ nguyên.';

  @override
  String get dataResetConfirmTitle => 'Đặt lại toàn bộ tiến độ?';

  @override
  String get dataResetConfirmBody =>
      'Việc này xoá lịch sử SRS, chuỗi ngày và danh sách từ đã biết. Không thể hoàn tác.';

  @override
  String get dataClearCache => 'Xoá cache';

  @override
  String get dataScreenTitle => 'Tài khoản & dữ liệu';

  @override
  String get dataAccountTitle => 'Tài khoản';

  @override
  String get dataAccountSubtitle =>
      'Đăng nhập để đồng bộ từ đã biết và bộ sưu tập giữa các thiết bị';

  @override
  String get dataBackupSubtitle =>
      'Lưu từ đã biết và bộ sưu tập của bạn dưới dạng tệp JSON';

  @override
  String get dataFeedback => 'Phản hồi';

  @override
  String get dataSignedIn => 'Đã đăng nhập';

  @override
  String get dataSignedOut => 'Đã đăng xuất';

  @override
  String dataSignInFailed(String error) {
    return 'Đăng nhập thất bại: $error';
  }

  @override
  String get dataExportFailed => 'Xuất thất bại';

  @override
  String get dataBackupReady => 'Bản sao lưu sẵn sàng để chia sẻ';

  @override
  String get dataImportCancelled => 'Đã huỷ hoặc nhập thất bại';

  @override
  String dataImportResult(int knownAdded, int collectionsAdded) {
    return 'Đã thêm $knownAdded từ đã biết và $collectionsAdded bộ sưu tập mới';
  }

  @override
  String get dataSignInWithGoogle => 'Đăng nhập bằng Google';

  @override
  String get dataSignInWithGoogleSubtitle =>
      'Đồng bộ từ đã biết, bộ sưu tập & lịch sử';

  @override
  String get dataGoogleUser => 'Người dùng Google';

  @override
  String get dataSignOut => 'Đăng xuất';

  @override
  String get dataRateApp => 'Đánh giá ELED';

  @override
  String get aboutTitle => 'Giới thiệu';

  @override
  String get aboutVersion => 'Phiên bản';

  @override
  String get aboutRateApp => 'Đánh giá ứng dụng';

  @override
  String get aboutCheckUpdate => 'Kiểm tra cập nhật';

  @override
  String get aboutSource => 'Mã nguồn';

  @override
  String get aboutPrivacy => 'Chính sách riêng tư';

  @override
  String get aboutLicenses => 'Giấy phép nguồn mở';

  @override
  String get aboutBuiltBy => 'Phát triển bởi';

  @override
  String get aboutCurrentVersion => 'Phiên bản hiện tại';

  @override
  String aboutVersionPrefix(String version) {
    return 'v$version';
  }

  @override
  String get aboutCheckButton => 'Kiểm tra';

  @override
  String get aboutAutoCheckOnStartup => 'Tự kiểm tra khi mở app';

  @override
  String aboutNewVersionAvailable(String version) {
    return 'Có v$version';
  }

  @override
  String get aboutUpdateNow => 'Cập nhật ngay';

  @override
  String get aboutOpen => 'Mở';

  @override
  String get aboutUpToDate => 'Bạn đang dùng phiên bản mới nhất';

  @override
  String aboutDownloadFailed(String error) {
    return 'Tải về thất bại: $error';
  }

  @override
  String get exerciseCorrect => 'Chính xác';

  @override
  String get exerciseIncorrect => 'Chưa đúng';

  @override
  String get exerciseAnswerLabel => 'Đáp án';

  @override
  String get exerciseWhatDoesItMean => 'Từ này nghĩa là gì?';

  @override
  String get exerciseListenAndType => 'Nghe và gõ';

  @override
  String get exerciseTypeTheWord => 'Gõ từ';

  @override
  String get exerciseFillInBlank => 'Điền vào chỗ trống';

  @override
  String get exerciseMissingWord => 'Từ còn thiếu';

  @override
  String get exerciseSkip => 'Bỏ qua';

  @override
  String get exerciseCheck => 'Kiểm tra';

  @override
  String popularityLevelLabel(String level) {
    return 'Cấp $level';
  }

  @override
  String get bulkImportTitle => 'Nhập danh sách từ';

  @override
  String get bulkImportTargetLabel => 'Bộ sưu tập đích';

  @override
  String get bulkImportPickCollection => 'Chọn bộ sưu tập';

  @override
  String get bulkImportCreateNew => 'Tạo bộ sưu tập mới…';

  @override
  String get bulkImportNewNameHint => 'Tên bộ sưu tập';

  @override
  String get bulkImportPasteLabel => 'Dán danh sách từ';

  @override
  String get bulkImportPasteHint => 'Mỗi dòng một từ. Dấu phẩy cũng được.';

  @override
  String get bulkImportPreview => 'Xem trước';

  @override
  String bulkImportPreviewMatched(int count) {
    return '$count từ sẽ được thêm';
  }

  @override
  String bulkImportPreviewSkipped(int count) {
    return '$count từ bị bỏ qua (không có trong từ vựng)';
  }

  @override
  String get bulkImportShowSkipped => 'Xem từ bị bỏ qua';

  @override
  String get bulkImportHideSkipped => 'Ẩn';

  @override
  String bulkImportAlreadyIn(int count) {
    return '$count từ đã có trong bộ sưu tập';
  }

  @override
  String bulkImportConfirmAdd(int count) {
    return 'Thêm $count từ';
  }

  @override
  String get bulkImportNoMatches => 'Không khớp được từ nào';

  @override
  String get bulkImportEmptyInput => 'Hãy dán ít nhất một từ';

  @override
  String get bulkImportNeedCollection => 'Chọn hoặc tạo bộ sưu tập trước';

  @override
  String bulkImportDoneToast(int count, String name) {
    return 'Đã thêm $count từ vào \"$name\"';
  }

  @override
  String bulkImportPreviewCustom(int count) {
    return '$count từ tự định nghĩa (sẽ dịch tự động)';
  }

  @override
  String get bulkImportTranslating => 'Đang dịch từ tự định nghĩa…';

  @override
  String get bulkImportCustomBadge => 'tự định nghĩa';

  @override
  String searchAddCustomCta(String word) {
    return 'Dùng \"$word\" làm từ tự định nghĩa';
  }

  @override
  String get helpTopic12Title => 'Nhập danh sách từ';

  @override
  String get helpTopic12Body =>
      'Mở Duyệt → Bộ sưu tập → bấm icon upload ở thanh trên. Dán danh sách (mỗi dòng một từ, hoặc cách nhau bằng dấu phẩy), chọn bộ sưu tập đích hoặc tạo mới ngay, rồi bấm Xem trước. App sẽ cho biết từ nào khớp với từ vựng có sẵn, từ nào là \"tự định nghĩa\" (sẽ tự dịch qua Google), và từ nào đã có. Xác nhận một phát là thêm hết. Từ tự định nghĩa hiển thị nhãn TỰ ĐỊNH NGHĨA nhỏ kèm nghĩa dịch — chúng không tham gia bài tập và SRS vì thiếu IPA và audio.';

  @override
  String get exerciseTypeEnglishFor => 'Gõ từ tiếng Anh cho nghĩa dưới đây';

  @override
  String get exerciseAnagramTitle => 'Sắp xếp chữ cái';

  @override
  String get exerciseAnagramClear => 'Xoá';

  @override
  String get exerciseFirstLetterTitle => 'Gõ phần còn lại của từ';

  @override
  String get exerciseReverseTypingTitle => 'Gõ nghĩa';

  @override
  String get exerciseReverseTypingHint => 'Nghĩa tiếng Việt';

  @override
  String get speedMatchTitle => 'Match tốc độ';

  @override
  String speedMatchSubtitle(int seconds) {
    return 'Ghép càng nhiều càng tốt trong ${seconds}s';
  }

  @override
  String get speedMatchStart => 'Bắt đầu';

  @override
  String speedMatchScore(int count) {
    return '$count cặp đã ghép';
  }

  @override
  String get speedMatchTimeUp => 'Hết giờ';

  @override
  String get speedMatchPlayAgain => 'Chơi lại';

  @override
  String get speedMatchNeedMore => 'Cần ít nhất 6 từ mới hoặc đang học';

  @override
  String get speedMatchToday => 'Match tốc độ';

  @override
  String get helpTopic13Title => 'Mini game & bài tập';

  @override
  String get helpTopic13Body =>
      'Mỗi thẻ dùng một trong nhiều kiểu bài tập để đa dạng:\n\n• Nhận biết — flashcard cổ điển.\n• Trắc nghiệm — chọn nghĩa đúng.\n• Nghe và gõ — nghe từ, gõ lại.\n• Điền vào câu — câu Oxford có chỗ trống cho từ. Nếu không có câu, bạn sẽ thấy nghĩa và gõ từ tiếng Anh.\n• Anagram — tap chữ cái xáo trộn vào đúng thứ tự.\n• Chữ cái đầu — có nghĩa + chữ đầu, gõ phần còn lại.\n• Gõ ngược — thấy từ tiếng Anh, gõ nghĩa.\n\nMàn Today cũng có hai trò độc lập khi đủ từ mới: Ghép cặp (4–6 cặp thư thái) và Match tốc độ (đồng hồ 30 giây).';

  @override
  String get posFilterLabel => 'Lọc theo loại từ';

  @override
  String get posFilterAll => 'Tất cả';

  @override
  String get posNoun => 'Danh từ';

  @override
  String get posVerb => 'Động từ';

  @override
  String get posAdjective => 'Tính từ';

  @override
  String get posAdverb => 'Trạng từ';

  @override
  String get posPreposition => 'Giới từ';

  @override
  String get posConjunction => 'Liên từ';

  @override
  String get posPronoun => 'Đại từ';

  @override
  String get posDeterminer => 'Hạn định từ';

  @override
  String get posExclamation => 'Cảm thán từ';

  @override
  String get posModal => 'Động từ tình thái';

  @override
  String get posNumber => 'Số từ';

  @override
  String get posArticle => 'Mạo từ';

  @override
  String get notificationsMaxCount => 'Số lượng tối đa';

  @override
  String get notificationsMaxCountSubtitle =>
      'Bao nhiêu thông báo gửi trong mỗi khung giờ hoạt động';

  @override
  String notificationsMaxCountValue(int count) {
    return 'Tối đa $count';
  }
}
