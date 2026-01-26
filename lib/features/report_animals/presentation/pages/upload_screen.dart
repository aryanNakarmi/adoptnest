import 'dart:io';
import 'package:adoptnest/features/report_animals/domain/entities/animal_report_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';


import '../../../../core/utils/snackbar_utils.dart';

class ReportAnimalPage extends ConsumerStatefulWidget {
  const ReportAnimalPage({super.key});

  @override
  ConsumerState<ReportAnimalPage> createState() => _ReportAnimalPageState();
}

class _ReportAnimalPageState extends ConsumerState<ReportAnimalPage> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _timestamp = '';
  String? _uploadedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _updateTimestamp();
  }

  void _updateTimestamp() {
    _timestamp = DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now());
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_uploadedPhotoUrl == null) {
        SnackbarUtils.showError(context, 'Please upload a photo');
        return;
      }

      final report = AnimalReportEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        species: _speciesController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _uploadedPhotoUrl!,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await ref
          .read(animalReportViewModelProvider.notifier)
          .createReport(report);
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This feature requires permission to access your camera or gallery.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: openAppSettings, child: const Text('Open Settings')),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo =
        await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (photo != null) {
      setState(() => _selectedImage = File(photo.path));
      final url = await ref
          .read(animalReportViewModelProvider.notifier)
          .uploadPhoto(File(photo.path));
      _uploadedPhotoUrl = url;
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
      final url = await ref
          .read(animalReportViewModelProvider.notifier)
          .uploadPhoto(File(image.path));
      _uploadedPhotoUrl = url;
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.camera), title: const Text('Camera'), onTap: _pickFromCamera),
          ListTile(leading: const Icon(Icons.photo), title: const Text('Gallery'), onTap: _pickFromGallery),
        ],
      ),
    );
  }

  void _clearForm() {
    _speciesController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(animalReportViewModelProvider);

    ref.listen<AnimalReportState>(animalReportViewModelProvider, (prev, next) {
      if (next.status == AnimalReportStatus.created) {
        SnackbarUtils.showSuccess(context, 'Animal reported successfully!');
        _clearForm();
        Navigator.pop(context);
      } else if (next.status == AnimalReportStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Report Animal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showMediaPicker,
                  child: _selectedImage == null
                      ? Container(
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Text("Upload Photo")),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_selectedImage!, height: 250, fit: BoxFit.cover),
                        ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(labelText: 'Species'),
                  validator: (v) => v!.isEmpty ? 'Enter species' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (v) => v!.isEmpty ? 'Enter location' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: reportState.status == AnimalReportStatus.loading
                      ? null
                      : _handleSubmit,
                  child: reportState.status == AnimalReportStatus.loading
                      ? const CircularProgressIndicator()
                      : const Text("Submit"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
