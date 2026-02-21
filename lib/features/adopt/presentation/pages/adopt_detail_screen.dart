import 'package:adoptnest/core/api/api_endpoints.dart';
import 'package:adoptnest/features/adopt/domain/entities/animal_post_entity.dart';
import 'package:adoptnest/features/adopt/presentation/state/animal_post_state.dart';
import 'package:adoptnest/features/adopt/presentation/view_model/animal_post_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const AdoptDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<AdoptDetailScreen> createState() => _AdoptDetailScreenState();
}

class _AdoptDetailScreenState extends ConsumerState<AdoptDetailScreen> {
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(animalPostViewModelProvider.notifier)
          .getPostById(widget.postId),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getFullImageUrl(String path) {
    if (path.isEmpty || path.startsWith('http')) return path;
    final base = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
    return '$base${path.startsWith('/') ? '' : '/'}$path';
  }

  void _copyId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reference ID copied to clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(animalPostViewModelProvider);
    final post = state.selectedPost;

    if (state.status == AnimalPostViewStatus.loading || post == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2.5),
        ),
      );
    }

    if (state.status == AnimalPostViewStatus.error) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(state.errorMessage ?? 'Failed to load post'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(animalPostViewModelProvider.notifier)
                    .getPostById(widget.postId),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final isAvailable = post.status == AnimalPostStatus.available;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo carousel
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  child: post.photos.isEmpty
                      ? Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.pets,
                                size: 72, color: Colors.grey),
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: post.photos.length,
                          onPageChanged: (i) =>
                              setState(() => _currentPhotoIndex = i),
                          itemBuilder: (_, i) => Image.network(
                            _getFullImageUrl(post.photos[i]),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: Icon(Icons.pets,
                                      size: 60, color: Colors.grey)),
                            ),
                          ),
                        ),
                ),

                // Status badge on photo
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isAvailable ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAvailable ? 'Available' : 'Adopted',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ),

                // Photo counter
                if (post.photos.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPhotoIndex + 1}/${post.photos.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),

            // Thumbnail strip
            if (post.photos.length > 1)
              Container(
                height: 68,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                    child: Container(
                      width: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _currentPhotoIndex == i
                              ? Colors.red
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          _getFullImageUrl(post.photos[i]),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.pets, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + status
                  Text(
                    post.breed,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${post.species} • ${post.gender}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),

                  const SizedBox(height: 20),

                  // Info grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        _InfoItem(label: 'Age', value: '${post.age} months'),
                        _divider(),
                        _InfoItem(label: 'Gender', value: post.gender),
                        _divider(),
                        _InfoItem(label: 'Species', value: post.species),
                        _divider(),
                        Expanded(
                          child: _InfoItem(
                              label: 'Location', value: post.location),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  if (post.description != null &&
                      post.description!.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.description!,
                      style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.6,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Divider(),
                  const SizedBox(height: 20),

                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Status',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          isAvailable ? 'Available' : 'Adopted',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isAvailable
                              ? 'This animal is looking for a home 🐾'
                              : 'This animal has found a home 🏠',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // How to adopt card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to Adopt',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Send this Reference ID along with a screenshot of this profile to our admin team.',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'REFERENCE ID',
                          style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            post.postId ?? '',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _copyId(post.postId ?? ''),
                            icon: const Icon(Icons.copy,
                                size: 16, color: Colors.white),
                            label: const Text('Copy Reference ID',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Metadata
                  Text(
                    'Posted: ${_formatDate(post.createdAt)}',
                    style:
                        TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  if (post.updatedAt != null)
                    Text(
                      'Updated: ${_formatDate(post.updatedAt!)}',
                      style:
                          TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 30,
        width: 1,
        color: Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
