#!/usr/bin/env bash
#
# Build + cài ELED lên iPhone qua cáp.
#
# Dùng:
#   ./scripts/run_ios.sh             # build release rồi cài
#   ./scripts/run_ios.sh debug       # build debug
#   ./scripts/run_ios.sh profile     # build profile
#   ./scripts/run_ios.sh release run # cài xong launch luôn (để thấy lỗi nếu có)
#
set -euo pipefail

# iPhone "Đức Cá" (iPhone 17). Đổi nếu dùng máy khác — xem `flutter devices`.
DEVICE_ID="00008150-001D0D492233401C"
MODE="${1:-release}"
ACTION="${2:-}"

cd "$(dirname "$0")/.."

echo "▶ Build ELED ($MODE)…"
flutter build ios "--$MODE"

echo "▶ Cài lên iPhone ($DEVICE_ID)…"
echo "  (mở khoá máy + giữ màn hình sáng trong lúc cài)"
flutter install "--$MODE" -d "$DEVICE_ID"

if [ "$ACTION" = "run" ]; then
  echo "▶ Thử launch…"
  xcrun devicectl device process launch --device "$DEVICE_ID" com.nguyenphuduc.eled || true
fi

cat <<'EOF'

✔ Đã cài xong.

Nếu app báo "Untrusted Developer" / không mở được:
  1) Bật WiFi cho iPhone (bắt buộc để xác minh).
  2) Chạm icon ELED 1 lần → popup hiện ra → Cancel.
  3) Settings → General → VPN & Device Management
       → Developer App → chọn email của bạn → Trust → Trust.
  4) Mở lại app.

Lưu ý: chứng chỉ free chỉ sống 7 ngày → ~1 tuần phải cài + trust lại.

Thêm widget vào màn hình chính:
  Mở app 1 lần để đẩy dữ liệu → giữ tay lên Home → "+" → tìm "ELED Từ vựng".
EOF
