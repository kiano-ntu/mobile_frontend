// lib/config/constants.dart

class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ============= APP INFORMATION =============
  static const String appName = 'ReUseMart';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Marketplace Barang Bekas Berkualitas';
  static const String appDeveloper = 'ReUseMart Team';
  static const String appEmail = 'support@reusemart.com';
  static const String appWebsite = 'https://www.reusemart.com';

  // ============= API CONFIGURATION =============
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const Duration downloadTimeout = Duration(minutes: 10);
  static const int maxRetryAttempts = 3;
  static const int paginationLimit = 20;

  // ============= STORAGE KEYS =============
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'auth_user';
  static const String userRoleKey = 'auth_role';
  static const String rememberMeKey = 'remember_me';
  static const String fcmTokenKey = 'fcm_token';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'selected_theme';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String firstTimeKey = 'first_time_user';

  // ============= USER ROLES =============
  static const String rolePembeli = 'pembeli';
  static const String rolePenitip = 'penitip';
  static const String roleKurir = 'kurir';
  static const String roleHunter = 'hunter';
  static const String rolePegawai = 'pegawai';
  static const String roleAdmin = 'admin';
  static const String roleOwner = 'owner';
  static const String roleCS = 'cs';
  static const String roleOrganisasi = 'organisasi';

  // ============= DASHBOARD ROUTES BY ROLE =============
  static const Map<String, String> dashboardRoutes = {
    rolePembeli: '/pembeli-dashboard',
    rolePenitip: '/penitip-dashboard',
    roleKurir: '/kurir-dashboard',
    roleHunter: '/hunter-dashboard',
    rolePegawai: '/pegawai-dashboard',
    roleAdmin: '/admin-dashboard',
    roleOwner: '/owner-dashboard',
    roleCS: '/cs-dashboard',
    roleOrganisasi: '/organisasi-dashboard',
  };

  // ============= ROLE DISPLAY NAMES =============
  static const Map<String, String> roleDisplayNames = {
    rolePembeli: 'Pembeli',
    rolePenitip: 'Penitip',
    roleKurir: 'Kurir',
    roleHunter: 'Hunter',
    rolePegawai: 'Pegawai',
    roleAdmin: 'Admin',
    roleOwner: 'Owner',
    roleCS: 'Customer Service',
    roleOrganisasi: 'Organisasi Sosial',
  };

  // ============= NOTIFICATION TYPES =============
  static const String notifProductSold = 'product_sold';
  static const String notifDeliverySchedule = 'delivery_schedule';
  static const String notifPickupSchedule = 'pickup_schedule';
  static const String notifItemShipped = 'item_shipped';
  static const String notifItemDelivered = 'item_delivered';
  static const String notifItemPickedUp = 'item_picked_up';
  static const String notifItemDonated = 'item_donated';
  static const String notifConsignmentExpiringH3 = 'consignment_expiring_h3';
  static const String notifConsignmentExpiringToday = 'consignment_expiring_today';
  static const String notifPaymentConfirmed = 'payment_confirmed';
  static const String notifGeneral = 'general';

  // ============= NOTIFICATION CHANNELS =============
  static const String channelGeneral = 'reusemart_general';
  static const String channelTransactions = 'reusemart_transactions';
  static const String channelDelivery = 'reusemart_delivery';
  static const String channelUrgent = 'reusemart_urgent';

  // ============= BUSINESS RULES =============
  // Penitipan
  static const int consignmentDurationDays = 30;
  static const int extensionDurationDays = 30;
  static const int maxExtensions = 1;
  static const int gracePeriodDays = 7;
  static const int reminderDaysBefore = 3;

  // Komisi
  static const double commissionRegular = 0.20; // 20%
  static const double commissionExtended = 0.30; // 30%
  static const double hunterCommission = 0.05; // 5%
  static const double bonusThreshold = 7; // days
  static const double bonusPercentage = 0.10; // 10%

  // Poin Reward
  static const int pointPerRupiah = 10000; // 1 poin = 10.000 rupiah
  static const double bonusPointsThreshold = 500000; // >= 500.000
  static const double bonusPointsPercentage = 0.20; // 20% bonus

  // Ongkos Kirim
  static const double freeShippingThreshold = 1500000; // >= 1.5 juta
  static const double shippingCost = 100000; // 100.000 rupiah
  static const String shippingArea = 'DIY'; // Daerah Istimewa Yogyakarta

  // Transaction Timeout
  static const int paymentTimeoutMinutes = 15;
  static const int pickupTimeoutDays = 2;

  // ============= PRODUCT CATEGORIES =============
  static const List<String> productCategories = [
    'Elektronik & Gadget',
    'Pakaian & Aksesori',
    'Perabotan Rumah Tangga',
    'Buku, Alat Tulis, & Peralatan Sekolah',
    'Hobi, Mainan, & Koleksi',
    'Perlengkapan Bayi & Anak',
    'Otomotif & Aksesori',
    'Perlengkapan Taman & Outdoor',
    'Peralatan Kantor & Industri',
    'Kosmetik & Perawatan Diri',
  ];

  // ============= PRODUCT STATUS =============
  static const String statusTersedia = 'Tersedia';
  static const String statusTidakTersedia = 'Tidak Tersedia';
  static const String statusTerjual = 'Terjual';
  static const String statusUntukDonasi = 'Untuk Donasi';
  static const String statusDonasi = 'Didonasikan';
  static const String statusDiambilKembali = 'Diambil Kembali';

  // ============= TRANSACTION STATUS =============
  // Status Pembayaran
  static const String paymentPending = 'Menunggu Pembayaran';
  static const String paymentConfirmed = 'Pembayaran Dikonfirmasi';
  static const String paymentCancelled = 'Dibatalkan';
  static const String paymentExpired = 'Hangus';

  // Status Pengiriman
  static const String shippingPending = 'Diproses';
  static const String shippingReady = 'Siap Diambil';
  static const String shippingInTransit = 'Dikirim';
  static const String shippingDelivered = 'Selesai';
  static const String shippingCancelled = 'Dibatalkan';

  // Mode Pengiriman
  static const String deliveryModeKurir = 'Kurir';
  static const String deliveryModePickup = 'Ambil Sendiri';

  // ============= FORM VALIDATION =============
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 100;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int maxDescriptionLength = 1000;
  static const int maxAddressLength = 255;

  // ============= FILE UPLOAD =============
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  static const int maxImagesPerProduct = 5;
  static const int minImagesPerProduct = 2;

  // ============= PAGINATION =============
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int searchPageSize = 15;

  // ============= CACHE DURATION =============
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(minutes: 30);
  static const Duration cacheLongDuration = Duration(hours: 24);

  // ============= ANIMATION DURATION =============
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);

  // ============= UI CONSTANTS =============
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double cardElevation = 2.0;
  static const double modalElevation = 8.0;

  // Button Heights
  static const double buttonHeight = 50.0;
  static const double smallButtonHeight = 40.0;
  static const double largeButtonHeight = 60.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeNormal = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXL = 48.0;

  // Avatar Sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeNormal = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXL = 80.0;

  // ============= REGULAR EXPRESSIONS =============
  static const String emailRegex = r'^[\w\.-]+@[\w\.-]+\.\w+$';
  static const String phoneRegex = r'^(\+62|62|0)[0-9]{9,13}$';
  static const String numberOnlyRegex = r'^[0-9]+$';
  static const String alphaNumericRegex = r'^[a-zA-Z0-9]+$';
  static const String nameRegex = r'^[a-zA-Z\s]+$';

  // ============= DATE FORMATS =============
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateFormatAPI = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy HH:mm';
  static const String dateTimeFormatAPI = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormatDisplay = 'HH:mm';

  // ============= CURRENCIES =============
  static const String currencySymbol = 'Rp';
  static const String currencyCode = 'IDR';
  static const String currencyLocale = 'id_ID';

  // ============= ERROR MESSAGES =============
  static const String errorNetwork = 'Tidak dapat terhubung ke internet';
  static const String errorServer = 'Terjadi kesalahan pada server';
  static const String errorUnknown = 'Terjadi kesalahan yang tidak diketahui';
  static const String errorTimeout = 'Koneksi timeout';
  static const String errorUnauthorized = 'Sesi Anda telah berakhir';
  static const String errorForbidden = 'Anda tidak memiliki akses';
  static const String errorNotFound = 'Data tidak ditemukan';
  static const String errorValidation = 'Data yang dimasukkan tidak valid';

  // Field specific errors
  static const String errorEmailRequired = 'Email tidak boleh kosong';
  static const String errorEmailInvalid = 'Format email tidak valid';
  static const String errorPasswordRequired = 'Password tidak boleh kosong';
  static const String errorPasswordTooShort = 'Password minimal 6 karakter';
  static const String errorNameRequired = 'Nama tidak boleh kosong';
  static const String errorPhoneRequired = 'Nomor telepon tidak boleh kosong';
  static const String errorPhoneInvalid = 'Format nomor telepon tidak valid';

  // ============= SUCCESS MESSAGES =============
  static const String successLogin = 'Login berhasil';
  static const String successLogout = 'Logout berhasil';
  static const String successSave = 'Data berhasil disimpan';
  static const String successUpdate = 'Data berhasil diperbarui';
  static const String successDelete = 'Data berhasil dihapus';
  static const String successUpload = 'File berhasil diupload';

  // ============= LOADING MESSAGES =============
  static const String loadingDefault = 'Memuat...';
  static const String loadingLogin = 'Sedang masuk...';
  static const String loadingLogout = 'Sedang keluar...';
  static const String loadingSave = 'Menyimpan data...';
  static const String loadingUpload = 'Mengupload file...';
  static const String loadingProcess = 'Memproses...';

  // ============= EMPTY STATE MESSAGES =============
  static const String emptyProducts = 'Belum ada produk';
  static const String emptyOrders = 'Belum ada pesanan';
  static const String emptyNotifications = 'Belum ada notifikasi';
  static const String emptyHistory = 'Belum ada riwayat';
  static const String emptySearch = 'Hasil pencarian tidak ditemukan';
  static const String emptyFavorites = 'Belum ada favorit';

  // ============= CONFIRMATION MESSAGES =============
  static const String confirmDelete = 'Apakah Anda yakin ingin menghapus?';
  static const String confirmLogout = 'Apakah Anda yakin ingin keluar?';
  static const String confirmCancel = 'Apakah Anda yakin ingin membatalkan?';
  static const String confirmSave = 'Apakah Anda yakin ingin menyimpan?';

  // ============= BUTTON LABELS =============
  static const String btnLogin = 'Masuk';
  static const String btnLogout = 'Keluar';
  static const String btnSave = 'Simpan';
  static const String btnCancel = 'Batal';
  static const String btnDelete = 'Hapus';
  static const String btnEdit = 'Edit';
  static const String btnAdd = 'Tambah';
  static const String btnSearch = 'Cari';
  static const String btnFilter = 'Filter';
  static const String btnSort = 'Urutkan';
  static const String btnRefresh = 'Refresh';
  static const String btnRetry = 'Coba Lagi';
  static const String btnContinue = 'Lanjutkan';
  static const String btnBack = 'Kembali';
  static const String btnNext = 'Selanjutnya';
  static const String btnPrevious = 'Sebelumnya';
  static const String btnFinish = 'Selesai';
  static const String btnOk = 'OK';
  static const String btnYes = 'Ya';
  static const String btnNo = 'Tidak';

  // ============= TAB LABELS =============
  static const String tabHome = 'Beranda';
  static const String tabProducts = 'Produk';
  static const String tabOrders = 'Pesanan';
  static const String tabProfile = 'Profil';
  static const String tabNotifications = 'Notifikasi';
  static const String tabHistory = 'Riwayat';
  static const String tabFavorites = 'Favorit';
  static const String tabSettings = 'Pengaturan';

  // ============= OPERATIONAL HOURS =============
  static const String operationalStartTime = '08:00';
  static const String operationalEndTime = '20:00';
  static const String cutoffTime = '16:00'; // Batas pemesanan hari yang sama

  // ============= DAYS OF WEEK =============
  static const List<String> daysOfWeek = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  static const List<String> monthsOfYear = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  // ============= HELPER METHODS =============
  
  /// Get dashboard route for specific role
  static String getDashboardRoute(String role) {
    return dashboardRoutes[role.toLowerCase()] ?? '/login';
  }

  /// Get display name for specific role
  static String getRoleDisplayName(String role) {
    return roleDisplayNames[role.toLowerCase()] ?? 'Unknown';
  }

  /// Check if role is valid
  static bool isValidRole(String role) {
    return dashboardRoutes.containsKey(role.toLowerCase());
  }

  /// Get all available roles
  static List<String> getAllRoles() {
    return dashboardRoutes.keys.toList();
  }

  /// Check if notification type is valid
  static bool isValidNotificationType(String type) {
    const validTypes = [
      notifProductSold,
      notifDeliverySchedule,
      notifPickupSchedule,
      notifItemShipped,
      notifItemDelivered,
      notifItemPickedUp,
      notifItemDonated,
      notifConsignmentExpiringH3,
      notifConsignmentExpiringToday,
      notifPaymentConfirmed,
      notifGeneral,
    ];
    return validTypes.contains(type);
  }

  /// Get channel ID for notification type
  static String getNotificationChannel(String type) {
    switch (type) {
      case notifProductSold:
      case notifItemDonated:
      case notifPaymentConfirmed:
        return channelTransactions;
      case notifDeliverySchedule:
      case notifPickupSchedule:
      case notifItemShipped:
      case notifItemDelivered:
      case notifItemPickedUp:
        return channelDelivery;
      case notifConsignmentExpiringH3:
      case notifConsignmentExpiringToday:
        return channelUrgent;
      default:
        return channelGeneral;
    }
  }

  /// Format currency
  static String formatCurrency(double amount) {
    return '$currencySymbol ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(emailRegex).hasMatch(email);
  }

  /// Validate phone format
  static bool isValidPhone(String phone) {
    return RegExp(phoneRegex).hasMatch(phone);
  }

  /// Check if file size is valid
  static bool isValidFileSize(int sizeInBytes) {
    return sizeInBytes <= maxImageSizeBytes;
  }

  /// Check if file extension is allowed for images
  static bool isValidImageType(String extension) {
    return allowedImageTypes.contains(extension.toLowerCase());
  }

  /// Check if file extension is allowed for documents
  static bool isValidDocumentType(String extension) {
    return allowedDocumentTypes.contains(extension.toLowerCase());
  }
}