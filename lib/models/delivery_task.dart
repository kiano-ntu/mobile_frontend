// File: lib/models/delivery_task.dart

import 'package:flutter/material.dart';

class DeliveryTask {
  final String id;
  final String orderId;
  final String productName;
  final String customerName;
  final String? customerPhone;
  final String deliveryAddress;
  final String deliveryDate;
  final String? deliveryTime;
  final String status;
  final String totalAmount;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final String? paymentMethod;
  final bool isPriority;

  DeliveryTask({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.customerName,
    this.customerPhone,
    required this.deliveryAddress,
    required this.deliveryDate,
    this.deliveryTime,
    required this.status,
    required this.totalAmount,
    this.notes,
    this.createdAt,
    this.completedAt,
    this.paymentMethod,
    this.isPriority = false,
  });

  factory DeliveryTask.fromJson(Map<String, dynamic> json) {
    try {
      // ⭐ DEBUG: Print raw data untuk debugging
      print('🔍 Parsing DeliveryTask from JSON:');
      print('📄 Keys: ${json.keys.toList()}');
      
      return DeliveryTask(
        // ⭐ SESUAI DATABASE: id_pemesanan adalah primary key
        id: _safeGetString(json, 'id_pemesanan', 'unknown_id'),
        orderId: _safeGetString(json, 'id_pemesanan', 'unknown_order'),
        
        // ⭐ MAPPING LANGSUNG dari Laravel response (sudah di-transform)
        productName: _safeGetString(json, 'nama_produk', 'Produk Tidak Diketahui'),
        customerName: _safeGetString(json, 'nama_pembeli', 'Pembeli Tidak Diketahui'),
        customerPhone: _safeGetString(json, 'noTelp_pembeli'), // bisa null
        
        // ⭐ ALAMAT LENGKAP yang sudah disiapkan Laravel
        deliveryAddress: _safeGetString(json, 'alamat_lengkap', 'Alamat tidak tersedia'),
        
        // ⭐ SESUAI DATABASE: kolom tanggal_kirim di tabel pemesanan
        deliveryDate: _safeGetString(json, 'tanggal_kirim') ?? 
                     _safeGetString(json, 'tanggal_pesan') ?? 
                     DateTime.now().toString().split(' ')[0],
        deliveryTime: _safeGetString(json, 'waktu_kirim'),
        
        // ⭐ SESUAI DATABASE: status_pengiriman di tabel pemesanan
        status: _safeGetString(json, 'status_pengiriman', 'Disiapkan'),
        
        // ⭐ SESUAI DATABASE: total_bayar di tabel pemesanan
        totalAmount: _formatCurrency(_safeGetValue(json, 'total_bayar')),
        
        notes: _safeGetString(json, 'catatan_pengiriman') ?? 
               _safeGetString(json, 'catatan'),
        createdAt: _parseDateTime(_safeGetString(json, 'tanggal_pesan')),
        completedAt: _parseDateTime(_safeGetString(json, 'tanggal_ambil')),
        paymentMethod: _safeGetString(json, 'mode_pengiriman'), // kurir/ambil sendiri
        isPriority: _safeGetBool(json, 'is_priority', false),
      );
    } catch (e) {
      print('❌ Error parsing DeliveryTask: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  // ⭐ HELPER METHODS untuk safely extract data
  static String _safeGetString(Map<String, dynamic> json, String key, [String? defaultValue]) {
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

  static dynamic _safeGetValue(Map<String, dynamic> json, String key) {
    try {
      return json[key];
    } catch (e) {
      return null;
    }
  }

  static bool _safeGetBool(Map<String, dynamic> json, String key, bool defaultValue) {
    try {
      final value = json[key];
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is int) return value == 1;
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
      'id_pemesanan': id,
      'order_id': orderId,
      'product_name': productName,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'delivery_date': deliveryDate,
      'delivery_time': deliveryTime,
      'status': status,
      'total_amount': totalAmount,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'payment_method': paymentMethod,
      'is_priority': isPriority,
    };
  }

  DeliveryTask copyWith({
    String? id,
    String? orderId,
    String? productName,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    String? deliveryDate,
    String? deliveryTime,
    String? status,
    String? totalAmount,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
    String? paymentMethod,
    bool? isPriority,
  }) {
    return DeliveryTask(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productName: productName ?? this.productName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPriority: isPriority ?? this.isPriority,
    );
  }

  // Helper methods untuk status
  bool get isCompleted => status == 'Selesai';
  bool get isInProgress => status == 'Dikirim';
  bool get isPending => status == 'Disiapkan';
  bool get hasArrived => status == 'Sampai';

  String get formattedDeliveryDate {
    try {
      final date = DateTime.parse(deliveryDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return deliveryDate;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'Disiapkan':
        return 'Siap Dikirim';
      case 'Dikirim':
        return 'Dalam Perjalanan';
      case 'Sampai':
        return 'Telah Sampai';
      case 'Selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  // Get color for status
  Color get statusColor {
    switch (status) {
      case 'Disiapkan':
        return const Color(0xFF6B7280); // Grey
      case 'Dikirim':
        return const Color(0xFFF59E0B); // Amber
      case 'Sampai':
        return const Color(0xFF3B82F6); // Blue
      case 'Selesai':
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF6B7280); // Grey
    }
  }

  // ⭐ GET NEXT AVAILABLE STATUS untuk update
  String? get nextStatus {
    switch (status) {
      case 'Disiapkan':
        return 'Dikirim';
      case 'Dikirim':
        return 'Sampai';
      case 'Sampai':
        return 'Selesai';
      case 'Selesai':
        return null; // Sudah selesai
      default:
        return null;
    }
  }

  // Get available next statuses for dropdown
  List<String> get availableNextStatuses {
    switch (status) {
      case 'Disiapkan':
        return ['Dikirim'];
      case 'Dikirim':
        return ['Sampai'];
      case 'Sampai':
        return ['Selesai'];
      case 'Selesai':
        return []; // No more status changes
      default:
        return [];
    }
  }

  // Check if status can be updated
  bool get canUpdateStatus => availableNextStatuses.isNotEmpty;

  // Get button text for next action
  String get actionButtonText {
    switch (status) {
      case 'Disiapkan':
        return 'Mulai Kirim';
      case 'Dikirim':
        return 'Sampai Tujuan';
      case 'Sampai':
        return 'Selesaikan';
      case 'Selesai':
        return 'Selesai';
      default:
        return 'Update Status';
    }
  }

  // Get icon for status
  IconData get statusIcon {
    switch (status) {
      case 'Disiapkan':
        return Icons.inventory;
      case 'Dikirim':
        return Icons.local_shipping;
      case 'Sampai':
        return Icons.location_on;
      case 'Selesai':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  // Static helper method for currency formatting
  static String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    
    try {
      final numAmount = amount is String ? double.parse(amount) : amount.toDouble();
      return 'Rp ${numAmount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    } catch (e) {
      return 'Rp $amount';
    }
  }

  @override
  String toString() {
    return 'DeliveryTask{id: $id, orderId: $orderId, productName: $productName, status: $status, phone: $customerPhone, address: $deliveryAddress}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryTask &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}