// File: lib/screens/pembeli/penukaran_cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/merchandise.dart';
import '../../services/mobile_penukaran_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import 'penukaran_success_screen.dart';

class PenukaranCartScreen extends StatefulWidget {
  final Map<String, int> cartItems;
  final List<Merchandise> merchandises;
  final Function(Map<String, int>) onCartUpdated;

  const PenukaranCartScreen({
    Key? key,
    required this.cartItems,
    required this.merchandises,
    required this.onCartUpdated,
  }) : super(key: key);

  @override
  State<PenukaranCartScreen> createState() => _PenukaranCartScreenState();
}

class _PenukaranCartScreenState extends State<PenukaranCartScreen> {
  late Map<String, int> _cart;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cart = Map.from(widget.cartItems);
  }

  void _updateQuantity(String merchandiseId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cart.remove(merchandiseId);
      } else {
        final merchandise = widget.merchandises.firstWhere((m) => m.idMerch == merchandiseId);
        if (newQuantity <= merchandise.stok) {
          _cart[merchandiseId] = newQuantity;
        }
      }
    });
    widget.onCartUpdated(_cart);
  }

  int get _totalItems {
    return _cart.values.fold(0, (sum, quantity) => sum + quantity);
  }

  int get _totalPoints {
    int total = 0;
    _cart.forEach((merchandiseId, quantity) {
      final merchandise = widget.merchandises.firstWhere((m) => m.idMerch == merchandiseId);
      total += merchandise.hargaPoin * quantity;
    });
    return total;
  }

  Future<void> _processExchange() async {
    final authProvider = context.read<AuthProvider>();
    
    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Prepare exchange items
      final List<Map<String, dynamic>> items = _cart.entries
          .map((entry) => {
                'id_merch': entry.key,
                'jumlah': entry.value,
              })
          .toList();

      final response = await MobilePenukaranService.exchangePointsMobile(
        idPembeli: authProvider.user!.id,
        items: items,
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (response.success && response.data != null) {
          // Update user points
          await authProvider.refreshUser();
          
          // Clear cart
          widget.onCartUpdated({});
          
          // Navigate to proper success screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PenukaranSuccessScreen(
                exchangeData: response.data!,
              ),
            ),
          );
        } else {
          _showErrorDialog(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorDialog('Gagal memproses penukaran: $e');
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Anda akan menukar:'),
            const SizedBox(height: 8),
            ..._cart.entries.map((entry) {
              final merchandise = widget.merchandises.firstWhere((m) => m.idMerch == entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• ${merchandise.namaMerch} x${entry.value}'),
              );
            }),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Poin:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$_totalPoints Poin',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.pembeliColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Penukaran tidak dapat dibatalkan setelah dikonfirmasi.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pembeliColor,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memproses penukaran poin...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Penukaran'),
        backgroundColor: AppColors.pembeliColor,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _cart.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: _cart.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.grey),
          SizedBox(height: 16),
          Text(
            'Keranjang penukaran kosong',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.greyDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan merchandise dari katalog',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        // Points Summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pembeliColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.pembeliColor.withOpacity(0.3)),
          ),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final userPoints = authProvider.poinPembeli;
              final canAfford = userPoints >= _totalPoints;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Poin Anda:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$userPoints Poin',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Penukaran:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '$_totalPoints Poin',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.pembeliColor,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sisa Poin:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${userPoints - _totalPoints} Poin',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: canAfford ? AppColors.pembeliColor : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (!canAfford) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Poin Anda tidak mencukupi untuk penukaran ini',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),

        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cart.length,
            itemBuilder: (context, index) {
              final entry = _cart.entries.elementAt(index);
              final merchandise = widget.merchandises.firstWhere((m) => m.idMerch == entry.key);
              return _buildCartItem(merchandise, entry.value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(Merchandise merchandise, int quantity) {
    final subtotal = merchandise.hargaPoin * quantity;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Merchandise Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.greyLight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: merchandise.gambarMerch != null && merchandise.gambarMerch!.isNotEmpty
                    ? Image.network(
                        merchandise.getImageUrl(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, color: AppColors.grey);
                        },
                      )
                    : const Icon(Icons.image_not_supported, color: AppColors.grey),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Merchandise Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchandise.namaMerch,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${merchandise.hargaPoin} Poin/item',
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: $subtotal Poin',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.pembeliColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _updateQuantity(merchandise.idMerch, quantity - 1),
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: quantity < merchandise.stok
                          ? () => _updateQuantity(merchandise.idMerch, quantity + 1)
                          : null,
                      icon: Icon(
                        Icons.add_circle,
                        color: quantity < merchandise.stok ? AppColors.pembeliColor : AppColors.grey,
                      ),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                Text(
                  'Stok: ${merchandise.stok}',
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final canAfford = authProvider.poinPembeli >= _totalPoints;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_totalItems item${_totalItems > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: AppColors.greyDark,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Total: $_totalPoints Poin',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: AppColors.pembeliColor,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: canAfford ? _processExchange : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? AppColors.pembeliColor : AppColors.grey,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        canAfford ? 'Tukar Sekarang' : 'Poin Tidak Cukup',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}