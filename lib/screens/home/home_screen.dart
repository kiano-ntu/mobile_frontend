import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/colors.dart';
import '../../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _topSellers = [];
  bool _isLoadingTopSellers = true;

  @override
  void initState() {
    super.initState();
    _loadTopSellers();
  }

  Future<void> _loadTopSellers() async {
    setState(() {
      _isLoadingTopSellers = true;
    });

    try {
      print('🔍 Loading top sellers...');

      final client = http.Client();
      final response = await client.get(
        Uri.parse(
            'http://10.0.2.2:8000/api/public/mobile/top-sellers-simple?limit=5'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response headers: ${response.headers}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('📊 Response data: $responseData');

        if (responseData['success'] == true) {
          final sellersData = responseData['data'] as List;
          setState(() {
            _topSellers = List<Map<String, dynamic>>.from(sellersData);
            _isLoadingTopSellers = false;
          });
          print('✅ Top sellers loaded: ${_topSellers.length} items');
          print(
              '✅ First seller: ${_topSellers.isNotEmpty ? _topSellers[0] : 'No data'}');
        } else {
          print('❌ API returned success: false');
          print('❌ Message: ${responseData['message']}');
          setState(() {
            _isLoadingTopSellers = false;
          });
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        setState(() {
          _isLoadingTopSellers = false;
        });
      }
    } catch (e) {
      print('❌ Exception: $e');
      print('❌ Exception type: ${e.runtimeType}');
      setState(() {
        _isLoadingTopSellers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _loadTopSellers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              _buildHeroSection(),

              // Category Section
              _buildCategorySection(),

              // How It Works Section
              _buildHowItWorksSection(),

              // Top Sellers Section
              _buildTopSellersSection(),

              // Why Choose Us Section
              _buildWhyChooseUsSection(),

              // Contact Section
              _buildContactSection(),

              // Bottom spacing
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Name
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'ReUse',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                TextSpan(
                  text: 'Mart',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          // Login Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        // Pattern overlay
        image: DecorationImage(
          image: NetworkImage(
              'data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%2310b981" fill-opacity="0.2"%3E%3Cpath d="M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E'),
          repeat: ImageRepeat.repeat,
          opacity: 0.3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Beri Barang Bekas Anda',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                height: 1.3,
              ),
            ),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Kesempatan Kedua',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ReUseMart adalah platform jual beli barang bekas berkualitas yang mengusung konsep ekonomi sirkular untuk masa depan yang lebih berkelanjutan.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Explore products action
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Jelajahi Produk'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {
        'name': 'Elektronik & Gadget',
        'icon': Icons.laptop_mac,
      },
      {
        'name': 'Pakaian & Aksesori',
        'icon': Icons.checkroom,
      },
      {
        'name': 'Perabotan Rumah',
        'icon': Icons.chair,
      },
      {
        'name': 'Buku & Alat Tulis',
        'icon': Icons.book,
      },
    ];

    return Container(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kategori Produk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Temukan berbagai jenis barang bekas berkualitas sesuai kebutuhan Anda',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    // Category tap action
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category['icon'] as IconData,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category['name'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      color: AppColors.greyLight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cara Kerja ReUseMart',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Proses jual beli barang bekas yang aman, mudah, dan tepercaya',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildStepCard(
              step: '1',
              title: 'Titipkan Barang',
              description:
                  'Datang ke ReUseMart untuk menitipkan barang bekas berkualitas Anda. Tim kami akan melakukan pengecekan kualitas barang.',
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              step: '2',
              title: 'Kami Pasarkan',
              description:
                  'Tim ReUseMart akan memasarkan barang Anda melalui platform kami. Pembeli dapat melihat dan membeli barang secara online.',
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              step: '3',
              title: 'Terima Keuntungan',
              description:
                  'Setelah barang terjual, Anda akan menerima keuntungan dari penjualan. Jika tidak terjual dalam 30 hari, Anda dapat mengambil kembali barang.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellersSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏆 Top Sellers',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Penjual dengan saldo terbesar',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Top Sellers Content
          if (_isLoadingTopSellers)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: LoadingWidget(message: 'Memuat top sellers...'),
            )
          else if (_topSellers.isEmpty)
            Container(
              padding: const EdgeInsets.all(40.0),
              child: const Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada top sellers',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.greyDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: _topSellers
                    .map((seller) => _buildTopSellerCard(seller))
                    .toList(),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopSellerCard(Map<String, dynamic> seller) {
    final rank = seller['rank'] as int;
    final rankColor = _getRankColor(rank);
    final rankIcon = _getRankIcon(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: rank <= 3 ? Border.all(color: rankColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Text(
                      rankIcon,
                      style: const TextStyle(fontSize: 18),
                    )
                  : Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Seller Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller['nama_penitip'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  seller['formatted_saldo'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Trophy for top 3
          if (rank <= 3)
            Icon(
              Icons.emoji_events,
              color: rankColor,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUsSection() {
    final features = [
      {
        'icon': Icons.verified,
        'title': 'Kualitas Terjamin',
        'description':
            'Setiap barang melewati proses Quality Control ketat untuk memastikan kualitasnya.',
      },
      {
        'icon': Icons.eco,
        'title': 'Mendukung Lingkungan',
        'description':
            'Dengan membeli barang bekas, Anda turut berkontribusi dalam upaya pelestarian lingkungan.',
      },
      {
        'icon': Icons.security,
        'title': 'Transaksi Aman',
        'description':
            'Sistem pembayaran dan pengiriman yang aman dan terpercaya untuk semua transaksi.',
      },
      {
        'icon': Icons.volunteer_activism,
        'title': 'Program Donasi',
        'description':
            'Barang yang tidak terjual dapat disumbangkan ke organisasi sosial yang membutuhkan.',
      },
    ];

    return Container(
      color: AppColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mengapa Memilih ReUseMart',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Platform jual beli barang bekas yang aman, mudah, dan terpercaya',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feature['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Siap Bergabung dengan ReUseMart?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Jual barang bekas berkualitas Anda atau temukan barang yang Anda butuhkan dengan harga terjangkau.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Explore products action
                },
                icon: const Icon(Icons.search),
                label: const Text('Jelajahi Produk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.white),
            const SizedBox(height: 16),
            const Text(
              'Hubungi Kami',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              icon: Icons.location_on,
              text: 'Jl. Green Eco Park No. 456 Yogyakarta',
            ),
            _buildContactItem(
              icon: Icons.email,
              text: 'info@reusemart.com',
            ),
            _buildContactItem(
              icon: Icons.phone,
              text: '(0274) 123456',
            ),
            _buildContactItem(
              icon: Icons.access_time,
              text: 'Senin - Sabtu: 08.00 - 20.00',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }

  String _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
