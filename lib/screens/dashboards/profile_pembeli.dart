// File: lib/screens/dashboards/profile_pembeli.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pembeli_provider.dart';
import '../../utils/colors.dart';
import '../dashboards/history_pembeli.dart';

class ProfilePembeli extends StatefulWidget {
  const ProfilePembeli({Key? key}) : super(key: key);

  @override
  State<ProfilePembeli> createState() => _ProfilePembeliState();
}

class _ProfilePembeliState extends State<ProfilePembeli> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
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
    final pembeliProvider =
        Provider.of<PembeliProvider>(context, listen: false);

    // Load profile dari provider
    pembeliProvider.loadProfile();

    // Set controller values dari provider
    if (pembeliProvider.pembeliName != null) {
      _namaController.text = pembeliProvider.pembeliName!;
    }
    if (pembeliProvider.pembeliEmail != null) {
      _emailController.text = pembeliProvider.pembeliEmail!;
    }
    if (pembeliProvider.pembeliPhone != null) {
      _teleponController.text = pembeliProvider.pembeliPhone!;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PembeliProvider>(
      builder: (context, authProvider, pembeliProvider, child) {
        // Update controllers when data changes
        if (pembeliProvider.pembeliName != null && !_isEditing) {
          if (_namaController.text != pembeliProvider.pembeliName!) {
            _namaController.text = pembeliProvider.pembeliName!;
          }
        }
        if (pembeliProvider.pembeliEmail != null && !_isEditing) {
          if (_emailController.text != pembeliProvider.pembeliEmail!) {
            _emailController.text = pembeliProvider.pembeliEmail!;
          }
        }
        if (pembeliProvider.pembeliPhone != null && !_isEditing) {
          if (_teleponController.text != pembeliProvider.pembeliPhone!) {
            _teleponController.text = pembeliProvider.pembeliPhone!;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.greyLight,
          appBar: AppBar(
            backgroundColor: AppColors.pembeliColor,
            foregroundColor: AppColors.white,
            title: const Text(
              'Profile Pembeli',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (!pembeliProvider.isLoading)
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
          body: pembeliProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : pembeliProvider.pembeliName == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            pembeliProvider.errorMessage ??
                                'Gagal memuat profile',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => pembeliProvider.loadProfile(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pembeliColor,
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
                          _buildProfileHeader(pembeliProvider),

                          const SizedBox(height: 20),

                          // Profile Form Card
                          _buildProfileForm(pembeliProvider),

                          const SizedBox(height: 20),

                          // Logout Card
                          _buildLogoutCard(authProvider, pembeliProvider),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildProfileHeader(PembeliProvider pembeliProvider) {
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
              AppColors.pembeliColor,
              AppColors.pembeliColor.withOpacity(0.8),
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
                Icons.person,
                size: 60,
                color: AppColors.pembeliColor,
              ),
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              pembeliProvider.pembeliName ?? 'Nama Pembeli',
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
              child: const Text(
                'Pembeli',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Poin Display
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
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
                  Text(
                    '${pembeliProvider.formattedPoin} Poin',
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
      ),
    );
  }

  Widget _buildProfileForm(PembeliProvider pembeliProvider) {
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
                  if (!pembeliProvider.isValidEmail(value)) {
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
                      !pembeliProvider.isValidPhone(value)) {
                    return 'Format nomor telepon tidak valid';
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
                      color: AppColors.pembeliColor,
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
                        pembeliProvider.isUpdatingProfile ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pembeliColor,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: pembeliProvider.isUpdatingProfile
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
      AuthProvider authProvider, PembeliProvider pembeliProvider) {
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

            // History Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPembeli(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pembeliColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.history),
                label: const Text(
                  'History Pembelian',
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
                    _showLogoutDialog(context, authProvider, pembeliProvider),
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
        prefixIcon: Icon(icon, color: AppColors.pembeliColor),
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
          borderSide: const BorderSide(color: AppColors.pembeliColor, width: 2),
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
      final pembeliProvider =
          Provider.of<PembeliProvider>(context, listen: false);

      final success = await pembeliProvider.updateProfile(
        namaPembeli: _namaController.text.trim(),
        emailPembeli: _emailController.text.trim(),
        noTelpPembeli: _teleponController.text.trim().isEmpty
            ? null
            : _teleponController.text.trim(),
        passwordPembeli: _passwordController.text.trim().isEmpty
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
                pembeliProvider.errorMessage ?? 'Gagal memperbarui profile'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider,
      PembeliProvider pembeliProvider) {
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

              // Reset pembeli provider data
              pembeliProvider.resetData();

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
