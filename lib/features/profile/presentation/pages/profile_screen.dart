import 'dart:io';

import 'package:adoptnest/app/routes/app_routes.dart';
import 'package:adoptnest/app/themes/font_data.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/core/services/storage/user_session_service.dart';
import 'package:adoptnest/features/auth/presentation/pages/login_screen.dart';
import 'package:adoptnest/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isSaving = false;

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
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _buildImageUrl(String? profilePath) {
    if (profilePath == null || profilePath.isEmpty) return null;

    final base = ApiEndpoints.baseUrl;

    // Remove "/api/v1" because static files are outside it
    final cleanedBase = base.replaceAll('/api/v1', '');

    return "$cleanedBase/profile_pictures/$profilePath";
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout from AdoptNest?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
              style: TextStyle(color: Colors.red),
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
    final profilePicture =
        userSession.getCurrentUserProfilePicture();

    final imageUrl = _buildImageUrl(profilePicture);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [

              const SizedBox(height: 30),

              // 🔴 HERO CARD
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade400,
                      Colors.red.shade600,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.35),
                      blurRadius: 35,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // 🖼 PROFILE IMAGE
                    ClipOval(
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return _buildInitialAvatar(
                                      fullName);
                                },
                              )
                            : _buildInitialAvatar(fullName),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      fullName,
                      style: FontData.header2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      email,
                      style: FontData.body2.copyWith(
                        color:
                            Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              if (!_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _toggleEditMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 400),
                child: _isEditing
                    ? Column(
                        children: [
                          _buildCard(
                            child: Column(
                              children: [
                                _buildEditableField(
                                  label: 'Full Name',
                                  controller:
                                      _fullNameController,
                                  icon:
                                      Icons.person_outline,
                                ),
                                const SizedBox(
                                    height: 20),
                                _buildEditableField(
                                  label: 'Phone Number',
                                  controller:
                                      _phoneController,
                                  icon:
                                      Icons.phone_outlined,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : _saveProfile,
                              style: ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                    Colors.red,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(20),
                                ),
                              ),
                              child: _isSaving
                                  ? const CircularProgressIndicator(
                                      color:
                                          Colors.white,
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style:
                                          TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed:
                                _toggleEditMode,
                            child:
                                const Text('Cancel'),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),

              const SizedBox(height: 40),

              TextButton.icon(
                onPressed: () =>
                    _showLogoutDialog(context),
                icon: const Icon(Icons.logout,
                    color: Colors.red),
                label: const Text(
                  'Logout',
                  style:
                      TextStyle(color: Colors.red),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String fullName) {
    return Container(
      color: Colors.white24,
      child: Center(
        child: Text(
          fullName.isNotEmpty
              ? fullName[0].toUpperCase()
              : 'U',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 25,
            offset:
                const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: Colors.red),
        filled: true,
        fillColor:
            const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}
