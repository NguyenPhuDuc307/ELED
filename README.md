# ELED - Ứng Dụng Học Từ Vựng Tiếng Anh (Alpha 1)

ELED là ứng dụng học từ vựng Tiếng Anh được thiết kế theo phong cách Neo-Brutalist, tập trung vào phương pháp ghi nhớ ngầm thông qua hệ thống thẻ từ (Flashcards) và tối ưu hóa việc học qua các thông báo hiển thị trên màn hình nền (Background Notifications). 

Tài liệu này cung cấp hướng dẫn chi tiết cách để tận dụng tối đa các tính năng của ELED.


## MỤC LỤC
1. Giới thiệu Giao diện và Phong cách thiết kế
2. Hệ thống Cơ sở Dữ liệu
3. Hướng dẫn Sử dụng Thẻ từ (Flashcards)
4. Hướng dẫn Cài đặt Thông báo Ngầm (Background Notifications)
5. Tính năng Tìm kiếm & Quản lý Lịch sử
6. Widget Màn hình chính (Android Home Screen Widget)


---


## 1. GIỚI THIỆU GIAO DIỆN VÀ PHONG CÁCH THIẾT KẾ
ELED được lập trình với cấu trúc Neo-Brutalist:
- Giao diện sử dụng các mảng màu nguyên bản (Vàng, Đỏ, Xanh) kết hợp với đường viền đen đậm và các góc vuông vức.
- Hệ thống màu sắc được thiết lập tự động điều chỉnh theo chế độ Sáng/Tối (Light/Dark mode) của thiết bị. Các thành phần nền đen sẽ tĩnh, trong khi nền trắng sẽ tự động đảo ngược để đảm bảo độ tương phản cao nhất.


## 2. HỆ THỐNG CƠ SỞ DỮ LIỆU KHỔNG LỒ (🌟 24.853 TỪ VỰNG DUY NHẤT)
Ứng dụng ELED mang trong lòng một cơ sở dữ liệu ngoại tuyến khổng lồ, biến nó thành một trong những từ điển học tập đồ sộ nhất hiện hành, chia làm hai đại phân khu:
- **Tần suất phổ biến (Oxford Core - 5.878 Từ):** Quét qua toàn bộ từ vựng lõi theo tiêu chuẩn quốc tế CEFR, chia thành 5 cấp độ mạch lạc: A1, A2, B1, B2, C1. Đã được lọc trùng tuyệt đối.
- **Chủ đề chuyên biệt (Topics - 23.073 Từ):** Không còn cảm giác "bí ý tưởng" giao tiếp. Hệ thống tự động phân tách và nạp vào 480 chủ đề chuyên sâu tĩnh (Kinh tế, Y tế, Kỹ thuật, Giao tiếp hằng ngày, Môi trường, Công nghệ, v.v.).

👉 Điều Điên Rồ Nhất: Khi có bất cứ lượt truy xuất nào (Học ngẫu nhiên, Phát Thông báo Ngầm hoặc Tìm kiếm thủ công), Hệ thống AI của ELED tự động phá vỡ vách ngăn thư mục, **Bóc tách, đối chiếu và hợp nhất toàn bộ 485 file CSV này thành một Siêu Bộ Não duy nhất chứa chính xác 24.853 Dữ Liệu Flashcard không hề trùng lặp**. Vĩnh biệt khái niệm "khan hiếm từ vựng"!


## 3. HƯỚNG DẪN SỬ DỤNG THẺ TỪ (FLASHCARDS)
Màn hình Flashcard là không gian học tập cốt lõi. Khi thao tác tại đây, bạn cần nắm rõ các chức năng sau:

A. Lật thẻ và Nghe phát âm
- Khi một từ vựng hiện ra, bạn chỉ nhìn thấy từ tiếng Anh.
- Chạm vào giữa màn hình để lật thẻ: Ứng dụng sẽ hiển thị Nghĩa Tiếng Việt, Phiên âm quốc tế (IPA), Từ loại (Danh từ, Động từ, v.v.) và Cấp độ khó của từ.
- Khi thẻ được lật, ứng dụng sẽ tự động phát âm từ vựng (Audio TTS). Bạn có thể bấm vào thẻ thêm lần nữa để nghe lại cách phát âm.

B. Ẩn/Hiện nghĩa Tiếng Việt
- Trên thanh điều hướng (AppBar), có một công tắc (Switch).
- Gạt công tắc này để tắt hoàn toàn phần dịch Tiếng Việt. Tính năng này ép buộc não bộ của bạn phải ghi nhớ từ vựng qua ngữ cảnh tiếng Anh mà không phụ thuộc vào ngôn ngữ mẹ đẻ.

C. Đánh dấu Từ Đã Biết (Known Words)
- Ở góc phải trên cùng của màn hình Flashcard có biểu tượng Dấu Tích (Checkmark).
- Bấm vào biểu tượng này để đánh dấu từ vựng hiện tại là "Đã thuộc". Ứng dụng sẽ hiển thị thông báo "MARKED AS KNOWN!".
- Khi một từ đã bị đánh dấu, hệ thống máy học sẽ loại bỏ nó vĩnh viễn khỏi các bài học và cả hệ thống gửi Thông báo ngầm ở màn hình chính. Đặc biệt, **thuật toán nhận diện đã được nâng cấp để hiểu chính xác định dạng chữ không phân biệt viết hoa/viết thường**, tự động lọc triệt để từ vựng đó khỏi mọi cấp độ học.
- Để bỏ đánh dấu, bấm lại biểu tượng này ("REMOVED FROM KNOWN WORDS!").


## 4. HƯỚNG DẪN CÀI ĐẶT THÔNG BÁO NGẦM (BACKGROUND NOTIFICATIONS)
Đây là tính năng quan trọng nhất của ELED: Nhồi nhét từ vựng thụ động. ELED sẽ gửi một từ vựng ngẫu nhiên lên màn hình khóa hoặc thanh thông báo của điện thoại theo chu kỳ bạn chọn. 

Trình tự thiết lập:
1. Mở ứng dụng, tại màn hình ngoài cùng (Menu Screen), chọn nút "SETTINGS" (Cài đặt).
2. Tại khu vực "LEVELS & TOPIC", hãy tích chọn những cấp độ hoặc chủ đề bạn muốn hệ thống bốc từ vựng ngẫu nhiên (Ví dụ: Chỉ tích B1 và B2).
3. Tại khu vực "NOTIFICATION INTERVAL", gập thanh trượt để chọn khoảng cách thời gian giữa 2 lần gửi (Ví dụ: 30 phút/lần).
4. Tại khu vực "ACTIVE TIME WINDOW", chọn khung giờ bạn thức. Ví dụ: Từ 08:00 đến 22:00. Ngoài khung giờ này, ứng dụng sẽ đi ngủ và không làm phiền bạn.
5. Cuối cùng, bật công tắc "ENABLE NOTIFICATIONS" lên. Khởi chạy đã hoàn tất. 

> **⚡ Nâng cấp Hệ thống thông báo mới nhất:** 
> - Cơ chế lập lịch ngầm (Isolate Background Scheduling) đã được tinh chỉnh, đảm bảo các thông báo được gửi vào các **mốc thời gian thực chính xác tuyệt đối** (ví dụ đúng 09:00, 09:30) thay vì thời gian đếm lùi tương đối.
> - Khắc phục hoàn toàn tình trạng spam thông báo đẩy khi khởi động máy, thu hẹp logic đảm bảo tuân thủ cực kỳ chuẩn xác các Cấp độ/Chủ đề tiếng Anh đã thiết lập.

Cách tương tác với hệ thống Truy cập nhanh (Deep Linking):
- Khi điện thoại hiển thị thông báo từ vựng của ELED, bạn có thể đọc nhanh từ, nghĩa và phiên âm ngay trên thông báo.
- Nếu muốn nghe phát âm hoặc học kỹ hơn, hãy BẤM trực tiếp vào Thông báo đó. ELED sẽ lập tức khởi động và dịch chuyển bạn thẳng vào màn hình Flashcard của đúng chữ đó (Bỏ qua mọi màn hình trung gian).


## 5. TÍNH NĂNG TÌM KIẾM & QUẢN LÝ LỊCH SỬ
Các tính năng quản trị dữ liệu học tập nằm tại màn hình Home (Menu Screen):

A. Tìm Kiếm (Search)
- Bấm vào biểu tượng Kính lúp ở góc màn hình.
- Gõ bất kỳ ký tự nào, ứng dụng sẽ tìm kiếm toàn bộ kho 3000 từ Popularity và kho Topics, trả về kết quả dạng danh sách dạng thẻ siêu nhanh.

B. Quản lý Từ đã biết (Known Words)
- Bấm vào khối vuông ghi "KNOWN WORDS" trên màn hình chính. Chiếc hộp này chứa toàn bộ danh sách các chữ bạn đã ấn nút Dấu Tích (Đã thuộc). 
- Bấm vào từng từ trong danh sách để mở Flashcard ôn tập lại nếu bị quên. Ngược lại, bạn có thể gỡ Dấu Tích ngay lập tức để từ đó quay lại luồng học.

C. Quản lý Vết Thông báo (History Tracker)
- Bấm vào khối vuông "NOTIFICATIONS HISTORY" ở màn hình chính. 
- Màn hình này sẽ liệt kê diễn biến thứ tự thời gian của tối đa 500 từ vựng mà hệ thống đã gửi ngầm cho bạn (Từ mới nhất nằm trên cùng). 
- Dọn dẹp thùng rác: Góc phải màn hình Lịch sử có một biểu tượng Thùng rác. Khi bấm vào, một hộp tuỳ chọn (Modal) sẽ hiện ra để xác nhận bạn có chắc chắn dọn dẹp bộ nhớ đệm lịch sử này hay không. Việc thao tác "DELETE" tại đây sẽ xoá trắng giao diện lịch sử hiện tại về 0, giúp bạn bắt đầu một chu kỳ theo dõi từ vựng mới dễ dàng hơn. Càng sạch sẽ, hệ thống càng mượt mà. 

## 6. WIDGET MÀN HÌNH CHÍNH (ANDROID HOME SCREEN WIDGET)
Tính năng mới: Không cần mở ứng dụng, giờ đây bạn có thể ghim ELED ra thẳng màn hình chính của thiết bị Android:
- **Thiết kế Đồng bộ:** Nhấn mạnh cấu trúc góc cạnh vuông vức tuyệt đối (Square Aspect Ratio) với phong cách Brutalist. Tương phản mạnh và phù hợp với mọi màn hình nền.
- **Thông tin Ngay lập tức:** Hiển thị tự động một Thẻ từ vựng mới thường xuyên, giúp tiếp thu kiến thức thụ động mỗi khi bạn mở điện thoại.
- **Tối ưu Hiệu suất:** Widget hiển thị trơn tru, sắc nét trên các thiết bị chạy bản Build Release. Lịch sử hiển thị chủ đề trên màn hình chính được đồng bộ song song với hệ thống lưu trữ ứng dụng.


---
ELED Alpha 1 - Documentation.
