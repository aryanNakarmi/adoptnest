import 'package:adoptnest/app/themes/font_data.dart';
import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/core/services/storage/user_session_service.dart';
import 'package:adoptnest/features/report_animals/presentation/view_model/animal_report_viewmodel.dart';
import 'package:adoptnest/features/report_animals/presentation/state/animal_report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback? onAdoptTap;

  const DashboardScreen({super.key, this.onAdoptTap});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  // ✅ FIX: Correct image URL builder
  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}'
        '${imagePath.startsWith('/') ? '' : '/'}$imagePath';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userSession = ref.read(userSessionServiceProvider);
      final userId = userSession.getCurrentUserId() ?? '';
      if (userId.isNotEmpty) {
        ref.read(animalReportViewModelProvider.notifier).getMyReports(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSession = ref.watch(userSessionServiceProvider);
    final fullName = userSession.getCurrentUserFullName() ?? 'User';
    final userId = userSession.getCurrentUserId() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome back", style: FontData.body2),
                    const SizedBox(height: 4),
                    Text(fullName, style: FontData.header1),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded, size: 28),
                ),
              ],
            ),
          ),

          Container(
            height: 270,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://hips.hearstapps.com/hmg-prod/images/dog-puppy-on-garden-royalty-free-image-1586966191.jpg",
                ),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Container(color: Colors.black.withOpacity(0.25)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Help a stray today",
                          style: FontData.header2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Every small act of kindness makes a huge difference in a life.",
                          style: FontData.body2.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Help a Stray"),
                                content: const Text(
                                    "Every small act of kindness can save a life! Volunteer, adopt, or donate to local shelters."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text("Learn More"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onAdoptTap,
                icon: const Icon(Icons.pets, color: Colors.red),
                label: Text("Adopt", style: FontData.body1.copyWith(color: Colors.red)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("My Reports", style: FontData.header2),
                    Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(animalReportViewModelProvider);
                        if (state.myReports.isNotEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${state.myReports.length}",
                              style: FontData.body2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(animalReportViewModelProvider);

                    if (state.status == AnimalReportViewStatus.loading) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: const [
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                              SizedBox(height: 12),
                              Text("Loading your reports..."),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state.status == AnimalReportViewStatus.error) {
                      return Center(child: Text(state.errorMessage ?? "Error loading reports"));
                    }
                    if (state.myReports.isEmpty) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      return Center(
                        child: Container(
                          width: screenWidth * 0.8, // 80% of the screen width
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon(Icons.report_gmailerrorred_outlined, size: 40, color: Colors.red.shade400),
                              const SizedBox(height: 40),
                              Text(
                                "No reports yet",
                                textAlign: TextAlign.center,
                                style: FontData.body1.copyWith(color: Colors.red.shade600, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Start by reporting an animal to help them find a safe home.",
                                textAlign: TextAlign.center,
                                style: FontData.body2.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    }




                    return SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.myReports.length,
                        itemBuilder: (context, index) {
                          final report = state.myReports[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == state.myReports.length - 1 ? 0 : 12,
                            ),
                            child: _buildReportCard(
                              species: report.species ?? "Unknown",
                              location: report.location ?? "Unknown",
                              status: report.status?.name ?? "Pending",
                              imageUrl: report.imageUrl ?? "",
                              description: report.description ?? "",
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String species,
    required String location,
    required String status,
    required String imageUrl,
    required String description,
  }) {
    final fullImageUrl = _getFullImageUrl(imageUrl);

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species,
                    style: FontData.body2.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    location,
                    style: FontData.body2.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: FontData.body2.copyWith(color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
