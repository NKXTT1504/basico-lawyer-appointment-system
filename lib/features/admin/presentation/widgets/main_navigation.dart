import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/admin_user.dart';
import '../../../chat/presentation/widgets/floating_chat_button.dart';

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
        widget.currentPath == '/profile' ||
        widget.currentPath == '/chat';

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

    // Mobile: use BottomNavigationBar (mobile app style)
    if (screenWidth < 800) {
      final navItems = _getBottomNavItems(role);
      final currentIndex = _getCurrentBottomNavIndex(role);
      final bool isAdminSubPage = widget.currentPath == '/admin/appointments' ||
          widget.currentPath == '/admin/customers' ||
          widget.currentPath == '/admin/lawyers';

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: isAdminSubPage
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => context.go('/admin/dashboard'),
                  tooltip: 'Về Dashboard',
                )
              : null,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName.length > 20
                          ? '${userName.substring(0, 20)}...'
                          : userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Icon(
                  _getUserIcon(role),
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) {
                if (value == 'refresh') {
                  context.go(widget.currentPath);
                } else if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => [
                if (role != UserRole.customer)
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text('Làm mới'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Đăng xuất'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            widget.child,
            // Hiển thị floating chat button cho customer
            if (role == UserRole.customer) const FloatingChatButton(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            final item = navItems[index];
            final path = item['path'] as String?;
            if (path != null) {
              context.go(path);
            } else {
              // Settings item - show popup menu
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Đăng xuất'),
                        onTap: () {
                          Navigator.pop(context);
                          _logout();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue[600],
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          items: navItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item['icon'] as IconData),
              label: item['label'] as String,
            );
          }).toList(),
        ),
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
                          child: FutureBuilder<User?>(
                            future: UserStorageService.getCurrentUser(),
                            builder: (context, snapshot) {
                              final displayName =
                                  snapshot.data?.name ?? userName;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
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
                              );
                            },
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
          Expanded(
            child: Stack(
              children: [
                widget.child,
                // Hiển thị floating chat button cho customer trên desktop
                if (role == UserRole.customer) const FloatingChatButton(),
              ],
            ),
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
      _buildNavItem(
        icon: Icons.chat,
        title: 'AI Tư vấn',
        path: '/chat',
        isActive: widget.currentPath == '/chat',
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

  List<Map<String, dynamic>> _getBottomNavItems(UserRole role) {
    if (role == UserRole.admin) {
      return [
        {
          'icon': Icons.dashboard,
          'label': 'Dashboard',
          'path': '/admin/dashboard',
        },
        {
          'icon': Icons.calendar_today,
          'label': 'Đặt lịch',
          'path': '/admin/appointments',
        },
        {
          'icon': Icons.people,
          'label': 'Khách hàng',
          'path': '/admin/customers',
        },
        {
          'icon': Icons.gavel,
          'label': 'Luật sư',
          'path': '/admin/lawyers',
        },
        {
          'icon': Icons.settings,
          'label': 'Settings',
          'path': null, // Will show settings menu
        },
      ];
    } else if (role == UserRole.customer) {
      return [
        {
          'icon': Icons.home,
          'label': 'Home',
          'path': '/home',
        },
        {
          'icon': Icons.calendar_today,
          'label': 'Đặt lịch',
          'path': '/appointments',
        },
        {
          'icon': Icons.gavel,
          'label': 'Luật sư',
          'path': '/lawyers',
        },
        {
          'icon': Icons.person,
          'label': 'Profile',
          'path': '/profile',
        },
        {
          'icon': Icons.chat,
          'label': 'Chat',
          'path': '/chat',
        },
      ];
    } else if (role == UserRole.lawyer) {
      return [
        {
          'icon': Icons.dashboard,
          'label': 'Dashboard',
          'path': '/lawyer/dashboard',
        },
        {
          'icon': Icons.calendar_today,
          'label': 'Lịch hẹn',
          'path': '/lawyer/appointments',
        },
        {
          'icon': Icons.person,
          'label': 'Profile',
          'path': '/lawyer/profile',
        },
        {
          'icon': Icons.settings,
          'label': 'Settings',
          'path': null,
        },
      ];
    }
    return [];
  }

  int _getCurrentBottomNavIndex(UserRole role) {
    final navItems = _getBottomNavItems(role);
    final currentPath = widget.currentPath;

    // Exact match first
    for (int i = 0; i < navItems.length; i++) {
      final path = navItems[i]['path'] as String?;
      if (path != null && currentPath == path) {
        return i;
      }
    }

    // Prefix match for admin sub-pages
    if (role == UserRole.admin) {
      if (currentPath.startsWith('/admin/appointments') ||
          currentPath.startsWith('/admin/customers') ||
          currentPath.startsWith('/admin/lawyers')) {
        for (int i = 0; i < navItems.length; i++) {
          final path = navItems[i]['path'] as String?;
          if (path != null && currentPath.startsWith(path)) {
            return i;
          }
        }
      }
      if (currentPath.startsWith('/admin/')) {
        return 0; // Dashboard
      }
    } else if (role == UserRole.customer) {
      if (currentPath.startsWith('/appointments')) return 1;
      if (currentPath.startsWith('/lawyers')) return 2;
      if (currentPath.startsWith('/profile')) return 3;
      if (currentPath.startsWith('/chat')) return 4;
      if (currentPath.startsWith('/home')) return 0;
    } else if (role == UserRole.lawyer) {
      if (currentPath.startsWith('/lawyer/appointments')) return 1;
      if (currentPath.startsWith('/lawyer/profile')) return 2;
      if (currentPath.startsWith('/lawyer/')) return 0; // Dashboard
    }

    return 0; // Default to first item
  }
}
