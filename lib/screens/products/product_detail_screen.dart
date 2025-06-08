import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../utils/colors.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  late List<String> _productImages;

  @override
  void initState() {
    super.initState();
    _initializeImages();
  }

  void _initializeImages() {
    List<String> images = [];
    
    if (widget.product.gambarProduk.isNotEmpty) {
      if (widget.product.gambarProduk.contains(',')) {
        final imageNames = widget.product.gambarProduk.split(',');
        for (String imageName in imageNames) {
          final trimmedName = imageName.trim();
          if (trimmedName.isNotEmpty) {
            final imageUrl = 'http://192.168.213.124:8000/storage/products/$trimmedName';
            images.add(imageUrl);
          }
        }
      } else {
        final imageUrl = 'http://192.168.213.124:8000/storage/products/${widget.product.gambarProduk.trim()}';
        images.add(imageUrl);
      }
    }
    
    if (images.isEmpty) {
      _productImages = [
        "https://source.unsplash.com/800x600/?${widget.product.kategoriProduk}&v=1",
      ];
    } else {
      _productImages = images;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                _buildProductInfo(),
                _buildPenitipInfo(),
                _buildProductDetails(),
                _buildDescription(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.greyDark,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.greyDark,
            size: 20,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur share akan segera hadir!')),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.share,
              color: AppColors.greyDark,
              size: 20,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur favorit akan segera hadir!')),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_border,
              color: AppColors.greyDark,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 350,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: _productImages.length,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                child: Image.network(
                  _productImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.greyLight,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.grey,
                        size: 60,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.greyLight,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          if (_productImages.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _productImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImageIndex == index ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentImageIndex == index
                          ? AppColors.primary
                          : AppColors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          
          if (_productImages.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${_productImages.length}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.getFormattedPrice(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            widget.product.namaProduk,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              if (widget.product.ratingProduk > 0) ...[
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.product.ratingProduk.toDouble()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.product.isAvailable 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.product.statusProduk,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.product.isAvailable 
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPenitipInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penitip',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getPenitipName(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildDetailRow('Kategori', widget.product.kategoriProduk),
          _buildDetailRow('Berat', '${widget.product.beratProduk} kg'),
          _buildGaransiRow(),
          
          if (widget.product.ratingProduk > 0)
            _buildDetailRow('Rating', '${widget.product.ratingProduk}/5'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.greyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaransiRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 80,
            child: Text(
              'Garansi',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGaransiBadgeColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getGaransiStatusText(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                
                if (widget.product.garansi != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Hingga: ${_formatDate(widget.product.garansi!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            widget.product.deskripsiProduk,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.greyDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getPenitipName() {
    return widget.product.getPenitipName();
  }

  String _getGaransiStatusText() {
    if (widget.product.garansi == null) {
      return 'Tidak Tersedia';
    }
    
    final now = DateTime.now();
    final garansiDate = widget.product.garansi!;
    
    if (now.isAfter(garansiDate)) {
      return 'Hangus';
    } else {
      return 'Tersedia';
    }
  }

  Color _getGaransiBadgeColor() {
    if (widget.product.garansi == null) {
      return AppColors.grey;
    }
    
    final now = DateTime.now();
    final garansiDate = widget.product.garansi!;
    
    if (now.isAfter(garansiDate)) {
      return AppColors.error;
    } else {
      return AppColors.success;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}