// File: lib/screens/dashboards/history_penitip.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/penitip_history_provider.dart';
import '../../models/penitipan_model.dart';
import '../../utils/colors.dart';

class HistoryPenitip extends StatefulWidget {
  const HistoryPenitip({Key? key}) : super(key: key);

  @override
  State<HistoryPenitip> createState() => _HistoryPenitipState();
}

class _HistoryPenitipState extends State<HistoryPenitip>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

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

  // Updated filter options based on actual database status
  final List<String> _filterOptions = [
    'Semua',
    'Tersedia',
    'Terjual',
    'Selesai',
    'Hampir Habis',
    'Menunggu Keputusan',
    'Siap Diambil',
    'Diambil Kembali',
    'Didonasikan',
    'Pesanan Diproses'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  void _loadHistory() {
    final historyProvider =
        Provider.of<PenitipHistoryProvider>(context, listen: false);
    historyProvider.loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PenitipHistoryProvider>(
      builder: (context, historyProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.greyLight,
          appBar: AppBar(
            backgroundColor: AppColors.penitipColor,
            foregroundColor: AppColors.white,
            title: const Text(
              'History Penitipan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => historyProvider.refreshHistory(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withOpacity(0.7),
              indicatorColor: AppColors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Tersedia'), // Changed from 'Aktif' to 'Tersedia'
                Tab(text: 'Selesai'),
                Tab(text: 'Perlu Tindakan'),
              ],
            ),
          ),
          body: Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilter(historyProvider),

              // Statistics Card
              _buildStatisticsCard(historyProvider),

              // Content
              Expanded(
                child: historyProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : historyProvider.errorMessage != null
                        ? _buildErrorState(historyProvider)
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildHistoryList(
                                  historyProvider.filteredHistory),
                              _buildHistoryList(historyProvider.activeProducts),
                              _buildHistoryList(
                                  historyProvider.completedProducts),
                              _buildHistoryList(
                                  historyProvider.needingDecisionProducts),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter(PenitipHistoryProvider historyProvider) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari berdasarkan ID, nama produk...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.penitipColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        historyProvider.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.penitipColor, width: 2),
              ),
            ),
            onChanged: (value) => historyProvider.setSearchQuery(value),
          ),

          const SizedBox(height: 12),

          // Filter Row
          Row(
            children: [
              // Status Filter Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter Status',
                    prefixIcon: const Icon(Icons.filter_list,
                        color: AppColors.penitipColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _filterOptions.map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });

                    if (value == 'Semua') {
                      historyProvider.setStatusFilter(null);
                    } else {
                      historyProvider.setStatusFilter(value);
                    }
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Date Filter Button
              OutlinedButton.icon(
                onPressed: () => _showDateFilter(historyProvider),
                icon:
                    const Icon(Icons.date_range, color: AppColors.penitipColor),
                label: const Text('Tanggal',
                    style: TextStyle(color: AppColors.penitipColor)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.penitipColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),

          // Active Filters Display
          if (historyProvider.startDate != null ||
              historyProvider.endDate != null ||
              historyProvider.selectedStatus != null)
            _buildActiveFilters(historyProvider),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(PenitipHistoryProvider historyProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        children: [
          if (historyProvider.selectedStatus != null)
            Chip(
              label: Text('Status: ${historyProvider.selectedStatus}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => historyProvider.setStatusFilter(null),
              backgroundColor: AppColors.penitipColor.withOpacity(0.1),
            ),
          if (historyProvider.startDate != null)
            Chip(
              label: Text('Dari: ${_formatDate(historyProvider.startDate!)}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => historyProvider.setDateRangeFilter(
                  null, historyProvider.endDate),
              backgroundColor: AppColors.penitipColor.withOpacity(0.1),
            ),
          if (historyProvider.endDate != null)
            Chip(
              label: Text('Sampai: ${_formatDate(historyProvider.endDate!)}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => historyProvider.setDateRangeFilter(
                  historyProvider.startDate, null),
              backgroundColor: AppColors.penitipColor.withOpacity(0.1),
            ),
          TextButton.icon(
            onPressed: () => historyProvider.clearFilters(),
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Hapus Semua'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(PenitipHistoryProvider historyProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Penitipan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                        'Total Produk',
                        historyProvider.totalPenitipan.toString(),
                        Icons.inventory,
                        AppColors.penitipColor),
                  ),
                  Expanded(
                    child: _buildStatItem(
                        'Terjual',
                        historyProvider.terjualCount.toString(),
                        Icons.attach_money,
                        Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                        'Tersedia', // Changed from 'Aktif' to 'Tersedia'
                        historyProvider.activePenitipan.toString(),
                        Icons.inventory_2,
                        Colors.blue),
                  ),
                  Expanded(
                    child: _buildStatItem(
                        'Perlu Tindakan',
                        historyProvider.needingDecision.toString(),
                        Icons.warning,
                        Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.greyDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<PenitipanHistory> penitipanList) {
    if (penitipanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Belum ada riwayat penitipan',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadHistory(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.penitipColor,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<PenitipHistoryProvider>(context, listen: false)
            .refreshHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: penitipanList.length,
        itemBuilder: (context, index) {
          final penitipan = penitipanList[index];
          return _buildPenitipanCard(penitipan);
        },
      ),
    );
  }

  Widget _buildPenitipanCard(PenitipanHistory penitipan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPenitipanDetail(penitipan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          penitipan.idPenitipan,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.penitipColor,
                          ),
                        ),
                        Text(
                          penitipan.formattedTanggalMasuk,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: penitipan.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: penitipan.statusColor, width: 1),
                    ),
                    child: Text(
                      penitipan.statusPenitipan,
                      style: TextStyle(
                        fontSize: 12,
                        color: penitipan.statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Product Info
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.grey.withOpacity(0.3)),
                    ),
                    child: penitipan.produk?.firstImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              penitipan.produk!.firstImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image,
                                    color: Colors.grey, size: 30);
                              },
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.grey, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          penitipan.displayNamaProduk,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kategori: ${penitipan.produk?.kategoriProduk ?? '-'}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          penitipan.produk?.formattedHarga ?? 'Rp 0',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.penitipColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Status Row
              Row(
                children: [
                  Icon(penitipan.statusIcon,
                      size: 16, color: penitipan.statusColor),
                  const SizedBox(width: 4),
                  Text(
                    penitipan.formattedTenggatWaktu,
                    style: TextStyle(
                      fontSize: 12,
                      color: penitipan.statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (penitipan.displayNamaHunter != 'Belum Ditugaskan') ...[
                    const Icon(Icons.person, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      penitipan.displayNamaHunter,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),

              // Action buttons for products needing decision
              if (penitipan.needsDecision)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleWithdraw(penitipan),
                          icon: const Icon(Icons.assignment_return, size: 16),
                          label: const Text('Ambil'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.penitipColor,
                            side:
                                const BorderSide(color: AppColors.penitipColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleDonate(penitipan),
                          icon: const Icon(Icons.volunteer_activism, size: 16),
                          label: const Text('Donasi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(PenitipHistoryProvider historyProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            historyProvider.errorMessage ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => historyProvider.refreshHistory(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.penitipColor,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showDateFilter(PenitipHistoryProvider historyProvider) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          historyProvider.startDate != null && historyProvider.endDate != null
              ? DateTimeRange(
                  start: historyProvider.startDate!,
                  end: historyProvider.endDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: AppColors.penitipColor),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      historyProvider.setDateRangeFilter(dateRange.start, dateRange.end);
      await historyProvider.loadHistory(
        status: historyProvider.selectedStatus,
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
    }
  }

  void _showPenitipanDetail(PenitipanHistory penitipan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.greyLight)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Detail Penitipan',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyDark),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('ID Penitipan', penitipan.idPenitipan),
                    _buildDetailRow('Nama Produk', penitipan.displayNamaProduk),
                    _buildDetailRow(
                        'Kategori', penitipan.produk?.kategoriProduk ?? '-'),
                    _buildDetailRow(
                        'Harga', penitipan.produk?.formattedHarga ?? 'Rp 0'),
                    _buildDetailRow(
                        'Tanggal Masuk', penitipan.formattedTanggalMasuk),
                    _buildDetailRow(
                        'Tenggat Waktu', penitipan.formattedTenggatWaktu),
                    _buildDetailRow('Status', penitipan.statusPenitipan,
                        color: penitipan.statusColor),
                    if (penitipan.displayNamaHunter != 'Belum Ditugaskan')
                      _buildDetailRow('Hunter', penitipan.displayNamaHunter),
                    if (penitipan.tanggalKeluar != null)
                      _buildDetailRow(
                          'Tanggal Keluar', penitipan.formattedTanggalKeluar),

                    // Action buttons
                    if (penitipan.needsDecision) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleWithdraw(penitipan);
                              },
                              icon: const Icon(Icons.assignment_return),
                              label: const Text('Ambil Produk'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.penitipColor,
                                side: const BorderSide(
                                    color: AppColors.penitipColor),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _handleDonate(penitipan);
                              },
                              icon: const Icon(Icons.volunteer_activism),
                              label: const Text('Donasikan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: AppColors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color ?? AppColors.greyDark,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _handleWithdraw(PenitipanHistory penitipan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(
            'Anda yakin ingin mengambil produk "${penitipan.displayNamaProduk}"?\n\nProduk akan siap diambil di toko ReUseMart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.penitipColor),
            child: const Text('Ya, Ambil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final historyProvider =
          Provider.of<PenitipHistoryProvider>(context, listen: false);

      final success =
          await historyProvider.withdrawProduct(penitipan.idPenitipan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Produk berhasil diproses untuk pengambilan'
                  : historyProvider.errorMessage ??
                      'Gagal memproses pengambilan produk',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _handleDonate(PenitipanHistory penitipan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Donasi'),
        content: Text(
            'Anda yakin ingin mendonasikan produk "${penitipan.displayNamaProduk}"?\n\nProduk yang didonasikan tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Ya, Donasikan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final historyProvider =
          Provider.of<PenitipHistoryProvider>(context, listen: false);

      final success =
          await historyProvider.donateProduct(penitipan.idPenitipan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Terima kasih! Produk berhasil didonasikan'
                  : historyProvider.errorMessage ?? 'Gagal mendonasikan produk',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }
}