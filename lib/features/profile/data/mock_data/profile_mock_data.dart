import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_role.dart';

class ProfileMockData {
  // Mock data cho các loại user khác nhau
  static final UserProfile mockCustomerProfile = UserProfile(
    id: 'customer_001',
    email: 'vanphuquocthinh2004@gmail.com',
    fullName: 'Kim',
    phoneNumber: '0902594800',
    role: UserRole.customer,
    avatarUrl: 'https://via.placeholder.com/150',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );

  static final UserProfile mockLawyerProfile = UserProfile(
    id: 'lawyer_001',
    email: 'lawyer@basico.com',
    fullName: 'Nguyễn Văn Luật Sư',
    phoneNumber: '0987654321',
    role: UserRole.lawyer,
    avatarUrl: 'https://via.placeholder.com/150',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    updatedAt: DateTime.now(),
  );

  static final UserProfile mockAdminProfile = UserProfile(
    id: 'admin_001',
    email: 'admin@basico.com',
    fullName: 'Admin Quản Trị',
    phoneNumber: '0123456789',
    role: UserRole.admin,
    avatarUrl: 'https://via.placeholder.com/150',
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now(),
  );

  // Simulate getting current user profile (sẽ thay bằng API call sau)
  static Future<UserProfile> getCurrentUserProfile() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Trong thực tế, sẽ lấy từ shared preferences hoặc API
    // Giả sử current user là customer
    return mockCustomerProfile;
  }

  // Simulate updating profile
  static Future<UserProfile> updateProfile(UserProfile updatedProfile) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Trong thực tế, sẽ gọi API để update
    return updatedProfile.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  // Simulate change password
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Simulate random failure
    return true;
  }
}
