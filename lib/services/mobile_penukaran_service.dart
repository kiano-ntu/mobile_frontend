// File: lib/services/mobile_penukaran_service.dart

import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class MobilePenukaranService {
  
  // ============= MAIN EXCHANGE FUNCTION FOR MOBILE =============
  // This is the key function you requested for pembeli to exchange points
  static Future<ApiResponse<Map<String, dynamic>>> exchangePointsMobile({
    required String idPembeli,
    required List<Map<String, dynamic>> items, // [{'id_merch': 'MRC1', 'jumlah': 2}]
  }) async {
    try {
      print('💰 Starting mobile point exchange for buyer: $idPembeli');
      print('📦 Items to exchange: ${items.length}');
      
      final requestData = {
        'id_pembeli': idPembeli,
        'items': items,
      };

      print('📤 Sending exchange request to mobile endpoint...');
      final response = await ApiService.post(
        '${AppConfig.apiUrl}/penukaran-poin/exchange-mobile',
        requestData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        print('✅ Mobile point exchange successful');
        return ApiResponse.success(response.data, message: response.message);
      } else {
        print('❌ Mobile point exchange failed: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error during mobile point exchange: $e');
      return ApiResponse.error('Gagal melakukan penukaran poin: $e');
    }
  }

  // ============= GET EXCHANGE HISTORY FOR MOBILE =============
  static Future<ApiResponse<List<Map<String, dynamic>>>> getExchangeHistoryMobile(String idPembeli) async {
    try {
      print('📜 Fetching mobile exchange history for buyer: $idPembeli');
      
      final response = await ApiService.post(
        '${AppConfig.apiUrl}/penukaran-poin/history-mobile',
        {'id_pembeli': idPembeli},
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final List<dynamic> historyJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        
        final List<Map<String, dynamic>> history = historyJson
            .map((json) => json as Map<String, dynamic>)
            .toList();

        print('✅ Successfully fetched mobile exchange history: ${history.length} entries');
        return ApiResponse.success(history, message: response.message);
      } else {
        print('❌ Failed to fetch mobile exchange history: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error fetching mobile exchange history: $e');
      return ApiResponse.error('Gagal mengambil riwayat penukaran: $e');
    }
  }

  // ============= SINGLE ITEM EXCHANGE (for your "Tukar" button) =============
  static Future<ApiResponse<Map<String, dynamic>>> exchangeSingleItem({
    required String idPembeli,
    required String idMerch,
    int jumlah = 1,
  }) async {
    try {
      print('🎯 Single item exchange: $idMerch x$jumlah for buyer: $idPembeli');
      
      // Use the main exchange function with a single item
      return await exchangePointsMobile(
        idPembeli: idPembeli,
        items: [
          {
            'id_merch': idMerch,
            'jumlah': jumlah,
          }
        ],
      );
    } catch (e) {
      print('❌ Error in single item exchange: $e');
      return ApiResponse.error('Gagal melakukan penukaran item: $e');
    }
  }

  // ============= CART-BASED EXCHANGE (for multiple items) =============
  static Future<ApiResponse<Map<String, dynamic>>> exchangeCartItems({
    required String idPembeli,
    required Map<String, int> cartItems, // Map of merchandise ID to quantity
  }) async {
    try {
      print('🛒 Cart-based exchange for buyer: $idPembeli');
      print('📦 Cart contains ${cartItems.length} different items');
      
      // Convert cart to items array
      final List<Map<String, dynamic>> items = cartItems.entries
          .map((entry) => {
                'id_merch': entry.key,
                'jumlah': entry.value,
              })
          .toList();

      // Use the main exchange function
      return await exchangePointsMobile(
        idPembeli: idPembeli,
        items: items,
      );
    } catch (e) {
      print('❌ Error in cart-based exchange: $e');
      return ApiResponse.error('Gagal melakukan penukaran keranjang: $e');
    }
  }
}

// ============= HELPER FUNCTIONS FOR YOUR EXISTING UI =============

class PenukaranHelper {
  // For your "Tukar" button in the merchandise catalog
  static Future<void> handleTukarButton({
    required BuildContext context,
    required String idPembeli,
    required String idMerch,
    required String namaMerch,
    required int hargaPoin,
    required int userPoin,
    int jumlah = 1,
  }) async {
    // Check if user has enough points
    if (userPoin < hargaPoin * jumlah) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Poin tidak mencukupi untuk menukar $namaMerch'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Anda akan menukar:'),
            const SizedBox(height: 8),
            Text('• $namaMerch x$jumlah'),
            Text('• ${hargaPoin * jumlah} Poin'),
            const SizedBox(height: 12),
            const Text(
              'Penukaran tidak dapat dibatalkan.',
              style: TextStyle(color: Colors.red, fontSize: 12),
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
            child: const Text('Tukar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Perform exchange
      final response = await MobilePenukaranService.exchangeSingleItem(
        idPembeli: idPembeli,
        idMerch: idMerch,
        jumlah: jumlah,
      );

      // Hide loading
      if (context.mounted) {
        Navigator.pop(context);

        if (response.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Penukaran $namaMerch berhasil!'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh user data or points display
          // You can call your AuthProvider refresh here
          
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading and show error
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}