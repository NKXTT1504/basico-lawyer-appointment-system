enum UserRole {
  customer,
  lawyer,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Khách hàng';
      case UserRole.lawyer:
        return 'Luật sư';
      case UserRole.admin:
        return 'Quản trị viên';
    }
  }

  String get roleValue {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.lawyer:
        return 'lawyer';
      case UserRole.admin:
        return 'admin';
    }
  }
}
