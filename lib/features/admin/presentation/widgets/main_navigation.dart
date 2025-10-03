import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/admin_user.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const MainNavigation({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isCollapsed = false; // for wide screens

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await UserStorageService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await UserStorageService.setCurrentUser(null);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Allow unauthenticated users to access customer routes
    final bool isCustomerRoute = widget.currentPath == '/home' ||
        widget.currentPath == '/appointments' ||
        widget.currentPath == '/lawyers' ||
        widget.currentPath == '/profile';

    if (_currentUser == null && !isCustomerRoute) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Chưa đăng nhập'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    final UserRole role = _currentUser?.role ?? UserRole.customer;
    // Guard admin routes: redirect non-admins appropriately
    if (_currentUser != null) {
      final String path = widget.currentPath;
      final bool isAdminRoute = path.startsWith('/admin/');
      final bool isLawyerRoute = path.startsWith('/lawyer/');
      if (isAdminRoute && role != UserRole.admin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (role == UserRole.lawyer) {
            context.go('/lawyer/dashboard');
          } else {
            context.go('/home');
          }
        });
      }
      if (isLawyerRoute && role == UserRole.customer) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.go('/home');
        });
      }
    }
    ;
    final String userName = _currentUser?.name ?? 'Khách';

    final screenWidth = MediaQuery.of(context).size.width;

    // Mobile: use Drawer + AppBar
    if (screenWidth < 800) {
      final String pageTitle = _getMobileTitle(widget.currentPath, role);
      final bool isAdminSubPage = widget.currentPath == '/admin/appointments' ||
          widget.currentPath == '/admin/customers' ||
          widget.currentPath == '/admin/lawyers';
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
          leading: isAdminSubPage
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/admin/dashboard'),
                  tooltip: 'Về Dashboard',
                )
              : null,
          title: Text(pageTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.go(widget.currentPath),
              tooltip: 'Làm mới',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
              ],
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: _buildDrawerContent(role, userName),
        ),
        body: widget.child,
      );
    }

    // Wide: persistent sidebar with collapse toggle
    final double sidebarWidth = _isCollapsed ? 72 : 250;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: sidebarWidth,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(
                          _getUserIcon(role),
                          size: 22,
                          color: Colors.blue[600],
                        ),
                      ),
                      if (!_isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _getRoleText(role),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      IconButton(
                        onPressed: () =>
                            setState(() => _isCollapsed = !_isCollapsed),
                        icon: Icon(
                            _isCollapsed
                                ? Icons.chevron_right
                                : Icons.chevron_left,
                            color: Colors.white),
                        tooltip: _isCollapsed ? 'Mở rộng' : 'Thu gọn',
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _buildNavigationItems(role).map((w) {
                      // When collapsed, show only icons
                      if (_isCollapsed && w is Container) {
                        final listTile = (w.child as ListTile);
                        return IconButton(
                          onPressed: listTile.onTap,
                          icon: listTile.leading as Widget,
                          tooltip: (listTile.title as Text).data,
                        );
                      }
                      return w;
                    }).toList(),
                  ),
                ),
                if (_currentUser != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _isCollapsed
                        ? IconButton(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, color: Colors.white),
                            tooltip: 'Đăng xuất',
                          )
                        : ListTile(
                            leading:
                                const Icon(Icons.logout, color: Colors.white),
                            title: const Text('Đăng xuất',
                                style: TextStyle(color: Colors.white)),
                            onTap: _logout,
                          ),
                  ),
              ],
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  // Drawer content for mobile
  Widget _buildDrawerContent(UserRole role, String userName) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.blue[600],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(_getUserIcon(role),
                      color: Colors.blue[600], size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(_getRoleText(role),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _buildNavigationItems(role).map((w) {
                if (w is Container) {
                  final listTile = (w.child as ListTile);
                  final Icon? oldIcon = listTile.leading is Icon
                      ? listTile.leading as Icon
                      : null;
                  final Text? oldTitle =
                      listTile.title is Text ? listTile.title as Text : null;
                  return ListTile(
                    leading: oldIcon != null
                        ? Icon(oldIcon.icon,
                            color: Colors.black87, size: oldIcon.size)
                        : listTile.leading,
                    title: Text(
                      oldTitle?.data ?? '',
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      listTile.onTap?.call();
                    },
                  );
                }
                return w;
              }).toList(),
            ),
          ),
          if (_currentUser != null)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black87),
              title: const Text('Đăng xuất',
                  style: TextStyle(color: Colors.black87)),
              onTap: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems(UserRole role) {
    final items = <Widget>[];

    if (role == UserRole.admin) {
      items.addAll(_buildAdminNavigationItems());
    } else if (role == UserRole.lawyer) {
      items.addAll(_buildLawyerNavigationItems());
    } else if (role == UserRole.customer) {
      items.addAll(_buildCustomerNavigationItems());
    }

    return items;
  }

  List<Widget> _buildAdminNavigationItems() {
    return [
      _buildNavItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        path: '/admin/dashboard',
        isActive: widget.currentPath == '/admin/dashboard',
      ),
      _buildNavItem(
        icon: Icons.calendar_today,
        title: 'Quản lý đặt lịch',
        path: '/admin/appointments',
        isActive: widget.currentPath == '/admin/appointments',
      ),
      _buildNavItem(
        icon: Icons.people,
        title: 'Quản lý khách hàng',
        path: '/admin/customers',
        isActive: widget.currentPath == '/admin/customers',
      ),
      _buildNavItem(
        icon: Icons.gavel,
        title: 'Quản lý luật sư',
        path: '/admin/lawyers',
        isActive: widget.currentPath == '/admin/lawyers',
      ),
    ];
  }

  List<Widget> _buildLawyerNavigationItems() {
    return [
      _buildNavItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        path: '/lawyer/dashboard',
        isActive: widget.currentPath == '/lawyer/dashboard',
      ),
      _buildNavItem(
        icon: Icons.calendar_today,
        title: 'Lịch hẹn của tôi',
        path: '/lawyer/appointments',
        isActive: widget.currentPath == '/lawyer/appointments',
      ),
      _buildNavItem(
        icon: Icons.person,
        title: 'Thông tin cá nhân',
        path: '/lawyer/profile',
        isActive: widget.currentPath == '/lawyer/profile',
      ),
    ];
  }

  List<Widget> _buildCustomerNavigationItems() {
    return [
      _buildNavItem(
        icon: Icons.home,
        title: 'Trang chủ',
        path: '/home',
        isActive: widget.currentPath == '/home',
      ),
      _buildNavItem(
        icon: Icons.calendar_today,
        title: 'Đặt lịch',
        path: '/appointments',
        isActive: widget.currentPath == '/appointments',
      ),
      _buildNavItem(
        icon: Icons.gavel,
        title: 'Luật sư',
        path: '/lawyers',
        isActive: widget.currentPath == '/lawyers',
      ),
      _buildNavItem(
        icon: Icons.person,
        title: 'Thông tin cá nhân',
        path: '/profile',
        isActive: widget.currentPath == '/profile',
      ),
    ];
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String path,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          context.go(path);
        },
      ),
    );
  }

  IconData _getUserIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.lawyer:
        return Icons.gavel;
      case UserRole.customer:
        return Icons.person;
    }
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.lawyer:
        return 'Luật sư';
      case UserRole.customer:
        return 'Khách hàng';
    }
  }

  String _getMobileTitle(String currentPath, UserRole role) {
    if (role == UserRole.admin) {
      switch (currentPath) {
        case '/admin/appointments':
          return 'Quản lý đặt lịch';
        case '/admin/customers':
          return 'Quản lý khách hàng';
        case '/admin/lawyers':
          return 'Quản lý luật sư';
        case '/admin/dashboard':
          return 'Dashboard';
      }
      return 'Admin';
    }
    return _getRoleText(role);
  }
}
