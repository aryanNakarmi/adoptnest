import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/features/adopt/domain/entities/animal_post_entity.dart';
import 'package:adoptnest/features/adopt/presentation/pages/adopt_detail_screen.dart';
import 'package:adoptnest/features/adopt/presentation/state/animal_post_state.dart';
import 'package:adoptnest/features/adopt/presentation/view_model/animal_post_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptScreen extends ConsumerStatefulWidget {
  const AdoptScreen({super.key});

  @override
  ConsumerState<AdoptScreen> createState() => _AdoptScreenState();
}

class _AdoptScreenState extends ConsumerState<AdoptScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  static const _genders = ['All', 'Male', 'Female'];
  static const _statuses = ['All', 'Available', 'Adopted'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(animalPostViewModelProvider.notifier).clearFilters();
        _searchController.clear();
        if (_tabController.index == 1) {
          ref.read(animalPostViewModelProvider.notifier).getMyAdoptions();
        }
      }
    });
    Future.microtask(
      () => ref.read(animalPostViewModelProvider.notifier).getAllPosts(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getFullImageUrl(String path) {
    if (path.isEmpty || path.startsWith('http')) return path;
    final base = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    return '$base${path.startsWith('/') ? '' : '/'}$path';
  }

  Color _statusColor(AnimalPostStatus status) =>
      status == AnimalPostStatus.available ? Colors.green : Colors.blue;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animalPostViewModelProvider);
    final vm = ref.read(animalPostViewModelProvider.notifier);

    final displayPosts = _tabController.index == 0
        ? state.filteredPosts
        : state.myAdoptions;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Adopt a Pet',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          tabs: [
            Tab(text: 'All Animals (${state.posts.length})'),
            Tab(text: 'My Adoptions (${state.myAdoptions.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: vm.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by breed, species, location...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          vm.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter chips row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Species dropdown chip
                  _FilterDropdown(
                    label: 'Species',
                    value: state.speciesFilter,
                    options: state.availableSpecies,
                    onChanged: vm.setSpeciesFilter,
                  ),
                  const SizedBox(width: 8),
                  // Gender dropdown chip
                  _FilterDropdown(
                    label: 'Gender',
                    value: state.genderFilter,
                    options: _genders,
                    onChanged: vm.setGenderFilter,
                  ),
                  const SizedBox(width: 8),
                  // Status dropdown chip
                  _FilterDropdown(
                    label: 'Status',
                    value: state.statusFilter,
                    options: _statuses,
                    onChanged: vm.setStatusFilter,
                  ),
                  // Clear all
                  if (state.speciesFilter != 'All' ||
                      state.genderFilter != 'All' ||
                      state.statusFilter != 'All') ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: vm.clearFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.close, size: 14, color: Colors.red),
                            SizedBox(width: 4),
                            Text('Clear',
                                style: TextStyle(
                                    color: Colors.red, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Body
          Expanded(
            child: state.status == AnimalPostViewStatus.loading &&
                    state.posts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                      strokeWidth: 2.5,
                    ),
                  )
                : state.status == AnimalPostViewStatus.error
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 60, color: Colors.red[300]),
                            const SizedBox(height: 12),
                            Text(state.errorMessage ?? 'Something went wrong'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: vm.getAllPosts,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Retry',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : displayPosts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pets,
                                    size: 72, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  _tabController.index == 1
                                      ? "You haven't adopted any animals yet"
                                      : 'No animals match your filters',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                if (state.speciesFilter != 'All' ||
                                    state.genderFilter != 'All' ||
                                    state.statusFilter != 'All' ||
                                    state.searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      vm.clearFilters();
                                    },
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    label: const Text('Clear Filters',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: Colors.red,
                            onRefresh: vm.getAllPosts,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: displayPosts.length,
                              itemBuilder: (context, index) {
                                final post = displayPosts[index];
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AdoptDetailScreen(postId: post.postId ?? ''),
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.07),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image
                                          Stack(
                                            children: [
                                              Container(
                                                height: 130,
                                                width: double.infinity,
                                                color: Colors.grey[200],
                                                child: post.photos.isNotEmpty
                                                    ? Image.network(
                                                        _getFullImageUrl(
                                                            post.photos.first),
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) =>
                                                            const Center(
                                                          child: Icon(
                                                              Icons.pets,
                                                              color: Colors
                                                                  .grey),
                                                        ),
                                                      )
                                                    : const Center(
                                                        child: Icon(Icons.pets,
                                                            color: Colors.grey),
                                                      ),
                                              ),
                                              // Photo count
                                              if (post.photos.length > 1)
                                                Positioned(
                                                  top: 6,
                                                  left: 6,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      '${post.photos.length} photos',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              // Status badge
                                              Positioned(
                                                top: 6,
                                                right: 6,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 7,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: _statusColor(
                                                        post.status),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    post.status ==
                                                            AnimalPostStatus
                                                                .available
                                                        ? 'Available'
                                                        : 'Adopted',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              // Adopted overlay
                                              if (post.status ==
                                                  AnimalPostStatus.adopted)
                                                Positioned.fill(
                                                  child: Container(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    child: const Center(
                                                      child: Icon(
                                                          Icons.favorite,
                                                          color: Colors.white,
                                                          size: 36),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),

                                          // Info
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    post.breed,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${post.species} • ${post.gender} • ${post.age}m',
                                                    style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 11),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    post.location,
                                                    style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 11),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    _formatDate(post.createdAt),
                                                    style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 10),
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
                          ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value != 'All';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.red : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 16, color: isActive ? Colors.white : Colors.grey[700]),
          style: TextStyle(
            fontSize: 13,
            color: isActive ? Colors.white : Colors.grey[800],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          dropdownColor: Colors.white,
          items: options.map((o) {
            return DropdownMenuItem(
              value: o,
              child: Text(o == 'All' ? label : o,
                  style: const TextStyle(color: Colors.black87, fontSize: 13)),
            );
          }).toList(),
          onChanged: (v) => onChanged(v ?? 'All'),
        ),
      ),
    );
  }
}
