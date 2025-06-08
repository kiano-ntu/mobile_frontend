// File: lib/screens/merchandise/merchandise_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/merchandise.dart';
import '../../services/merchandise_service.dart';
import '../../utils/colors.dart';

class MerchandiseDetailScreen extends StatefulWidget {
  final Merchandise merchandise;

  const MerchandiseDetailScreen({
    Key? key,
    required this.merchandise,
  }) : super(key: key);

  @override
  State<MerchandiseDetailScreen> createState() => _MerchandiseDetailScreenState();
}

class _MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  bool _isExchanging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMerchandiseImage(),
                _buildMerchandiseInfo(),
                _buildPointsInfo(),
                _buildStockInfo(),
                _buildDescription(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.greyDark,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.greyDark,
            size: 20,
          ),
        ),
      ),
      title: const Text(
        'Detail Merchandise',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMerchandiseImage() {
    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.merchandise.getImageUrl(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.greyLight,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: AppColors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gambar tidak tersedia',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.greyLight,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.pembeliColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMerchandiseInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.merchandise.namaMerch,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pembeliColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Merchandise Eksklusif',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.pembeliColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfo() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userPoints = authProvider.poinPembeli;
        final canAfford = userPoints >= widget.merchandise.hargaPoin;
        
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.pembeliColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canAfford 
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Penukaran',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                        Text(
                          widget.merchandise.getFormattedPrice(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pembeliColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    canAfford ? Icons.check_circle : Icons.error,
                    color: canAfford ? AppColors.success : AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      canAfford 
                          ? 'Poin Anda mencukupi untuk penukaran ini'
                          : 'Poin Anda tidak mencukupi (Kekurangan: ${widget.merchandise.hargaPoin - userPoints} poin)',
                      style: TextStyle(
                        fontSize: 12,
                        color: canAfford ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Poin Anda:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    '$userPoints Poin',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.merchandise.isAvailable 
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.merchandise.isAvailable 
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.merchandise.isAvailable 
                ? Icons.inventory_2 
                : Icons.inventory_2_outlined,
            color: widget.merchandise.isAvailable 
                ? AppColors.success 
                : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ketersediaan Stok',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  widget.merchandise.isAvailable 
                      ? '${widget.merchandise.stok} unit tersedia'
                      : 'Stok habis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.merchandise.isAvailable 
                        ? AppColors.success 
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang Merchandise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dapatkan merchandise eksklusif "${widget.merchandise.namaMerch}" dengan menukarkan poin yang sudah Anda kumpulkan dari setiap pembelian di ReUseMart.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.greyDark,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Syarat & Ketentuan:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                ...[
                  '• Penukaran poin tidak dapat dibatalkan',
                  '• Merchandise yang sudah ditukar tidak dapat dikembalikan',
                  '• Pengambilan merchandise di kantor ReUseMart',
                  '• Berlaku selama stok masih tersedia',
                ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userPoints = authProvider.poinPembeli;
        final canAfford = userPoints >= widget.merchandise.hargaPoin;
        final canExchange = widget.merchandise.isAvailable && canAfford;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Points summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Penukaran:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: AppColors.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.merchandise.getFormattedPrice(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pembeliColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Exchange button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: canExchange && !_isExchanging ? _handleExchange : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canExchange 
                          ? AppColors.pembeliColor 
                          : AppColors.grey,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isExchanging
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Memproses...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.swap_horiz,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getButtonText(canExchange),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getButtonText(bool canExchange) {
    if (!widget.merchandise.isAvailable) {
      return 'Stok Habis';
    }
    
    if (!canExchange) {
      return 'Poin Tidak Mencukupi';
    }
    
    return 'Tukar Sekarang';
  }

  Future<void> _handleExchange() async {
    final authProvider = context.read<AuthProvider>();
    
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;
    
    setState(() {
      _isExchanging = true;
    });
    
    try {
      // For now, we'll use a placeholder pegawai ID
      // In a real app, this might be determined by the system or current staff
      const pegawaiId = 'PGW3'; // Customer Service
      
      final response = await MerchandiseService.exchangePoints(
        idPembeli: authProvider.user!.id,
        idPegawai: pegawaiId,
        items: [
          {
            'id_merch': widget.merchandise.idMerch,
            'jumlah': 1,
          }
        ],
      );
      
      if (mounted) {
        setState(() {
          _isExchanging = false;
        });
        
        if (response.success) {
          // Refresh user data to update points
          await authProvider.refreshUser();
          
          // Show success dialog
          _showSuccessDialog();
        } else {
          _showErrorDialog(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExchanging = false;
        });
        _showErrorDialog('Terjadi kesalahan: $e');
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menukar poin untuk:'),
            const SizedBox(height: 8),
            Text(
              widget.merchandise.namaMerch,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Harga: ${widget.merchandise.getFormattedPrice()}',
              style: const TextStyle(
                color: AppColors.pembeliColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Penukaran ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pembeliColor,
            ),
            child: const Text('Ya, Tukar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
            ),
            SizedBox(width: 8),
            Text('Penukaran Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selamat! Anda berhasil menukar poin untuk "${widget.merchandise.namaMerch}".',
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan ambil merchandise Anda di kantor ReUseMart dengan menunjukkan konfirmasi ini.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to catalog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.error,
              color: AppColors.error,
            ),
            SizedBox(width: 8),
            Text('Penukaran Gagal'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}