// File: lib/screens/dashboards/kurir_dashboard.dart - FIXED OVERFLOW VERSION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kurir_provider.dart';
import '../../models/delivery_task.dart';
import '../../utils/colors.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';

class KurirDashboard extends StatefulWidget {
  const KurirDashboard({Key? key}) : super(key: key);

  @override
  State<KurirDashboard> createState() => _KurirDashboardState();
}

class _KurirDashboardState extends State<KurirDashboard> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedData = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (_hasLoadedData) return;
    
    final authProvider = context.read<AuthProvider>();
    final kurirProvider = context.read<KurirProvider>();
    
    if (authProvider.isAuthenticated && authProvider.userRole == 'kurir') {
      try {
        await Future.wait([
          kurirProvider.loadDeliveryTasks(),
          kurirProvider.loadProfile(),
        ]);
        _hasLoadedData = true;
      } catch (e) {
        print('❌ Error loading data: $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, KurirProvider>(
      builder: (context, authProvider, kurirProvider, child) {
        if (!authProvider.isAuthenticated || authProvider.userRole != 'kurir') {
          return _buildAccessDenied(authProvider);
        }

        return Scaffold(
          backgroundColor: AppColors.greyLight,
          appBar: AppBar(
            backgroundColor: AppColors.kurirColor,
            foregroundColor: AppColors.white,
            title: const Text('Kurir ReUseMart'),
            actions: [
              IconButton(
                onPressed: () => _logout(authProvider),
                icon: const Icon(Icons.logout),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withOpacity(0.7),
              indicatorColor: AppColors.accent,
              tabs: const [
                Tab(icon: Icon(Icons.local_shipping), text: 'Tugas'),
                Tab(icon: Icon(Icons.person), text: 'Profil'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTasksTab(kurirProvider),
              _buildProfileTab(authProvider, kurirProvider),
            ],
          ),
          floatingActionButton: _tabController.index == 0 
              ? FloatingActionButton(
                  onPressed: () => kurirProvider.refreshTasks(),
                  backgroundColor: AppColors.kurirColor,
                  child: const Icon(Icons.refresh),
                )
              : null,
        );
      },
    );
  }

  Widget _buildAccessDenied(AuthProvider authProvider) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            const Text('Akses Ditolak', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Halaman ini hanya untuk kurir'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _logout(authProvider),
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab(KurirProvider kurirProvider) {
    return RefreshIndicator(
      onRefresh: () => kurirProvider.refreshTasks(),
      child: kurirProvider.isLoading && kurirProvider.allTasks.isEmpty
          ? const LoadingWidget(message: 'Memuat tugas...')
          : kurirProvider.allTasks.isEmpty
              ? _buildEmptyTasks()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kurirProvider.allTasks.length,
                  itemBuilder: (context, index) {
                    final task = kurirProvider.allTasks[index];
                    return _buildTaskCard(task, kurirProvider);
                  },
                ),
    );
  }

  Widget _buildEmptyTasks() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tugas pengiriman',
            style: TextStyle(fontSize: 16, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(DeliveryTask task, KurirProvider kurirProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan #${task.orderId}',
                        style: const TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.productName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(task),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(task.customerName)),
                if (task.customerPhone != null && task.customerPhone!.isNotEmpty) ...[
                  Icon(Icons.phone, size: 16, color: AppColors.kurirColor),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _showPhone(task.customerPhone!),
                    child: Text(
                      task.customerPhone!,
                      style: const TextStyle(
                        color: AppColors.kurirColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.deliveryAddress,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(task.formattedDeliveryDate),
                const Spacer(),
                Text(
                  task.totalAmount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.kurirColor,
                  ),
                ),
              ],
            ),
            if (task.canUpdateStatus) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(task, kurirProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: task.statusColor,
                    foregroundColor: AppColors.white,
                  ),
                  icon: Icon(task.statusIcon),
                  label: Text(task.actionButtonText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(DeliveryTask task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: task.statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        task.statusDisplayName,
        style: TextStyle(
          fontSize: 12,
          color: task.statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProfileTab(AuthProvider authProvider, KurirProvider kurirProvider) {
    return RefreshIndicator(
      onRefresh: () => kurirProvider.loadProfile(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.kurirColor,
                    AppColors.kurirColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.white,
                          child: Icon(
                            Icons.delivery_dining,
                            size: 40,
                            color: AppColors.kurirColor,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        kurirProvider.kurirName ?? authProvider.userName ?? 'Kurir',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: AppColors.kurirColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kurir ReUseMart',
                              style: TextStyle(
                                color: AppColors.kurirColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Quick Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickStat(
                            '${kurirProvider.totalDeliveries}',
                            'Total',
                            Icons.local_shipping,
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: AppColors.white.withOpacity(0.3),
                          ),
                          _buildQuickStat(
                            '${kurirProvider.monthlyDeliveries}',
                            'Bulan Ini',
                            Icons.trending_up,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Personal Info Card
                  _buildInfoCard(
                    title: 'Informasi Personal',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoItem(
                        Icons.email_outlined,
                        'Email',
                        kurirProvider.kurirEmail ?? 'Email tidak tersedia',
                        AppColors.info,
                      ),
                      _buildInfoItem(
                        Icons.phone_outlined,
                        'Telepon',
                        kurirProvider.kurirPhone ?? 'Telepon tidak tersedia',
                        AppColors.success,
                      ),
                      _buildInfoItem(
                        Icons.location_on_outlined,
                        'Alamat',
                        kurirProvider.kurirAddress ?? 'Alamat tidak tersedia',
                        AppColors.warning,
                        isLast: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Performance Card
                  _buildInfoCard(
                    title: 'Performa Pengiriman',
                    icon: Icons.analytics_outlined,
                    children: [
                      Container(
                        height: 80,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildPerformanceStat(
                                'Total Selesai',
                                '${kurirProvider.totalDeliveries}',
                                Icons.check_circle_outline,
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPerformanceStat(
                                'Bulan Ini',
                                '${kurirProvider.monthlyDeliveries}',
                                Icons.flag_outlined,
                                AppColors.kurirColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.kurirColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.kurirColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(color: AppColors.greyLight, height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildPerformanceStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 8,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(DeliveryTask task, KurirProvider kurirProvider) async {
    if (task.nextStatus == null) return;

    if (task.nextStatus == 'Selesai') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Apakah pesanan #${task.orderId} sudah diterima customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya, Selesai'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingWidget(message: 'Mengupdate status...'),
    );

    final success = await kurirProvider.updateDeliveryStatus(task.id, task.nextStatus!);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? '✅ Status berhasil diupdate ke: ${task.nextStatus}'
                : '❌ Gagal update status',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showPhone(String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontak Customer'),
        content: Text('Telepon: $phone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}