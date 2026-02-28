import 'dart:io';
import 'package:adoptnest/app/routes/app_routes.dart';
import 'package:adoptnest/features/home/presentation/pages/home_screen.dart';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:adoptnest/features/report_animals/domain/entities/location_value.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';
import 'package:adoptnest/features/report_animals/presentation/widgets/map_location_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/snackbar_utils.dart';

class ReportAnimalScreen extends ConsumerStatefulWidget {
  const ReportAnimalScreen({super.key});

  @override
  ConsumerState<ReportAnimalScreen> createState() => _ReportAnimalScreenState();
}

class _ReportAnimalScreenState extends ConsumerState<ReportAnimalScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  File? _image;
  final _speciesController = TextEditingController();
  final _descriptionController = TextEditingController();
  LocationValue? _selectedLocation;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _image = null;
      _selectedLocation = null;
      _speciesController.clear();
      _descriptionController.clear();
    });
    ref.read(animalReportViewModelProvider.notifier).resetUploadedPhoto();
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) SnackbarUtils.showError(context, 'Camera permission denied');
      return false;
    }
    return true;
  }

  Future<bool> _requestGalleryPermission() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (mounted) SnackbarUtils.showError(context, 'Gallery permission denied');
      return false;
    }
    return true;
  }

  Future<void> _openCamera() async {
    if (!await _requestCameraPermission()) return;
    try {
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (photo == null) return;
      final imageFile = File(photo.path);
      setState(() => _image = imageFile);
      await ref.read(animalReportViewModelProvider.notifier).uploadPhoto(imageFile);
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Failed to pick image: $e');
    }
  }

  Future<void> _openGallery() async {
    if (!await _requestGalleryPermission()) return;
    try {
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (photo == null) return;
      final imageFile = File(photo.path);
      setState(() => _image = imageFile);
      await ref.read(animalReportViewModelProvider.notifier).uploadPhoto(imageFile);
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Failed to pick image: $e');
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('Select Image Source',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.red),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.red),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _openGallery();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(animalReportViewModelProvider);

    if (state.uploadedPhotoUrl == null) {
      SnackbarUtils.showError(context, 'Please capture a photo');
      return;
    }
    if (_selectedLocation == null) {
      SnackbarUtils.showError(context, 'Please select a location on the map');
      return;
    }

    final report = AnimalReportEntity(
      reportId: const Uuid().v4(),
      species: _speciesController.text.trim(),
      location: _selectedLocation!,
      description: _descriptionController.text.trim(),
      imageUrl: state.uploadedPhotoUrl!,
      reportedBy: '',
      status: AnimalReportStatus.pending,
      createdAt: DateTime.now(),
    );

    await ref.read(animalReportViewModelProvider.notifier).createReport(report);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animalReportViewModelProvider);
    final isLoading = state.status == AnimalReportViewStatus.loading;

    ref.listen<AnimalReportState>(animalReportViewModelProvider, (prev, next) {
      if (prev?.status == AnimalReportViewStatus.loading &&
          next.status == AnimalReportViewStatus.created) {
        SnackbarUtils.showSuccess(context, 'Animal reported successfully!');
        _clearForm();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) AppRoutes.pushAndRemoveUntil(context, const HomeScreen());
        });
      }
      if (next.status == AnimalReportViewStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
      if (next.status == AnimalReportViewStatus.loading) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
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
                          const SizedBox(height: 24),
                          _buildSpeciesField(),
                          const SizedBox(height: 16),
                          _buildLocationSection(),
                          const SizedBox(height: 16),
                          _buildDescriptionField(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(isLoading),
                          const SizedBox(height: 12),
                          _buildClearButton(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            IgnorePointer(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.all(20),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Report an Animal',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      );

  Widget _buildPhotoSection() => GestureDetector(
        onTap: _showImageSourceBottomSheet,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: _image == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 44, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text('Tap to capture or select photo',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                ),
        ),
      );

  Widget _buildSpeciesField() => TextFormField(
        controller: _speciesController,
        validator: (val) =>
            val == null || val.isEmpty ? 'Please enter animal species' : null,
        decoration: _inputDecoration(
            label: 'Animal Species', hint: 'e.g., Dog, Cat, Bird', icon: Icons.pets),
      );

  Widget _buildLocationSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(
                    text: 'Location',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          MapLocationPicker(
            value: _selectedLocation,
            onChange: (loc) => setState(() => _selectedLocation = loc),
          ),
        ],
      );

  Widget _buildDescriptionField() => TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        maxLength: 500,
        decoration: _inputDecoration(
          label: 'Description (Optional)',
          hint: "Describe the animal's condition, behavior, etc.",
        ),
      );

  InputDecoration _inputDecoration(
      {required String label, required String hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.red) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: Colors.white,
      filled: true,
    );
  }

  Widget _buildSubmitButton(bool isLoading) => ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          disabledBackgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Submit Report',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      );

  Widget _buildClearButton() => OutlinedButton(
        onPressed: _clearForm,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.grey, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Clear Form',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      );
}
