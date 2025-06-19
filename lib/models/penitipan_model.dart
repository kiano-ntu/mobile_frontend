// File: lib/models/penitipan_model.dart

import 'package:flutter/material.dart';

class PenitipanHistory {
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relationship objects
  final ProdukPenitipan? produk;
  final PegawaiPenitipan? pegawai;

  PenitipanHistory({
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
    this.createdAt,
    this.updatedAt,
    this.produk,
    this.pegawai,
  });

  factory PenitipanHistory.fromJson(Map<String, dynamic> json) {
    try {
      return PenitipanHistory(
        idPenitipan: _safeGetString(json, 'id_penitipan', 'unknown_id'),
        idProduk: _safeGetString(json, 'id_produk', ''),
        idPegawai: _safeGetString(json, 'id_pegawai'),
        tanggalMasuk: _parseDateTime(_safeGetString(json, 'tanggal_masuk')) ??
            DateTime.now(),
        tenggatWaktu: _parseDateTime(_safeGetString(json, 'tenggat_waktu')) ??
            DateTime.now().add(const Duration(days: 30)),
        tanggalKeluar: _parseDateTime(_safeGetString(json, 'tanggal_keluar')),
        batasAmbil: _parseDateTime(_safeGetString(json, 'batas_ambil')),
        tanggalDiambil: _parseDateTime(_safeGetString(json, 'tanggal_diambil')),
        barangHunting: _safeParseBool(json, 'barang_hunting'),
        statusPerpanjangan:
            _safeParseBool(json, 'status_perpanjangan') ?? false,
        createdAt: _parseDateTime(_safeGetString(json, 'created_at')),
        updatedAt: _parseDateTime(_safeGetString(json, 'updated_at')),
        produk: json['produk'] != null
            ? ProdukPenitipan.fromJson(json['produk'] as Map<String, dynamic>)
            : null,
        pegawai: json['pegawai'] != null
            ? PegawaiPenitipan.fromJson(json['pegawai'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing PenitipanHistory: $e');
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

  static bool? _safeParseBool(Map<String, dynamic> json, String key) {
    try {
      final value = json[key];
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return null;
    } catch (e) {
      return null;
    }
  }

  static DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Helper methods
  String get formattedTanggalMasuk => _formatDate(tanggalMasuk);
  String get formattedTenggatWaktu => _formatDate(tenggatWaktu);
  String get formattedTanggalKeluar =>
      tanggalKeluar != null ? _formatDate(tanggalKeluar!) : '-';

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Status helpers - SIMPLIFIED & BASED ON PRODUCT STATUS
  String get statusPenitipan {
    // Jika produk sudah keluar dari penitipan (ada tanggal_keluar)
    if (tanggalKeluar != null) {
      if (produk?.statusProduk == 'Terjual') return 'Terjual';
      if (produk?.statusProduk == 'Diambil Kembali') return 'Diambil Kembali';
      if (produk?.statusProduk == 'Barang Donasi') return 'Didonasikan';
      return 'Selesai';
    }

    // Jika belum keluar, gunakan status produk langsung dari database
    final statusProduk = produk?.statusProduk ?? '';

    switch (statusProduk) {
      case 'Tersedia':
        // Cek apakah hampir habis masa penitipan
        final now = DateTime.now();
        final daysDiff = tenggatWaktu.difference(now).inDays;
        if (daysDiff < 0) return 'Masa Penitipan Habis';
        if (daysDiff <= 3) return 'Hampir Habis';
        return 'Tersedia';

      case 'Terjual':
        return 'Terjual';

      case 'Siap Diambil':
        return 'Siap Diambil';

      case 'Tenggat Waktu Habis':
        return 'Menunggu Keputusan';

      case 'Barang Donasi':
        return 'Didonasikan';

      case 'Diambil Kembali':
        return 'Diambil Kembali';

      case 'Pesanan Diproses':
        return 'Pesanan Diproses';

      default:
        return statusProduk.isNotEmpty ? statusProduk : 'Tidak Diketahui';
    }
  }

  Color get statusColor {
    switch (statusPenitipan) {
      case 'Terjual':
        return Colors.green;
      case 'Tersedia':
        return Colors.blue;
      case 'Hampir Habis':
        return Colors.orange;
      case 'Masa Penitipan Habis':
      case 'Menunggu Keputusan':
        return Colors.red;
      case 'Siap Diambil':
        return Colors.purple;
      case 'Diambil Kembali':
        return Colors.grey;
      case 'Didonasikan':
        return Colors.amber;
      case 'Pesanan Diproses':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (statusPenitipan) {
      case 'Terjual':
        return Icons.attach_money;
      case 'Tersedia':
        return Icons.inventory;
      case 'Hampir Habis':
        return Icons.schedule;
      case 'Masa Penitipan Habis':
      case 'Menunggu Keputusan':
        return Icons.warning;
      case 'Siap Diambil':
        return Icons.check_circle;
      case 'Diambil Kembali':
        return Icons.assignment_return;
      case 'Didonasikan':
        return Icons.volunteer_activism;
      case 'Pesanan Diproses':
        return Icons.shopping_cart;
      default:
        return Icons.help;
    }
  }

  // Update status boolean helpers
  bool get isActive =>
      tanggalKeluar == null &&
      (statusPenitipan == 'Tersedia' || statusPenitipan == 'Hampir Habis');

  bool get isCompleted =>
      tanggalKeluar != null ||
      statusPenitipan == 'Terjual' ||
      statusPenitipan == 'Diambil Kembali' ||
      statusPenitipan == 'Didonasikan';

  bool get needsDecision =>
      statusPenitipan == 'Menunggu Keputusan' ||
      statusPenitipan == 'Masa Penitipan Habis';

  String get displayNamaProduk =>
      produk?.namaProduk ?? 'Produk Tidak Diketahui';
  String get displayNamaHunter => pegawai?.namaPegawai ?? 'Belum Ditugaskan';

  @override
  String toString() {
    return 'PenitipanHistory{id: $idPenitipan, produk: ${produk?.namaProduk}, status: $statusPenitipan}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenitipanHistory &&
          runtimeType == other.runtimeType &&
          idPenitipan == other.idPenitipan;

  @override
  int get hashCode => idPenitipan.hashCode;
}

class ProdukPenitipan {
  final String idProduk;
  final String namaProduk;
  final String? gambarProduk;
  final String kategoriProduk;
  final String deskripsiProduk;
  final double hargaProduk;
  final String statusProduk;

  ProdukPenitipan({
    required this.idProduk,
    required this.namaProduk,
    this.gambarProduk,
    required this.kategoriProduk,
    required this.deskripsiProduk,
    required this.hargaProduk,
    required this.statusProduk,
  });

  factory ProdukPenitipan.fromJson(Map<String, dynamic> json) {
    return ProdukPenitipan(
      idProduk: json['id_produk']?.toString() ?? '',
      namaProduk: json['nama_produk']?.toString() ?? '',
      gambarProduk: json['gambar_produk']?.toString(),
      kategoriProduk: json['kategori_produk']?.toString() ?? '',
      deskripsiProduk: json['deskripsi_produk']?.toString() ?? '',
      hargaProduk: (json['harga_produk'] as num?)?.toDouble() ?? 0.0,
      statusProduk: json['status_produk']?.toString() ?? '',
    );
  }

  String get formattedHarga =>
      'Rp ${hargaProduk.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  List<String> get gambarList {
    if (gambarProduk == null || gambarProduk!.isEmpty) return [];
    return gambarProduk!.split(',').map((e) => e.trim()).toList();
  }

  String? get firstImage {
    final images = gambarList;
    return images.isNotEmpty ? images.first : null;
  }
}

class PegawaiPenitipan {
  final String idPegawai;
  final String namaPegawai;
  final String emailPegawai;

  PegawaiPenitipan({
    required this.idPegawai,
    required this.namaPegawai,
    required this.emailPegawai,
  });

  factory PegawaiPenitipan.fromJson(Map<String, dynamic> json) {
    return PegawaiPenitipan(
      idPegawai: json['id_pegawai']?.toString() ?? '',
      namaPegawai: json['nama_pegawai']?.toString() ?? '',
      emailPegawai: json['email_pegawai']?.toString() ?? '',
    );
  }
}
