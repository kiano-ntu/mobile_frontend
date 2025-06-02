class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final Map<String, dynamic>? additionalData;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.additionalData,
  });

  // Factory untuk Pembeli
  factory User.fromPembeli(Map<String, dynamic> json) {
    return User(
      id: json['id_pembeli'] ?? '',
      name: json['nama_pembeli'] ?? '',
      email: json['email_pembeli'] ?? '',
      role: 'pembeli',
      phone: json['noTelp_pembeli'],
      additionalData: {
        'poin_pembeli': json['poin_pembeli'] ?? 0,
      },
    );
  }

  // Factory untuk Penitip
  factory User.fromPenitip(Map<String, dynamic> json) {
    return User(
      id: json['id_penitip'] ?? '',
      name: json['nama_penitip'] ?? '',
      email: json['email_penitip'] ?? '',
      role: 'penitip',
      phone: json['noTelp_penitip'],
      additionalData: {
        'saldo_penitip': json['saldo_penitip'] ?? 0.0,
        'poin_penitip': json['poin_penitip'] ?? 0,
        'badge_loyalitas': json['badge_loyalitas'] ?? false,
      },
    );
  }

  // Factory untuk Pegawai (termasuk Kurir/Hunter/Admin/dll)
  factory User.fromPegawai(Map<String, dynamic> json, String specificRole) {
    return User(
      id: json['id_pegawai'] ?? '',
      name: json['nama_pegawai'] ?? '',
      email: json['email_pegawai'] ?? '',
      role: specificRole, // Gunakan role yang sudah dideteksi (kurir, hunter, admin, dll)
      phone: json['notelp_pegawai'],
      additionalData: {
        'jabatan': json['jabatan'],
        'alamat_pegawai': json['alamat_pegawai'],
        'tanggal_lahir_pegawai': json['tanggal_lahir_pegawai'],
        'id_jabatan': json['id_jabatan'],
      },
    );
  }

  // Factory umum dari JSON - hanya untuk mobile roles
  factory User.fromJson(Map<String, dynamic> json, String userType) {
    print('🏭 User.fromJson called with userType: $userType');
    switch (userType.toLowerCase()) {
      case 'pembeli':
        print('📱 Creating Pembeli user');
        return User.fromPembeli(json);
      case 'penitip':
        print('📦 Creating Penitip user');
        return User.fromPenitip(json);
      case 'kurir':
        print('🚚 Creating Kurir user');
        return User.fromPegawai(json, 'kurir');
      case 'hunter':
        print('🔍 Creating Hunter user');
        return User.fromPegawai(json, 'hunter');
      default:
        print('❌ Unknown userType: $userType');
        throw Exception('Role $userType tidak tersedia di mobile app');
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'additionalData': additionalData,
    };
  }

  // Copy with
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    Map<String, dynamic>? additionalData,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Helper methods untuk check role (mobile only)
  bool isPembeli() => role == 'pembeli';
  bool isPenitip() => role == 'penitip';
  bool isKurir() => role == 'kurir';
  bool isHunter() => role == 'hunter';

  // Get display name for role (mobile only)
  String getRoleDisplayName() {
    switch (role.toLowerCase()) {
      case 'pembeli':
        return 'Pembeli';
      case 'penitip':
        return 'Penitip';
      case 'kurir':
        return 'Kurir';
      case 'hunter':
        return 'Hunter';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, role: $role}';
  }
}