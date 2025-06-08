import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/merchandise.dart';
import '../../services/merchandise_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import 'merchandise_detail_screen.dart';
import '../pembeli/penukaran_cart_screen.dart';

class MerchandiseCatalogScreen extends StatefulWidget {
  const MerchandiseCatalogScreen({Key? key}) : super(key: key);

  @override
  State<MerchandiseCatalogScreen> createState() => _MerchandiseCatalogScreenState();
}

class _MerchandiseCatalogScreenState extends State<MerchandiseCatalogScreen> {
  List<Merchandise> _merchandises = [];
  Map<String, int> _cart = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMerchandise();
  }

  Future<void> _loadMerchandise() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await MerchandiseService.getAllMerchandise();
      
      if (response.success && response.data != null) {
        setState(() {
          _merchandises = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat merchandise: $e';
        _isLoading = false;
      });
    }
  }

  void _addToCart(String merchandiseId) {
    final merchandise = _merchandises.firstWhere((m) => m.idMerch == merchandiseId);
    final currentQuantity = _cart[merchandiseId] ?? 0;
    
    if (currentQuantity < merchandise.stok) {
      setState(() {
        _cart[merchandiseId] = currentQuantity + 1;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_truncateName(merchandise.namaMerch)} ditambahkan ke keranjang'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${_truncateName(merchandise.namaMerch)} tidak mencukupi'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeFromCart(String merchandiseId) {
    final currentQuantity = _cart[merchandiseId] ?? 0;
    
    if (currentQuantity > 1) {
      setState(() {
        _cart[merchandiseId] = currentQuantity - 1;
      });
    } else if (currentQuantity == 1) {
      setState(() {
        _cart.remove(merchandiseId);
      });
    }
  }

  int get _totalCartItems {
    return _cart.values.fold(0, (sum, quantity) => sum + quantity);
  }

  int get _totalCartPoints {
    int total = 0;
    _cart.forEach((merchandiseId, quantity) {
      final merchandise = _merchandises.firstWhere((m) => m.idMerch == merchandiseId);
      total += merchandise.hargaPoin * quantity;
    });
    return total;
  }

  String _truncateName(String name) {
    if (name.length <= 20) return name;
    return '${name.substring(0, 20)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Merchandise'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${authProvider.poinPembeli} Poin',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _cart.isNotEmpty ? _buildCartFAB() : null,
    );
  }

  Widget _buildCartFAB() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final canAffordCart = authProvider.poinPembeli >= _totalCartPoints;
        
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PenukaranCartScreen(
                  cartItems: _cart,
                  merchandises: _merchandises,
                  onCartUpdated: (updatedCart) {
                    setState(() {
                      _cart = updatedCart;
                    });
                  },
                ),
              ),
            );
          },
          backgroundColor: canAffordCart ? AppColors.primary : Colors.red,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.shopping_cart),
          label: Text('$_totalCartItems item${_totalCartItems > 1 ? 's' : ''}\n$_totalCartPoints poin'),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMerchandise,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_merchandises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada merchandise tersedia',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMerchandise,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tukar Poin Anda',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Dapatkan merchandise eksklusif dengan poin yang Anda kumpulkan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Merchandise Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Merchandise Tersedia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65, // Changed to 0.65 for even more height
                    ),
                    itemCount: _merchandises.length,
                    itemBuilder: (context, index) {
                      final merchandise = _merchandises[index];
                      return _buildMerchandiseCard(merchandise);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchandiseCard(Merchandise merchandise) {
    final cartQuantity = _cart[merchandise.idMerch] ?? 0;
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userPoints = authProvider.poinPembeli;
        final canAfford = userPoints >= merchandise.hargaPoin;
        final isAvailable = merchandise.stok > 0;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MerchandiseDetailScreen(
                  merchandise: merchandise,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section
                Expanded(
                  flex: 5, // Increased to 5 for more image space
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey,
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: merchandise.gambarMerch != null && merchandise.gambarMerch!.isNotEmpty
                              ? Image.network(
                                  merchandise.getImageUrl(),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        // Stock Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAvailable ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isAvailable ? 'Stok: ${merchandise.stok}' : 'Stok: 0',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content Section - Fixed height with proper constraints
                Container(
                  height: 80, // Reduced from 90 to 80
                  padding: const EdgeInsets.all(6), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name - Fixed height with proper overflow handling
                      SizedBox(
                        height: 28, // Reduced from 32 to 28
                        child: Text(
                          merchandise.namaMerch,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11, // Reduced from 12 to 11
                            color: AppColors.primary,
                            height: 1.1, // Reduced line height
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 2), // Reduced spacing
                      
                      // Points Price
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber, size: 12), // Smaller icon
                          const SizedBox(width: 2),
                          Text(
                            '${merchandise.hargaPoin} Poin',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: canAfford ? AppColors.primary : Colors.red,
                              fontSize: 10, // Reduced from 11 to 10
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Action Button or Cart Controls
                      if (cartQuantity == 0)
                        SizedBox(
                          width: double.infinity,
                          height: 24, // Reduced from 28 to 24
                          child: ElevatedButton(
                            onPressed: isAvailable && canAfford 
                              ? () => _addToCart(merchandise.idMerch)
                              : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAvailable && canAfford
                                  ? AppColors.primary
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              !isAvailable
                                  ? 'Habis'
                                  : !canAfford
                                      ? 'Poin Kurang'
                                      : 'Tambah',
                              style: const TextStyle(
                                fontSize: 9, // Reduced from 10 to 9
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 24, // Reduced from 28 to 24
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _removeFromCart(merchandise.idMerch),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                  child: Container(
                                    height: 22, // Reduced from 26 to 22
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        bottomLeft: Radius.circular(5),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 12, // Reduced from 14 to 12
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 22, // Reduced from 26 to 22
                                  color: AppColors.white,
                                  child: Center(
                                    child: Text(
                                      '$cartQuantity',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11, // Reduced from 12 to 11
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: cartQuantity < merchandise.stok
                                      ? () => _addToCart(merchandise.idMerch)
                                      : null,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                  child: Container(
                                    height: 22, // Reduced from 26 to 22
                                    decoration: BoxDecoration(
                                      color: cartQuantity < merchandise.stok
                                          ? AppColors.primary
                                          : Colors.grey,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 12, // Reduced from 14 to 12
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}