import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/widgets/app_image.dart';
import 'custom_card.dart';

class AdminMovieManagementScreen extends StatefulWidget {
  const AdminMovieManagementScreen({super.key});

  @override
  State<AdminMovieManagementScreen> createState() => _AdminMovieManagementScreenState();
}

class _AdminMovieManagementScreenState extends State<AdminMovieManagementScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All Movies';
  String _selectedStatus = 'All Status'; // 'All Status', 'Active', 'Inactive'

  List<MovieModel> get _filteredMovies {
    return MockData.allMovies.where((movie) {
      final matchesSearch = _searchQuery.isEmpty ||
          movie.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          movie.genres.any((g) => g.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesCategory = _selectedCategory == 'All Movies' ||
          movie.genres.any((g) => g.toLowerCase() == _selectedCategory.toLowerCase());

      final matchesStatus = _selectedStatus == 'All Status' ||
          (_selectedStatus == 'Active' && movie.isActive) ||
          (_selectedStatus == 'Inactive' && !movie.isActive);

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Future<void> _toggleMovieStatus(MovieModel movie) async {
    final updated = movie.copyWith(isActive: !movie.isActive);
    final index = MockData.allMovies.indexWhere((m) => m.id == movie.id);
    if (index != -1) {
      setState(() {
        MockData.allMovies[index] = updated;
      });
      await MockData.saveAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${updated.title} is now ${updated.isActive ? "Active (Visible)" : "Inactive (Hidden)"}',
            ),
            backgroundColor: updated.isActive ? AppTheme.successGreen : AppTheme.darkRed,
          ),
        );
      }
    }
  }

  Future<void> _deleteMovie(MovieModel movie) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Movie'),
        content: Text('Are you sure you want to delete "${movie.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      MockData.allMovies.removeWhere((m) => m.id == movie.id);
      MockData.featuredMovies.removeWhere((m) => m.id == movie.id);
      MockData.movieSchedules.remove(movie.title);
      MockData.movieCast.remove(movie.title);
    });

    await MockData.saveAll();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${movie.title}" deleted successfully.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _showMovieDetails(MovieModel movie) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppImage(
                        urlOrPath: movie.posterUrl,
                        width: 100,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  movie.certification,
                                  style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${movie.duration} • ★ ${movie.rating}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: movie.genres.map((g) => Chip(
                              label: Text(g, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text('Overview', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(movie.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text('Theaters Available', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(movie.theaters.join(', '), style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditMovieDialog([MovieModel? existingMovie]) {
    final isEditing = existingMovie != null;
    final titleCtrl = TextEditingController(text: existingMovie?.title ?? '');
    final descCtrl = TextEditingController(text: existingMovie?.description ?? '');
    final durationCtrl = TextEditingController(text: existingMovie?.duration ?? '02:15');
    final posterCtrl = TextEditingController(text: existingMovie?.posterUrl ?? '');
    final bannerCtrl = TextEditingController(text: existingMovie?.bannerUrl ?? '');
    final certCtrl = TextEditingController(text: existingMovie?.certification ?? 'UA');
    final genreCtrl = TextEditingController(text: existingMovie?.genres.join(', ') ?? 'Action, Drama');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Movie' : 'Add New Movie'),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Movie Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: durationCtrl,
                        decoration: const InputDecoration(labelText: 'Duration (e.g. 02:15)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: certCtrl,
                        decoration: const InputDecoration(labelText: 'Certification (U/UA/A)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: genreCtrl,
                  decoration: const InputDecoration(labelText: 'Genres (comma-separated)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: posterCtrl,
                  decoration: const InputDecoration(labelText: 'Poster Image URL/Path'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bannerCtrl,
                  decoration: const InputDecoration(labelText: 'Banner Image URL/Path'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;

              final genresList = genreCtrl.text
                  .split(',')
                  .map((g) => g.trim())
                  .where((g) => g.isNotEmpty)
                  .toList();

              final poster = posterCtrl.text.trim().isNotEmpty
                  ? posterCtrl.text.trim()
                  : 'https://picsum.photos/seed/${titleCtrl.text.trim()}/300/450';

              final banner = bannerCtrl.text.trim().isNotEmpty
                  ? bannerCtrl.text.trim()
                  : poster;

              if (isEditing) {
                final updated = existingMovie.copyWith(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  duration: durationCtrl.text.trim(),
                  certification: certCtrl.text.trim(),
                  genres: genresList,
                  posterUrl: poster,
                  bannerUrl: banner,
                );
                final idx = MockData.allMovies.indexWhere((m) => m.id == existingMovie.id);
                if (idx != -1) {
                  MockData.allMovies[idx] = updated;
                }
              } else {
                final newMovie = MovieModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  duration: durationCtrl.text.trim(),
                  rating: 4.5,
                  certification: certCtrl.text.trim().isNotEmpty ? certCtrl.text.trim() : 'UA',
                  posterUrl: poster,
                  bannerUrl: banner,
                  genres: genresList.isNotEmpty ? genresList : ['Action'],
                  theaters: const ['Kairali', 'Nila'],
                  isActive: true,
                );
                MockData.allMovies.insert(0, newMovie);
              }

              await MockData.saveAll();
              setState(() {});
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            child: Text(isEditing ? 'Save Changes' : 'Add Movie'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movies = _filteredMovies;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Action Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Movie Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage total catalog, visibility, details, and schedules.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditMovieDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Movie'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Search & Filter Controls ──
          CustomCard(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 40,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search movies or genres...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                  items: MockData.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                  items: const [
                    DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                    DropdownMenuItem(value: 'Active', child: Text('Active Only')),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive Only')),
                  ],
                ),
                Text(
                  '${movies.length} movies found',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Movie Cards Grid ──
          if (movies.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Icon(Icons.movie_filter_outlined, size: 48, color: AppTheme.textLight),
                    const SizedBox(height: 12),
                    Text(
                      'No movies matching filter criteria.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 3
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AppImage(
                                  urlOrPath: movie.posterUrl,
                                  width: 80,
                                  height: 110,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            movie.title,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.info_outline, size: 18),
                                          onPressed: () => _showMovieDetails(movie),
                                          tooltip: 'Details',
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${movie.duration} • ${movie.certification}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text('${movie.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text('Visible:', style: TextStyle(fontSize: 12)),
                                        const SizedBox(width: 4),
                                        Transform.scale(
                                          scale: 0.75,
                                          child: Switch(
                                            value: movie.isActive,
                                            activeColor: AppTheme.primaryRed,
                                            onChanged: (_) => _toggleMovieStatus(movie),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            movie.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const Spacer(),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showAddEditMovieDialog(movie),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit'),
                              ),
                              TextButton.icon(
                                onPressed: () => _deleteMovie(movie),
                                icon: const Icon(Icons.delete, size: 16, color: AppTheme.errorRed),
                                label: const Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
