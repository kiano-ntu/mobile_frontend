// File: lib/providers/pembeli_provider.dart

import 'package:flutter/foundation.dart';
import '../models/pembeli.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class PembeliProvider with ChangeNotifier {
  // ============= STATE VARIABLES =============
  bool _isLoading = false;
  String? _errorMessage;

  // Pembeli Data - Menggunakan Model Pembeli
  Pembeli? _pembeli;

  // Riwayat & Transaction Data
  List<RiwayatPoin> _riwayatPoin = [];
  List<dynamic> _pemesananHistory = [];

  // Loading States
  bool _isUpdatingProfile = false;
  bool _isLoadingRiwayat = false;
  bool _isLoadingHistory = false;

  // ============= GETTERS =============
  bool get isLoading => _isLoading;
  bool get isUpdatingProfile => _isUpdatingProfile;
  bool get isLoadingRiwayat => _isLoadingRiwayat;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get errorMessage => _errorMessage;

  // Profile getters - menggunakan model Pembeli
  Pembeli? get pembeli => _pembeli;
  String? get pembeliName => _pembeli?.namaPembeli;
  String? get pembeliEmail => _pembeli?.emailPembeli;
  String? get pembeliPhone => _pembeli?.noTelpPembeli;
  String? get pembeliId => _pembeli?.idPembeli;
  int get pembeliPoin => _pembeli?.poinPembeli ?? 0;
  String get formattedPoin => _pembeli?.formattedPoin ?? '0';

  // Alamat getters - menggunakan model Pembeli.alamat
  List<Alamat> get alamatList => _pembeli?.alamat ?? [];
  Alamat? get defaultAlamat => _pembeli?.defaultAlamat;

  // Riwayat getters
  List<RiwayatPoin> get riwayatPoin => _riwayatPoin;
  List<RiwayatPoin> get riwayatEarn =>
      _riwayatPoin.where((r) => r.isEarn).toList();
  List<RiwayatPoin> get riwayatRedeem =>
      _riwayatPoin.where((r) => r.isRedeem).toList();
  List<dynamic> get pemesananHistory => _pemesananHistory;
  List<dynamic> get recentPemesanan => _pemesananHistory.take(5).toList();

  // Dashboard stats
  int get totalPemesanan => _pemesananHistory.length;
  int get completedPemesanan => _pemesananHistory
      .where((p) => p['status_pengiriman'] == 'Selesai')
      .length;
  int get activePemesanan => _pemesananHistory
      .where((p) =>
          ['Disiapkan', 'Dikirim', 'Sampai'].contains(p['status_pengiriman']))
      .length;

  // ============= INITIALIZATION =============
  PembeliProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    try {
      print('📱 PembeliProvider initialized');
    } catch (e) {
      print('❌ Error loading stored data: $e');
    }
  }

  // ============= PROFILE MANAGEMENT =============
  Future<void> loadProfile() async {
    _setLoading(true);

    try {
      // Cek apakah user sudah login dan rolenya pembeli
      final userRole = await StorageService.getUserRole();
      if (userRole != 'pembeli') {
        print('⚠️ User bukan pembeli, skip load profile');
        _setLoading(false);
        return;
      }

      print(
          '📡 Loading pembeli profile from: ${AppConfig.pembeliMobileProfileEndpoint}');

      final response = await ApiService.get(
        AppConfig.pembeliMobileProfileEndpoint,
        requiresAuth: true,
      );

      print('📥 Profile response: ${response.toString()}');

      if (response.success && response.data != null) {
        final profileData = response.data as Map<String, dynamic>;

        print('👤 Profile data received: ${profileData.keys.toList()}');
        print('🏠 Alamat data in response: ${profileData['alamat']}');

        // 🎯 MENGGUNAKAN MODEL PEMBELI YANG SUDAH ADA
        try {
          _pembeli = Pembeli.fromJson(profileData);
          print('✅ Pembeli model created successfully');
          print('👤 Pembeli: ${_pembeli!.namaPembeli}');
          print('🏠 Alamat count: ${_pembeli!.alamat?.length ?? 0}');

          // Debug alamat
          if (_pembeli!.alamat != null) {
            for (var alamat in _pembeli!.alamat!) {
              print(
                  '🏠 Alamat: ${alamat.tagAlamat} (${alamat.idAlamat}) - Default: ${alamat.isDefault}');
            }
            print(
                '🏠 Default alamat: ${_pembeli!.defaultAlamat?.tagAlamat ?? 'None'}');
          } else {
            print('⚠️ No alamat in pembeli model');
          }

          _clearError();
        } catch (e) {
          print('❌ Error creating Pembeli model: $e');
          print('📄 Profile data: $profileData');
          _setError('Gagal memproses data profil: $e');
        }
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Gagal memuat profil: $e');
      print('❌ LoadProfile error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============= UPDATE PROFILE =============
  Future<bool> updateProfile({
    String? namaPembeli,
    String? emailPembeli,
    String? noTelpPembeli,
    String? passwordPembeli,
  }) async {
    if (_pembeli == null) {
      _setError('Profile belum dimuat');
      return false;
    }

    _setUpdatingProfile(true);

    try {
      print('📡 Updating pembeli profile...');

      final updateData = <String, dynamic>{};

      if (namaPembeli != null && namaPembeli.isNotEmpty) {
        updateData['nama_pembeli'] = namaPembeli;
      }
      if (emailPembeli != null && emailPembeli.isNotEmpty) {
        updateData['email_pembeli'] = emailPembeli;
      }
      if (noTelpPembeli != null && noTelpPembeli.isNotEmpty) {
        updateData['noTelp_pembeli'] = noTelpPembeli;
      }
      if (passwordPembeli != null && passwordPembeli.isNotEmpty) {
        updateData['password_pembeli'] = passwordPembeli;
      }

      if (updateData.isEmpty) {
        _setError('Tidak ada perubahan data');
        return false;
      }

      print('📤 Update data: $updateData');

      final response = await ApiService.put(
        AppConfig.pembeliMobileUpdateEndpoint,
        updateData,
        requiresAuth: true,
      );

      print('📥 Update response: ${response.toString()}');

      if (response.success && response.data != null) {
        final updatedData = response.data as Map<String, dynamic>;

        // Update pembeli model
        try {
          _pembeli = Pembeli.fromJson(updatedData);
          print('✅ Profile updated successfully');
          _clearError();
          return true;
        } catch (e) {
          print('❌ Error updating Pembeli model: $e');
          _setError('Gagal memproses data yang diperbarui: $e');
          return false;
        }
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Gagal update profil: $e');
      print('❌ UpdateProfile error: $e');
      return false;
    } finally {
      _setUpdatingProfile(false);
    }
  }

  // ============= RIWAYAT POIN MANAGEMENT =============
  Future<void> loadRiwayatPoin() async {
    _setLoadingRiwayat(true);

    try {
      // Cek apakah user sudah login dan rolenya pembeli
      final userRole = await StorageService.getUserRole();
      if (userRole != 'pembeli') {
        print('⚠️ User bukan pembeli, skip load riwayat');
        _setLoadingRiwayat(false);
        return;
      }

      print(
          '📡 Loading riwayat poin from: ${AppConfig.pembeliMobileRiwayatPoinEndpoint}');

      final response = await ApiService.get(
        AppConfig.pembeliMobileRiwayatPoinEndpoint,
        requiresAuth: true,
      );

      print('📥 Riwayat response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          final riwayatData = response.data as List<dynamic>;

          print('💰 Found ${riwayatData.length} riwayat poin in response');

          _riwayatPoin = riwayatData
              .map((riwayatJson) {
                try {
                  print('🔍 Processing riwayat: ${riwayatJson['id']}');
                  return RiwayatPoin.fromJson(
                      riwayatJson as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ Error parsing riwayat: $e');
                  print('📄 Riwayat data: $riwayatJson');
                  return null;
                }
              })
              .where((riwayat) => riwayat != null)
              .cast<RiwayatPoin>()
              .toList();

          // Sort by date descending
          _riwayatPoin.sort((a, b) => b.tanggal.compareTo(a.tanggal));

          _clearError();
          print('✅ Riwayat poin loaded: ${_riwayatPoin.length} items');

          // Debug print riwayat dengan info lengkap
          for (var riwayat in _riwayatPoin.take(3)) {
            print(
                '💰 Riwayat: ${riwayat.deskripsi} - ${riwayat.tipe} - ${riwayat.jumlah}');
          }
        } catch (e) {
          print('❌ Error processing riwayat data: $e');
          _riwayatPoin = [];
          _setError('Format data riwayat tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _riwayatPoin = [];
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat riwayat poin: $e');
      print('❌ LoadRiwayatPoin error: $e');
      _riwayatPoin = [];
    } finally {
      _setLoadingRiwayat(false);
    }
  }

  Future<void> refreshRiwayat() async {
    await loadRiwayatPoin();
  }

  // ============= DASHBOARD DATA =============
  Future<void> loadDashboardData() async {
    _setLoading(true);

    try {
      final userRole = await StorageService.getUserRole();
      if (userRole != 'pembeli') {
        print('⚠️ User bukan pembeli, skip load dashboard');
        _setLoading(false);
        return;
      }

      print(
          '📡 Loading dashboard data from: ${AppConfig.pembeliMobileDashboardEndpoint}');

      final response = await ApiService.get(
        AppConfig.pembeliMobileDashboardEndpoint,
        requiresAuth: true,
      );

      print('📥 Dashboard response: ${response.toString()}');

      if (response.success && response.data != null) {
        final dashboardData = response.data as Map<String, dynamic>;

        // Update user info menggunakan model Pembeli
        if (dashboardData['user_info'] != null) {
          try {
            _pembeli = Pembeli.fromJson(
                dashboardData['user_info'] as Map<String, dynamic>);
            print('✅ Dashboard user info updated');
          } catch (e) {
            print('❌ Error parsing dashboard user info: $e');
          }
        }

        // Update recent orders
        if (dashboardData['recent_orders'] != null) {
          _pemesananHistory = dashboardData['recent_orders'] as List<dynamic>;
        }

        _clearError();
        print('✅ Dashboard data loaded successfully');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Gagal memuat data dashboard: $e');
      print('❌ LoadDashboard error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============= UTILITY METHODS =============
  Future<void> refreshData() async {
    await loadProfile();
    await loadRiwayatPoin();
  }

  Future<void> refreshAll() async {
    await loadDashboardData();
    await loadRiwayatPoin();
  }

  bool _isToday(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (e) {
      return false;
    }
  }

  // ============= STATE MANAGEMENT HELPERS =============
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdatingProfile(bool updating) {
    _isUpdatingProfile = updating;
    notifyListeners();
  }

  void _setLoadingRiwayat(bool loading) {
    _isLoadingRiwayat = loading;
    notifyListeners();
  }

  void _setLoadingHistory(bool loading) {
    _isLoadingHistory = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    print('❌ PembeliProvider Error: $error');
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // ============= SEARCH FUNCTIONALITY =============
  void searchRiwayat(String query) {
    // This method doesn't modify the original list, just for UI filtering
    notifyListeners();
  }

  List<RiwayatPoin> getFilteredRiwayat(String query) {
    if (query.isEmpty) return _riwayatPoin;

    return _riwayatPoin.where((riwayat) {
      return riwayat.deskripsi.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ============= RESET DATA =============
  void resetData() {
    _pembeli = null;
    _riwayatPoin.clear();
    _pemesananHistory.clear();
    _clearError();
    notifyListeners();
  }

  // ============= FILTER HELPERS =============
  List<RiwayatPoin> getRiwayatByType(String type) {
    return _riwayatPoin.where((riwayat) => riwayat.tipe == type).toList();
  }

  List<RiwayatPoin> getEarnRiwayat() {
    return getRiwayatByType('earn');
  }

  List<RiwayatPoin> getRedeemRiwayat() {
    return getRiwayatByType('redeem');
  }

  List<RiwayatPoin> getRiwayatByDateRange(
      DateTime startDate, DateTime endDate) {
    return _riwayatPoin.where((riwayat) {
      return riwayat.tanggal
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          riwayat.tanggal.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // ============= VALIDATION HELPERS =============
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^[0-9+\-\s()]{8,15}$').hasMatch(phone);
  }

  String? validateInput({
    String? nama,
    String? email,
    String? phone,
    String? password,
  }) {
    if (nama != null && nama.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }

    if (email != null && !isValidEmail(email)) {
      return 'Format email tidak valid';
    }

    if (phone != null && phone.isNotEmpty && !isValidPhone(phone)) {
      return 'Format nomor telepon tidak valid';
    }

    if (password != null && password.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // ============= DEBUG INFO =============
  String getDebugInfo() {
    return '''
PembeliProvider Debug Info:
- Loading: $_isLoading
- Updating Profile: $_isUpdatingProfile
- Loading Riwayat: $_isLoadingRiwayat
- Loading History: $_isLoadingHistory
- Pembeli: ${_pembeli != null ? 'Loaded' : 'Null'}
- ID: ${_pembeli?.idPembeli ?? 'null'}
- Name: ${_pembeli?.namaPembeli ?? 'null'}
- Email: ${_pembeli?.emailPembeli ?? 'null'}
- Phone: ${_pembeli?.noTelpPembeli ?? 'null'}
- Poin: ${_pembeli?.poinPembeli ?? 0}
- Alamat Count: ${_pembeli?.alamat?.length ?? 0}
- Default Alamat: ${_pembeli?.defaultAlamat?.tagAlamat ?? 'null'}
- Riwayat Count: ${_riwayatPoin.length}
- Pemesanan Count: ${_pemesananHistory.length}
- Error: $_errorMessage
- Total Pemesanan: $totalPemesanan
- Completed: $completedPemesanan
- Active: $activePemesanan
    ''';
  }

  void printDebugInfo() {
    print('🐛 ${getDebugInfo()}');
  }
}