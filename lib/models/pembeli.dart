// File: lib/models/pembeli.dart

import 'package:flutter/material.dart';

class Pembeli {
  final String idPembeli;
  final String namaPembeli;
  final String emailPembeli;
  final String? noTelpPembeli;
  final int poinPembeli;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Alamat>? alamat;

  Pembeli({
    required this.idPembeli,
    required this.namaPembeli,
    required this.emailPembeli,
    this.noTelpPembeli,
    required this.poinPembeli,
    this.createdAt,
    this.updatedAt,
    this.alamat,
  });

  factory Pembeli.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing Pembeli from JSON:');
      print('📄 Keys: ${json.keys.toList()}');

      return Pembeli(
        idPembeli: _safeGetString(json, 'id_pembeli', 'unknown_id'),
        namaPembeli:
            _safeGetString(json, 'nama_pembeli', 'Nama Tidak Diketahui'),
        emailPembeli: _safeGetString(json, 'email_pembeli', ''),
        noTelpPembeli: _safeGetString(json, 'noTelp_pembeli'),
        poinPembeli: _safeGetInt(json, 'poin_pembeli', 0),
        createdAt: _parseDateTime(_safeGetString(json, 'created_at')),
        updatedAt: _parseDateTime(_safeGetString(json, 'updated_at')),
        alamat: _parseAlamatList(json['alamat']),
      );
    } catch (e) {
      print('❌ Error parsing Pembeli: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  static String _safeGetString(Map<String, dynamic> json, String key,
      [String? defaultValue]) {
    try {
      final value = json[key];
      if (value == null || value.toString().trim().isEmpty) {
        return defaultValue ?? '';
      }
      return value.toString();
    } catch (e) {
      return defaultValue ?? '';
    }
  }

  static int _safeGetInt(
      Map<String, dynamic> json, String key, int defaultValue) {
    try {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.parse(value);
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  static DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('⚠️ Failed to parse date: $dateString');
      return null;
    }
  }

  static List<Alamat>? _parseAlamatList(dynamic alamatData) {
    if (alamatData == null) {
      print('⚠️ Alamat data is null');
      return null;
    }

    try {
      print('🔍 Parsing alamat data type: ${alamatData.runtimeType}');
      print('📄 Alamat raw data: $alamatData');

      if (alamatData is List) {
        print('✅ Alamat data is List with ${alamatData.length} items');

        List<Alamat> alamatList = [];

        for (int i = 0; i < alamatData.length; i++) {
          try {
            final item = alamatData[i];
            print('🏠 Processing alamat $i: $item');

            if (item is Map<String, dynamic>) {
              final alamat = Alamat.fromJson(item);
              alamatList.add(alamat);
              print(
                  '✅ Alamat $i parsed successfully: ${alamat.tagAlamat} (${alamat.idAlamat}) - Default: ${alamat.isDefault}');
            } else {
              print(
                  '⚠️ Alamat item $i is not Map<String, dynamic>: ${item.runtimeType}');
            }
          } catch (e) {
            print('❌ Error parsing alamat item $i: $e');
            // Continue dengan item berikutnya
          }
        }

        print(
            '✅ Successfully parsed ${alamatList.length} alamat from ${alamatData.length} items');
        return alamatList;
      } else {
        print('⚠️ Alamat data is not a List: ${alamatData.runtimeType}');
        return null;
      }
    } catch (e) {
      print('❌ Failed to parse alamat list: $e');
      print('📄 Alamat data: $alamatData');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pembeli': idPembeli,
      'nama_pembeli': namaPembeli,
      'email_pembeli': emailPembeli,
      'noTelp_pembeli': noTelpPembeli,
      'poin_pembeli': poinPembeli,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'alamat': alamat?.map((a) => a.toJson()).toList(),
    };
  }

  Pembeli copyWith({
    String? idPembeli,
    String? namaPembeli,
    String? emailPembeli,
    String? noTelpPembeli,
    int? poinPembeli,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Alamat>? alamat,
  }) {
    return Pembeli(
      idPembeli: idPembeli ?? this.idPembeli,
      namaPembeli: namaPembeli ?? this.namaPembeli,
      emailPembeli: emailPembeli ?? this.emailPembeli,
      noTelpPembeli: noTelpPembeli ?? this.noTelpPembeli,
      poinPembeli: poinPembeli ?? this.poinPembeli,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      alamat: alamat ?? this.alamat,
    );
  }

  // Helper methods
  String get displayName => namaPembeli.isNotEmpty ? namaPembeli : 'Pembeli';
  String get formattedPoin => poinPembeli.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

  Alamat? get defaultAlamat {
    if (alamat == null || alamat!.isEmpty) return null;
    try {
      return alamat!.firstWhere((a) => a.isDefault);
    } catch (e) {
      return alamat!.first;
    }
  }

  @override
  String toString() {
    return 'Pembeli{id: $idPembeli, nama: $namaPembeli, email: $emailPembeli, poin: $poinPembeli}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pembeli &&
          runtimeType == other.runtimeType &&
          idPembeli == other.idPembeli;

  @override
  int get hashCode => idPembeli.hashCode;
}

class Alamat {
  final String idAlamat;
  final String idPembeli;
  final String kota;
  final String kecamatan;
  final String desa;
  final int kodePos;
  final String? detailLebih;
  final String tagAlamat;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Alamat({
    required this.idAlamat,
    required this.idPembeli,
    required this.kota,
    required this.kecamatan,
    required this.desa,
    required this.kodePos,
    this.detailLebih,
    required this.tagAlamat,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory Alamat.fromJson(Map<String, dynamic> json) {
    try {
      print('🏠 Parsing Alamat from JSON:');
      print('📄 Keys: ${json.keys.toList()}');
      print('📄 Values: $json');

      // Parse kode_pos dengan handling yang lebih baik
      int parsedKodePos = 0;
      final kodePosRaw = json['kode_pos'];
      if (kodePosRaw != null) {
        if (kodePosRaw is int) {
          parsedKodePos = kodePosRaw;
        } else if (kodePosRaw is String) {
          parsedKodePos = int.tryParse(kodePosRaw) ?? 0;
        } else {
          print('⚠️ Unexpected kode_pos type: ${kodePosRaw.runtimeType}');
        }
      }

      // Parse isdefault dengan handling yang lebih baik
      bool parsedIsDefault = false;
      final isDefaultRaw = json['isdefault'];
      if (isDefaultRaw != null) {
        if (isDefaultRaw is bool) {
          parsedIsDefault = isDefaultRaw;
        } else if (isDefaultRaw is int) {
          parsedIsDefault = isDefaultRaw == 1;
        } else if (isDefaultRaw is String) {
          parsedIsDefault =
              isDefaultRaw.toLowerCase() == 'true' || isDefaultRaw == '1';
        } else {
          print('⚠️ Unexpected isdefault type: ${isDefaultRaw.runtimeType}');
        }
      }

      final alamat = Alamat(
        idAlamat: json['id_alamat']?.toString() ?? '',
        idPembeli: json['id_pembeli']?.toString() ?? '',
        kota: json['kota']?.toString() ?? '',
        kecamatan: json['kecamatan']?.toString() ?? '',
        desa: json['desa']?.toString() ?? '',
        kodePos: parsedKodePos,
        detailLebih: json['detail_lebih']?.toString(),
        tagAlamat: json['tag_alamat']?.toString() ?? '',
        isDefault: parsedIsDefault,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
      );

      print(
          '✅ Alamat parsed: ${alamat.tagAlamat} (${alamat.idAlamat}) - Default: ${alamat.isDefault}');
      return alamat;
    } catch (e) {
      print('❌ Error parsing Alamat: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alamat': idAlamat,
      'id_pembeli': idPembeli,
      'kota': kota,
      'kecamatan': kecamatan,
      'desa': desa,
      'kode_pos': kodePos,
      'detail_lebih': detailLebih,
      'tag_alamat': tagAlamat,
      'isdefault': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get alamatLengkap {
    final parts = [
      if (detailLebih?.isNotEmpty == true) detailLebih,
      desa,
      kecamatan,
      kota,
      kodePos.toString(),
    ].where((part) => part != null && part.toString().isNotEmpty);

    return parts.join(', ');
  }

  String get alamatSingkat {
    return '$desa, $kecamatan, $kota';
  }

  Alamat copyWith({
    String? idAlamat,
    String? idPembeli,
    String? kota,
    String? kecamatan,
    String? desa,
    int? kodePos,
    String? detailLebih,
    String? tagAlamat,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Alamat(
      idAlamat: idAlamat ?? this.idAlamat,
      idPembeli: idPembeli ?? this.idPembeli,
      kota: kota ?? this.kota,
      kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa,
      kodePos: kodePos ?? this.kodePos,
      detailLebih: detailLebih ?? this.detailLebih,
      tagAlamat: tagAlamat ?? this.tagAlamat,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Alamat{id: $idAlamat, tag: $tagAlamat, alamat: $alamatLengkap, default: $isDefault}';
  }
}

// Model untuk riwayat poin
class RiwayatPoin {
  final String id;
  final String idPembeli;
  final String deskripsi;
  final int jumlah;
  final int saldo;
  final String tipe; // 'earn' atau 'redeem'
  final DateTime tanggal;

  RiwayatPoin({
    required this.id,
    required this.idPembeli,
    required this.deskripsi,
    required this.jumlah,
    required this.saldo,
    required this.tipe,
    required this.tanggal,
  });

  factory RiwayatPoin.fromJson(Map<String, dynamic> json) {
    return RiwayatPoin(
      id: json['id']?.toString() ?? '',
      idPembeli: json['id_pembeli']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      jumlah: json['jumlah'] is int
          ? json['jumlah']
          : int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      saldo: json['saldo'] is int
          ? json['saldo']
          : int.tryParse(json['saldo']?.toString() ?? '0') ?? 0,
      tipe: json['tipe']?.toString() ?? 'earn',
      tanggal: DateTime.tryParse(json['tanggal']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pembeli': idPembeli,
      'deskripsi': deskripsi,
      'jumlah': jumlah,
      'saldo': saldo,
      'tipe': tipe,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  bool get isEarn => tipe == 'earn';
  bool get isRedeem => tipe == 'redeem';

  String get formattedJumlah {
    final prefix = isEarn ? '+' : '-';
    return '$prefix${jumlah.abs()}';
  }

  String get formattedSaldo => saldo.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

  Color get typeColor => isEarn ? Colors.green : Colors.red;
  IconData get typeIcon => isEarn ? Icons.add_circle : Icons.remove_circle;
}