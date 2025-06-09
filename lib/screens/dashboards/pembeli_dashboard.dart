// File: lib/screens/dashboards/pembeli_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../dashboards/profile_pembeli.dart'; // Import halaman profile pembeli

class PembeliDashboard extends StatelessWidget {
  const PembeliDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.greyLight,
          appBar: AppBar(
            backgroundColor: AppColors.pembeliColor,
            foregroundColor: AppColors.white,
            title: const Text(
              'Dashboard Pembeli',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Tombol Logout
              IconButton(
                onPressed: () => _showLogoutDialog(context, authProvider),
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol Profile Pembeli (sebelumnya hanya Icon)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePembeli(),
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.pembeliColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: AppColors.pembeliColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.pembeliColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Label untuk tombol profile
                  Text(
                    'Lihat Profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.pembeliColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Greeting Text
                  Text(
                    'Halo ${authProvider.userName ?? 'Pembeli'}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Role Text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pembeliColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pembeli',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Welcome Message
                  Text(
                    'Selamat datang di ReUseMart!\nSiap berbelanja barang bekas berkualitas?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
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
              await authProvider.logout();
              if (context.mounted) {
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
