// File: lib/services/komisi_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

class KomisiService {
  static const String _baseUrl = AppConfig.apiUrl;

  /// Get total commission for a specific hunter
  static Future<Map<String, dynamic>> getTotalKomisiHunter(String idPegawai) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/komisi/hunter/$idPegawai/total'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      print('🔍 Komisi API Response Status: ${response.statusCode}');
      print('🔍 Komisi API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
          };
        } else {
          throw Exception(data['message'] ?? 'Gagal mengambil data komisi');
        }
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Pegawai tidak ditemukan');
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Pegawai bukan Hunter');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getTotalKomisiHunter: $e');
      rethrow;
    }
  }

  /// Format currency to Indonesian Rupiah
  static String formatCurrency(double amount) {
    if (amount == 0) return 'Rp 0';
    
    // Convert to int to remove decimal places for whole numbers
    int intAmount = amount.round();
    
    // Format with thousand separators
    String formattedAmount = intAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    
    return 'Rp $formattedAmount';
  }

  /// Get commission details for hunter
  static Future<Map<String, dynamic>> getKomisiDetails(String idPegawai) async {
    try {
      final result = await getTotalKomisiHunter(idPegawai);
      
      if (result['success'] == true) {
        final data = result['data'];
        final double totalKomisi = (data['total_komisi'] ?? 0).toDouble();
        final List komisiDetails = data['komisi_details'] ?? [];
        
        return {
          'success': true,
          'total_komisi': totalKomisi,
          'total_komisi_formatted': formatCurrency(totalKomisi),
          'komisi_details': komisiDetails,
          'pegawai': data['pegawai'],
        };
      } else {
        return {
          'success': false,
          'total_komisi': 0.0,
          'total_komisi_formatted': 'Rp 0',
          'komisi_details': [],
          'error': 'Gagal mengambil data komisi',
        };
      }
    } catch (e) {
      print('❌ Error in getKomisiDetails: $e');
      return {
        'success': false,
        'total_komisi': 0.0,
        'total_komisi_formatted': 'Rp 0',
        'komisi_details': [],
        'error': e.toString(),
      };
    }
  }
}