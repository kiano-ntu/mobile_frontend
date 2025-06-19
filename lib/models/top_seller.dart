// File: lib/models/top_seller.dart

import 'package:flutter/material.dart';

class TopSeller {
  final String idPenitip;
  final String namaPenitip;
  final String emailPenitip;
  final String? noTelpPenitip;
  final String? alamatPenitip;
  final double saldoPenitip;
  final int poinPenitip;
  final bool badgeLoyalitas;
  final int totalProdukTerjual;
  final double totalPendapatan;
  final int rankPosisi;
  final List<ProdukTopSeller>? produkTerlaris;

  TopSeller({
    required this.idPenitip,
    required this.namaPenitip,
    required this.emailPenitip,
    this.noTelpPenitip,
    this.alamatPenitip,
    required this.saldoPenitip,
    required this.poinPenitip,
    required this.badgeLoyalitas,
    required this.totalProdukTerjual,
    required this.totalPendapatan,
    required this.rankPosisi,
    this.produkTerlaris,
  });

  factory TopSeller.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing TopSeller from JSON:');
      print('📄 Keys: ${json.keys.toList()}');

      return TopSeller(
        idPenitip: _safeGetString(json, 'id_penitip', 'unknown_id'),
        namaPenitip:
            _safeGetString(json, 'nama_penitip', 'Nama Tidak Diketahui'),
        emailPenitip: _safeGetString(json, 'email_penitip', ''),
        noTelpPenitip: _safeGetString(json, 'noTelp_penitip'),
        alamatPenitip: _safeGetString(json, 'alamat_penitip'),
        saldoPenitip: _safeGetDouble(json, 'saldo_penitip', 0.0),
        poinPenitip: _safeGetInt(json, 'poin_penitip', 0),
        badgeLoyalitas: _safeGetBool(json, 'badge_loyalitas', false),
        totalProdukTerjual: _safeGetInt(json, 'total_produk_terjual', 0),
        totalPendapatan: _safeGetDouble(json, 'total_pendapatan', 0.0),
        rankPosisi: _safeGetInt(json, 'rank_posisi', 0),
        produkTerlaris: _parseProdukTerlarisList(json['produk_terlaris']),
      );
    } catch (e) {
      print('❌ Error parsing TopSeller: $e');
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

  static List<ProdukTopSeller>? _parseProdukTerlarisList(dynamic produkData) {
    if (produkData == null) {
      print('⚠️ Produk terlaris data is null');
      return null;
    }

    try {
      print('🔍 Parsing produk terlaris data type: ${produkData.runtimeType}');

      if (produkData is List) {
        print('✅ Produk terlaris data is List with ${produkData.length} items');

        List<ProdukTopSeller> produkList = [];

        for (int i = 0; i < produkData.length; i++) {
          try {
            final item = produkData[i];
            if (item is Map<String, dynamic>) {
              final produk = ProdukTopSeller.fromJson(item);
              produkList.add(produk);
              print(
                  '✅ Produk terlaris $i parsed successfully: ${produk.namaProduk}');
            } else {
              print(
                  '⚠️ Produk terlaris item $i is not Map<String, dynamic>: ${item.runtimeType}');
            }
          } catch (e) {
            print('❌ Error parsing produk terlaris item $i: $e');
          }
        }

        print(
            '✅ Successfully parsed ${produkList.length} produk terlaris from ${produkData.length} items');
        return produkList;
      } else {
        print(
            '⚠️ Produk terlaris data is not a List: ${produkData.runtimeType}');
        return null;
      }
    } catch (e) {
      print('❌ Failed to parse produk terlaris list: $e');
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
      'saldo_penitip': saldoPenitip,
      'poin_penitip': poinPenitip,
      'badge_loyalitas': badgeLoyalitas,
      'total_produk_terjual': totalProdukTerjual,
      'total_pendapatan': totalPendapatan,
      'rank_posisi': rankPosisi,
      'produk_terlaris': produkTerlaris?.map((p) => p.toJson()).toList(),
    };
  }

  // Helper methods
  String get displayName => namaPenitip.isNotEmpty ? namaPenitip : 'Top Seller';

  String get formattedPendapatan =>
      'Rp ${totalPendapatan.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedSaldo =>
      'Rp ${saldoPenitip.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedPoin => poinPenitip.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

  String get rankText {
    switch (rankPosisi) {
      case 1:
        return '🥇 #1';
      case 2:
        return '🥈 #2';
      case 3:
        return '🥉 #3';
      default:
        return '#$rankPosisi';
    }
  }

  Color get rankColor {
    switch (rankPosisi) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF00965F); // AppColors.primary
    }
  }

  IconData get rankIcon {
    switch (rankPosisi) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.star;
    }
  }

  String get badgeText {
    if (badgeLoyalitas) {
      return '👑 Loyal Seller';
    }
    return 'Seller';
  }

  @override
  String toString() {
    return 'TopSeller{rank: $rankPosisi, nama: $namaPenitip, terjual: $totalProdukTerjual, pendapatan: $totalPendapatan}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopSeller &&
          runtimeType == other.runtimeType &&
          idPenitip == other.idPenitip;

  @override
  int get hashCode => idPenitip.hashCode;
}

class ProdukTopSeller {
  final String idProduk;
  final String namaProduk;
  final String? gambarProduk;
  final String kategoriProduk;
  final double hargaProduk;
  final int jumlahTerjual;
  final double totalPendapatan;

  ProdukTopSeller({
    required this.idProduk,
    required this.namaProduk,
    this.gambarProduk,
    required this.kategoriProduk,
    required this.hargaProduk,
    required this.jumlahTerjual,
    required this.totalPendapatan,
  });

  factory ProdukTopSeller.fromJson(Map<String, dynamic> json) {
    try {
      return ProdukTopSeller(
        idProduk: json['id_produk']?.toString() ?? '',
        namaProduk: json['nama_produk']?.toString() ?? '',
        gambarProduk: json['gambar_produk']?.toString(),
        kategoriProduk: json['kategori_produk']?.toString() ?? '',
        hargaProduk: TopSeller._safeGetDouble(json, 'harga_produk', 0.0),
        jumlahTerjual: TopSeller._safeGetInt(json, 'jumlah_terjual', 0),
        totalPendapatan:
            TopSeller._safeGetDouble(json, 'total_pendapatan', 0.0),
      );
    } catch (e) {
      print('❌ Error parsing ProdukTopSeller: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'nama_produk': namaProduk,
      'gambar_produk': gambarProduk,
      'kategori_produk': kategoriProduk,
      'harga_produk': hargaProduk,
      'jumlah_terjual': jumlahTerjual,
      'total_pendapatan': totalPendapatan,
    };
  }

  String get formattedHarga =>
      'Rp ${hargaProduk.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedPendapatan =>
      'Rp ${totalPendapatan.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  List<String> get gambarList {
    if (gambarProduk == null || gambarProduk!.isEmpty) return [];
    return gambarProduk!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? get firstImage => gambarList.isNotEmpty ? gambarList.first : null;

  @override
  String toString() {
    return 'ProdukTopSeller{nama: $namaProduk, terjual: $jumlahTerjual, pendapatan: $totalPendapatan}';
  }
}
