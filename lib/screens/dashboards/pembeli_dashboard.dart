// File: lib/screens/dashboards/pembeli_dashboard.dart - UPDATED VERSION

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
              // Points display
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '3750 Poin', // You can make this dynamic from provider
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Add refresh logic here if needed
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MAIN WELCOME CARD - Updated with "Lihat Profile" button
                  _buildWelcomeCard(context, authProvider),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // UPDATED: Welcome Card Widget with "Lihat Profile" button
  Widget _buildWelcomeCard(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.pembeliColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppColors.pembeliColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Welcome Message
          Text(
            'Halo Kevin Denyno!', // You can make this dynamic from authProvider
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.pembeliColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pembeli',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // NEW: "Lihat Profile" Button
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePembeli(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.pembeliColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            child: const Text(
              'Lihat Profile',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.pembeliColor,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
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
    );
  }
}