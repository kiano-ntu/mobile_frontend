// File: lib/screens/pembeli/penukaran_success_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../dashboards/profile_pembeli.dart';

class PenukaranSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> exchangeData;

  const PenukaranSuccessScreen({
    Key? key,
    required this.exchangeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        title: const Text('Penukaran Berhasil'),
        backgroundColor: AppColors.pembeliColor,
        foregroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Success Icon and Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Penukaran Poin Berhasil!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pembeliColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Silakan datang ke kantor ReUseMart untuk mengambil merchandise Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.greyDark,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Transaction Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pembeliColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildDetailRow('ID Transaksi', _getTransactionId()),
                  const SizedBox(height: 12),
                  _buildDetailRow('Tanggal Klaim', _getFormattedClaimDate()),
                  const SizedBox(height: 12),
                  _buildDetailRow('Status', 'Menunggu Pengambilan'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Total Items', '${_getTotalItemsQuantity()} item${_getTotalItemsQuantity() > 1 ? 's' : ''}'),
                  
                  const Divider(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Poin Digunakan:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${_getTotalPoints()} Poin',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pembeliColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Points Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Poin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pembeliColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildPointRow('Poin Sebelumnya', _getPointsBefore(), AppColors.greyDark),
                  const SizedBox(height: 8),
                  _buildPointRow('Poin Digunakan', -_getTotalPoints(), Colors.red),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildPointRow('Poin Sekarang', _getPointsAfter(), AppColors.pembeliColor, isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Items List
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items yang Ditukar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pembeliColor,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ..._getExchangedItems().map((item) => _buildItemCard(item)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePembeli(),
                        ),
                        (route) => route.settings.name == '/pembeli-dashboard',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pembeliColor,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Important Notice
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Informasi Penting',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Silakan datang ke kantor ReUseMart untuk mengambil merchandise Anda\n'
                    '• Bawa ID transaksi ini sebagai bukti penukaran\n'
                    '• Merchandise akan disimpan selama 30 hari\n'
                    '• Jam operasional: Senin-Jumat 08:00-17:00',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Changed to handle overflow better
      children: [
        SizedBox(
          width: 100, // Fixed width for label
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.greyDark,
              fontSize: 14,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 14)),
        Expanded( // Use Expanded to prevent overflow
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis, // Handle overflow
            maxLines: 2, // Allow up to 2 lines
          ),
        ),
      ],
    );
  }

  Widget _buildPointRow(String label, int points, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.greyDark,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '${points.abs()} Poin',
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                fontSize: isBold ? 16 : 14,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_merch'] ?? 'Merchandise',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jumlah: ${item['jumlah'] ?? 1}',
                  style: const TextStyle(
                    color: AppColors.greyDark,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${item['harga_poin_satuan'] ?? 0} poin/item',
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['subtotal'] ?? 0} Poin',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pembeliColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stok tersisa: ${item['stok_tersisa'] ?? 0}',
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods to extract data from exchangeData
  String _getTransactionId() {
    try {
      return exchangeData['penukaran_poin']?['id_penukaranPoin'] ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  // FIXED: Format date without time to prevent overflow
  String _getFormattedClaimDate() {
    try {
      final dateString = exchangeData['penukaran_poin']?['tanggal_klaim'] ?? '';
      if (dateString.isNotEmpty) {
        // Parse the date and format it as dd/MM/yyyy
        DateTime date = DateTime.parse(dateString);
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
      // Fallback to current date if no date available
      DateTime now = DateTime.now();
      return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    } catch (e) {
      // Fallback to current date if parsing fails
      DateTime now = DateTime.now();
      return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    }
  }

  int _getTotalPoints() {
    try {
      return exchangeData['penukaran_poin']?['total_poin_digunakan'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // FIXED: Calculate total quantity instead of total unique items
  int _getTotalItemsQuantity() {
    try {
      final items = exchangeData['items_exchanged'] as List<dynamic>?;
      if (items == null || items.isEmpty) return 0;
      
      // Sum up all quantities instead of just counting items
      int totalQuantity = 0;
      for (var item in items) {
        totalQuantity += (item['jumlah'] ?? 1) as int;
      }
      return totalQuantity;
    } catch (e) {
      return 0;
    }
  }

  int _getPointsBefore() {
    try {
      return exchangeData['pembeli']?['poin_sebelumnya'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  int _getPointsAfter() {
    try {
      return exchangeData['pembeli']?['poin_sekarang'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  List<Map<String, dynamic>> _getExchangedItems() {
    try {
      final items = exchangeData['items_exchanged'] as List<dynamic>?;
      return items?.cast<Map<String, dynamic>>() ?? []; 
    } catch (e) {
      return [];
    }
  }
}