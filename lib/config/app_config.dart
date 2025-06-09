class AppConfig {
  // ============= LARAVEL BACKEND CONFIGURATION =============

  // Menggunakan IP address komputer Anda
  static const String baseUrl = 'http://192.168.213.124:8000';
  
  // Alternatif URL untuk testing berbeda platform:
  // static const String baseUrl = 'http://10.0.2.2:8000';        // Untuk Android Emulator
  // static const String baseUrl = 'http://127.0.0.1:8000';       // Untuk iOS Simulator/Web

  static const String apiUrl = '$baseUrl/api';

  // ============= API ENDPOINTS (sesuai dengan routes Laravel) =============

  // Authentication endpoints
  static const String loginEndpoint = '$apiUrl/login'; // POST /api/login
  static const String logoutEndpoint = '$apiUrl/logout'; // POST /api/logout
  static const String userEndpoint = '$apiUrl/user'; // GET /api/user

  // Registration endpoints (jika diperlukan)
  static const String registerPembeliEndpoint = '$apiUrl/register/pembeli';
  static const String registerOrganisasiEndpoint =
      '$apiUrl/register/organisasi';

  // Password reset endpoints
  static const String forgotPasswordEndpoint = '$apiUrl/forgot-password';
  static const String resetPasswordEndpoint = '$apiUrl/reset-password';

  // Data endpoints (authenticated)
  static const String pegawaiEndpoint = '$apiUrl/pegawai';
  static const String penitipEndpoint = '$apiUrl/penitip';
  static const String organisasiEndpoint = '$apiUrl/organisasi';
  static const String alamatEndpoint = '$apiUrl/alamat';

  // ============= KURIR SPECIFIC ENDPOINTS =============
  static const String kurirProfileEndpoint = '$apiUrl/kurir/profile';
  static const String kurirTasksEndpoint = '$apiUrl/kurir/delivery-tasks';

  // ============= PEMBELI MOBILE ENDPOINTS =============
  static const String mobileApiUrl = '$apiUrl/mobile';
  static const String pembeliMobileEndpoint = '$mobileApiUrl/pembeli';
  static const String pembeliMobileLoginEndpoint =
      '$pembeliMobileEndpoint/login';
  static const String pembeliMobileProfileEndpoint =
      '$pembeliMobileEndpoint/profil';
  static const String pembeliMobileUpdateEndpoint =
      '$pembeliMobileEndpoint/profile';
  static const String pembeliMobileRiwayatPoinEndpoint =
      '$pembeliMobileEndpoint/riwayat-poin';
  static const String pembeliMobileDashboardEndpoint =
      '$pembeliMobileEndpoint/dashboard';
  static const String pembeliMobileLogoutEndpoint =
      '$pembeliMobileEndpoint/logout';

  static const String pembeliMobileHistoryEndpoint =
      '$pembeliMobileEndpoint/history';

  // ============= LOCAL STORAGE KEYS =============
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'auth_user';
  static const String userRoleKey = 'auth_role';
  static const String rememberMeKey = 'remember_me';

  // ============= APP INFORMATION =============
  static const String appName = 'ReUseMart';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Marketplace Barang Bekas Berkualitas';

  // ============= API CONFIGURATION =============
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // ============= DEVELOPMENT FLAGS =============
  static const bool isDebugMode = true; // Set false untuk production
  static const bool enableApiLogging = true;
}
