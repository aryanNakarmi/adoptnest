import 'dart:io';

import 'package:adoptnest/app/routes/app_routes.dart';
import 'package:adoptnest/app/themes/font_data.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/core/services/storage/user_session_service.dart';
import 'package:adoptnest/core/utils/snackbar_utils.dart';
import 'package:adoptnest/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:adoptnest/features/auth/presentation/pages/login_screen.dart';
import 'package:adoptnest/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isEditing = false;
  bool _isSaving = false;
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userSession = ref.read(userSessionServiceProvider);

    _fullNameController = TextEditingController(
      text: userSession.getCurrentUserFullName() ?? '',
    );

    _phoneController = TextEditingController(
      text: userSession.getCurrentUserPhoneNumber() ?? '',
    );

    _emailController = TextEditingController(
      text: userSession.getCurrentUserEmail() ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;

    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');

    if (imagePath.contains('/profile_pictures')) {
      return '$baseUrl${imagePath.startsWith('/') ? '' : '/'}$imagePath';
    }

    return '$baseUrl/profile_pictures/${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}';
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedImage = null;
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        SnackbarUtils.showError(context, 'Gallery permission denied');
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      SnackbarUtils.showError(context, 'Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (fullName.isEmpty) {
      SnackbarUtils.showError(context, 'Please enter your full name');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Call usecase with optional image
      final result = await ref.read(updateProfileUsecaseProvider).call(
        UpdateProfileUsecaseParams(
          fullName: fullName,
          phoneNumber: phone,
          profilePicture: _selectedImage,  // Can be null
        ),
      );

      result.fold(
        (failure) {
          if (mounted) {
            SnackbarUtils.showError(context, failure.message);
          }
          setState(() => _isSaving = false);
        },
        (success) {
          if (mounted) {
            SnackbarUtils.showSuccess(context, 'Profile updated successfully');
          }
          setState(() {
            _isSaving = false;
            _isEditing = false;
            _selectedImage = null;
          });
        },
      );
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: $e');
      }
      setState(() => _isSaving = false);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout from AdoptNest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                AppRoutes.pushAndRemoveUntil(
                  context,
                  const LoginScreen(),
                );
              }
            },
            child: const Text(
              'Logout',
              style:
                  TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userSession = ref.watch(userSessionServiceProvider);

    final fullName = userSession.getCurrentUserFullName() ?? 'User';
    final email = userSession.getCurrentUserEmail() ?? '';
    final phone = userSession.getCurrentUserPhoneNumber() ?? '';
    final profilePicture = userSession.getCurrentUserProfilePicture();

    final imageUrl = _getFullImageUrl(profilePicture);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: FontData.header2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (!_isEditing)
                    GestureDetector(
                      onTap: _toggleEditMode,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 24,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Profile Info Card (View Mode)
                    if (!_isEditing)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            ClipOval(
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return _buildInitialAvatar(fullName);
                                        },
                                      )
                                    : _buildInitialAvatar(fullName),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Name
                            Text(
                              fullName,
                              style: FontData.header3.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Email
                            Text(
                              email,
                              style: FontData.body2.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (!_isEditing) const SizedBox(height: 24),

                    // Edit Form
                    if (_isEditing)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile Picture Section
                          Center(
                            child: Column(
                              children: [
                                ClipOval(
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          )
                                        : imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return _buildInitialAvatar(
                                                      fullName);
                                                },
                                              )
                                            : _buildInitialAvatar(fullName),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.image_outlined),
                                  label: const Text('Choose Photo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                if (_selectedImage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Photo selected',
                                      style: FontData.body2.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Text Fields
                          _buildProfileTextField(
                            controller: _fullNameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildProfileTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: 'Enter your phone number',
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildProfileTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Your email address',
                            icon: Icons.email_outlined,
                            enabled: false,
                          ),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                          const SizedBox(height: 12),
                          _buildCancelButton(),
                        ],
                      ),

                    // Info List (View Mode)
                    if (!_isEditing) ...[
                      _buildInfoItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: phone.isEmpty ? 'Not provided' : phone,
                      ),
                      _buildDivider(),
                      _buildInfoItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email,
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Logout Button 
            if (!_isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildLogoutButton(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FontData.body2.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: FontData.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Colors.grey[200], height: 1),
    );
  }

  Widget _buildInitialAvatar(String fullName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
      ),
      child: Center(
        child: Text(
          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.red),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Save Changes',
                style: FontData.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton(
      onPressed: _toggleEditMode,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Cancel',
        style: FontData.body1.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

Widget _buildLogoutButton() {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.8,
    child: ElevatedButton(
      onPressed: () => _showLogoutDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Logout',
        style: FontData.body1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  );

  }
}