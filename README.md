# Basico Lawyer Appointment System - Flutter Frontend

Hệ thống đặt lịch tư vấn pháp lý - Ứng dụng di động Flutter kết nối với Backend .NET qua API.

## 📱 Tính năng chính

- **Xác thực người dùng**: Đăng nhập/Đăng ký
- **Quản lý lịch hẹn**: Xem, tạo, hủy lịch hẹn
- **Danh sách luật sư**: Tìm kiếm và xem thông tin luật sư
- **Hồ sơ cá nhân**: Quản lý thông tin người dùng
- **Giao diện hiện đại**: Material Design 3 với dark/light theme

## 🛠️ Cài đặt môi trường phát triển

### 1. Cài đặt Flutter SDK

1. Tải Flutter SDK từ [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Giải nén vào thư mục (ví dụ: `C:\flutter`)
3. Thêm Flutter vào PATH của Windows:
   - Mở System Properties > Environment Variables
   - Thêm `C:\flutter\bin` vào PATH
4. Kiểm tra cài đặt:
   ```bash
   flutter doctor
   ```

### 2. Cài đặt IDE

**Tùy chọn 1: Android Studio**
- Tải và cài đặt [Android Studio](https://developer.android.com/studio)
- Cài đặt Flutter plugin
- Cài đặt Android SDK

**Tùy chọn 2: Visual Studio Code**
- Tải và cài đặt [VS Code](https://code.visualstudio.com/)
- Cài đặt Flutter extension
- Cài đặt Dart extension

### 3. Cài đặt Git (nếu chưa có)
- Tải và cài đặt [Git](https://git-scm.com/)

## 🚀 Chạy ứng dụng

1. **Clone repository:**
   ```bash
   git clone <repository-url>
   cd basico-lawyer-appointment-system
   ```

2. **Cài đặt dependencies:**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

## 📁 Cấu trúc dự án

```
lib/
├── core/                           # Core functionality
│   ├── config/                     # App configuration
│   ├── constants/                  # App constants
│   ├── di/                        # Dependency injection
│   ├── network/                    # API client & network info
│   ├── router/                     # Navigation routing
│   ├── storage/                    # Local storage
│   └── theme/                      # App themes & colors
├── features/                       # Feature modules
│   ├── auth/                       # Authentication
│   │   ├── data/                   # Data layer
│   │   ├── domain/                 # Business logic
│   │   └── presentation/           # UI layer
│   ├── appointment/                # Appointment management
│   ├── lawyer/                     # Lawyer management
│   ├── profile/                    # User profile
│   ├── home/                       # Home screen
│   └── splash/                     # Splash screen
└── main.dart                       # App entry point
```

## 🏗️ Kiến trúc dự án

Dự án sử dụng **Clean Architecture** với các layer:

- **Presentation Layer**: UI, Bloc/Cubit, Pages, Widgets
- **Domain Layer**: Use cases, Entities, Repository interfaces
- **Data Layer**: Repository implementations, Data sources, Models

## 📦 Dependencies chính

- **flutter_bloc**: State management
- **go_router**: Navigation
- **dio**: HTTP client
- **shared_preferences**: Local storage
- **flutter_screenutil**: Responsive design
- **equatable**: Value equality
- **formz**: Form validation

## 🔧 Cấu hình API

Cập nhật API endpoint trong `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

## 🎨 Theme

Ứng dụng hỗ trợ:
- Light theme (mặc định)
- Dark theme
- Material Design 3
- Responsive design

## 📱 Tính năng đã hoàn thành

- [x] Cấu trúc dự án chuẩn
- [x] Authentication flow (UI)
- [x] Navigation setup
- [x] Theme configuration
- [x] State management setup
- [x] API client setup
- [x] Local storage setup

## 🚧 Tính năng đang phát triển

- [ ] API integration
- [ ] Appointment management
- [ ] Lawyer listing & details
- [ ] Profile management
- [ ] Push notifications
- [ ] Offline support

## 🤝 Đóng góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 License

Dự án này được phân phối dưới MIT License. Xem file `LICENSE` để biết thêm thông tin.