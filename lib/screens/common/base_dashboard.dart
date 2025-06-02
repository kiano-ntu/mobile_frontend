import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/loading_widget.dart';

abstract class BaseDashboard extends StatefulWidget {
  const BaseDashboard({Key? key}) : super(key: key);
}

abstract class BaseDashboardState<T extends BaseDashboard> extends State<T> {
  // Abstract methods yang harus diimplementasi oleh setiap dashboard
  String get title;
  List<DashboardMenuItem> get menuItems;
  Widget buildMainContent();
  Color get primaryColor;
  IconData get roleIcon;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          // Jika tidak terautentikasi, redirect ke login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return const LoadingWidget(message: 'Mengarahkan ke login...');
        }

        return Scaffold(
          backgroundColor: AppColors.greyLight,
          appBar: _buildAppBar(authProvider),
          drawer: _buildDrawer(authProvider),
          body: RefreshIndicator(
            onRefresh: () async {
              await authProvider.refreshUser();
            },
            child: buildMainContent(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AuthProvider authProvider) {
    return AppBar(
      backgroundColor: primaryColor,
      foregroundColor: AppColors.white,
      elevation: 0,
      title: Row(
        children: [
          Icon(roleIcon, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Notification Badge
        IconButton(
          onPressed: () {
            // TODO: Implement notifications
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur notifikasi akan segera hadir!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Profile Menu
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'profile':
                _showProfileDialog(authProvider);
                break;
              case 'logout':
                _showLogoutDialog(authProvider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: AppColors.grey),
                  SizedBox(width: 8),
                  Text('Profil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              child: Text(
                authProvider.userName?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(AuthProvider authProvider) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.white,
                      child: Icon(
                        roleIcon,
                        size: 30,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authProvider.userName ?? 'User',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.getRoleDisplayName(),
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authProvider.userEmail ?? '',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...menuItems.map((item) => _buildDrawerItem(item)),
                const Divider(),
                _buildDrawerItem(
                  DashboardMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur pengaturan akan segera hadir!'),
                        ),
                      );
                    },
                  ),
                ),
                _buildDrawerItem(
                  DashboardMenuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur bantuan akan segera hadir!'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(authProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(DashboardMenuItem item) {
    return ListTile(
      leading: Icon(item.icon, color: AppColors.grey),
      title: Text(item.title),
      onTap: item.onTap,
    );
  }

  void _showProfileDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Pengguna'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileItem('Nama', authProvider.userName ?? '-'),
            _buildProfileItem('Email', authProvider.userEmail ?? '-'),
            _buildProfileItem('Role', authProvider.getRoleDisplayName()),
            if (authProvider.user?.phone != null)
              _buildProfileItem('Telepon', authProvider.user!.phone!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.greyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const LoadingWidget(
                  message: 'Sedang logout...',
                ),
              );
              
              await authProvider.logout();
              
              // Navigate to login
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  DashboardMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}