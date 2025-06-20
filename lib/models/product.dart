class Product {
  final String idProduk;
  final String idPenitip;
  final String namaProduk;
  final String gambarProduk;
  final String kategoriProduk;
  final DateTime? garansi;
  final String deskripsiProduk;
  final double beratProduk;
  final double hargaProduk;
  final String statusProduk;
  final int ratingProduk;
  
  // 🔥 NEW: Add penitip data
  final Map<String, dynamic>? penitip;

  Product({
    required this.idProduk,
    required this.idPenitip,
    required this.namaProduk,
    required this.gambarProduk,
    required this.kategoriProduk,
    this.garansi,
    required this.deskripsiProduk,
    required this.beratProduk,
    required this.hargaProduk,
    required this.statusProduk,
    required this.ratingProduk,
    this.penitip, // 🔥 NEW: Add penitip parameter
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      idProduk: json['id_produk'] ?? '',
      idPenitip: json['id_penitip'] ?? '',
      namaProduk: json['nama_produk'] ?? '',
      gambarProduk: json['gambar_produk'] ?? '',
      kategoriProduk: json['kategori_produk'] ?? '',
      garansi: json['garansi'] != null ? DateTime.tryParse(json['garansi']) : null,
      deskripsiProduk: json['deskripsi_produk'] ?? '',
      beratProduk: (json['berat_produk'] ?? 0).toDouble(),
      hargaProduk: (json['harga_produk'] ?? 0).toDouble(),
      statusProduk: json['status_produk'] ?? '',
      ratingProduk: json['rating_produk'] ?? 0,
      penitip: json['penitip'], // 🔥 NEW: Parse penitip data
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'id_penitip': idPenitip,
      'nama_produk': namaProduk,
      'gambar_produk': gambarProduk,
      'kategori_produk': kategoriProduk,
      'garansi': garansi?.toIso8601String(),
      'deskripsi_produk': deskripsiProduk,
      'berat_produk': beratProduk,
      'harga_produk': hargaProduk,
      'status_produk': statusProduk,
      'rating_produk': ratingProduk,
      'penitip': penitip, // 🔥 NEW: Include penitip data
    };
  }

  // Helper method to get main image URL
  String getMainImageUrl() {
    if (gambarProduk.isEmpty) {
      return "https://source.unsplash.com/random/800x600/?$kategoriProduk";
    }

    // Handle comma-separated images
    if (gambarProduk.contains(',')) {
      final images = gambarProduk.split(',');
      final firstImage = images.first.trim();
      return 'http://192.168.213.225:8000/storage/products/$firstImage';
    }

    return 'http://192.168.213.225:8000/storage/products/${gambarProduk.trim()}';
  }

  // Helper method to get all image URLs
  List<String> getImageGalleryUrls() {
    List<String> images = [];
    
    if (gambarProduk.isEmpty) {
      return images;
    }

    // Handle comma-separated images like "PRD1_1.jpg, PRD1_2.jpg, PRD1_3.jpg"
    if (gambarProduk.contains(',')) {
      final imageNames = gambarProduk.split(',');
      for (String name in imageNames) {
        final trimmedName = name.trim();
        if (trimmedName.isNotEmpty) {
          images.add('http://192.168.213.225:8000/storage/products/$trimmedName');
        }
      }
    } else {
      // Single image
      images.add('http://192.168.213.225:8000/storage/products/${gambarProduk.trim()}');
    }

    return images;
  }

  // Helper method to format price
  String getFormattedPrice() {
    return 'Rp ${hargaProduk.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // Helper method to check if product is available
  bool get isAvailable => statusProduk == 'Tersedia';

  // 🔥 NEW: Helper method to get penitip name
  String getPenitipName() {
    if (penitip != null && penitip!['nama_penitip'] != null) {
      return penitip!['nama_penitip'];
    }
    return 'Unknown'; // Fallback if penitip data not available
  }

  @override
  String toString() {
    return 'Product{idProduk: $idProduk, namaProduk: $namaProduk, statusProduk: $statusProduk}';
  }
}