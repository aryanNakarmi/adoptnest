import 'package:adoptnest/app/themes/font_data.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/core/services/storage/user_session_service.dart';
import 'package:adoptnest/features/report_animals/presentation/pages/report_detail_screen.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(userSessionServiceProvider).getCurrentUserId() ?? '';
      if (userId.isNotEmpty) {
        ref.read(animalReportViewModelProvider.notifier).getMyReports(userId);
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final userSession = ref.watch(userSessionServiceProvider);
    final userId = userSession.getCurrentUserId() ?? '';
    final state = ref.watch(animalReportViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Reports', style: FontData.header2.copyWith(color: Colors.black)),
            Text(
              '${state.myReports.length} report${state.myReports.length != 1 ? 's' : ''}',
              style: FontData.body2.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: state.status == AnimalReportViewStatus.loading
          ? const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red)))
          : state.status == AnimalReportViewStatus.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(state.errorMessage ?? 'Error loading reports'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(animalReportViewModelProvider.notifier)
                            .getMyReports(userId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.myReports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined,
                              size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 20),
                          Text('No reports yet',
                              style: FontData.header2.copyWith(color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Text(
                            'Start creating animal reports to help animals in need',
                            style: FontData.body2.copyWith(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Back to Dashboard'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.myReports.length,
                      itemBuilder: (context, index) {
                        final report = state.myReports[index];
                        final locationAddress = report.location.address;

                        return GestureDetector(
                          onTap: () async {
                            final deleted = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportDetailScreen(
                                  reportId: report.reportId ?? '',
                                  initialSpecies: report.species,
                                  initialLocation: locationAddress,
                                  initialLocationLat: report.location.lat,
                                  initialLocationLng: report.location.lng,
                                  initialImageUrl: report.imageUrl,
                                  initialDescription: report.description,
                                  initialStatus: report.status.name,
                                ),
                              ),
                            );
                            if (deleted == true) {
                              ref
                                  .read(animalReportViewModelProvider.notifier)
                                  .getMyReports(userId);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        height: 120,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: report.imageUrl.isNotEmpty
                                            ? Image.network(
                                                _getFullImageUrl(report.imageUrl),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Icon(
                                                    Icons.image_not_supported_outlined,
                                                    color: Colors.grey[600]),
                                              )
                                            : Icon(Icons.image_outlined,
                                                color: Colors.grey[600]),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(report.status.name),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            report.status.name
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            report.species,
                                            style: FontData.body2
                                                .copyWith(fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on,
                                                  size: 12, color: Colors.grey[500]),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(
                                                  locationAddress,
                                                  style: FontData.body2.copyWith(
                                                      color: Colors.grey[600],
                                                      fontSize: 11),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (report.description != null &&
                                              report.description!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                report.description!,
                                                style: FontData.body2.copyWith(
                                                    color: Colors.grey[500],
                                                    fontSize: 11),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
