// File: lib/screens/hunter/hunter_komisi_detail_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/komisi_service.dart';

class HunterKomisiDetailScreen extends StatefulWidget {
  final String idPegawai;
  final String totalKomisiFormatted;
  final double totalKomisi;

  const HunterKomisiDetailScreen({
    Key? key,
    required this.idPegawai,
    required this.totalKomisiFormatted,
    required this.totalKomisi,
  }) : super(key: key);

  @override
  State<HunterKomisiDetailScreen> createState() => _HunterKomisiDetailScreenState();
}

class _HunterKomisiDetailScreenState extends State<HunterKomisiDetailScreen> {
  List<dynamic> komisiDetails = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadKomisiDetails();
  }

  Future<void> _loadKomisiDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await KomisiService.getKomisiDetails(widget.idPegawai);
      
      setState(() {
        if (result['success'] == true) {
          komisiDetails = result['komisi_details'] ?? [];
        } else {
          error = result['error'] ?? 'Gagal memuat detail komisi';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('❌ Error loading komisi details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyLight,
      appBar: AppBar(
        backgroundColor: AppColors.hunterColor,
        foregroundColor: AppColors.white,
        title: const Text(
          'Detail & Riwayat Komisi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
        ),
        actions: [
          IconButton(
            onPressed: _loadKomisiDetails,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(),
          
          // Commission Table
          Expanded(
            child: _buildCommissionTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Komisi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monetization_on_outlined,
                  size: 32,
                  color: AppColors.success,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.totalKomisiFormatted,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    const Text(
                      'Total Komisi Yang Diperoleh',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    Text(
                      'Dari ${komisiDetails.length} transaksi',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionTable() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (error != null) {
      return _buildErrorState();
    }

    if (komisiDetails.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.greyLight,
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              'Riwayat Komisi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
          ),
          
          // Table Content
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: MediaQuery.of(context).size.width - 32,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Table Headers
                      _buildTableHeader(),
                      
                      // Table Rows
                      ...komisiDetails.asMap().entries.map((entry) {
                        int index = entry.key;
                        dynamic komisi = entry.value;
                        return _buildTableRow(komisi, index);
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.hunterColor.withOpacity(0.1),
        border: const Border(
          bottom: BorderSide(
            color: AppColors.greyLight,
            width: 1,
          ),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'ID Komisi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.hunterColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ID Pemesanan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.hunterColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Komisi Yang Didapatkan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.hunterColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic komisi, int index) {
    final isEven = index % 2 == 0;
    final komisiAmount = (komisi['komisi_hunter'] ?? 0).toDouble();
    final formattedKomisi = KomisiService.formatCurrency(komisiAmount);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isEven ? AppColors.white : AppColors.greyLight.withOpacity(0.5),
        border: const Border(
          bottom: BorderSide(
            color: AppColors.greyLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // ID Komisi
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  komisi['id_komisi'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
                if (komisi['tanggal_pesan'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(komisi['tanggal_pesan']),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // ID Pemesanan
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  komisi['id_pemesanan'] ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
                if (komisi['nama_produk'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    komisi['nama_produk'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Komisi Amount
          Expanded(
            flex: 3,
            child: Text(
              formattedKomisi,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.hunterColor),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat detail komisi...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              error ?? 'Gagal memuat detail komisi',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _loadKomisiDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hunterColor,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.grey.withOpacity(0.5),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Belum Ada Komisi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Anda belum memiliki riwayat komisi.\nMulai bekerja untuk mendapatkan komisi!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hunterColor,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '-';
    
    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return '-';
      }
      
      // Format to Indonesian date format
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '-';
    }
  }
}