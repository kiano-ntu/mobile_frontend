// File: lib/models/merchandise.dart

class Merchandise {
  final String idMerch;
  final String namaMerch;
  final int hargaPoin;
  final int stok;
  final String? gambarMerch; // Added for image

  Merchandise({
    required this.idMerch,
    required this.namaMerch,
    required this.hargaPoin,
    required this.stok,
    this.gambarMerch,
  });

  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      idMerch: json['id_merch'] ?? '',
      namaMerch: json['nama_merch'] ?? '',
      hargaPoin: json['harga_poin'] ?? 0,
      stok: json['stok'] ?? 0,
      gambarMerch: json['gambar_merch'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_merch': idMerch,
      'nama_merch': namaMerch,
      'harga_poin': hargaPoin,
      'stok': stok,
      'gambar_merch': gambarMerch,
    };
  }

  // Helper method to get image URL
  String getImageUrl() {
    if (gambarMerch == null || gambarMerch!.isEmpty) {
      return "https://source.unsplash.com/400x400/?gift,merchandise,reward";
    }
    
    // Construct the full URL using your Laravel storage setup
    return 'http://192.168.213.225:8000/storage/merchs/${gambarMerch!.trim()}';
  }

  // Helper method to check if merchandise is available
  bool get isAvailable => stok > 0;

  // Helper method to format price in points
  String getFormattedPrice() {
    return '$hargaPoin Poin';
  }

  @override
  String toString() {
    return 'Merchandise{idMerch: $idMerch, namaMerch: $namaMerch, hargaPoin: $hargaPoin, stok: $stok}';
  }
}