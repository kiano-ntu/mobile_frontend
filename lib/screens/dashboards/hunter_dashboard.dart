import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/loading_widget.dart';

class HunterDashboard extends StatelessWidget {
  const HunterDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.greyLight,
          appBar: AppBar(
            backgroundColor: AppColors.hunterColor,
            foregroundColor: AppColors.white,
            title: const Text(
              'Dashboard Hunter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Profile Button
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/hunter/profile'),
                icon: const Icon(Icons.person),
                tooltip: 'Profil',
              ),
              // Logout Button
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
                  // Icon Hunter
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.hunterColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 40,
                      color: AppColors.hunterColor,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Greeting Text
                  Text(
                    'Halo ${authProvider.userName ?? 'Hunter'}!',
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
                      color: AppColors.hunterColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Hunter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Welcome Message
                  const Text(
                    'Selamat datang di ReUseMart!\nSiap berburu barang bekas berkualitas?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Quick Action Buttons
                  Column(
                    children: [
                      // View Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/hunter/profile'),
                          icon: const Icon(Icons.person),
                          label: const Text('Lihat Profil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.hunterColor,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Additional Action Button (Future feature)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur akan segera tersedia'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Mulai Berburu'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.hunterColor,
                            side: const BorderSide(color: AppColors.hunterColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
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