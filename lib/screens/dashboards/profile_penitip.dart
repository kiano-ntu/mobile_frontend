// File: lib/screens/dashboards/profile_penitip.dart - FIXED VERSION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/penitip_provider.dart';
import '../../utils/colors.dart';
import '../dashboards/history_penitip.dart'; // Import the history screen

class ProfilePenitip extends StatefulWidget {
  const ProfilePenitip({Key? key}) : super(key: key);

  @override
  State<ProfilePenitip> createState() => _ProfilePenitipState();
}

class _ProfilePenitipState extends State<ProfilePenitip> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final penitipProvider =
        Provider.of<PenitipProvider>(context, listen: false);

    // Load profile dari provider
    penitipProvider.loadProfile();

    // Set controller values dari provider
    if (penitipProvider.penitipName != null) {
      _namaController.text = penitipProvider.penitipName!;
    }
    if (penitipProvider.penitipEmail != null) {
      _emailController.text = penitipProvider.penitipEmail!;
    }
    if (penitipProvider.penitipPhone != null) {
      _teleponController.text = penitipProvider.penitipPhone!;
    }
    if (penitipProvider.penitipAddress != null) {
      _alamatController.text = penitipProvider.penitipAddress!;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PenitipProvider>(
      builder: (context, authProvider, penitipProvider, child) {
        // Update controllers when data changes
        if (penitipProvider.penitipName != null && !_isEditing) {
          if (_namaController.text != penitipProvider.penitipName!) {
            _namaController.text = penitipProvider.penitipName!;
          }
        }
        if (penitipProvider.penitipEmail != null && !_isEditing) {
          if (_emailController.text != penitipProvider.penitipEmail!) {
            _emailController.text = penitipProvider.penitipEmail!;
          }
        }
        if (penitipProvider.penitipPhone != null && !_isEditing) {
          if (_teleponController.text != penitipProvider.penitipPhone!) {
            _teleponController.text = penitipProvider.penitipPhone!;
          }
        }
        if (penitipProvider.penitipAddress != null && !_isEditing) {
          if (_alamatController.text != penitipProvider.penitipAddress!) {
            _alamatController.text = penitipProvider.penitipAddress!;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.greyLight,
          appBar: AppBar(
            backgroundColor: AppColors.penitipColor,
            foregroundColor: AppColors.white,
            title: const Text(
              'Profile Penitip',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (!penitipProvider.isLoading)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        // Reset form when canceling edit
                        _loadUserData();
                        _passwordController.clear();
                      }
                    });
                  },
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  tooltip: _isEditing ? 'Batal Edit' : 'Edit Profile',
                ),
            ],
          ),
          body: penitipProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : penitipProvider.penitipName == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            penitipProvider.errorMessage ??
                                'Gagal memuat profile',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => penitipProvider.loadProfile(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.penitipColor,
                              foregroundColor: AppColors.white,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Profile Header Card
                          _buildProfileHeader(penitipProvider),

                          const SizedBox(height: 20),

                          // Profile Form Card
                          _buildProfileForm(penitipProvider),

                          const SizedBox(height: 20),

                          // Logout Card
                          _buildLogoutCard(authProvider, penitipProvider),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildProfileHeader(PenitipProvider penitipProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.penitipColor,
              AppColors.penitipColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.white,
              child: Icon(
                Icons.store,
                size: 60,
                color: AppColors.penitipColor,
              ),
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              penitipProvider.penitipName ?? 'Nama Penitip',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.store, size: 16, color: AppColors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Penitip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  if (penitipProvider.penitipBadgeLoyalitas) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Saldo & Poin Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Saldo Container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text(
                            'Saldo',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            penitipProvider.formattedSaldo,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.penitipColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Poin Container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text(
                            'Poin',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            '${penitipProvider.formattedPoin} Pts',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.penitipColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(PenitipProvider penitipProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyDark,
                ),
              ),
              const SizedBox(height: 20),

              // Nama Field
              _buildTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!penitipProvider.isValidEmail(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Telepon Field
              _buildTextField(
                controller: _teleponController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !penitipProvider.isValidPhone(value)) {
                    return 'Format nomor telepon tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Alamat Field
              _buildTextField(
                controller: _alamatController,
                label: 'Alamat',
                icon: Icons.location_on_outlined,
                enabled: _isEditing,
                maxLines: 3,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      value.trim().length < 5) {
                    return 'Alamat minimal 5 karakter';
                  }
                  return null;
                },
              ),

              // Password Field (only show when editing)
              if (_isEditing) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password Baru (Opsional)',
                  icon: Icons.lock_outline,
                  enabled: _isEditing,
                  obscureText: !_showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.penitipColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
              ],

              if (_isEditing) ...[
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        penitipProvider.isUpdatingProfile ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.penitipColor,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: penitipProvider.isUpdatingProfile
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                            ),
                          )
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard(
      AuthProvider authProvider, PenitipProvider penitipProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: 16),

            // Products Button - FIXED: Direct navigation to HistoryPenitip
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // FIXED: Navigate directly to the widget instead of route
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPenitip(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.penitipColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.inventory),
                label: const Text(
                  'Kelola Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Transactions Button - FIXED: Direct navigation to HistoryPenitip
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // FIXED: Navigate directly to the widget instead of route
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPenitip(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.penitipColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.history),
                label: const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showLogoutDialog(context, authProvider, penitipProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.penitipColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.penitipColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
        ),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.greyLight,
      ),
    );
  }

  // ============= ACTION METHODS =============

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final penitipProvider =
          Provider.of<PenitipProvider>(context, listen: false);

      final success = await penitipProvider.updateProfile(
        namaPenitip: _namaController.text.trim(),
        emailPenitip: _emailController.text.trim(),
        noTelpPenitip: _teleponController.text.trim().isEmpty
            ? null
            : _teleponController.text.trim(),
        alamatPenitip: _alamatController.text.trim().isEmpty
            ? null
            : _alamatController.text.trim(),
        passwordPenitip: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
      );

      if (success) {
        setState(() {
          _isEditing = false;
          _passwordController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                penitipProvider.errorMessage ?? 'Gagal memperbarui profile'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider,
      PenitipProvider penitipProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Reset penitip provider data
              penitipProvider.resetData();

              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}