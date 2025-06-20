// File: lib/models/pemesanan.dart

import 'package:flutter/material.dart';

class Pemesanan {
  final String idPemesanan;
  final String idPenitipan;
  final String idPembeli;
  final String? idPegawai;
  final String? idAlamat;
  final DateTime tanggalPesan;
  final DateTime? tanggalBayar;
  final DateTime? tanggalKirim;
  final DateTime? tanggalAmbil;
  final int? poinDiskon;
  final double? jumHargaDiskon;
  final double jumHargaBersih;
  final double jumHargaOngkir;
  final double totalBayar;
  final int poinDidapatkan;
  final String statusBayar;
  final String? buktiPembayaran;
  final String modePengiriman;
  final String statusPengiriman;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relationship objects
  final Penitipan? penitipan;
  final PembeliPemesanan? pembeli;
  final Pegawai? pegawai;
  final AlamatPemesanan? alamat;
  final Komisi? komisi;

  Pemesanan({
    required this.idPemesanan,
    required this.idPenitipan,
    required this.idPembeli,
    this.idPegawai,
    this.idAlamat,
    required this.tanggalPesan,
    this.tanggalBayar,
    this.tanggalKirim,
    this.tanggalAmbil,
    this.poinDiskon,
    this.jumHargaDiskon,
    required this.jumHargaBersih,
    required this.jumHargaOngkir,
    required this.totalBayar,
    required this.poinDidapatkan,
    required this.statusBayar,
    this.buktiPembayaran,
    required this.modePengiriman,
    required this.statusPengiriman,
    this.createdAt,
    this.updatedAt,
    this.penitipan,
    this.pembeli,
    this.pegawai,
    this.alamat,
    this.komisi,
  });

  factory Pemesanan.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing Pemesanan from JSON:');
      print('📄 Keys: ${json.keys.toList()}');

      return Pemesanan(
        idPemesanan: _safeGetString(json, 'id_pemesanan', 'unknown_id'),
        idPenitipan: _safeGetString(json, 'id_penitipan', ''),
        idPembeli: _safeGetString(json, 'id_pembeli', ''),
        idPegawai: _safeGetString(json, 'id_pegawai'),
        idAlamat: _safeGetString(json, 'id_alamat'),
        tanggalPesan: _parseDateTime(_safeGetString(json, 'tanggal_pesan')) ??
            DateTime.now(),
        tanggalBayar: _parseDateTime(_safeGetString(json, 'tanggal_bayar')),
        tanggalKirim: _parseDateTime(_safeGetString(json, 'tanggal_kirim')),
        tanggalAmbil: _parseDateTime(_safeGetString(json, 'tanggal_ambil')),
        poinDiskon: _safeGetInt(json, 'poin_diskon'),
        jumHargaDiskon: _safeGetDouble(json, 'jumHarga_diskon'),
        jumHargaBersih: _safeGetDouble(json, 'jumHarga_bersih', 0.0),
        jumHargaOngkir: _safeGetDouble(json, 'jumHarga_ongkir', 0.0),
        totalBayar: _safeGetDouble(json, 'total_bayar', 0.0),
        poinDidapatkan: _safeGetInt(json, 'poin_didapatkan', 0),
        statusBayar:
            _safeGetString(json, 'status_bayar', 'Menunggu Pembayaran'),
        buktiPembayaran: _safeGetString(json, 'bukti_pembayaran'),
        modePengiriman: _safeGetString(json, 'mode_pengiriman', ''),
        statusPengiriman: _safeGetString(json, 'status_pengiriman', 'Diproses'),
        createdAt: _parseDateTime(_safeGetString(json, 'created_at')),
        updatedAt: _parseDateTime(_safeGetString(json, 'updated_at')),
        penitipan: json['penitipan'] != null
            ? Penitipan.fromJson(json['penitipan'] as Map<String, dynamic>)
            : null,
        pembeli: json['pembeli'] != null
            ? PembeliPemesanan.fromJson(json['pembeli'] as Map<String, dynamic>)
            : null,
        pegawai: json['pegawai'] != null
            ? Pegawai.fromJson(json['pegawai'] as Map<String, dynamic>)
            : null,
        alamat: json['alamat'] != null
            ? AlamatPemesanan.fromJson(json['alamat'] as Map<String, dynamic>)
            : null,
        komisi: json['komisi'] != null
            ? Komisi.fromJson(json['komisi'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('❌ Error parsing Pemesanan: $e');
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

  static int _safeGetInt(Map<String, dynamic> json, String key,
      [int defaultValue = 0]) {
    try {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  static double _safeGetDouble(Map<String, dynamic> json, String key,
      [double defaultValue = 0.0]) {
    try {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
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

  Map<String, dynamic> toJson() {
    return {
      'id_pemesanan': idPemesanan,
      'id_penitipan': idPenitipan,
      'id_pembeli': idPembeli,
      'id_pegawai': idPegawai,
      'id_alamat': idAlamat,
      'tanggal_pesan': tanggalPesan.toIso8601String(),
      'tanggal_bayar': tanggalBayar?.toIso8601String(),
      'tanggal_kirim': tanggalKirim?.toIso8601String(),
      'tanggal_ambil': tanggalAmbil?.toIso8601String(),
      'poin_diskon': poinDiskon,
      'jumHarga_diskon': jumHargaDiskon,
      'jumHarga_bersih': jumHargaBersih,
      'jumHarga_ongkir': jumHargaOngkir,
      'total_bayar': totalBayar,
      'poin_didapatkan': poinDidapatkan,
      'status_bayar': statusBayar,
      'bukti_pembayaran': buktiPembayaran,
      'mode_pengiriman': modePengiriman,
      'status_pengiriman': statusPengiriman,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'penitipan': penitipan?.toJson(),
      'pembeli': pembeli?.toJson(),
      'pegawai': pegawai?.toJson(),
      'alamat': alamat?.toJson(),
      'komisi': komisi?.toJson(),
    };
  }

  // Helper methods
  String get formattedTotalBayar =>
      'Rp ${totalBayar.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedJumHargaBersih =>
      'Rp ${jumHargaBersih.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedJumHargaOngkir =>
      'Rp ${jumHargaOngkir.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';

  String get formattedJumHargaDiskon => jumHargaDiskon != null
      ? 'Rp ${jumHargaDiskon!.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}'
      : 'Rp 0';

  String get formattedTanggalPesan => _formatDate(tanggalPesan);
  String get formattedTanggalBayar =>
      tanggalBayar != null ? _formatDate(tanggalBayar!) : '-';
  String get formattedTanggalKirim =>
      tanggalKirim != null ? _formatDate(tanggalKirim!) : '-';
  String get formattedTanggalAmbil =>
      tanggalAmbil != null ? _formatDate(tanggalAmbil!) : '-';

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

  // Status color helpers
  Color get statusBayarColor {
    switch (statusBayar.toLowerCase()) {
      case 'lunas':
      case 'pembayaran dikonfirmasi':
        return Colors.green;
      case 'menunggu pembayaran':
        return Colors.orange;
      case 'dibatalkan':
      case 'hangus':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get statusPengirimanColor {
    switch (statusPengiriman.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'dikirim':
      case 'sampai':
        return Colors.blue;
      case 'disiapkan':
      case 'menunggu pengambilan':
        return Colors.orange;
      case 'diproses':
        return Colors.amber;
      case 'hangus':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Status icon helpers
  IconData get statusBayarIcon {
    switch (statusBayar.toLowerCase()) {
      case 'lunas':
      case 'pembayaran dikonfirmasi':
        return Icons.check_circle;
      case 'menunggu pembayaran':
        return Icons.schedule;
      case 'dibatalkan':
      case 'hangus':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  IconData get statusPengirimanIcon {
    switch (statusPengiriman.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle;
      case 'dikirim':
        return Icons.local_shipping;
      case 'sampai':
        return Icons.home;
      case 'disiapkan':
        return Icons.inventory;
      case 'menunggu pengambilan':
        return Icons.store;
      case 'diproses':
        return Icons.hourglass_empty;
      case 'hangus':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Status helpers
  bool get isPaid =>
      statusBayar.toLowerCase() == 'lunas' ||
      statusBayar.toLowerCase() == 'pembayaran dikonfirmasi';
  bool get isCompleted => statusPengiriman.toLowerCase() == 'selesai';
  bool get isCancelled =>
      statusBayar.toLowerCase() == 'dibatalkan' ||
      statusBayar.toLowerCase() == 'hangus';
  bool get isActive => !isCompleted && !isCancelled;

  String get displayNamaProduk =>
      penitipan?.produk?.namaProduk ?? 'Produk Tidak Diketahui';
  String get displayNamaPenitip =>
      penitipan?.produk?.penitip?.namaPenitip ?? 'Penitip Tidak Diketahui';

  @override
  String toString() {
    return 'Pemesanan{id: $idPemesanan, tanggal: $tanggalPesan, total: $totalBayar, status: $statusPengiriman}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pemesanan &&
          runtimeType == other.runtimeType &&
          idPemesanan == other.idPemesanan;

  @override
  int get hashCode => idPemesanan.hashCode;
}

// Related models for Pemesanan relationships
class Penitipan {
  final String idPenitipan;
  final String idProduk;
  final String? idPegawai;
  final DateTime tanggalMasuk;
  final DateTime? tanggalKeluar;
  final bool statusPerpanjangan;
  final bool barangHunting;
  final ProdukPemesanan? produk;

  Penitipan({
    required this.idPenitipan,
    required this.idProduk,
    this.idPegawai,
    required this.tanggalMasuk,
    this.tanggalKeluar,
    required this.statusPerpanjangan,
    required this.barangHunting,
    this.produk,
  });

  factory Penitipan.fromJson(Map<String, dynamic> json) {
    return Penitipan(
      idPenitipan: json['id_penitipan']?.toString() ?? '',
      idProduk: json['id_produk']?.toString() ?? '',
      idPegawai: json['id_pegawai']?.toString(),
      tanggalMasuk:
          DateTime.tryParse(json['tanggal_masuk']?.toString() ?? '') ??
              DateTime.now(),
      tanggalKeluar: json['tanggal_keluar'] != null
          ? DateTime.tryParse(json['tanggal_keluar'])
          : null,
      statusPerpanjangan: json['status_perpanjangan'] == true ||
          json['status_perpanjangan'] == 1,
      barangHunting:
          json['barang_hunting'] == true || json['barang_hunting'] == 1,
      produk: json['produk'] != null
          ? ProdukPemesanan.fromJson(json['produk'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penitipan': idPenitipan,
      'id_produk': idProduk,
      'id_pegawai': idPegawai,
      'tanggal_masuk': tanggalMasuk.toIso8601String(),
      'tanggal_keluar': tanggalKeluar?.toIso8601String(),
      'status_perpanjangan': statusPerpanjangan,
      'barang_hunting': barangHunting,
      'produk': produk?.toJson(),
    };
  }
}

class ProdukPemesanan {
  final String idProduk;
  final String namaProduk;
  final String? deskripsiProduk;
  final double hargaProduk;
  final String? fotoProduk;
  final String statusProduk;
  final PenitipPemesanan? penitip;

  ProdukPemesanan({
    required this.idProduk,
    required this.namaProduk,
    this.deskripsiProduk,
    required this.hargaProduk,
    this.fotoProduk,
    required this.statusProduk,
    this.penitip,
  });

  factory ProdukPemesanan.fromJson(Map<String, dynamic> json) {
    return ProdukPemesanan(
      idProduk: json['id_produk']?.toString() ?? '',
      namaProduk: json['nama_produk']?.toString() ?? '',
      deskripsiProduk: json['deskripsi_produk']?.toString(),
      hargaProduk: (json['harga_produk'] as num?)?.toDouble() ?? 0.0,
      fotoProduk: json['foto_produk']?.toString(),
      statusProduk: json['status_produk']?.toString() ?? '',
      penitip: json['penitip'] != null
          ? PenitipPemesanan.fromJson(json['penitip'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'nama_produk': namaProduk,
      'deskripsi_produk': deskripsiProduk,
      'harga_produk': hargaProduk,
      'foto_produk': fotoProduk,
      'status_produk': statusProduk,
      'penitip': penitip?.toJson(),
    };
  }

  String get formattedHarga =>
      'Rp ${hargaProduk.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}';
}

class PenitipPemesanan {
  final String idPenitip;
  final String namaPenitip;
  final String? emailPenitip;
  final String? noTelpPenitip;

  PenitipPemesanan({
    required this.idPenitip,
    required this.namaPenitip,
    this.emailPenitip,
    this.noTelpPenitip,
  });

  factory PenitipPemesanan.fromJson(Map<String, dynamic> json) {
    return PenitipPemesanan(
      idPenitip: json['id_penitip']?.toString() ?? '',
      namaPenitip: json['nama_penitip']?.toString() ?? '',
      emailPenitip: json['email_penitip']?.toString(),
      noTelpPenitip: json['noTelp_penitip']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penitip': idPenitip,
      'nama_penitip': namaPenitip,
      'email_penitip': emailPenitip,
      'noTelp_penitip': noTelpPenitip,
    };
  }
}

class PembeliPemesanan {
  final String idPembeli;
  final String namaPembeli;
  final String emailPembeli;
  final String? noTelpPembeli;

  PembeliPemesanan({
    required this.idPembeli,
    required this.namaPembeli,
    required this.emailPembeli,
    this.noTelpPembeli,
  });

  factory PembeliPemesanan.fromJson(Map<String, dynamic> json) {
    return PembeliPemesanan(
      idPembeli: json['id_pembeli']?.toString() ?? '',
      namaPembeli: json['nama_pembeli']?.toString() ?? '',
      emailPembeli: json['email_pembeli']?.toString() ?? '',
      noTelpPembeli: json['noTelp_pembeli']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pembeli': idPembeli,
      'nama_pembeli': namaPembeli,
      'email_pembeli': emailPembeli,
      'noTelp_pembeli': noTelpPembeli,
    };
  }
}

class Pegawai {
  final String idPegawai;
  final String namaPegawai;
  final String emailPegawai;

  Pegawai({
    required this.idPegawai,
    required this.namaPegawai,
    required this.emailPegawai,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    return Pegawai(
      idPegawai: json['id_pegawai']?.toString() ?? '',
      namaPegawai: json['nama_pegawai']?.toString() ?? '',
      emailPegawai: json['email_pegawai']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pegawai': idPegawai,
      'nama_pegawai': namaPegawai,
      'email_pegawai': emailPegawai,
    };
  }
}

class AlamatPemesanan {
  final String idAlamat;
  final String kota;
  final String kecamatan;
  final String desa;
  final int kodePos;
  final String? detailLebih;
  final String tagAlamat;

  AlamatPemesanan({
    required this.idAlamat,
    required this.kota,
    required this.kecamatan,
    required this.desa,
    required this.kodePos,
    this.detailLebih,
    required this.tagAlamat,
  });

  factory AlamatPemesanan.fromJson(Map<String, dynamic> json) {
    return AlamatPemesanan(
      idAlamat: json['id_alamat']?.toString() ?? '',
      kota: json['kota']?.toString() ?? '',
      kecamatan: json['kecamatan']?.toString() ?? '',
      desa: json['desa']?.toString() ?? '',
      kodePos: json['kode_pos'] is int
          ? json['kode_pos']
          : int.tryParse(json['kode_pos']?.toString() ?? '0') ?? 0,
      detailLebih: json['detail_lebih']?.toString(),
      tagAlamat: json['tag_alamat']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_alamat': idAlamat,
      'kota': kota,
      'kecamatan': kecamatan,
      'desa': desa,
      'kode_pos': kodePos,
      'detail_lebih': detailLebih,
      'tag_alamat': tagAlamat,
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
}

class Komisi {
  final String? idPegawai;
  final double komisiHunter;
  final double komisiPerusahaan;
  final double bonusPenitip;

  Komisi({
    this.idPegawai,
    required this.komisiHunter,
    required this.komisiPerusahaan,
    required this.bonusPenitip,
  });

  factory Komisi.fromJson(Map<String, dynamic> json) {
    return Komisi(
      idPegawai: json['id_pegawai']?.toString(),
      komisiHunter: (json['komisi_hunter'] as num?)?.toDouble() ?? 0.0,
      komisiPerusahaan: (json['komisi_perusahaan'] as num?)?.toDouble() ?? 0.0,
      bonusPenitip: (json['bonus_penitip'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pegawai': idPegawai,
      'komisi_hunter': komisiHunter,
      'komisi_perusahaan': komisiPerusahaan,
      'bonus_penitip': bonusPenitip,
    };
  }
}