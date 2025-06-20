// File: lib/screens/hunter/hunter_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../../widgets/loading_widget.dart';
import '../../services/komisi_service.dart';
import 'hunter_komisi_detail_screen.dart';

class HunterProfileScreen extends StatefulWidget {
  const HunterProfileScreen({Key? key}) : super(key: key);

  @override
  State<HunterProfileScreen> createState() => _HunterProfileScreenState();
}

class _HunterProfileScreenState extends State<HunterProfileScreen> {
  Map<String, dynamic>? komisiData;
  bool isLoadingKomisi = true;
  String? komisiError;

  @override
  void initState() {
    super.initState();
    _loadKomisiData();
  }

  Future<void> _loadKomisiData() async {
    try {
      setState(() {
        isLoadingKomisi = true;
        komisiError = null;
      });

      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;

      if (userId != null) {
        final result = await KomisiService.getKomisiDetails(userId);
        
        setState(() {
          komisiData = result;
          isLoadingKomisi = false;
          if (result['success'] != true) {
            komisiError = result['error'] ?? 'Gagal memuat data komisi';
          }
        });
      } else {
        setState(() {
          isLoadingKomisi = false;
          komisiError = 'ID pengguna tidak ditemukan';
        });
      }
    } catch (e) {
      setState(() {
        isLoadingKomisi = false;
        komisiError = e.toString();
      });
      print('❌ Error loading komisi data: $e');
    }
  }

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
              'Profil Hunter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Kembali',
            ),
            actions: [
              // Refresh Button for Komisi Data
              IconButton(
                onPressed: _loadKomisiData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header Card
                _buildProfileHeaderCard(authProvider),
                
                const SizedBox(height: 16),
                
                // Profile Details Card
                _buildProfileDetailsCard(authProvider),
                
                const SizedBox(height: 16),
                
                // Statistics Card (with real commission data)
                _buildStatisticsCard(authProvider),
                
                const SizedBox(height: 24),
                
                // Logout Button
                _buildLogoutButton(context, authProvider),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeaderCard(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.hunterColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppColors.hunterColor,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.search,
              size: 50,
              color: AppColors.hunterColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            authProvider.userName ?? 'Hunter',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Role Badge
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
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsCard(AuthProvider authProvider) {
    final user = authProvider.user;
    final additionalData = user?.additionalData ?? {};
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Personal Information Items
          _buildProfileDetailItem(
            icon: Icons.badge_outlined,
            label: 'ID Pegawai',
            value: user?.id ?? '-',
          ),

          _buildProfileDetailItem(
            icon: Icons.person_outline,
            label: 'Nama Lengkap',
            value: authProvider.userName ?? '-',
          ),
          
          _buildProfileDetailItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: authProvider.userEmail ?? '-',
          ),
          
          _buildProfileDetailItem(
            icon: Icons.phone_outlined,
            label: 'No. Telepon',
            value: user?.phone ?? '-',
          ),
          
          _buildProfileDetailItem(
            icon: Icons.work_outline,
            label: 'Jabatan',
            value: additionalData['jabatan'] ?? 'Hunter',
          ),
          
          _buildProfileDetailItem(
            icon: Icons.location_on_outlined,
            label: 'Alamat',
            value: additionalData['alamat_pegawai'] ?? '-',
          ),
          
          _buildProfileDetailItem(
            icon: Icons.cake_outlined,
            label: 'Tanggal Lahir',
            value: _formatDate(additionalData['tanggal_lahir_pegawai']),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.hunterColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.hunterColor,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komisi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Komisi Card with real data
          if (isLoadingKomisi)
            _buildLoadingKomisiCard()
          else if (komisiError != null)
            _buildErrorKomisiCard()
          else
            _buildKomisiCard(),
        ],
      ),
    );
  }

  Widget _buildLoadingKomisiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memuat...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Total Komisi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorKomisiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: AppColors.error,
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  komisiError ?? 'Gagal memuat data',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: _loadKomisiData,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.error,
            ),
            tooltip: 'Coba Lagi',
          ),
        ],
      ),
    );
  }

  Widget _buildKomisiCard() {
    final totalKomisiFormatted = komisiData?['total_komisi_formatted'] ?? 'Rp 0';
    final totalKomisi = komisiData?['total_komisi'] ?? 0.0;
    
    return GestureDetector(
      onTap: () {
        final authProvider = context.read<AuthProvider>();
        final userId = authProvider.user?.id;
        
        if (userId != null && komisiData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HunterKomisiDetailScreen(
                idPegawai: userId,
                totalKomisiFormatted: totalKomisiFormatted,
                totalKomisi: totalKomisi,
              ),
            ),
          );
        }
      },
      child: _buildStatisticItem(
        title: 'Total Komisi',
        value: totalKomisiFormatted,
        icon: Icons.monetization_on_outlined,
        color: AppColors.success,
        subtitle: totalKomisi > 0 
          ? 'Dari ${(komisiData?['komisi_details'] as List?)?.length ?? 0} transaksi • Tap untuk detail'
          : 'Belum ada komisi • Tap untuk detail',
        isClickable: true,
      ),
    );
  }

  Widget _buildStatisticItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    bool isClickable = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: isClickable ? [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          
          const SizedBox(width: 20),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),
                
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isClickable ? color : AppColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          if (isClickable) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '-';
    
    try {
      // Handle different date formats
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return '-';
      }
      
      // Format to Indonesian date format
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '-';
    }
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, authProvider),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
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