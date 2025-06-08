// File: lib/services/merchandise_service.dart

import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/merchandise.dart';
import 'api_service.dart';

class MerchandiseService {
  // Get all available merchandise
  static Future<ApiResponse<List<Merchandise>>> getAllMerchandise() async {
    try {
      print('🎁 Fetching all merchandise from Laravel API');
      
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/merchandise',
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final List<dynamic> merchandiseJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        
        final List<Merchandise> merchandises = merchandiseJson
            .map((json) => Merchandise.fromJson(json))
            .toList();

        print('✅ Successfully fetched ${merchandises.length} merchandise items');
        return ApiResponse.success(merchandises, message: response.message);
      } else {
        print('❌ Failed to fetch merchandise: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error fetching merchandise: $e');
      return ApiResponse.error('Gagal mengambil data merchandise: $e');
    }
  }

  // Get merchandise by ID
  static Future<ApiResponse<Merchandise>> getMerchandiseById(String merchandiseId) async {
    try {
      print('🔍 Fetching merchandise by ID: $merchandiseId');
      
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/merchandise/$merchandiseId',
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final merchandise = Merchandise.fromJson(response.data);
        
        print('✅ Successfully fetched merchandise: ${merchandise.namaMerch}');
        return ApiResponse.success(merchandise, message: response.message);
      } else {
        print('❌ Failed to fetch merchandise: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error fetching merchandise by ID: $e');
      return ApiResponse.error('Gagal mengambil detail merchandise: $e');
    }
  }

  // Exchange points for merchandise
  static Future<ApiResponse<Map<String, dynamic>>> exchangePoints({
    required String idPembeli,
    required String idPegawai,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      print('💰 Attempting point exchange for buyer: $idPembeli');
      print('📦 Items to exchange: ${items.length}');
      
      final requestData = {
        'id_pembeli': idPembeli,
        'id_pegawai': idPegawai,
        'items': items,
      };

      final response = await ApiService.post(
        '${AppConfig.apiUrl}/merchandise/tukar-poin',
        requestData,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        print('✅ Point exchange successful');
        return ApiResponse.success(response.data, message: response.message);
      } else {
        print('❌ Point exchange failed: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error during point exchange: $e');
      return ApiResponse.error('Gagal melakukan penukaran poin: $e');
    }
  }

  // Get exchange history for a buyer
  static Future<ApiResponse<List<Map<String, dynamic>>>> getExchangeHistory(String idPembeli) async {
    try {
      print('📜 Fetching exchange history for buyer: $idPembeli');
      
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/merchandise/history/$idPembeli',
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final List<dynamic> historyJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        
        final List<Map<String, dynamic>> history = historyJson
            .map((json) => json as Map<String, dynamic>)
            .toList();

        print('✅ Successfully fetched exchange history: ${history.length} entries');
        return ApiResponse.success(history, message: response.message);
      } else {
        print('❌ Failed to fetch exchange history: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error fetching exchange history: $e');
      return ApiResponse.error('Gagal mengambil riwayat penukaran: $e');
    }
  }
}