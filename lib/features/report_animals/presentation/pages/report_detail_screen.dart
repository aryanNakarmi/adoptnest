import 'package:adoptnest/app/themes/font_data.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String reportId;
  final String? initialSpecies;
  final String? initialLocation;
  final double? initialLocationLat;
  final double? initialLocationLng;
  final String? initialImageUrl;
  final String? initialDescription;
  final String? initialStatus;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    this.initialSpecies,
    this.initialLocation,
    this.initialLocationLat,
    this.initialLocationLng,
    this.initialImageUrl,
    this.initialDescription,
    this.initialStatus,
  });

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  bool isDeleting = false;

  String _getFullImageUrl(String imagePath) {
    if (imagePath.isEmpty || imagePath.startsWith('http')) return imagePath;
    return '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}'
        '${imagePath.startsWith('/') ? '' : '/'}$imagePath';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _openOnMap() async {
    final lat = widget.initialLocationLat;
    final lng = widget.initialLocationLng;
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
        'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text(
          'Are you sure you want to delete the ${widget.initialSpecies} report? This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReport();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReport() async {
    setState(() => isDeleting = true);
    try {
      final success = await ref
          .read(animalReportViewModelProvider.notifier)
          .deleteReport(widget.reportId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Report deleted successfully'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to delete report'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusStr = widget.initialStatus ?? 'pending';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: isDeleting ? null : _showDeleteConfirmation,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[300],
                  child: widget.initialImageUrl != null &&
                          widget.initialImageUrl!.isNotEmpty
                      ? Image.network(
                          _getFullImageUrl(widget.initialImageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 60, color: Colors.grey[600]),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.image_outlined,
                              size: 60, color: Colors.grey[600])),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(statusStr),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusStr[0].toUpperCase() + statusStr.substring(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.initialSpecies ?? 'Unknown',
                    style: FontData.header1
                        .copyWith(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.initialLocation ?? 'Unknown location',
                              style: FontData.body1
                                  .copyWith(color: Colors.grey[700], fontSize: 16),
                            ),
                            if (widget.initialLocationLat != null &&
                                widget.initialLocationLng != null)
                              GestureDetector(
                                onTap: _openOnMap,
                                child: const Text(
                                  'Open on map ↗',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  if (widget.initialDescription != null &&
                      widget.initialDescription!.isNotEmpty) ...[
                    Text('Description',
                        style: FontData.header3
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      widget.initialDescription!,
                      style: FontData.body2
                          .copyWith(color: Colors.grey[700], height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 20),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Report ID: ${widget.reportId.length > 8 ? widget.reportId.substring(0, 8) : widget.reportId}...',
                        style: FontData.body2.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isDeleting
          ? Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
                ),
              ),
            )
          : null,
    );
  }
}
