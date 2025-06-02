import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthService {
  // ============= LOGIN - Sesuai dengan Laravel API =============
  static Future<ApiResponse<User>> login(
    String email,
    String password, {
    bool remember = false,
    String? fcmToken, // Parameter FCM token
  }) async {
    try {
      print('🔐 Attempting login for: $email');
      print('📲 FCM Token available: ${fcmToken != null ? 'YES (${fcmToken.substring(0, 20)}...)' : 'NO'}');
      
      // 🔥 SIAPKAN DATA LOGIN
      final loginData = <String, dynamic>{
        'email': email,
        'password': password,
        'remember': remember,
      };
      
      // 🔥 TAMBAHKAN FCM TOKEN JIKA ADA
      if (fcmToken != null && fcmToken.isNotEmpty) {
        loginData['fcm_token'] = fcmToken;
        print('✅ FCM token added to login data');
      } else {
        print('⚠️ No FCM token to send');
      }

      print('📤 Sending login data: ${loginData.keys.toList()} (password & fcm_token hidden)');

      final response = await ApiService.post(
        AppConfig.loginEndpoint, // http://127.0.0.1:8000/api/login
        loginData,
      );

      print('🔐 Login Response: ${response.toString()}');

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Extract data dari response Laravel
        String? token = responseData['token'];
        Map<String, dynamic>? userData = responseData['user'];
        String? userRole = responseData['role'];
        bool? fcmRegistered = responseData['fcm_registered'];

        if (token == null || userData == null || userRole == null) {
          return ApiResponse.error('Data tidak lengkap dari server');
        }

        print('✅ Login berhasil:');
        print('  - Token: ${token.substring(0, 20)}...');
        print('  - Role: $userRole');
        print('  - FCM Registered: ${fcmRegistered ?? false}');

        // Gunakan role langsung dari Laravel response
        String finalRole = userRole.toLowerCase();
        
        // Validasi bahwa role diizinkan di mobile
        List<String> allowedMobileRoles = ['pembeli', 'penitip', 'kurir', 'hunter'];
        if (!allowedMobileRoles.contains(finalRole)) {
          print('❌ Role $finalRole tidak tersedia di mobile app');
          return ApiResponse.error('Akun Anda memiliki role "$userRole" yang tidak dapat mengakses aplikasi mobile. Silakan gunakan aplikasi web ReUseMart.');
        }

        print('🎯 Final role determined: $finalRole');

        // Create User object berdasarkan role yang sudah dideteksi
        User user;
        try {
          print('🏗️ Creating User object with finalRole: $finalRole');
          user = User.fromJson(userData, finalRole);
          print('✅ User object created with final role: ${user.role}');
        } catch (e) {
          print('❌ Error creating user object: $e');
          return ApiResponse.error('Gagal memproses data user: $e');
        }

        // Save to storage
        await StorageService.saveToken(token);
        await StorageService.saveUser(user);

        print('✅ Login berhasil untuk role: ${user.role}');
        return ApiResponse.success(user, message: response.message);

      } else {
        // Login gagal, kembalikan error dari Laravel
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Login error: $e');
      return ApiResponse.error('Terjadi kesalahan saat login: $e');
    }
  }

  // ============= LOGOUT - Sesuai dengan Laravel API =============
  static Future<ApiResponse<bool>> logout() async {
    try {
      // Panggil API logout Laravel jika ada token
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          await ApiService.post(
            AppConfig.logoutEndpoint, // http://127.0.0.1:8000/api/logout
            {},
            requiresAuth: true,
          );
          print('✅ Logout API call berhasil');
        } catch (e) {
          print('⚠️ Logout API call gagal (tapi tetap lanjut clear storage): $e');
          // Tidak throw error, tetap lanjut clear storage
        }
      }

      // Clear local storage
      await StorageService.clearAll();
      
      print('✅ Logout berhasil dan storage cleared');
      return ApiResponse.success(true, message: 'Logout berhasil');
    } catch (e) {
      print('❌ Logout error: $e');
      // Tetap clear storage meskipun API error
      await StorageService.clearAll();
      return ApiResponse.success(true, message: 'Logout berhasil');
    }
  }

  // ============= CHECK LOGIN STATUS =============
  static Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  // ============= GET CURRENT USER =============
  static Future<User?> getCurrentUser() async {
    return await StorageService.getUser();
  }

  // ============= GET CURRENT ROLE =============
  static Future<String?> getCurrentRole() async {
    return await StorageService.getUserRole();
  }

  // ============= REFRESH USER DATA =============
  static Future<ApiResponse<User>> refreshUser() async {
    try {
      // Panggil endpoint user Laravel untuk refresh data
      final response = await ApiService.get(
        AppConfig.userEndpoint, // http://127.0.0.1:8000/api/user
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['user'] ?? responseData;
        final userRole = responseData['role'];
        
        if (userData != null && userRole != null) {
          // Apply same role detection logic as login
          String finalRole = userRole.toLowerCase();
          
          if (finalRole == 'pegawai' || finalRole.contains('pegawai')) {
            if (userData.containsKey('jabatan') && userData['jabatan'] != null) {
              Map<String, dynamic> jabatan = userData['jabatan'];
              String namaJabatan = jabatan['role']?.toString().toLowerCase() ?? '';
              
              if (namaJabatan.contains('kurir')) {
                finalRole = 'kurir';
              } else if (namaJabatan.contains('hunter')) {
                finalRole = 'hunter';
              } else {
                // Role lain tidak tersedia di mobile
                return ApiResponse.error('Role tidak tersedia di mobile app');
              }
            }
          }
          
          final user = User.fromJson(userData, finalRole);
          await StorageService.saveUser(user);
          return ApiResponse.success(user);
        }
      }

      return ApiResponse.error(response.message);
    } catch (e) {
      return ApiResponse.error('Gagal refresh user data: $e');
    }
  }

  // ============= VALIDATE TOKEN dengan Laravel =============
  static Future<bool> validateToken() async {
    try {
      final response = await ApiService.get(
        AppConfig.userEndpoint, // http://127.0.0.1:8000/api/user
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      print('❌ Token validation failed: $e');
      return false;
    }
  }

  // ============= GET DASHBOARD ROUTE BASED ON ROLE =============
  static String getDashboardRouteForRole(String role) {
    switch (role.toLowerCase()) {
      case 'pembeli':
        return '/pembeli-dashboard';
      case 'penitip':
        return '/penitip-dashboard';
      case 'kurir':
        return '/kurir-dashboard';
      case 'hunter':
        return '/hunter-dashboard';
      default:
        // Role lain (admin, owner, cs, kepala gudang) tidak ada di mobile
        // Redirect ke login atau tampilkan error
        return '/login';
    }
  }

  // ============= CHECK CONNECTION TO LARAVEL API =============
  static Future<bool> checkApiConnection() async {
    try {
      // Simple ping ke base URL untuk cek koneksi
      final response = await ApiService.get(AppConfig.baseUrl);
      return response.success || response.statusCode == 200;
    } catch (e) {
      print('❌ API connection check failed: $e');
      return false;
    }
  }
}