import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  // Get available products (status = "Tersedia")
  static Future<ApiResponse<List<Product>>> getAvailableProducts({
    int limit = 10,
    int page = 1,
  }) async {
    try {
      print('🛍️ Fetching available products (limit: $limit, page: $page)');
      
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/produk/public?limit=$limit&page=$page',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final List<dynamic> productsJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        
        final List<Product> products = productsJson
            .map((json) => Product.fromJson(json))
            .where((product) => product.isAvailable)
            .toList();

        print('✅ Successfully fetched ${products.length} available products');
        return ApiResponse.success(products, message: response.message);
      } else {
        print('❌ Failed to fetch products: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error fetching available products: $e');
      return ApiResponse.error('Gagal mengambil data produk: $e');
    }
  }

  // 🔥 FIXED: Get featured products for home screen - USE REAL API INSTEAD OF MOCK
  static Future<ApiResponse<List<Product>>> getFeaturedProducts({
    int limit = 4,
  }) async {
    try {
      print('⭐ Fetching featured products from Laravel API (limit: $limit)');
      
      // Call your Laravel API endpoint
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/produk/public?limit=$limit',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final List<dynamic> productsJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        
        final List<Product> products = productsJson
            .map((json) => Product.fromJson(json))
            .where((product) => product.isAvailable)
            .take(limit)
            .toList();

        print('⭐ Successfully fetched ${products.length} featured products from Laravel API');
        return ApiResponse.success(products, message: response.message);
      } else {
        print('❌ Failed to fetch featured products: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error fetching featured products: $e');
      return ApiResponse.error('Gagal mengambil produk unggulan: $e');
    }
  }

  // Get product by ID
  static Future<ApiResponse<Product>> getProductById(String productId) async {
    try {
      print('🔍 Fetching product by ID: $productId');
      
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/produk/public/$productId',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final product = Product.fromJson(response.data);
        
        print('✅ Successfully fetched product: ${product.namaProduk}');
        return ApiResponse.success(product, message: response.message);
      } else {
        print('❌ Failed to fetch product: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error fetching product by ID: $e');
      return ApiResponse.error('Gagal mengambil detail produk: $e');
    }
  }

  // Search products
  static Future<ApiResponse<List<Product>>> searchProducts({
    required String query,
    String? category,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      print('🔎 Searching products: "$query" (category: $category)');
      
      String endpoint = '${AppConfig.apiUrl}/produk/search?q=$query&limit=$limit&page=$page&status=Tersedia';
      
      if (category != null && category.isNotEmpty) {
        endpoint += '&category=$category';
      }
      
      final response = await ApiService.get(endpoint, requiresAuth: false);

      if (response.success && response.data != null) {
        final List<dynamic> productsJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        
        final List<Product> products = productsJson
            .map((json) => Product.fromJson(json))
            .where((product) => product.isAvailable)
            .toList();

        print('🔎 Found ${products.length} products matching "$query"');
        return ApiResponse.success(products, message: response.message);
      } else {
        print('❌ Failed to search products: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error searching products: $e');
      return ApiResponse.error('Gagal mencari produk: $e');
    }
  }

  // Get products by category
  static Future<ApiResponse<List<Product>>> getProductsByCategory({
    required String category,
    int limit = 20,
    int page = 1,
  }) async {
    try {
      print('📂 Fetching products by category: $category');
      
      final response = await ApiService.get(
        '${AppConfig.apiUrl}/produk/public?category=$category&limit=$limit&page=$page&status=Tersedia',
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final List<dynamic> productsJson = response.data is List 
            ? response.data 
            : response.data['data'] ?? [];
        
        final List<Product> products = productsJson
            .map((json) => Product.fromJson(json))
            .where((product) => product.isAvailable)
            .toList();

        print('📂 Found ${products.length} products in category: $category');
        return ApiResponse.success(products, message: response.message);
      } else {
        print('❌ Failed to fetch products by category: ${response.message}');
        return ApiResponse.error(response.message);
      }
    } catch (e) {
      print('❌ Error fetching products by category: $e');
      return ApiResponse.error('Gagal mengambil produk kategori: $e');
    }
  }
}