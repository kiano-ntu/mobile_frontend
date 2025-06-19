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
  List<dynamic> filteredKomisiDetails = [];
  bool isLoading = true;
  String? error;
  
  // Filter variables
  int? selectedMonth;
  int? selectedYear;
  List<int> availableMonths = [];
  List<int> availableYears = [];

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
          _initializeFilters();
          _applyFilters();
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

  void _initializeFilters() {
    // Always show all 12 months
    availableMonths = List.generate(12, (index) => index + 1);
    
    // Only get years from actual data
    Set<int> years = {};
    
    for (var komisi in komisiDetails) {
      final tanggalPesan = komisi['tanggal_pesan'];
      if (tanggalPesan != null) {
        try {
          DateTime date = DateTime.parse(tanggalPesan.toString());
          years.add(date.year);
        } catch (e) {
          print('Error parsing date: $tanggalPesan');
        }
      }
    }
    
    // Add current year if no data exists
    if (years.isEmpty) {
      years.add(DateTime.now().year);
    }
    
    availableYears = years.toList()..sort((a, b) => b.compareTo(a)); // Sort descending
  }

  void _applyFilters() {
    if (selectedMonth == null && selectedYear == null) {
      filteredKomisiDetails = komisiDetails;
    } else {
      filteredKomisiDetails = komisiDetails.where((komisi) {
        final tanggalPesan = komisi['tanggal_pesan'];
        if (tanggalPesan == null) return false;
        
        try {
          DateTime date = DateTime.parse(tanggalPesan.toString());
          bool matchMonth = selectedMonth == null || date.month == selectedMonth;
          bool matchYear = selectedYear == null || date.year == selectedYear;
          return matchMonth && matchYear;
        } catch (e) {
          return false;
        }
      }).toList();
    }
  }

  double _getFilteredTotalKomisi() {
    double total = 0;
    for (var komisi in filteredKomisiDetails) {
      final komisiHunter = komisi['komisi_hunter'];
      if (komisiHunter != null) {
        total += double.tryParse(komisiHunter.toString()) ?? 0;
      }
    }
    return total;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int? tempMonth = selectedMonth;
        int? tempYear = selectedYear;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Filter Komisi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.hunterColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Month filter
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: tempMonth,
                        hint: const Text('Pilih Bulan'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Semua Bulan'),
                          ),
                          ...availableMonths.map((month) => DropdownMenuItem<int?>(
                            value: month,
                            child: Text(_getMonthName(month)),
                          )),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            tempMonth = value;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Year filter
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: tempYear,
                        hint: const Text('Pilih Tahun'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Semua Tahun'),
                          ),
                          ...availableYears.map((year) => DropdownMenuItem<int?>(
                            value: year,
                            child: Text(year.toString()),
                          )),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            tempYear = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedMonth = null;
                      selectedYear = null;
                      _applyFilters();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.hunterColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedMonth = tempMonth;
                      selectedYear = tempYear;
                      _applyFilters();
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hunterColor,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  String _getActiveFilterText() {
    if (selectedMonth == null && selectedYear == null) {
      return 'Semua Data';
    }
    
    String text = '';
    if (selectedMonth != null) {
      text += _getMonthName(selectedMonth!);
    }
    if (selectedYear != null) {
      if (text.isNotEmpty) text += ' ';
      text += selectedYear.toString();
    }
    return text;
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
            onPressed: _showFilterDialog,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (selectedMonth != null || selectedYear != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filter',
          ),
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
          
          // Filter Info Card
          if (selectedMonth != null || selectedYear != null)
            _buildFilterInfoCard(),
          
          // Commission Table
          Expanded(
            child: _buildCommissionTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final displayTotal = selectedMonth != null || selectedYear != null 
        ? _getFilteredTotalKomisi() 
        : widget.totalKomisi;
    final displayTotalFormatted = KomisiService.formatCurrency(displayTotal);
    final displayCount = filteredKomisiDetails.length;
    
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
                      displayTotalFormatted,
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
                      'Dari $displayCount transaksi',
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

  Widget _buildFilterInfoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.hunterColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.hunterColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 20,
            color: AppColors.hunterColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Filter aktif: ${_getActiveFilterText()}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.hunterColor,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedMonth = null;
                selectedYear = null;
                _applyFilters();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.hunterColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),
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
    
    if (filteredKomisiDetails.isEmpty) {
      return _buildEmptyState();
    }
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.hunterColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Text(
              'Riwayat Komisi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          
          // Table Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.greyLight,
                      border: Border(
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
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.hunterColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'ID Pemesanan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.hunterColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Komisi Yang Didapatkan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.hunterColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Data Rows
                  ...filteredKomisiDetails.asMap().entries.map((entry) {
                    final index = entry.key;
                    final komisi = entry.value;
                    return _buildTableRow(komisi, index);
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> komisi, int index) {
    final komisiHunter = komisi['komisi_hunter'];
    final formattedKomisi = komisiHunter != null 
        ? KomisiService.formatCurrency(double.tryParse(komisiHunter.toString()) ?? 0)
        : 'Rp 0';
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? AppColors.white : AppColors.greyLight.withOpacity(0.5),
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
                    komisi['nama_produk'].toString().length > 20
                        ? '${komisi['nama_produk'].toString().substring(0, 20)}...'
                        : komisi['nama_produk'].toString(),
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
          
          // Komisi Hunter Amount
          Expanded(
            flex: 2,
            child: Text(
              formattedKomisi,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
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
            color: AppColors.hunterColor,
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Gagal Memuat Data',
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
    final isFiltered = selectedMonth != null || selectedYear != null;
    
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
              isFiltered ? Icons.search_off : Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.grey.withOpacity(0.5),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              isFiltered ? 'Tidak Ada Komisi' : 'Belum Ada Komisi',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              isFiltered 
                  ? _getFilteredEmptyMessage()
                  : 'Anda belum memiliki riwayat komisi.\nMulai bekerja untuk mendapatkan komisi!',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            if (isFiltered)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedMonth = null;
                    selectedYear = null;
                    _applyFilters();
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Reset Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hunterColor,
                  foregroundColor: AppColors.white,
                ),
              )
            else
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

  String _getFilteredEmptyMessage() {
    String period = '';
    if (selectedMonth != null && selectedYear != null) {
      period = 'di ${_getMonthName(selectedMonth!)} ${selectedYear}';
    } else if (selectedMonth != null) {
      period = 'di bulan ${_getMonthName(selectedMonth!)}';
    } else if (selectedYear != null) {
      period = 'di tahun ${selectedYear}';
    }
    
    return 'Tidak ada komisi $period.\nCoba pilih periode lain atau reset filter.';
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