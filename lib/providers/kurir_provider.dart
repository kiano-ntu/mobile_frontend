// File: lib/providers/kurir_provider.dart

import 'package:flutter/foundation.dart';
import '../models/delivery_task.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class KurirProvider with ChangeNotifier {
  // ============= STATE VARIABLES =============
  bool _isLoading = false;
  String? _errorMessage;

  // Kurir Profile Data (117)
  String? _kurirName;
  String? _kurirEmail;
  String? _kurirPhone;
  String? _kurirAddress;
  String? _kurirBirthDate;

  // Performance Stats
  int _totalDeliveries = 0;
  int _monthlyDeliveries = 0;
  double _averageRating = 0.0;
  int _onTimePercentage = 0;

  // Delivery Tasks (118 & 119)
  List<DeliveryTask> _allTasks = [];
  List<DeliveryTask> _filteredTasks = [];
  String? _currentFilter;

  // ============= GETTERS =============
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Profile getters (117)
  String? get kurirName => _kurirName;
  String? get kurirEmail => _kurirEmail;
  String? get kurirPhone => _kurirPhone;
  String? get kurirAddress => _kurirAddress;
  String? get kurirBirthDate => _kurirBirthDate;

  // Performance getters
  int get totalDeliveries => _totalDeliveries;
  int get monthlyDeliveries => _monthlyDeliveries;
  double get averageRating => _averageRating;
  int get onTimePercentage => _onTimePercentage;

  // Task getters (118)
  List<DeliveryTask> get allTasks => _allTasks;
  List<DeliveryTask> get filteredTasks => _filteredTasks;
  List<DeliveryTask> get recentTasks => _allTasks.take(5).toList();

  // Dashboard stats
  int get todayTasksCount => _allTasks.where((task) => _isToday(task.deliveryDate)).length;
  int get completedTasksCount => _allTasks.where((task) => task.status == 'Selesai').length;
  int get ongoingTasksCount => _allTasks.where((task) => task.status == 'Dikirim').length;
  int get pendingTasksCount => _allTasks.where((task) => task.status == 'Disiapkan').length;
  int get arrivedTasksCount => _allTasks.where((task) => task.status == 'Sampai').length;

  // ============= INITIALIZATION =============
  KurirProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    try {
      // Load any cached data if needed
      print('📱 KurirProvider initialized');
    } catch (e) {
      print('❌ Error loading stored data: $e');
    }
  }

  // ============= PROFILE MANAGEMENT (117) =============
  Future<void> loadProfile() async {
    _setLoading(true);

    try {
      // Cek apakah user sudah login dan rolenya kurir
      final userRole = await StorageService.getUserRole();
      if (userRole != 'kurir') {
        print('⚠️ User bukan kurir, skip load profile');
        _setLoading(false);
        return;
      }

      print('📡 Loading kurir profile from: ${AppConfig.kurirProfileEndpoint}');

      final response = await ApiService.get(
        AppConfig.kurirProfileEndpoint, // http://192.168.1.5:8000/api/kurir/profile
        requiresAuth: true,
      );

      print('📥 Profile response: ${response.toString()}');

      if (response.success && response.data != null) {
        final profileData = response.data as Map<String, dynamic>;
        
        print('👤 Profile data received: ${profileData.keys.toList()}');
        
        // ⭐ MAPPING SESUAI DATABASE STRUCTURE
        _kurirName = profileData['nama_pegawai']?.toString();
        _kurirEmail = profileData['email_pegawai']?.toString();
        _kurirPhone = profileData['notelp_pegawai']?.toString();
        _kurirAddress = profileData['alamat_pegawai']?.toString();
        _kurirBirthDate = profileData['tanggal_lahir_pegawai']?.toString();

        // Load performance stats dengan default values
        final performanceStats = profileData['performance_stats'] ?? {};
        _totalDeliveries = performanceStats['total_deliveries'] ?? 0;
        _monthlyDeliveries = performanceStats['monthly_deliveries'] ?? 0;
        _averageRating = (performanceStats['average_rating'] ?? 4.5).toDouble();
        _onTimePercentage = performanceStats['on_time_percentage'] ?? 95;

        _clearError();
        print('✅ Kurir profile loaded successfully: $_kurirName');
        print('📞 Phone: $_kurirPhone');
        print('🏠 Address: $_kurirAddress');
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

  // ============= DELIVERY TASKS MANAGEMENT (118) =============
  Future<void> loadDeliveryTasks() async {
    _setLoading(true);

    try {
      // Cek apakah user sudah login dan rolenya kurir
      final userRole = await StorageService.getUserRole();
      if (userRole != 'kurir') {
        print('⚠️ User bukan kurir, skip load tasks');
        _setLoading(false);
        return;
      }

      print('📡 Loading delivery tasks from: ${AppConfig.kurirTasksEndpoint}');

      final response = await ApiService.get(
        AppConfig.kurirTasksEndpoint, // http://192.168.1.5:8000/api/kurir/delivery-tasks
        requiresAuth: true,
      );

      print('📥 Tasks response: ${response.toString()}');

      if (response.success && response.data != null) {
        try {
          final tasksData = response.data as List<dynamic>;
          
          print('📋 Found ${tasksData.length} tasks in response');
          
          _allTasks = tasksData.map((taskJson) {
            try {
              print('🔍 Processing task: ${taskJson['id_pemesanan']}');
              print('📱 Phone: ${taskJson['noTelp_pembeli']}');
              print('🏠 Address: ${taskJson['alamat_lengkap']}');
              return DeliveryTask.fromJson(taskJson as Map<String, dynamic>);
            } catch (e) {
              print('⚠️ Error parsing task: $e');
              print('📄 Task data: $taskJson');
              return null;
            }
          }).where((task) => task != null).cast<DeliveryTask>().toList();
          
          _applyCurrentFilter();
          
          _clearError();
          print('✅ Delivery tasks loaded: ${_allTasks.length} tasks');
          
          // Debug print tasks dengan info lengkap
          for (var task in _allTasks.take(3)) {
            print('📦 Task: ${task.orderId} - ${task.productName} - ${task.status}');
            print('   Customer: ${task.customerName} (${task.customerPhone ?? 'No phone'})');
            print('   Address: ${task.deliveryAddress}');
            print('   Can Update: ${task.canUpdateStatus}');
            print('   Next Status: ${task.nextStatus}');
          }
          
        } catch (e) {
          print('❌ Error processing tasks data: $e');
          _allTasks = [];
          _filteredTasks = [];
          _setError('Format data tugas tidak valid: $e');
        }
      } else {
        _setError(response.message);
        _allTasks = [];
        _filteredTasks = [];
        print('❌ API Error: ${response.message}');
      }
    } catch (e) {
      _setError('Gagal memuat tugas pengiriman: $e');
      print('❌ LoadDeliveryTasks error: $e');
      _allTasks = [];
      _filteredTasks = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshTasks() async {
    await loadDeliveryTasks();
  }

  void filterTasks(String? status) {
    _currentFilter = status;
    _applyCurrentFilter();
  }

  void _applyCurrentFilter() {
    if (_currentFilter == null) {
      _filteredTasks = List.from(_allTasks);
    } else {
      _filteredTasks = _allTasks.where((task) => task.status == _currentFilter).toList();
    }
    notifyListeners();
  }

  // ============= UPDATE DELIVERY STATUS (119) =============
  Future<bool> updateDeliveryStatus(String taskId, String newStatus) async {
    try {
      print('📡 Updating delivery status: $taskId to $newStatus');

      final response = await ApiService.put(
        '${AppConfig.apiUrl}/kurir/delivery-tasks/$taskId/status',
        {
          'status_pengiriman': newStatus,
        },
        requiresAuth: true,
      );

      if (response.success) {
        // Update local task status
        final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          _allTasks[taskIndex] = _allTasks[taskIndex].copyWith(
            status: newStatus,
            completedAt: newStatus == 'Selesai' ? DateTime.now() : null,
          );
          _applyCurrentFilter();
        }

        print('✅ Delivery status updated to: $newStatus');
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      print('❌ Failed to update delivery status: $e');
      _setError('Gagal update status: $e');
      return false;
    }
  }

  // ⭐ QUICK UPDATE TO NEXT STATUS
  Future<bool> updateToNextStatus(String taskId) async {
    final task = _allTasks.firstWhere((t) => t.id == taskId);
    if (task.nextStatus != null) {
      return await updateDeliveryStatus(taskId, task.nextStatus!);
    }
    return false;
  }

  // ============= UTILITY METHODS =============
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

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    print('❌ KurirProvider Error: $error');
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // ============= SEARCH FUNCTIONALITY =============
  void searchTasks(String query) {
    if (query.isEmpty) {
      _applyCurrentFilter();
      return;
    }

    final searchResults = _allTasks.where((task) {
      return task.productName.toLowerCase().contains(query.toLowerCase()) ||
             task.customerName.toLowerCase().contains(query.toLowerCase()) ||
             task.orderId.toLowerCase().contains(query.toLowerCase()) ||
             task.deliveryAddress.toLowerCase().contains(query.toLowerCase()) ||
             (task.customerPhone?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    _filteredTasks = searchResults;
    notifyListeners();
  }

  // ============= RESET DATA =============
  void resetData() {
    _allTasks.clear();
    _filteredTasks.clear();
    _kurirName = null;
    _kurirEmail = null;
    _kurirPhone = null;
    _kurirAddress = null;
    _kurirBirthDate = null;
    _totalDeliveries = 0;
    _monthlyDeliveries = 0;
    _averageRating = 0.0;
    _onTimePercentage = 0;
    _clearError();
    notifyListeners();
  }

  // ============= FILTER HELPERS =============
  List<DeliveryTask> getTasksByStatus(String status) {
    return _allTasks.where((task) => task.status == status).toList();
  }

  List<DeliveryTask> getPendingTasks() {
    return getTasksByStatus('Disiapkan');
  }

  List<DeliveryTask> getOngoingTasks() {
    return getTasksByStatus('Dikirim');
  }

  List<DeliveryTask> getArrivedTasks() {
    return getTasksByStatus('Sampai');
  }

  List<DeliveryTask> getCompletedTasks() {
    return getTasksByStatus('Selesai');
  }

  // ============= DEBUG INFO =============
  String getDebugInfo() {
    return '''
KurirProvider Debug Info:
- Loading: $_isLoading
- Name: $_kurirName
- Phone: $_kurirPhone
- Address: $_kurirAddress
- Total Tasks: ${_allTasks.length}
- Filtered Tasks: ${_filteredTasks.length}
- Current Filter: $_currentFilter
- Error: $_errorMessage
- Today Tasks: $todayTasksCount
- Completed: $completedTasksCount
- Ongoing: $ongoingTasksCount
- Pending: $pendingTasksCount
- Arrived: $arrivedTasksCount
    ''';
  }

  void printDebugInfo() {
    print('🐛 ${getDebugInfo()}');
  }
}