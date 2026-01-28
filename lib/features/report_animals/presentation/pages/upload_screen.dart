import 'dart:io';

import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/snackbar_utils.dart';

class UploadReportScreen extends ConsumerStatefulWidget {
  const UploadReportScreen({super.key});

  @override
  ConsumerState<UploadReportScreen> createState() =>
      _UploadReportScreenState();
}

class _UploadReportScreenState extends ConsumerState<UploadReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  File? _image;
  String? _uploadedPhotoUrl;

  final _speciesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _speciesController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Camera permission denied');
      }
      return false;
    }
    return true;
  }

 
  Future<void> _openCamera() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) return;

      final imageFile = File(photo.path);
      setState(() => _image = imageFile);

      // Upload photo using viewmodel
      if (mounted) {
        await ref
            .read(animalReportViewModelProvider.notifier)
            .uploadPhoto(imageFile);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to pick image: $e');
      }
    }
  }

 
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(animalReportViewModelProvider);

    if (state.uploadedPhotoUrl == null) {
      SnackbarUtils.showError(context, 'Please capture a photo');
      return;
    }

    final report = AnimalReportEntity(
      reportId: const Uuid().v4(),
      species: _speciesController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: state.uploadedPhotoUrl!,
      reportedBy: 'user_id_here', // Replace with auth user later
      reportedByName: 'User Name',
      status: AnimalReportStatus.pending,
      createdAt: DateTime.now(),
    );

    if (mounted) {
      await ref
          .read(animalReportViewModelProvider.notifier)
          .createReport(report);
    }
  }

  void _setupStateListener() {
    ref.listen<AnimalReportState>(
      animalReportViewModelProvider,
      (previous, next) {
        if (next.status == AnimalReportViewStatus.created) {
          SnackbarUtils.showSuccess(context, 'Animal reported successfully 🐾');
          if (mounted) {
            Navigator.pop(context);
          }
        }

        if (next.status == AnimalReportViewStatus.error &&
            next.errorMessage != null) {
          SnackbarUtils.showError(context, next.errorMessage!);
        }
      },
    );
  }
  @override
void initState() {
  super.initState();
  _setupStateListener();
}


  @override
  Widget build(BuildContext context) {
   
    final state = ref.watch(animalReportViewModelProvider);
    final isLoading = state.status == AnimalReportViewStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildPhotoSection(),
                      const SizedBox(height: 28),
                      _buildSpeciesField(),
                      const SizedBox(height: 16),
                      _buildLocationField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(isLoading),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Report an Animal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _openCamera,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
          color: Colors.grey[100],
        ),
        child: _image == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to capture photo',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }

  Widget _buildSpeciesField() {
    return TextFormField(
      controller: _speciesController,
      decoration: InputDecoration(
        labelText: 'Animal Species',
        labelStyle: const TextStyle(color: Colors.black),
        hintText: 'e.g., Dog, Cat, Bird',
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: const Icon(Icons.pets, color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter animal species';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Location',
        labelStyle: const TextStyle(color: Colors.black),
        hintText: 'Where was the animal spotted?',
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: const Icon(Icons.location_on, color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter location';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        labelStyle: const TextStyle(color: Colors.black),
        hintText: 'Describe the animal\'s condition, behavior, etc.',
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Submit Report',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }
}