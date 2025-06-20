// File: lib/providers/history_provider.dart

import 'package:flutter/foundation.dart';
import '../models/pemesanan.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class HistoryProvider with ChangeNotifier {
  // ============= STATE VARIABLES =============
  bool _isLoading = false;
  String? _errorMessage;

  // History Data
  List<Pemesanan> _pemesananHistory = [];

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
  List<Pemesanan> get pemesananHistory => _pemesananHistory;
  List<Pemesanan> get filteredHistory => _getFilteredHistory();

  // Filter getters
  String? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  // Statistics getters
  int get totalPemesanan => _pemesananHistory.length;
  int get completedPemesanan =>
      _pemesananHistory.where((p) => p.isCompleted).length;
  int get activePemesanan => _pemesananHistory.where((p) => p.isActive).length;
  int get cancelledPemesanan =>
      _pemesananHistory.where((p) => p.isCancelled).length;

  double get totalSpent => _pemesananHistory
      .where((p) => p.isPaid)
      .fold(0.0, (sum, p) => sum + p.totalBayar);

  int get totalPoinEarned => _pemesananHistory
      .where((p) => p.isCompleted)
      .fold(0, (sum, p) => sum + p.poinDidapatkan);

  // Recent history
  List<Pemesanan> get recentHistory => _pemesananHistory.take(5).toList();

  // Status-based lists
  List<Pemesanan> get completedOrders =>
      _pemesananHistory.where((p) => p.isCompleted).toList();
  List<Pemesanan> get activeOrders =>
      _pemesananHistory.where((p) => p.isActive).toList();
  List<Pemesanan> get cancelledOrders =>
      _pemesananHistory.where((p) => p.isCancelled).toList();

  // ============= INITIALIZATION =============
  HistoryProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    try {
      print('📱 HistoryProvider initialized');
    } catch (e) {
      print('❌ Error loading stored data: $e');
    }
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
      // Cek apakah user sudah login dan rolenya pembeli
      final userRole = await StorageService.getUserRole();
      if (userRole != 'pembeli') {
        print('⚠️ User bukan pembeli, skip load history');
        _setLoading(false);
        return;
      }

      print(
          '📡 Loading pemesanan history from: ${AppConfig.pembeliMobileHistoryEndpoint}');

      // Build query parameters
      final queryParams = <String, String>{};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      // Build URL with query parameters
      String url = AppConfig.pembeliMobileHistoryEndpoint;
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$query';
      }

      final response = await ApiService.get(
        url,
        requiresAuth: true,
      );

      print('📥 History response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          final historyData = response.data as List<dynamic>;

          print('📦 Found ${historyData.length} pemesanan in response');

          _pemesananHistory = historyData
              .map((pemesananJson) {
                try {
                  print(
                      '🔍 Processing pemesanan: ${pemesananJson['id_pemesanan']}');
                  return Pemesanan.fromJson(
                      pemesananJson as Map<String, dynamic>);
                } catch (e) {
                  print('⚠️ Error parsing pemesanan: $e');
                  print('📄 Pemesanan data: $pemesananJson');
                  return null;
                }
              })
              .where((pemesanan) => pemesanan != null)
              .cast<Pemesanan>()
              .toList();

          // Sort by date descending (newest first)
          _pemesananHistory
              .sort((a, b) => b.tanggalPesan.compareTo(a.tanggalPesan));

          _clearError();
          print('✅ History loaded: ${_pemesananHistory.length} items');

          // Debug print pemesanan dengan info lengkap
          for (var pemesanan in _pemesananHistory.take(3)) {
            print(
                '📦 Pemesanan: ${pemesanan.idPemesanan} - ${pemesanan.displayNamaProduk} - ${pemesanan.statusPengiriman}');
          }
        } catch (e) {
          print('❌ Error processing history data: $e');
          _pemesananHistory = [];
          _setError('Format data history tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _pemesananHistory = [];
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat history pemesanan: $e');
      print('❌ LoadHistory error: $e');
      _pemesananHistory = [];
    } finally {
      _setLoading(false);
    }
  }

  // ============= DETAIL PEMESANAN =============
  Future<Pemesanan?> loadPemesananDetail(String idPemesanan) async {
    _setLoadingDetail(true);

    try {
      final userRole = await StorageService.getUserRole();
      if (userRole != 'pembeli') {
        print('⚠️ User bukan pembeli, skip load detail');
        _setLoadingDetail(false);
        return null;
      }

      print('📡 Loading pemesanan detail: $idPemesanan');

      final response = await ApiService.get(
        '${AppConfig.pembeliMobileHistoryEndpoint}/$idPemesanan',
        requiresAuth: true,
      );

      print('📥 Detail response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          final detailData = response.data as Map<String, dynamic>;

          final pemesanan = Pemesanan.fromJson(detailData);

          // Update local list if exists
          final index =
              _pemesananHistory.indexWhere((p) => p.idPemesanan == idPemesanan);
          if (index != -1) {
            _pemesananHistory[index] = pemesanan;
            notifyListeners();
          }

          _clearError();
          print('✅ Detail loaded for: $idPemesanan');

          return pemesanan;
        } catch (e) {
          print('❌ Error parsing detail data: $e');
          _setError('Format data detail tidak valid: $e');
          return null;
        }
      } else {
        _setError(response.message);
        return null;
      }
    } catch (e) {
      _setError('Gagal memuat detail pemesanan: $e');
      print('❌ LoadDetail error: $e');
      return null;
    } finally {
      _setLoadingDetail(false);
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

  List<Pemesanan> _getFilteredHistory() {
    List<Pemesanan> filtered = List.from(_pemesananHistory);

    // Filter by status
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((pemesanan) {
        // Check both payment and shipping status
        return pemesanan.statusBayar
                .toLowerCase()
                .contains(_selectedStatus!.toLowerCase()) ||
            pemesanan.statusPengiriman
                .toLowerCase()
                .contains(_selectedStatus!.toLowerCase());
      }).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered.where((pemesanan) {
        return pemesanan.tanggalPesan
            .isAfter(_startDate!.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((pemesanan) {
        return pemesanan.tanggalPesan
            .isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((pemesanan) {
        final query = _searchQuery.toLowerCase();
        return pemesanan.idPemesanan.toLowerCase().contains(query) ||
            pemesanan.displayNamaProduk.toLowerCase().contains(query) ||
            pemesanan.displayNamaPenitip.toLowerCase().contains(query) ||
            pemesanan.statusBayar.toLowerCase().contains(query) ||
            pemesanan.statusPengiriman.toLowerCase().contains(query);
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

  // ============= UTILITY METHODS =============
  List<Pemesanan> getPemesananByStatus(String status) {
    return _pemesananHistory.where((pemesanan) {
      return pemesanan.statusBayar
              .toLowerCase()
              .contains(status.toLowerCase()) ||
          pemesanan.statusPengiriman
              .toLowerCase()
              .contains(status.toLowerCase());
    }).toList();
  }

  List<Pemesanan> getPemesananByDateRange(DateTime start, DateTime end) {
    return _pemesananHistory.where((pemesanan) {
      return pemesanan.tanggalPesan
              .isAfter(start.subtract(const Duration(days: 1))) &&
          pemesanan.tanggalPesan.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Pemesanan> getPemesananByMonth(int year, int month) {
    return _pemesananHistory.where((pemesanan) {
      return pemesanan.tanggalPesan.year == year &&
          pemesanan.tanggalPesan.month == month;
    }).toList();
  }

  // ============= STATISTICS METHODS =============
  Map<String, int> getStatusStatistics() {
    final stats = <String, int>{};

    for (var pemesanan in _pemesananHistory) {
      final status = pemesanan.statusPengiriman;
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }

  Map<String, double> getMonthlySpending(int year) {
    final monthlySpending = <String, double>{};

    for (var pemesanan in _pemesananHistory
        .where((p) => p.tanggalPesan.year == year && p.isPaid)) {
      final monthKey =
          '${pemesanan.tanggalPesan.year}-${pemesanan.tanggalPesan.month.toString().padLeft(2, '0')}';
      monthlySpending[monthKey] =
          (monthlySpending[monthKey] ?? 0.0) + pemesanan.totalBayar;
    }

    return monthlySpending;
  }

  // ============= SEARCH FUNCTIONALITY =============
  List<Pemesanan> searchPemesanan(String query) {
    if (query.isEmpty) return _pemesananHistory;

    return _pemesananHistory.where((pemesanan) {
      final searchQuery = query.toLowerCase();
      return pemesanan.idPemesanan.toLowerCase().contains(searchQuery) ||
          pemesanan.displayNamaProduk.toLowerCase().contains(searchQuery) ||
          pemesanan.displayNamaPenitip.toLowerCase().contains(searchQuery);
    }).toList();
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
    print('❌ HistoryProvider Error: $error');
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
    _pemesananHistory.clear();
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _clearError();
    notifyListeners();
  }

  // ============= DEBUG INFO =============
  String getDebugInfo() {
    return '''
HistoryProvider Debug Info:
- Loading: $_isLoading
- Loading Detail: $_isLoadingDetail
- Total Pemesanan: ${_pemesananHistory.length}
- Filtered Pemesanan: ${filteredHistory.length}
- Selected Status: $_selectedStatus
- Start Date: $_startDate
- End Date: $_endDate
- Search Query: $_searchQuery
- Total Spent: $totalSpent
- Total Completed: $completedPemesanan
- Total Active: $activePemesanan
- Total Cancelled: $cancelledPemesanan
- Total Poin Earned: $totalPoinEarned
- Error: $_errorMessage
    ''';
  }

  void printDebugInfo() {
    print('🐛 ${getDebugInfo()}');
  }
}