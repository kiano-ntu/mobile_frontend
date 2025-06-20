// File: lib/models/penitip.dart

import 'package:flutter/material.dart';

class Penitip {
  final String idPenitip;
  final String namaPenitip;
  final String emailPenitip;
  final String? noTelpPenitip;
  final String? alamatPenitip;
  final String? nikPenitip;
  final String? ktpPenitip;
  final double saldoPenitip;
  final int poinPenitip;
  final bool badgeLoyalitas;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ProdukPenitip>? produk;

  Penitip({
    required this.idPenitip,
    required this.namaPenitip,
    required this.emailPenitip,
    this.noTelpPenitip,
    this.alamatPenitip,
    this.nikPenitip,
    this.ktpPenitip,
    required this.saldoPenitip,
    required this.poinPenitip,
    required this.badgeLoyalitas,
    this.createdAt,
    this.updatedAt,
    this.produk,
  });

  factory Penitip.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing Penitip from JSON:');
      print('📄 Keys: ${json.keys.toList()}');

      return Penitip(
        idPenitip: _safeGetString(json, 'id_penitip', 'unknown_id'),
        namaPenitip:
            _safeGetString(json, 'nama_penitip', 'Nama Tidak Diketahui'),
        emailPenitip: _safeGetString(json, 'email_penitip', ''),
        noTelpPenitip: _safeGetString(json, 'noTelp_penitip'),
        alamatPenitip: _safeGetString(json, 'alamat_penitip'),
        nikPenitip: _safeGetString(json, 'nik_penitip'),
        ktpPenitip: _safeGetString(json, 'ktp_penitip'),
        saldoPenitip: _safeGetDouble(json, 'saldo_penitip', 0.0),
        poinPenitip: _safeGetInt(json, 'poin_penitip', 0),
        badgeLoyalitas: _safeGetBool(json, 'badge_loyalitas', false),
        createdAt: _parseDateTime(_safeGetString(json, 'created_at')),
        updatedAt: _parseDateTime(_safeGetString(json, 'updated_at')),
        produk: _parseProdukList(json['produk']),
      );
    } catch (e) {
      print('❌ Error parsing Penitip: $e');
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
      if (value is double) return value.toInt();
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  static double _safeGetDouble(
      Map<String, dynamic> json, String key, double defaultValue) {
    try {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.parse(value);
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  static bool _safeGetBool(
      Map<String, dynamic> json, String key, bool defaultValue) {
    try {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
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

  static List<ProdukPenitip>? _parseProdukList(dynamic produkData) {
    if (produkData == null) {
      print('⚠️ Produk data is null');
      return null;
    }

    try {
      print('🔍 Parsing produk data type: ${produkData.runtimeType}');

      if (produkData is List) {
        print('✅ Produk data is List with ${produkData.length} items');

        List<ProdukPenitip> produkList = [];

        for (int i = 0; i < produkData.length; i++) {
          try {
            final item = produkData[i];
            if (item is Map<String, dynamic>) {
              final produk = ProdukPenitip.fromJson(item);
              produkList.add(produk);
              print(
                  '✅ Produk $i parsed successfully: ${produk.namaProduk} (${produk.idProduk})');
            } else {
              print(
                  '⚠️ Produk item $i is not Map<String, dynamic>: ${item.runtimeType}');
            }
          } catch (e) {
            print('❌ Error parsing produk item $i: $e');
          }
        }

        print(
            '✅ Successfully parsed ${produkList.length} produk from ${produkData.length} items');
        return produkList;
      } else {
        print('⚠️ Produk data is not a List: ${produkData.runtimeType}');
        return null;
      }
    } catch (e) {
      print('❌ Failed to parse produk list: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penitip': idPenitip,
      'nama_penitip': namaPenitip,
      'email_penitip': emailPenitip,
      'noTelp_penitip': noTelpPenitip,
      'alamat_penitip': alamatPenitip,
      'nik_penitip': nikPenitip,
      'ktp_penitip': ktpPenitip,
      'saldo_penitip': saldoPenitip,
      'poin_penitip': poinPenitip,
      'badge_loyalitas': badgeLoyalitas,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'produk': produk?.map((p) => p.toJson()).toList(),
    };
  }

  Penitip copyWith({
    String? idPenitip,
    String? namaPenitip,
    String? emailPenitip,
    String? noTelpPenitip,
    String? alamatPenitip,
    String? nikPenitip,
    String? ktpPenitip,
    double? saldoPenitip,
    int? poinPenitip,
    bool? badgeLoyalitas,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ProdukPenitip>? produk,
  }) {
    return Penitip(
      idPenitip: idPenitip ?? this.idPenitip,
      namaPenitip: namaPenitip ?? this.namaPenitip,
      emailPenitip: emailPenitip ?? this.emailPenitip,
      noTelpPenitip: noTelpPenitip ?? this.noTelpPenitip,
      alamatPenitip: alamatPenitip ?? this.alamatPenitip,
      nikPenitip: nikPenitip ?? this.nikPenitip,
      ktpPenitip: ktpPenitip ?? this.ktpPenitip,
      saldoPenitip: saldoPenitip ?? this.saldoPenitip,
      poinPenitip: poinPenitip ?? this.poinPenitip,
      badgeLoyalitas: badgeLoyalitas ?? this.badgeLoyalitas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      produk: produk ?? this.produk,
    );
  }

  // Helper methods
  String get displayName => namaPenitip.isNotEmpty ? namaPenitip : 'Penitip';

  String get formattedSaldo =>
      'Rp ${saldoPenitip.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedPoin => poinPenitip.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

  String get formattedNik => nikPenitip ?? 'Belum diisi';

  int get totalProduk => produk?.length ?? 0;
  int get produkTersedia =>
      produk?.where((p) => p.statusProduk == 'Tersedia').length ?? 0;
  int get produkTerjual =>
      produk?.where((p) => p.statusProduk == 'Terjual').length ?? 0;

  @override
  String toString() {
    return 'Penitip{id: $idPenitip, nama: $namaPenitip, email: $emailPenitip, saldo: $saldoPenitip, poin: $poinPenitip}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Penitip &&
          runtimeType == other.runtimeType &&
          idPenitip == other.idPenitip;

  @override
  int get hashCode => idPenitip.hashCode;
}

class ProdukPenitip {
  final String idProduk;
  final String idPenitip;
  final String namaProduk;
  final String? gambarProduk;
  final String kategoriProduk;
  final String? deskripsiProduk;
  final double beratProduk;
  final double hargaProduk;
  final String statusProduk;
  final int ratingProduk;
  final DateTime? garansi;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PenitipanInfo? penitipan;

  ProdukPenitip({
    required this.idProduk,
    required this.idPenitip,
    required this.namaProduk,
    this.gambarProduk,
    required this.kategoriProduk,
    this.deskripsiProduk,
    required this.beratProduk,
    required this.hargaProduk,
    required this.statusProduk,
    required this.ratingProduk,
    this.garansi,
    this.createdAt,
    this.updatedAt,
    this.penitipan,
  });

  factory ProdukPenitip.fromJson(Map<String, dynamic> json) {
    try {
      return ProdukPenitip(
        idProduk: json['id_produk']?.toString() ?? '',
        idPenitip: json['id_penitip']?.toString() ?? '',
        namaProduk: json['nama_produk']?.toString() ?? '',
        gambarProduk: json['gambar_produk']?.toString(),
        kategoriProduk: json['kategori_produk']?.toString() ?? '',
        deskripsiProduk: json['deskripsi_produk']?.toString(),
        beratProduk: Penitip._safeGetDouble(json, 'berat_produk', 0.0),
        hargaProduk: Penitip._safeGetDouble(json, 'harga_produk', 0.0),
        statusProduk: json['status_produk']?.toString() ?? 'Tidak Diketahui',
        ratingProduk: Penitip._safeGetInt(json, 'rating_produk', 0),
        garansi: Penitip._parseDateTime(json['garansi']?.toString()),
        createdAt: Penitip._parseDateTime(json['created_at']?.toString()),
        updatedAt: Penitip._parseDateTime(json['updated_at']?.toString()),
        penitipan: json['penitipan'] != null
            ? PenitipanInfo.fromJson(json['penitipan'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing ProdukPenitip: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'id_penitip': idPenitip,
      'nama_produk': namaProduk,
      'gambar_produk': gambarProduk,
      'kategori_produk': kategoriProduk,
      'deskripsi_produk': deskripsiProduk,
      'berat_produk': beratProduk,
      'harga_produk': hargaProduk,
      'status_produk': statusProduk,
      'rating_produk': ratingProduk,
      'garansi': garansi?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'penitipan': penitipan?.toJson(),
    };
  }

  String get formattedHarga =>
      'Rp ${hargaProduk.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedBerat => '${beratProduk.toStringAsFixed(1)} kg';

  List<String> get gambarList {
    if (gambarProduk == null || gambarProduk!.isEmpty) return [];
    return gambarProduk!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? get firstImage => gambarList.isNotEmpty ? gambarList.first : null;

  Color get statusColor {
    switch (statusProduk) {
      case 'Tersedia':
        return Colors.green;
      case 'Terjual':
        return Colors.blue;
      case 'Diambil Kembali':
        return Colors.orange;
      case 'Didonasikan':
      case 'Barang Donasi':
        return Colors.purple;
      case 'Tenggat Waktu Habis':
        return Colors.red;
      case 'Siap Diambil':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (statusProduk) {
      case 'Tersedia':
        return Icons.check_circle;
      case 'Terjual':
        return Icons.attach_money;
      case 'Diambil Kembali':
        return Icons.arrow_back;
      case 'Didonasikan':
      case 'Barang Donasi':
        return Icons.favorite;
      case 'Tenggat Waktu Habis':
        return Icons.timer_off;
      case 'Siap Diambil':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  @override
  String toString() {
    return 'ProdukPenitip{id: $idProduk, nama: $namaProduk, status: $statusProduk, harga: $hargaProduk}';
  }
}

class PenitipanInfo {
  final String idPenitipan;
  final String idProduk;
  final String? idPegawai;
  final DateTime tanggalMasuk;
  final DateTime tenggatWaktu;
  final DateTime? tanggalKeluar;
  final DateTime? batasAmbil;
  final DateTime? tanggalDiambil;
  final bool? barangHunting;
  final bool statusPerpanjangan;

  PenitipanInfo({
    required this.idPenitipan,
    required this.idProduk,
    this.idPegawai,
    required this.tanggalMasuk,
    required this.tenggatWaktu,
    this.tanggalKeluar,
    this.batasAmbil,
    this.tanggalDiambil,
    this.barangHunting,
    required this.statusPerpanjangan,
  });

  factory PenitipanInfo.fromJson(Map<String, dynamic> json) {
    return PenitipanInfo(
      idPenitipan: json['id_penitipan']?.toString() ?? '',
      idProduk: json['id_produk']?.toString() ?? '',
      idPegawai: json['id_pegawai']?.toString(),
      tanggalMasuk: DateTime.parse(json['tanggal_masuk']),
      tenggatWaktu: DateTime.parse(json['tenggat_waktu']),
      tanggalKeluar: json['tanggal_keluar'] != null
          ? DateTime.parse(json['tanggal_keluar'])
          : null,
      batasAmbil: json['batas_ambil'] != null
          ? DateTime.parse(json['batas_ambil'])
          : null,
      tanggalDiambil: json['tanggal_diambil'] != null
          ? DateTime.parse(json['tanggal_diambil'])
          : null,
      barangHunting: json['barang_hunting'] == 1,
      statusPerpanjangan: json['status_perpanjangan'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penitipan': idPenitipan,
      'id_produk': idProduk,
      'id_pegawai': idPegawai,
      'tanggal_masuk': tanggalMasuk.toIso8601String(),
      'tenggat_waktu': tenggatWaktu.toIso8601String(),
      'tanggal_keluar': tanggalKeluar?.toIso8601String(),
      'batas_ambil': batasAmbil?.toIso8601String(),
      'tanggal_diambil': tanggalDiambil?.toIso8601String(),
      'barang_hunting': barangHunting,
      'status_perpanjangan': statusPerpanjangan,
    };
  }

  bool get isActive => tanggalKeluar == null;
  bool get isExpired => DateTime.now().isAfter(tenggatWaktu);
  int get daysRemaining => tenggatWaktu.difference(DateTime.now()).inDays;

  String get formattedTanggalMasuk =>
      '${tanggalMasuk.day}/${tanggalMasuk.month}/${tanggalMasuk.year}';
  String get formattedTenggatWaktu =>
      '${tenggatWaktu.day}/${tenggatWaktu.month}/${tenggatWaktu.year}';
}

// Model untuk riwayat transaksi penitip
class RiwayatTransaksi {
  final String id;
  final String idPenitip;
  final String deskripsi;
  final double jumlah;
  final double saldo;
  final String tipe; // 'income' atau 'withdrawal'
  final DateTime tanggal;
  final String? idPemesanan;
  final String? namaProduk;

  RiwayatTransaksi({
    required this.id,
    required this.idPenitip,
    required this.deskripsi,
    required this.jumlah,
    required this.saldo,
    required this.tipe,
    required this.tanggal,
    this.idPemesanan,
    this.namaProduk,
  });

  factory RiwayatTransaksi.fromJson(Map<String, dynamic> json) {
    return RiwayatTransaksi(
      id: json['id']?.toString() ?? '',
      idPenitip: json['id_penitip']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      jumlah: Penitip._safeGetDouble(json, 'jumlah', 0.0),
      saldo: Penitip._safeGetDouble(json, 'saldo', 0.0),
      tipe: json['tipe']?.toString() ?? 'income',
      tanggal: DateTime.tryParse(json['tanggal']?.toString() ?? '') ??
          DateTime.now(),
      idPemesanan: json['id_pemesanan']?.toString(),
      namaProduk: json['nama_produk']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_penitip': idPenitip,
      'deskripsi': deskripsi,
      'jumlah': jumlah,
      'saldo': saldo,
      'tipe': tipe,
      'tanggal': tanggal.toIso8601String(),
      'id_pemesanan': idPemesanan,
      'nama_produk': namaProduk,
    };
  }

  bool get isIncome => tipe == 'income';
  bool get isWithdrawal => tipe == 'withdrawal';

  String get formattedJumlah {
    final prefix = isIncome ? '+' : '-';
    return '$prefix Rp ${jumlah.abs().toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  String get formattedSaldo => 'Rp ${saldo.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';

  Color get typeColor => isIncome ? Colors.green : Colors.red;
  IconData get typeIcon => isIncome ? Icons.add_circle : Icons.remove_circle;
}