// File: lib/providers/penitip_provider.dart - FIXED VERSION

import 'package:flutter/foundation.dart';
import '../models/penitip.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class PenitipProvider with ChangeNotifier {
  // ============= STATE VARIABLES =============
  bool _isLoading = false;
  String? _errorMessage;

  // Penitip Data - Menggunakan Model Penitip
  Penitip? _penitip;

  // Produk & Transaction Data
  List<ProdukPenitip> _produkList = [];
  List<RiwayatTransaksi> _riwayatTransaksi = [];

  // Dashboard Stats
  Map<String, dynamic> _dashboardStats = {};

  // Loading States
  bool _isUpdatingProfile = false;
  bool _isLoadingProduk = false;
  bool _isLoadingTransaksi = false;
  bool _isLoadingIncome = false;
  bool _isLoadingPoints = false;

  // ============= GETTERS =============
  bool get isLoading => _isLoading;
  bool get isUpdatingProfile => _isUpdatingProfile;
  bool get isLoadingProduk => _isLoadingProduk;
  bool get isLoadingTransaksi => _isLoadingTransaksi;
  bool get isLoadingIncome => _isLoadingIncome;
  bool get isLoadingPoints => _isLoadingPoints;
  String? get errorMessage => _errorMessage;

  // Profile getters - menggunakan model Penitip
  Penitip? get penitip => _penitip;
  String? get penitipName => _penitip?.namaPenitip;
  String? get penitipEmail => _penitip?.emailPenitip;
  String? get penitipPhone => _penitip?.noTelpPenitip;
  String? get penitipId => _penitip?.idPenitip;
  String? get penitipAddress => _penitip?.alamatPenitip;
  String? get penitipNik => _penitip?.nikPenitip;
  double get penitipSaldo => _penitip?.saldoPenitip ?? 0.0;
  int get penitipPoin => _penitip?.poinPenitip ?? 0;
  bool get penitipBadgeLoyalitas => _penitip?.badgeLoyalitas ?? false;
  String get formattedSaldo => _penitip?.formattedSaldo ?? 'Rp 0';
  String get formattedPoin => _penitip?.formattedPoin ?? '0';

  // Produk getters
  List<ProdukPenitip> get produkList => _produkList;
  List<ProdukPenitip> get produkTersedia =>
      _produkList.where((p) => p.statusProduk == 'Tersedia').toList();
  List<ProdukPenitip> get produkTerjual =>
      _produkList.where((p) => p.statusProduk == 'Terjual').toList();
  List<ProdukPenitip> get produkDiambilKembali =>
      _produkList.where((p) => p.statusProduk == 'Diambil Kembali').toList();
  List<ProdukPenitip> get produkDidonasikan =>
      _produkList.where((p) => p.statusProduk == 'Barang Donasi').toList();

  // Transaksi getters
  List<RiwayatTransaksi> get riwayatTransaksi => _riwayatTransaksi;
  List<RiwayatTransaksi> get riwayatIncome =>
      _riwayatTransaksi.where((r) => r.isIncome).toList();
  List<RiwayatTransaksi> get riwayatWithdrawal =>
      _riwayatTransaksi.where((r) => r.isWithdrawal).toList();
  List<RiwayatTransaksi> get recentTransaksi =>
      _riwayatTransaksi.take(5).toList();

  // Dashboard stats
  int get totalProduk => _penitip?.totalProduk ?? 0;
  int get totalProdukTersedia => _penitip?.produkTersedia ?? 0;
  int get totalProdukTerjual => _penitip?.produkTerjual ?? 0;
  double get totalPendapatan =>
      _dashboardStats['total_pendapatan']?.toDouble() ?? 0.0;
  double get rataRataRating =>
      _dashboardStats['rata_rata_rating']?.toDouble() ?? 0.0;

  // ============= INITIALIZATION =============
  PenitipProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    try {
      print('📱 PenitipProvider initialized');
    } catch (e) {
      print('❌ Error loading stored data: $e');
    }
  }

  // ============= PROFILE MANAGEMENT =============
  Future<void> loadProfile() async {
    _setLoading(true);

    try {
      // Cek apakah user sudah login dan rolenya penitip
      final userRole = await StorageService.getUserRole();
      if (userRole != 'penitip') {
        print('⚠️ User bukan penitip, skip load profile');
        _setLoading(false);
        return;
      }

      print(
          '📡 Loading penitip profile from: ${AppConfig.penitipMobileProfileEndpoint}');

      final response = await ApiService.get(
        AppConfig.penitipMobileProfileEndpoint,
        requiresAuth: true,
      );

      print('📥 Profile response: ${response.toString()}');

      if (response.success && response.data != null) {
        final profileData = response.data as Map<String, dynamic>;

        print('👤 Profile data received: ${profileData.keys.toList()}');
        print('📦 Produk data in response: ${profileData['produk']}');

        try {
          _penitip = Penitip.fromJson(profileData);
          print('✅ Penitip model created successfully');
          print('👤 Penitip: ${_penitip!.namaPenitip}');
          print('💰 Saldo: ${_penitip!.formattedSaldo}');
          print('🏆 Poin: ${_penitip!.formattedPoin}');
          print('📦 Produk count: ${_penitip!.produk?.length ?? 0}');

          // Update produk list from profile
          if (_penitip!.produk != null) {
            _produkList = _penitip!.produk!;
            print('📦 Produk list updated: ${_produkList.length} items');
          }

          _clearError();
        } catch (e) {
          print('❌ Error creating Penitip model: $e');
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

  // ============= DASHBOARD DATA =============
  Future<void> loadDashboardData() async {
    _setLoading(true);

    try {
      final userRole = await StorageService.getUserRole();
      if (userRole != 'penitip') {
        print('⚠️ User bukan penitip, skip load dashboard');
        _setLoading(false);
        return;
      }

      print(
          '📡 Loading dashboard data from: ${AppConfig.penitipMobileDashboardEndpoint}');

      final response = await ApiService.get(
        AppConfig.penitipMobileDashboardEndpoint,
        requiresAuth: true,
      );

      print('📥 Dashboard response: ${response.toString()}');

      if (response.success && response.data != null) {
        final dashboardData = response.data as Map<String, dynamic>;

        // Update penitip info menggunakan model Penitip
        if (dashboardData['user_info'] != null) {
          try {
            _penitip = Penitip.fromJson(
                dashboardData['user_info'] as Map<String, dynamic>);
            print('✅ Dashboard user info updated');
          } catch (e) {
            print('❌ Error parsing dashboard user info: $e');
          }
        }

        // Update stats
        if (dashboardData['statistics'] != null) {
          _dashboardStats = dashboardData['statistics'] as Map<String, dynamic>;
          print('📊 Dashboard stats updated: ${_dashboardStats.keys.toList()}');
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

  // ============= PRODUK MANAGEMENT =============
  Future<void> loadProdukList() async {
    _setLoadingProduk(true);

    try {
      final userRole = await StorageService.getUserRole();
      if (userRole != 'penitip') {
        print('⚠️ User bukan penitip, skip load produk');
        _setLoadingProduk(false);
        return;
      }

      print(
          '📡 Loading produk list from: ${AppConfig.penitipMobileProdukEndpoint}');

      final response = await ApiService.get(
        AppConfig.penitipMobileProdukEndpoint,
        requiresAuth: true,
      );

      print('📥 Produk response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          final produkData = response.data as List<dynamic>;

          print('📦 Found ${produkData.length} produk in response');

          _produkList = produkData
              .map((produkJson) {
                try {
                  print('🔍 Processing produk: ${produkJson['id_produk']}');
                  return ProdukPenitip.fromJson(
                      produkJson as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ Error parsing produk: $e');
                  print('📄 Produk data: $produkJson');
                  return null;
                }
              })
              .where((produk) => produk != null)
              .cast<ProdukPenitip>()
              .toList();

          // Sort by created date descending
          _produkList.sort((a, b) => (b.createdAt ?? DateTime.now())
              .compareTo(a.createdAt ?? DateTime.now()));

          _clearError();
          print('✅ Produk list loaded: ${_produkList.length} items');

          // Debug print produk dengan info lengkap
          for (var produk in _produkList.take(3)) {
            print(
                '📦 Produk: ${produk.namaProduk} - ${produk.statusProduk} - ${produk.formattedHarga}');
          }
        } catch (e) {
          print('❌ Error processing produk data: $e');
          _produkList = [];
          _setError('Format data produk tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _produkList = [];
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat daftar produk: $e');
      print('❌ LoadProdukList error: $e');
      _produkList = [];
    } finally {
      _setLoadingProduk(false);
    }
  }

  // ============= TRANSAKSI MANAGEMENT =============
  Future<void> loadRiwayatTransaksi() async {
    _setLoadingTransaksi(true);

    try {
      final userRole = await StorageService.getUserRole();
      if (userRole != 'penitip') {
        print('⚠️ User bukan penitip, skip load transaksi');
        _setLoadingTransaksi(false);
        return;
      }

      print(
          '📡 Loading riwayat transaksi from: ${AppConfig.penitipMobileTransaksiEndpoint}');

      final response = await ApiService.get(
        AppConfig.penitipMobileTransaksiEndpoint,
        requiresAuth: true,
      );

      print('📥 Transaksi response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          final transaksiData = response.data as List<dynamic>;

          print('💳 Found ${transaksiData.length} transaksi in response');

          _riwayatTransaksi = transaksiData
              .map((transaksiJson) {
                try {
                  print(
                      '🔍 Processing transaksi: ${transaksiJson['id_pemesanan']}');
                  return RiwayatTransaksi.fromJson(
                      transaksiJson as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ Error parsing transaksi: $e');
                  print('📄 Transaksi data: $transaksiJson');
                  return null;
                }
              })
              .where((transaksi) => transaksi != null)
              .cast<RiwayatTransaksi>()
              .toList();

          // Sort by date descending
          _riwayatTransaksi.sort((a, b) => b.tanggal.compareTo(a.tanggal));

          _clearError();
          print(
              '✅ Riwayat transaksi loaded: ${_riwayatTransaksi.length} items');

          // Debug print transaksi dengan info lengkap
          for (var transaksi in _riwayatTransaksi.take(3)) {
            print(
                '💳 Transaksi: ${transaksi.deskripsi} - ${transaksi.tipe} - ${transaksi.formattedJumlah}');
          }
        } catch (e) {
          print('❌ Error processing transaksi data: $e');
          _riwayatTransaksi = [];
          _setError('Format data transaksi tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _riwayatTransaksi = [];
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat riwayat transaksi: $e');
      print('❌ LoadRiwayatTransaksi error: $e');
      _riwayatTransaksi = [];
    } finally {
      _setLoadingTransaksi(false);
    }
  }

  // ============= UPDATE PROFILE =============
  Future<bool> updateProfile({
    String? namaPenitip,
    String? emailPenitip,
    String? noTelpPenitip,
    String? alamatPenitip,
    String? passwordPenitip,
  }) async {
    if (_penitip == null) {
      _setError('Profile belum dimuat');
      return false;
    }

    _setUpdatingProfile(true);

    try {
      print('📡 Updating penitip profile...');

      final updateData = <String, dynamic>{};

      if (namaPenitip != null && namaPenitip.isNotEmpty) {
        updateData['nama_penitip'] = namaPenitip;
      }
      if (emailPenitip != null && emailPenitip.isNotEmpty) {
        updateData['email_penitip'] = emailPenitip;
      }
      if (noTelpPenitip != null && noTelpPenitip.isNotEmpty) {
        updateData['noTelp_penitip'] = noTelpPenitip;
      }
      if (alamatPenitip != null && alamatPenitip.isNotEmpty) {
        updateData['alamat_penitip'] = alamatPenitip;
      }
      if (passwordPenitip != null && passwordPenitip.isNotEmpty) {
        updateData['password_penitip'] = passwordPenitip;
      }

      if (updateData.isEmpty) {
        _setError('Tidak ada perubahan data');
        return false;
      }

      print('📤 Update data: $updateData');

      final response = await ApiService.put(
        AppConfig.penitipMobileUpdateEndpoint,
        updateData,
        requiresAuth: true,
      );

      print('📥 Update response: ${response.toString()}');

      if (response.success && response.data != null) {
        final updatedData = response.data as Map<String, dynamic>;

        // Update penitip model
        try {
          _penitip = Penitip.fromJson(updatedData);
          print('✅ Profile updated successfully');
          _clearError();
          return true;
        } catch (e) {
          print('❌ Error updating Penitip model: $e');
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

  // ============= UTILITY METHODS =============
  Future<void> refreshData() async {
    await loadProfile();
    await loadProdukList();
    await loadRiwayatTransaksi();
  }

  Future<void> refreshAll() async {
    await loadDashboardData();
    await loadProdukList();
    await loadRiwayatTransaksi();
  }

  // ============= SEARCH FUNCTIONALITY =============
  List<ProdukPenitip> getFilteredProduk(String query) {
    if (query.isEmpty) return _produkList;

    return _produkList.where((produk) {
      return produk.namaProduk.toLowerCase().contains(query.toLowerCase()) ||
          produk.kategoriProduk.toLowerCase().contains(query.toLowerCase()) ||
          produk.statusProduk.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<RiwayatTransaksi> getFilteredTransaksi(String query) {
    if (query.isEmpty) return _riwayatTransaksi;

    return _riwayatTransaksi.where((transaksi) {
      return transaksi.deskripsi.toLowerCase().contains(query.toLowerCase()) ||
          (transaksi.namaProduk?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  // ============= FILTER HELPERS =============
  List<ProdukPenitip> getProdukByStatus(String status) {
    return _produkList
        .where((produk) => produk.statusProduk == status)
        .toList();
  }

  List<ProdukPenitip> getProdukByKategori(String kategori) {
    return _produkList
        .where((produk) => produk.kategoriProduk == kategori)
        .toList();
  }

  List<RiwayatTransaksi> getTransaksiByType(String type) {
    return _riwayatTransaksi
        .where((transaksi) => transaksi.tipe == type)
        .toList();
  }

  List<RiwayatTransaksi> getTransaksiByDateRange(
      DateTime startDate, DateTime endDate) {
    return _riwayatTransaksi.where((transaksi) {
      return transaksi.tanggal
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          transaksi.tanggal.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
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

  void _setLoadingProduk(bool loading) {
    _isLoadingProduk = loading;
    notifyListeners();
  }

  void _setLoadingTransaksi(bool loading) {
    _isLoadingTransaksi = loading;
    notifyListeners();
  }

  void _setLoadingIncome(bool loading) {
    _isLoadingIncome = loading;
    notifyListeners();
  }

  void _setLoadingPoints(bool loading) {
    _isLoadingPoints = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    print('❌ PenitipProvider Error: $error');
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // ============= RESET DATA =============
  void resetData() {
    _penitip = null;
    _produkList.clear();
    _riwayatTransaksi.clear();
    _dashboardStats.clear();
    _clearError();
    notifyListeners();
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
    String? alamat,
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

    if (alamat != null && alamat.trim().length < 5) {
      return 'Alamat minimal 5 karakter';
    }

    if (password != null && password.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // ============= DEBUG INFO =============
  String getDebugInfo() {
    return '''
PenitipProvider Debug Info:
- Loading: $_isLoading
- Updating Profile: $_isUpdatingProfile
- Loading Produk: $_isLoadingProduk
- Loading Transaksi: $_isLoadingTransaksi
- Loading Income: $_isLoadingIncome
- Loading Points: $_isLoadingPoints
- Penitip: ${_penitip != null ? 'Loaded' : 'Null'}
- ID: ${_penitip?.idPenitip ?? 'null'}
- Name: ${_penitip?.namaPenitip ?? 'null'}
- Email: ${_penitip?.emailPenitip ?? 'null'}
- Phone: ${_penitip?.noTelpPenitip ?? 'null'}
- Saldo: ${_penitip?.formattedSaldo ?? 'Rp 0'}
- Poin: ${_penitip?.formattedPoin ?? '0'}
- Badge: ${_penitip?.badgeLoyalitas ?? false}
- Produk Count: ${_produkList.length}
- Transaksi Count: ${_riwayatTransaksi.length}
- Error: $_errorMessage
- Total Produk: $totalProduk
- Produk Tersedia: $totalProdukTersedia
- Produk Terjual: $totalProdukTerjual
- Total Pendapatan: $totalPendapatan
- Rata-rata Rating: $rataRataRating
    ''';
  }

  void printDebugInfo() {
    print('🐛 ${getDebugInfo()}');
  }
}
