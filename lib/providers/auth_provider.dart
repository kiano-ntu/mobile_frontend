import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // ============= GETTERS =============
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  
  String? get userRole => _user?.role;
  String? get userName => _user?.name;
  String? get userEmail => _user?.email;

  // ============= INIT - CHECK EXISTING AUTH =============
  Future<void> initializeAuth() async {
    _setState(AuthState.loading);
    
    try {
      print('🚀 Initializing auth...');
      
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await AuthService.getCurrentUser();
        
        if (user != null) {
          // Validate token dengan Laravel server
          final isValidToken = await AuthService.validateToken();
          
          if (isValidToken) {
            _user = user;
            _setState(AuthState.authenticated);
            print('✅ Auth initialized - User: ${user.name}, Role: ${user.role}');
          } else {
            // Token tidak valid, clear storage
            print('⚠️ Token tidak valid, melakukan logout...');
            await logout();
          }
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      print('❌ Auth initialization error: $e');
      _setError('Gagal menginisialisasi autentikasi: $e');
    }
  }

  // ============= LOGIN - FIXED FCM TOKEN =============
  Future<bool> login(String email, String password, {bool remember = false}) async {
    _setLoading(true);
    
    try {
      print('🔐 Attempting login for: $email (remember: $remember)');
      
      // 🔥 DAPATKAN FCM TOKEN DENGAN ERROR HANDLING
      String? fcmToken;
      try {
        // Pastikan Firebase sudah diinisialisasi
        await FirebaseMessaging.instance.requestPermission();
        fcmToken = await FirebaseMessaging.instance.getToken();
        print('📲 FCM Token obtained: ${fcmToken?.substring(0, 20)}...');
        
        if (fcmToken == null) {
          print('⚠️ FCM Token is null, akan retry...');
          // Retry sekali lagi
          await Future.delayed(Duration(seconds: 1));
          fcmToken = await FirebaseMessaging.instance.getToken();
          print('📲 FCM Token retry result: ${fcmToken?.substring(0, 20)}...');
        }
      } catch (fcmError) {
        print('❌ Error getting FCM token: $fcmError');
        // Lanjutkan login tanpa FCM token
        fcmToken = null;
      }
      
      // 🔥 PANGGIL LOGIN SERVICE DENGAN FCM TOKEN
      final response = await AuthService.login(
        email, 
        password,
        remember: remember,
        fcmToken: fcmToken, // Kirim FCM token (bisa null)
      );
      
      if (response.success && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);
        
        print('✅ Login berhasil - Role: ${_user!.role}');
        print('👤 User: ${_user!.name} (${_user!.email})');
        return true;
      } else {
        _setError(response.message);
        print('❌ Login gagal: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan saat login: $e');
      print('❌ Login exception: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============= LOGOUT =============
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      print('🚪 Logging out...');
      
      await AuthService.logout();
      _user = null;
      _errorMessage = null;
      _setState(AuthState.unauthenticated);
      
      print('✅ Logout berhasil');
    } catch (e) {
      print('❌ Logout error: $e');
      // Tetap logout meskipun error
      _user = null;
      _errorMessage = null;
      _setState(AuthState.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  // ============= REFRESH USER DATA =============
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;
    
    try {
      print('🔄 Refreshing user data...');
      
      final response = await AuthService.refreshUser();
      
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
        print('✅ User data refreshed');
      } else {
        print('⚠️ Failed to refresh user data: ${response.message}');
      }
    } catch (e) {
      print('❌ Refresh user error: $e');
    }
  }

  // ============= CHECK API CONNECTION =============
  Future<bool> checkConnection() async {
    try {
      return await AuthService.checkApiConnection();
    } catch (e) {
      print('❌ Connection check error: $e');
      return false;
    }
  }

  // ============= HELPER METHODS =============
  void _setState(AuthState newState) {
    _state = newState;
    _isLoading = false;
    notifyListeners();
    
    print('📱 Auth state changed to: $newState');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
    
    if (loading) {
      print('⏳ Loading...');
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    _isLoading = false;
    notifyListeners();
    
    print('❌ Auth Error: $error');
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = isAuthenticated ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
    
    print('🧹 Error cleared');
  }

  // ============= ROLE CHECKS =============
  bool isPembeli() => _user?.role == 'pembeli';
  bool isPenitip() => _user?.role == 'penitip';
  bool isKurir() => _user?.role == 'kurir';
  bool isHunter() => _user?.role == 'hunter';
  bool isPegawai() => _user?.role == 'pegawai';

  // ============= GET DASHBOARD ROUTE BY ROLE =============
  String getDashboardRoute() {
    if (_user == null) return '/login';
    
    switch (_user!.role.toLowerCase()) {
      case 'pembeli':
        return '/pembeli-dashboard';
      case 'penitip':
        return '/penitip-dashboard';
      case 'kurir':
        return '/kurir-dashboard';
      case 'hunter':
        return '/hunter-dashboard';
      case 'pegawai':
      default:
        return '/login';
    }
  }

  // ============= GET ROLE DISPLAY NAME =============
  String getRoleDisplayName() {
    if (_user == null) return 'Unknown';
    
    switch (_user!.role.toLowerCase()) {
      case 'pembeli':
        return 'Pembeli';
      case 'penitip':
        return 'Penitip';
      case 'kurir':
        return 'Kurir';
      case 'hunter':
        return 'Hunter';
      case 'pegawai':
        return 'Pegawai';
      default:
        return 'Unknown';
    }
  }

  // ============= GET USER ADDITIONAL DATA =============
  T? getUserData<T>(String key) {
    return _user?.additionalData?[key] as T?;
  }

  // Specific getters untuk data user
  int get poinPembeli => getUserData<int>('poin_pembeli') ?? 0;
  double get saldoPenitip => getUserData<double>('saldo_penitip') ?? 0.0;
  int get poinPenitip => getUserData<int>('poin_penitip') ?? 0;
  bool get badgeLoyalitas => getUserData<bool>('badge_loyalitas') ?? false;
  
  Map<String, dynamic>? get jabatan => getUserData<Map<String, dynamic>>('jabatan');
  String? get alamatPegawai => getUserData<String>('alamat_pegawai');

  // ============= DEBUG INFO =============
  String getDebugInfo() {
    return '''
Debug Info:
- State: $_state
- IsAuthenticated: $isAuthenticated
- User: ${_user?.name ?? 'null'}
- Role: ${_user?.role ?? 'null'}
- Email: ${_user?.email ?? 'null'}
- Error: ${_errorMessage ?? 'none'}
- Loading: $_isLoading
    ''';
  }

  void printDebugInfo() {
    print('🐛 ${getDebugInfo()}');
  }
}