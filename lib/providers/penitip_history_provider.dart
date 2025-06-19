// File: lib/providers/penitip_history_provider.dart

import 'package:flutter/foundation.dart';
import '../models/penitipan_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class PenitipHistoryProvider with ChangeNotifier {
  // ============= STATE VARIABLES =============
  bool _isLoading = false;
  String? _errorMessage;

  // History Data
  List<PenitipanHistory> _penitipanHistory = [];

  // Filter States
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  // Loading States
  bool _isLoadingDetail = false;

  // ============= GETTERS =============
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessage => _errorMessage;

  // History getters
  List<PenitipanHistory> get penitipanHistory => _penitipanHistory;
  List<PenitipanHistory> get filteredHistory => _getFilteredHistory();

  // Filter getters
  String? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  // Statistics getters - Updated to reflect new status logic
  int get totalPenitipan => _penitipanHistory.length;
  int get activePenitipan => _penitipanHistory.where((p) => p.isActive).length;
  int get completedPenitipan =>
      _penitipanHistory.where((p) => p.isCompleted).length;
  int get needingDecision =>
      _penitipanHistory.where((p) => p.needsDecision).length;
  int get terjualCount =>
      _penitipanHistory.where((p) => p.statusPenitipan == 'Terjual').length;
  int get tersediaCount =>
      _penitipanHistory.where((p) => p.statusPenitipan == 'Tersedia').length;

  // Status-based lists - Updated
  List<PenitipanHistory> get activeProducts =>
      _penitipanHistory.where((p) => p.isActive).toList();
  List<PenitipanHistory> get completedProducts =>
      _penitipanHistory.where((p) => p.isCompleted).toList();
  List<PenitipanHistory> get needingDecisionProducts =>
      _penitipanHistory.where((p) => p.needsDecision).toList();
  List<PenitipanHistory> get tersediaProducts =>
      _penitipanHistory.where((p) => p.statusPenitipan == 'Tersedia').toList();

  // ============= INITIALIZATION =============
  PenitipHistoryProvider() {
    print('📱 PenitipHistoryProvider initialized');
  }

  // ============= HISTORY MANAGEMENT =============
  Future<void> loadHistory({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool refresh = false,
  }) async {
    if (!refresh && _isLoading) return;

    _setLoading(true);

    try {
      // Cek apakah user sudah login dan rolenya penitip
      final userRole = await StorageService.getUserRole();
      if (userRole != 'penitip') {
        print('⚠️ User bukan penitip, skip load history');
        _setLoading(false);
        return;
      }

      print(
          '📡 Loading penitipan history from: ${AppConfig.penitipMobileProfileEndpoint}');

      final response = await ApiService.get(
        AppConfig.penitipMobileProfileEndpoint,
        requiresAuth: true,
      );

      print('📥 History response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          // Response structure from profile endpoint includes produk list
          final profileData = response.data as Map<String, dynamic>;
          final produkList = profileData['produk'] as List<dynamic>? ?? [];

          print('📦 Found ${produkList.length} produk with penitipan data');

          _penitipanHistory = produkList
              .where((produkJson) => produkJson['penitipan'] != null)
              .map((produkJson) {
                try {
                  // Create combined data for PenitipanHistory
                  final penitipanData =
                      produkJson['penitipan'] as Map<String, dynamic>;
                  penitipanData['produk'] = produkJson;

                  return PenitipanHistory.fromJson(penitipanData);
                } catch (e) {
                  print('⚠️ Error parsing penitipan: $e');
                  return null;
                }
              })
              .where((penitipan) => penitipan != null)
              .cast<PenitipanHistory>()
              .toList();

          // Sort by date descending (newest first)
          _penitipanHistory
              .sort((a, b) => b.tanggalMasuk.compareTo(a.tanggalMasuk));

          _clearError();
          print('✅ History loaded: ${_penitipanHistory.length} items');

          // Print status breakdown for debugging
          _debugPrintStatusBreakdown();
        } catch (e) {
          print('❌ Error processing history data: $e');
          _penitipanHistory = [];
          _setError('Format data history tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _penitipanHistory = [];
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat history penitipan: $e');
      print('❌ LoadHistory error: $e');
      _penitipanHistory = [];
    } finally {
      _setLoading(false);
    }
  }

  // Debug method to print status breakdown
  void _debugPrintStatusBreakdown() {
    final statusCounts = <String, int>{};
    for (final penitipan in _penitipanHistory) {
      final status = penitipan.statusPenitipan;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    print('📊 Status breakdown:');
    statusCounts.forEach((status, count) {
      print('  - $status: $count');
    });

    print('📊 Categories:');
    print('  - Active: ${activePenitipan}');
    print('  - Completed: ${completedPenitipan}');
    print('  - Needing Decision: ${needingDecision}');
    print('  - Tersedia: ${tersediaCount}');
    print('  - Terjual: ${terjualCount}');
  }

  // ============= PRODUCT ACTIONS =============
  Future<bool> withdrawProduct(String idPenitipan) async {
    try {
      print('📡 Withdrawing product: $idPenitipan');

      final response = await ApiService.post(
        '/penitipan/$idPenitipan/withdraw',
        {},
        requiresAuth: true,
      );

      if (response.success) {
        await refreshHistory();
        _clearError();
        print('✅ Product withdrawn successfully');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Gagal menarik produk: $e');
      print('❌ Withdraw error: $e');
      return false;
    }
  }

  Future<bool> donateProduct(String idPenitipan) async {
    try {
      print('📡 Donating product: $idPenitipan');

      final response = await ApiService.post(
        '/penitipan/$idPenitipan/donate',
        {},
        requiresAuth: true,
      );

      if (response.success) {
        await refreshHistory();
        _clearError();
        print('✅ Product donated successfully');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Gagal mendonasikan produk: $e');
      print('❌ Donate error: $e');
      return false;
    }
  }

  // ============= FILTER MANAGEMENT =============
  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setDateRangeFilter(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    notifyListeners();
  }

  List<PenitipanHistory> _getFilteredHistory() {
    List<PenitipanHistory> filtered = List.from(_penitipanHistory);

    // Filter by status
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((penitipan) {
        return penitipan.statusPenitipan
                .toLowerCase()
                .contains(_selectedStatus!.toLowerCase()) ||
            penitipan.produk?.statusProduk
                    .toLowerCase()
                    .contains(_selectedStatus!.toLowerCase()) ==
                true;
      }).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered.where((penitipan) {
        return penitipan.tanggalMasuk
            .isAfter(_startDate!.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((penitipan) {
        return penitipan.tanggalMasuk
            .isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((penitipan) {
        final query = _searchQuery.toLowerCase();
        return penitipan.idPenitipan.toLowerCase().contains(query) ||
            penitipan.displayNamaProduk.toLowerCase().contains(query) ||
            penitipan.displayNamaHunter.toLowerCase().contains(query) ||
            penitipan.statusPenitipan.toLowerCase().contains(query) ||
            penitipan.produk?.kategoriProduk.toLowerCase().contains(query) ==
                true;
      }).toList();
    }

    return filtered;
  }

  // ============= REFRESH METHODS =============
  Future<void> refreshHistory() async {
    await loadHistory(
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
      refresh: true,
    );
  }

  // ============= STATE MANAGEMENT HELPERS =============
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingDetail(bool loading) {
    _isLoadingDetail = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    print('❌ PenitipHistoryProvider Error: $error');
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
    _penitipanHistory.clear();
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _clearError();
    notifyListeners();
  }
}
