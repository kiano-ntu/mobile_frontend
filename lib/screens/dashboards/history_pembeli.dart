// File: lib/screens/dashboards/history_pembeli.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart'; // HAPUS BARIS INI
import '../../providers/history_provider.dart';
import '../../models/pemesanan.dart';
import '../../utils/colors.dart';

class HistoryPembeli extends StatefulWidget {
  const HistoryPembeli({Key? key}) : super(key: key);

  @override
  State<HistoryPembeli> createState() => _HistoryPembeliState();
}

class _HistoryPembeliState extends State<HistoryPembeli>
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

  final List<String> _filterOptions = [
    'Semua',
    'Aktif',
    'Selesai',
    'Dibatalkan',
    'Menunggu Pembayaran',
    'Dikirim',
    'Sampai'
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
        Provider.of<HistoryProvider>(context, listen: false);
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
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.greyLight,
          appBar: AppBar(
            backgroundColor: AppColors.pembeliColor,
            foregroundColor: AppColors.white,
            title: const Text(
              'History Pembelian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                Tab(text: 'Aktif'),
                Tab(text: 'Selesai'),
                Tab(text: 'Batal'),
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
                              _buildHistoryList(historyProvider.activeOrders),
                              _buildHistoryList(
                                  historyProvider.completedOrders),
                              _buildHistoryList(
                                  historyProvider.cancelledOrders),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter(HistoryProvider historyProvider) {
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
                  const Icon(Icons.search, color: AppColors.pembeliColor),
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
                    const BorderSide(color: AppColors.pembeliColor, width: 2),
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
                        color: AppColors.pembeliColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _filterOptions.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
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
                    const Icon(Icons.date_range, color: AppColors.pembeliColor),
                label: const Text(
                  'Tanggal',
                  style: TextStyle(color: AppColors.pembeliColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.pembeliColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

  Widget _buildActiveFilters(HistoryProvider historyProvider) {
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
              backgroundColor: AppColors.pembeliColor.withOpacity(0.1),
            ),
          if (historyProvider.startDate != null)
            Chip(
              label: Text('Dari: ${_formatDate(historyProvider.startDate!)}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => historyProvider.setDateRangeFilter(
                  null, historyProvider.endDate),
              backgroundColor: AppColors.pembeliColor.withOpacity(0.1),
            ),
          if (historyProvider.endDate != null)
            Chip(
              label: Text('Sampai: ${_formatDate(historyProvider.endDate!)}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => historyProvider.setDateRangeFilter(
                  historyProvider.startDate, null),
              backgroundColor: AppColors.pembeliColor.withOpacity(0.1),
            ),
          TextButton.icon(
            onPressed: () => historyProvider.clearFilters(),
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Hapus Semua'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(HistoryProvider historyProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Pembelian',
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
                      'Total Pesanan',
                      historyProvider.totalPemesanan.toString(),
                      Icons.shopping_bag,
                      AppColors.pembeliColor,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Selesai',
                      historyProvider.completedPemesanan.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Belanja',
                      _formatCurrency(historyProvider.totalSpent),
                      Icons.payment,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Poin Diperoleh',
                      historyProvider.totalPoinEarned.toString(),
                      Icons.stars,
                      Colors.amber,
                    ),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.greyDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Pemesanan> pemesananList) {
    if (pemesananList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat pembelian',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadHistory(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pembeliColor,
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
        await Provider.of<HistoryProvider>(context, listen: false)
            .refreshHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pemesananList.length,
        itemBuilder: (context, index) {
          final pemesanan = pemesananList[index];
          return _buildPemesananCard(pemesanan);
        },
      ),
    );
  }

  Widget _buildPemesananCard(Pemesanan pemesanan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showPemesananDetail(pemesanan),
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
                          pemesanan.idPemesanan,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pembeliColor,
                          ),
                        ),
                        Text(
                          pemesanan.formattedTanggalPesan,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pemesanan.statusPengirimanColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: pemesanan.statusPengirimanColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      pemesanan.statusPengiriman,
                      style: TextStyle(
                        fontSize: 12,
                        color: pemesanan.statusPengirimanColor,
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
                    child: pemesanan.penitipan?.produk?.fotoProduk != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              pemesanan.penitipan!.produk!.fotoProduk!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pemesanan.displayNamaProduk,
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
                          'Oleh: ${pemesanan.displayNamaPenitip}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pemesanan.formattedTotalBayar,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pembeliColor,
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
                  Icon(
                    pemesanan.statusBayarIcon,
                    size: 16,
                    color: pemesanan.statusBayarColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    pemesanan.statusBayar,
                    style: TextStyle(
                      fontSize: 12,
                      color: pemesanan.statusBayarColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (pemesanan.poinDidapatkan > 0) ...[
                    const Icon(
                      Icons.stars,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${pemesanan.poinDidapatkan} poin',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(HistoryProvider historyProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
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
              backgroundColor: AppColors.pembeliColor,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showDateFilter(HistoryProvider historyProvider) async {
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.pembeliColor,
                ),
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

  void _showPemesananDetail(Pemesanan pemesanan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPemesananDetailModal(pemesanan),
    );
  }

  Widget _buildPemesananDetailModal(Pemesanan pemesanan) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
              border: Border(
                bottom: BorderSide(color: AppColors.greyLight),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Detail Pemesanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
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
                  _buildDetailSection('Informasi Pesanan', [
                    _buildDetailRow('ID Pemesanan', pemesanan.idPemesanan),
                    _buildDetailRow(
                        'Tanggal Pesan', pemesanan.formattedTanggalPesan),
                    _buildDetailRow('Status Pembayaran', pemesanan.statusBayar,
                        color: pemesanan.statusBayarColor),
                    _buildDetailRow(
                        'Status Pengiriman', pemesanan.statusPengiriman,
                        color: pemesanan.statusPengirimanColor),
                    _buildDetailRow(
                        'Mode Pengiriman', pemesanan.modePengiriman),
                  ]),
                  const SizedBox(height: 20),
                  _buildDetailSection('Informasi Produk', [
                    _buildProductDetail(pemesanan),
                  ]),
                  const SizedBox(height: 20),
                  _buildDetailSection('Rincian Biaya', [
                    _buildDetailRow(
                        'Harga Produk', pemesanan.formattedJumHargaBersih),
                    if (pemesanan.jumHargaDiskon != null &&
                        pemesanan.jumHargaDiskon! > 0)
                      _buildDetailRow('Diskon Poin',
                          '- ${pemesanan.formattedJumHargaDiskon}',
                          color: Colors.green),
                    _buildDetailRow(
                        'Ongkos Kirim', pemesanan.formattedJumHargaOngkir),
                    const Divider(),
                    _buildDetailRow(
                        'Total Bayar', pemesanan.formattedTotalBayar,
                        isBold: true, color: AppColors.pembeliColor),
                  ]),
                  if (pemesanan.alamat != null) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection('Alamat Pengiriman', [
                      _buildDetailRow(
                          'Tag Alamat', pemesanan.alamat!.tagAlamat),
                      _buildDetailRow(
                          'Alamat Lengkap', pemesanan.alamat!.alamatLengkap),
                    ]),
                  ],
                  if (pemesanan.poinDidapatkan > 0 ||
                      (pemesanan.poinDiskon != null &&
                          pemesanan.poinDiskon! > 0)) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection('Informasi Poin', [
                      if (pemesanan.poinDiskon != null &&
                          pemesanan.poinDiskon! > 0)
                        _buildDetailRow(
                            'Poin Digunakan', '${pemesanan.poinDiskon} poin',
                            color: Colors.red),
                      if (pemesanan.poinDidapatkan > 0)
                        _buildDetailRow('Poin Diperoleh',
                            '${pemesanan.poinDidapatkan} poin',
                            color: Colors.amber),
                    ]),
                  ],
                  if (pemesanan.tanggalBayar != null ||
                      pemesanan.tanggalKirim != null ||
                      pemesanan.tanggalAmbil != null) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection('Timeline', [
                      if (pemesanan.tanggalBayar != null)
                        _buildDetailRow(
                            'Tanggal Bayar', pemesanan.formattedTanggalBayar),
                      if (pemesanan.tanggalKirim != null)
                        _buildDetailRow(
                            'Tanggal Kirim', pemesanan.formattedTanggalKirim),
                      if (pemesanan.tanggalAmbil != null)
                        _buildDetailRow(
                            'Tanggal Ambil', pemesanan.formattedTanggalAmbil),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color ?? AppColors.greyDark,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail(Pemesanan pemesanan) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey.withOpacity(0.3)),
            ),
            child: pemesanan.penitipan?.produk?.fotoProduk != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      pemesanan.penitipan!.produk!.fotoProduk!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.image,
                    color: Colors.grey,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pemesanan.displayNamaProduk,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Oleh: ${pemesanan.displayNamaPenitip}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                if (pemesanan.penitipan?.produk?.deskripsiProduk != null)
                  Text(
                    pemesanan.penitipan!.produk!.deskripsiProduk!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}