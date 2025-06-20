// File: lib/providers/top_seller_provider.dart

import 'package:flutter/foundation.dart';
import '../models/top_seller.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class TopSellerProvider with ChangeNotifier {
  // ============= STATE VARIABLES =============
  bool _isLoading = false;
  String? _errorMessage;

  // Top Seller Data
  List<TopSeller> _topSellerList = [];
  TopSeller? _topSellerOfMonth;

  // Statistics
  Map<String, dynamic> _topSellerStats = {};

  // Loading States
  bool _isLoadingTopSellers = false;
  bool _isLoadingTopSellerOfMonth = false;
  bool _isLoadingStats = false;

  // ============= GETTERS =============
  bool get isLoading => _isLoading;
  bool get isLoadingTopSellers => _isLoadingTopSellers;
  bool get isLoadingTopSellerOfMonth => _isLoadingTopSellerOfMonth;
  bool get isLoadingStats => _isLoadingStats;
  String? get errorMessage => _errorMessage;

  // Top Seller getters
  List<TopSeller> get topSellerList => _topSellerList;
  TopSeller? get topSellerOfMonth => _topSellerOfMonth;
  List<TopSeller> get top3Sellers => _topSellerList.take(3).toList();
  List<TopSeller> get top5Sellers => _topSellerList.take(5).toList();
  List<TopSeller> get top10Sellers => _topSellerList.take(10).toList();

  // Statistics getters
  Map<String, dynamic> get topSellerStats => _topSellerStats;
  int get totalTopSellers => _topSellerList.length;
  double get averagePendapatan =>
      _topSellerStats['average_pendapatan']?.toDouble() ?? 0.0;
  int get totalProdukTerjual =>
      _topSellerStats['total_produk_terjual']?.toInt() ?? 0;
  double get totalPendapatan =>
      _topSellerStats['total_pendapatan']?.toDouble() ?? 0.0;

  // ============= INITIALIZATION =============
  TopSellerProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      print('📱 TopSellerProvider initialized');
    } catch (e) {
      print('❌ Error loading initial data: $e');
    }
  }

  // ============= TOP SELLER LIST =============
  Future<void> loadTopSellers({int limit = 10}) async {
    _setLoadingTopSellers(true);

    try {
      print('📡 Loading top sellers with limit: $limit');

      final response = await ApiService.get(
        '${AppConfig.baseUrl}/api/top-sellers?limit=$limit',
        requiresAuth: false,
      );

      print('📥 Top sellers response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          final topSellersData = response.data as List<dynamic>;

          print('🏆 Found ${topSellersData.length} top sellers in response');

          _topSellerList = topSellersData
              .asMap()
              .entries
              .map((entry) {
                try {
                  final index = entry.key;
                  final topSellerJson = entry.value as Map<String, dynamic>;

                  // Add rank position to the data
                  topSellerJson['rank_posisi'] = index + 1;

                  print(
                      '🔍 Processing top seller #${index + 1}: ${topSellerJson['nama_penitip']}');
                  return TopSeller.fromJson(topSellerJson);
                } catch (e) {
                  print('⚠️ Error parsing top seller: $e');
                  print('📄 TopSeller data: ${entry.value}');
                  return null;
                }
              })
              .where((topSeller) => topSeller != null)
              .cast<TopSeller>()
              .toList();

          _clearError();
          print('✅ Top sellers loaded: ${_topSellerList.length} items');

          // Debug print top sellers dengan info lengkap
          for (var topSeller in _topSellerList.take(3)) {
            print(
                '🏆 Top Seller: ${topSeller.rankText} ${topSeller.namaPenitip} - ${topSeller.totalProdukTerjual} terjual - ${topSeller.formattedPendapatan}');
          }

          // Set top seller of month (rank #1)
          if (_topSellerList.isNotEmpty) {
            _topSellerOfMonth = _topSellerList.first;
            print('👑 Top Seller of Month: ${_topSellerOfMonth!.namaPenitip}');
          }
        } catch (e) {
          print('❌ Error processing top sellers data: $e');
          _topSellerList = [];
          _setError('Format data top seller tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _topSellerList = [];
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat daftar top seller: $e');
      print('❌ LoadTopSellers error: $e');
      _topSellerList = [];
    } finally {
      _setLoadingTopSellers(false);
    }
  }

  // ============= TOP SELLER OF MONTH =============
  Future<void> loadTopSellerOfMonth() async {
    _setLoadingTopSellerOfMonth(true);

    try {
      print('📡 Loading top seller of month');

      final response = await ApiService.get(
        '${AppConfig.baseUrl}/api/top-seller-of-month',
        requiresAuth: false,
      );

      print('📥 Top seller of month response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          final topSellerData = response.data as Map<String, dynamic>;

          // Set rank as #1 for top seller of month
          topSellerData['rank_posisi'] = 1;

          print(
              '👑 Top seller of month data: ${topSellerData['nama_penitip']}');

          _topSellerOfMonth = TopSeller.fromJson(topSellerData);

          _clearError();
          print(
              '✅ Top seller of month loaded: ${_topSellerOfMonth!.namaPenitip}');
        } catch (e) {
          print('❌ Error processing top seller of month data: $e');
          _topSellerOfMonth = null;
          _setError('Format data top seller of month tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _topSellerOfMonth = null;
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat top seller of month: $e');
      print('❌ LoadTopSellerOfMonth error: $e');
      _topSellerOfMonth = null;
    } finally {
      _setLoadingTopSellerOfMonth(false);
    }
  }

  // ============= TOP SELLER STATISTICS =============
  Future<void> loadTopSellerStatistics() async {
    _setLoadingStats(true);

    try {
      print('📡 Loading top seller statistics');

      final response = await ApiService.get(
        '${AppConfig.baseUrl}/api/top-seller-statistics',
        requiresAuth: false,
      );

      print('📥 Top seller statistics response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          _topSellerStats = response.data as Map<String, dynamic>;

          print(
              '📊 Top seller statistics loaded: ${_topSellerStats.keys.toList()}');

          _clearError();
          print('✅ Top seller statistics loaded successfully');
        } catch (e) {
          print('❌ Error processing top seller statistics data: $e');
          _topSellerStats = {};
          _setError('Format data statistik tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _topSellerStats = {};
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat statistik top seller: $e');
      print('❌ LoadTopSellerStatistics error: $e');
      _topSellerStats = {};
    } finally {
      _setLoadingStats(false);
    }
  }

  // ============= UTILITY METHODS =============
  Future<void> refreshData() async {
    await loadTopSellers();
    await loadTopSellerOfMonth();
    await loadTopSellerStatistics();
  }

  Future<void> refreshAll() async {
    await loadTopSellers(limit: 10);
    await loadTopSellerOfMonth();
    await loadTopSellerStatistics();
  }

  // ============= SEARCH FUNCTIONALITY =============
  List<TopSeller> getFilteredTopSellers(String query) {
    if (query.isEmpty) return _topSellerList;

    return _topSellerList.where((topSeller) {
      return topSeller.namaPenitip
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          topSeller.emailPenitip.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ============= FILTER HELPERS =============
  List<TopSeller> getTopSellersByRankRange(int startRank, int endRank) {
    return _topSellerList.where((topSeller) {
      return topSeller.rankPosisi >= startRank &&
          topSeller.rankPosisi <= endRank;
    }).toList();
  }

  List<TopSeller> getTopSellersByMinProdukTerjual(int minProduk) {
    return _topSellerList.where((topSeller) {
      return topSeller.totalProdukTerjual >= minProduk;
    }).toList();
  }

  List<TopSeller> getTopSellersByMinPendapatan(double minPendapatan) {
    return _topSellerList.where((topSeller) {
      return topSeller.totalPendapatan >= minPendapatan;
    }).toList();
  }

  List<TopSeller> getBadgeLoyalitasSellers() {
    return _topSellerList.where((topSeller) {
      return topSeller.badgeLoyalitas;
    }).toList();
  }

  // ============= RANKING HELPERS =============
  TopSeller? getTopSellerByRank(int rank) {
    try {
      return _topSellerList
          .firstWhere((topSeller) => topSeller.rankPosisi == rank);
    } catch (e) {
      return null;
    }
  }

  TopSeller? getTopSellerById(String idPenitip) {
    try {
      return _topSellerList
          .firstWhere((topSeller) => topSeller.idPenitip == idPenitip);
    } catch (e) {
      return null;
    }
  }

  int? getRankByPenitipId(String idPenitip) {
    try {
      final topSeller =
          _topSellerList.firstWhere((ts) => ts.idPenitip == idPenitip);
      return topSeller.rankPosisi;
    } catch (e) {
      return null;
    }
  }

  // ============= STATISTICS HELPERS =============
  String get formattedAveragePendapatan =>
      'Rp ${averagePendapatan.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedTotalPendapatan =>
      'Rp ${totalPendapatan.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedTotalProdukTerjual =>
      totalProdukTerjual.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );

  // ============= STATE MANAGEMENT HELPERS =============
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingTopSellers(bool loading) {
    _isLoadingTopSellers = loading;
    notifyListeners();
  }

  void _setLoadingTopSellerOfMonth(bool loading) {
    _isLoadingTopSellerOfMonth = loading;
    notifyListeners();
  }

  void _setLoadingStats(bool loading) {
    _isLoadingStats = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    print('❌ TopSellerProvider Error: $error');
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
    _topSellerList.clear();
    _topSellerOfMonth = null;
    _topSellerStats.clear();
    _clearError();
    notifyListeners();
  }

  // ============= DEBUG INFO =============
  String getDebugInfo() {
    return '''
TopSellerProvider Debug Info:
- Loading: $_isLoading
- Loading Top Sellers: $_isLoadingTopSellers
- Loading Top Seller of Month: $_isLoadingTopSellerOfMonth
- Loading Stats: $_isLoadingStats
- Top Sellers Count: ${_topSellerList.length}
- Top Seller of Month: ${_topSellerOfMonth?.namaPenitip ?? 'null'}
- Total Top Sellers: $totalTopSellers
- Average Pendapatan: $formattedAveragePendapatan
- Total Produk Terjual: $formattedTotalProdukTerjual
- Total Pendapatan: $formattedTotalPendapatan
- Error: $_errorMessage
    ''';
  }

  void printDebugInfo() {
    print('🐛 ${getDebugInfo()}');
  }
}