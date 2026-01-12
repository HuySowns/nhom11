# Hướng dẫn cài đặt dự án

## Yêu cầu
- Flutter SDK
- Dart SDK
- Android Studio / Xcode
- Node.js (nếu cần)

## Các bước cài đặt

### 1. Clone dự án
```bash
git clone <repository-url>
cd nhom11
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Cấu hình Firebase (nếu cần)
- Tải file `google-services.json` từ Firebase Console
- Đặt vào: `android/app/google-services.json`
- Tải file `GoogleService-Info.plist` từ Firebase Console
- Đặt vào: `ios/Runner/GoogleService-Info.plist`

### 4. Clean và build
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Chạy ứng dụng
```bash
flutter run
```

## Troubleshooting
- Nếu lỗi BUILD FAILED: chạy `flutter clean` rồi `flutter pub get`
- Nếu lỗi Firebase: kiểm tra file cấu hình Firebase
- Nếu lỗi gradle: cập nhật Android SDK
