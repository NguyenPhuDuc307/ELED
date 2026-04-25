#!/usr/bin/env python3
"""
Upload vocabulary CSV files to Firebase Storage.

Requirements:
  pip install firebase-admin

Usage:
  python3 tools/upload_vocabulary.py

Cần có file service account key tại tools/serviceAccountKey.json
Tải tại: Firebase Console → Project Settings → Service accounts → Generate new private key
"""

import json
import os
import sys
from pathlib import Path

try:
    import firebase_admin
    from firebase_admin import credentials, storage
except ImportError:
    print("Thiếu thư viện: pip install firebase-admin")
    sys.exit(1)

# ── Config ────────────────────────────────────────────────────────────────────
SCRIPT_DIR   = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
DATA_DIR     = PROJECT_ROOT / "assets" / "data"
VERSION_FILE = SCRIPT_DIR / "version.json"
BUCKET_NAME  = "eled-aaf5c.firebasestorage.app"
KEY_FILE     = PROJECT_ROOT / "eled-aaf5c-firebase-adminsdk-fbsvc-86acb786a6.json"
STORAGE_PREFIX = "vocabulary"
# ─────────────────────────────────────────────────────────────────────────────


def init_firebase():
    if not KEY_FILE.exists():
        print(f"Không tìm thấy service account key: {KEY_FILE}")
        print("Tải tại: Firebase Console → Project Settings → Service accounts → Generate new private key")
        sys.exit(1)
    cred = credentials.Certificate(str(KEY_FILE))
    firebase_admin.initialize_app(cred, {"storageBucket": BUCKET_NAME})


def collect_files():
    files = []
    for csv_file in sorted(DATA_DIR.rglob("*.csv")):
        relative = csv_file.relative_to(DATA_DIR)
        files.append(str(relative))
    return files


def generate_version_json(files):
    data = {"version": "1", "files": files}
    with open(VERSION_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"Đã tạo version.json với {len(files)} file")


def upload_files(files):
    bucket = storage.bucket()
    total = len(files)

    for i, relative_path in enumerate(files, 1):
        local_path = DATA_DIR / relative_path
        storage_path = f"{STORAGE_PREFIX}/{relative_path}"

        blob = bucket.blob(storage_path)
        blob.upload_from_filename(str(local_path), content_type="text/csv; charset=utf-8")

        pct = round(i / total * 100)
        print(f"[{pct:3d}%] {i}/{total}  {relative_path}", end="\r")

    print(f"\nĐã upload {total} file CSV xong.")


def upload_version_json():
    bucket = storage.bucket()
    blob = bucket.blob(f"{STORAGE_PREFIX}/version.json")
    blob.upload_from_filename(str(VERSION_FILE), content_type="application/json")
    print(f"Đã upload version.json lên gs://{BUCKET_NAME}/{STORAGE_PREFIX}/version.json")


def main():
    print("=== Upload Vocabulary CSVs to Firebase Storage ===\n")

    print("1. Khởi tạo Firebase...")
    init_firebase()

    print("2. Thu thập danh sách file CSV...")
    files = collect_files()
    print(f"   Tìm thấy {len(files)} file")

    print("3. Tạo version.json...")
    generate_version_json(files)

    print("4. Upload CSVs...")
    upload_files(files)

    print("5. Upload version.json...")
    upload_version_json()

    print("\nHoàn tất! App sẽ tự download khi user mở lần đầu.")


if __name__ == "__main__":
    main()
