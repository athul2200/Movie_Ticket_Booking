import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/models/cast_model.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/widgets/admin_text_field.dart';
import 'package:booking/screens/owner/widgets/admin_dropdown.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';

import 'package:booking/core/utils/ist_time_utils.dart';

class OwnerMoviesScreen extends StatefulWidget {
  final String theaterName;
  const OwnerMoviesScreen({super.key, this.theaterName = 'Kairali'});

  @override
  State<OwnerMoviesScreen> createState() => _OwnerMoviesScreenState();
}

class _OwnerMoviesScreenState extends State<OwnerMoviesScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _movieNameCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _trailerCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _posterUrlCtrl = TextEditingController();
  
  String _selectedLanguage = 'English';
  String _selectedCertification = 'UA';
  String _posterSource = 'URL'; // 'URL' or 'Upload'
  String? _uploadedPosterName;
  String? _editingMovieId;
  final ScrollController _scrollController = ScrollController();

  List<MovieModel> get _managedMovies {
    return MockData.allMovies
        .where((m) => m.theaters.contains(widget.theaterName))
        .toList();
  }

  // ── Cast entries ──
  final List<_CastEntry> _castMembers = [];
  void _addCastMember() {
    setState(() => _castMembers.add(_CastEntry()));
  }
  void _removeCastMember(int index) {
    if (index >= 0 && index < _castMembers.length) {
      final removed = _castMembers.removeAt(index);
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        removed.dispose();
      });
    }
  }
  
  @override
  void dispose() {
    _movieNameCtrl.dispose();
    _durationCtrl.dispose();
    _trailerCtrl.dispose();
    _descriptionCtrl.dispose();
    _posterUrlCtrl.dispose();
    _scrollController.dispose();
    for (final c in _castMembers) {
      c.dispose();
    }
    super.dispose();
  }

  void _editMovie(MovieModel movie) {
    setState(() {
      _editingMovieId = movie.id;
      _movieNameCtrl.text = movie.title;
      _descriptionCtrl.text = movie.description;
      _posterSource = 'URL';
      _posterUrlCtrl.text = movie.posterUrl;
      _uploadedPosterName = null;
      _selectedLanguage = movie.genres.isNotEmpty ? movie.genres.first : 'English';
      if (!['English', 'Malayalam', 'Tamil', 'Hindi', 'Telugu'].contains(_selectedLanguage)) {
        _selectedLanguage = 'English';
      }
      _selectedCertification = movie.certification.isNotEmpty ? movie.certification : 'UA';
      if (!['U', 'UA'].contains(_selectedCertification)) {
        _selectedCertification = 'UA';
      }
      _durationCtrl.text = movie.duration;
      _trailerCtrl.text = movie.trailerUrl;

      // Load cast
      for (final c in _castMembers) {
        c.dispose();
      }
      _castMembers.clear();
      final existingCast = MockData.movieCast[movie.title] ?? [];
      for (final castItem in existingCast) {
        final entry = _CastEntry();
        entry.nameCtrl.text = castItem.name;
        entry.selectedRole = castItem.role;
        _castMembers.add(entry);
      }
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _cancelEdit() {
    _formKey.currentState?.reset();
    _movieNameCtrl.clear();
    _descriptionCtrl.clear();
    _durationCtrl.clear();
    _trailerCtrl.clear();
    _posterUrlCtrl.clear();
    final oldCast = List<_CastEntry>.from(_castMembers);
    _castMembers.clear();
    setState(() {
      _editingMovieId = null;
      _uploadedPosterName = null;
      _selectedLanguage = 'English';
      _selectedCertification = 'UA';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in oldCast) {
        c.dispose();
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_posterSource == 'URL' && _posterUrlCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a poster URL.')),
        );
        return;
      } else if (_posterSource == 'Upload' && _uploadedPosterName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a poster image.')),
        );
        return;
      }
      
      final String poster = _posterSource == 'URL'
          ? _posterUrlCtrl.text
          : 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=2070&auto=format&fit=crop';

      final String updatedTitle = _movieNameCtrl.text.trim();

      if (_editingMovieId != null) {
        // Find existing movie
        final existingIndex = MockData.allMovies.indexWhere((m) => m.id == _editingMovieId);
        final oldMovieTitle = existingIndex != -1 ? MockData.allMovies[existingIndex].title : '';
        final currentTheaters = existingIndex != -1 ? MockData.allMovies[existingIndex].theaters : [widget.theaterName];
        final updatedTheaters = Set<String>.from(currentTheaters)..add(widget.theaterName);

        final updatedMovie = MovieModel(
          id: _editingMovieId!,
          title: updatedTitle,
          description: _descriptionCtrl.text.trim(),
          genres: [_selectedLanguage],
          duration: _durationCtrl.text.trim(),
          rating: existingIndex != -1 ? MockData.allMovies[existingIndex].rating : 4.5,
          certification: _selectedCertification,
          posterUrl: poster,
          bannerUrl: poster,
          trailerUrl: _trailerCtrl.text.trim(),
          theaters: updatedTheaters.toList(),
        );

        if (existingIndex != -1) {
          MockData.allMovies[existingIndex] = updatedMovie;
        }
        final featIndex = MockData.featuredMovies.indexWhere((m) => m.id == _editingMovieId);
        if (featIndex != -1) {
          MockData.featuredMovies[featIndex] = updatedMovie;
        }

        // Transfer schedule and cast if title changed
        if (oldMovieTitle.isNotEmpty && oldMovieTitle != updatedTitle) {
          if (MockData.movieSchedules.containsKey(oldMovieTitle)) {
            MockData.movieSchedules[updatedTitle] = MockData.movieSchedules.remove(oldMovieTitle)!;
          }
          if (MockData.movieCast.containsKey(oldMovieTitle)) {
            MockData.movieCast.remove(oldMovieTitle);
          }
        }

        // Save updated cast
        if (_castMembers.isNotEmpty) {
          MockData.movieCast[updatedTitle] = _castMembers
              .where((c) => c.nameCtrl.text.trim().isNotEmpty)
              .map((c) => CastModel(
                    name: c.nameCtrl.text.trim(),
                    role: c.selectedRole,
                    imageUrl: 'https://picsum.photos/seed/${Uri.encodeComponent(c.nameCtrl.text.trim())}/200/200',
                  ))
              .toList();
        } else {
          MockData.movieCast.remove(updatedTitle);
        }

        await MockData.saveAll();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Movie updated successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } else {
        // Check if movie with same title already exists
        final existingIdx = MockData.allMovies.indexWhere(
          (m) => m.title.trim().toLowerCase() == updatedTitle.toLowerCase(),
        );

        if (existingIdx != -1) {
          final existing = MockData.allMovies[existingIdx];
          final updatedTheaters = Set<String>.from(existing.theaters)..add(widget.theaterName);
          final updated = existing.copyWith(
            description: _descriptionCtrl.text.trim(),
            genres: [_selectedLanguage],
            duration: _durationCtrl.text.trim(),
            certification: _selectedCertification,
            posterUrl: poster,
            bannerUrl: poster,
            trailerUrl: _trailerCtrl.text.trim(),
            theaters: updatedTheaters.toList(),
          );
          MockData.allMovies[existingIdx] = updated;
          final featIdx = MockData.featuredMovies.indexWhere((m) => m.id == existing.id);
          if (featIdx != -1) {
            MockData.featuredMovies[featIdx] = updated;
          }
        } else {
          final newMovie = MovieModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: updatedTitle,
            description: _descriptionCtrl.text.trim(),
            genres: [_selectedLanguage],
            duration: _durationCtrl.text.trim(),
            rating: 4.5,
            certification: _selectedCertification,
            posterUrl: poster,
            bannerUrl: poster,
            trailerUrl: _trailerCtrl.text.trim(),
            theaters: [widget.theaterName],
          );

          MockData.allMovies.insert(0, newMovie);
          MockData.featuredMovies.insert(0, newMovie);
        }

        // Save per-movie cast
        if (_castMembers.isNotEmpty) {
          MockData.movieCast[updatedTitle] = _castMembers
              .where((c) => c.nameCtrl.text.trim().isNotEmpty)
              .map((c) => CastModel(
                    name: c.nameCtrl.text.trim(),
                    role: c.selectedRole,
                    imageUrl: 'https://picsum.photos/seed/${Uri.encodeComponent(c.nameCtrl.text.trim())}/200/200',
                  ))
              .toList();
        }

        await MockData.saveAll();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Movie added successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }

      _cancelEdit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(title: widget.theaterName, noLeading: true),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text(
              'Movie Management',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add new titles to your catalog and manage\nexisting theater listings.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Add New Movie Card ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _editingMovieId != null ? Icons.edit : Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _editingMovieId != null ? 'Edit Movie' : 'Add New Movie',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (_editingMovieId != null)
                          TextButton(
                            onPressed: _cancelEdit,
                            child: const Text('Cancel Edit'),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Movie Name',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AdminTextField(
                      controller: _movieNameCtrl,
                      hintText: 'e.g. Interstellar',
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'Movie Description',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AdminTextField(
                      controller: _descriptionCtrl,
                      hintText: 'Enter movie synopsis or description...',
                      maxLines: 3,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'Movie Poster',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'URL',
                          groupValue: _posterSource,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _posterSource = val!),
                        ),
                        const Text('Image URL'),
                        const SizedBox(width: AppSpacing.md),
                        Radio<String>(
                          value: 'Upload',
                          groupValue: _posterSource,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _posterSource = val!),
                        ),
                        const Text('Upload from Device'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (_posterSource == 'URL')
                      AdminTextField(
                        controller: _posterUrlCtrl,
                        hintText: 'https://example.com/poster.jpg',
                        prefixIcon: const Icon(
                          Icons.link,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _uploadedPosterName = image.name;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.divider,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _uploadedPosterName != null
                                    ? Icons.check_circle_outline
                                    : Icons.cloud_upload_outlined,
                                color: _uploadedPosterName != null
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 32,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _uploadedPosterName ?? 'Tap to browse files',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _uploadedPosterName != null
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Language',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              AdminDropdown<String>(
                                value: _selectedLanguage,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'English',
                                    child: Text('English'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Malayalam',
                                    child: Text('Malayalam'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Tamil',
                                    child: Text('Tamil'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Hindi',
                                    child: Text('Hindi'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Telugu',
                                    child: Text('Telugu'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedLanguage = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sensor Certificate',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              AdminDropdown<String>(
                                value: _selectedCertification,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'UA',
                                    child: Text('UA'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'U',
                                    child: Text('U'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCertification = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'Duration',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AdminTextField(
                      controller: _durationCtrl,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        TimeDurationFormatter(),
                      ],
                      hintText: 'HH:MM (e.g. 02:30)',
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'YouTube Trailer Link',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AdminTextField(
                      controller: _trailerCtrl,
                      hintText: 'https://youtube.com/watch?v=...',
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                      prefixIcon: const Icon(
                        Icons.play_circle_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Cast Members ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cast & Crew',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton.icon(
                          onPressed: _addCastMember,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            'Add Member',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_castMembers.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Center(
                          child: Text(
                            'No cast members added yet',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _castMembers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final entry = _castMembers[index];
                          return _buildCastEntryRow(index, entry, key: entry.key);
                        },
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    AdminButton(
                      text: _editingMovieId != null ? 'Update Movie' : 'Save Movie',
                      onPressed: _submitForm,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Banner Card ──
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=2070&auto=format&fit=crop',
                  ), // Cinema hall abstract
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expand Your Library',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add up to 50 active listings per theater.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Currently Managed Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Currently Managed',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.grid_view,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.format_list_bulleted,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Movie List — dynamic from MockData
            if (_managedMovies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    'No movies added for ${widget.theaterName} yet. Use the form above to add one.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ..._managedMovies.asMap().entries.map((entry) {
                final index = entry.key;
                final movie = entry.value;
                final isLive = MockData.movieSchedules.containsKey(movie.title) &&
                    (MockData.movieSchedules[movie.title]?.values.any((dates) => dates.containsKey(widget.theaterName)) ?? false);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < _managedMovies.length - 1 ? AppSpacing.md : 0,
                  ),
                  child: _buildManagedMovieCard(
                    title: movie.title,
                    duration: movie.duration,
                    imageUrl: movie.posterUrl,
                    badgeText: isLive ? 'Running Now' : null,
                    isLive: isLive,
                    onEdit: () => _editMovie(movie),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Remove Movie'),
                          content: Text('Remove "${movie.title}" from ${widget.theaterName}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Remove',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        setState(() {
                          final remainingTheaters = List<String>.from(movie.theaters)..remove(widget.theaterName);
                          if (remainingTheaters.isEmpty) {
                            MockData.allMovies.removeWhere((m) => m.id == movie.id);
                            MockData.featuredMovies.removeWhere((m) => m.id == movie.id);
                          } else {
                            final idx = MockData.allMovies.indexWhere((m) => m.id == movie.id);
                            if (idx != -1) {
                              MockData.allMovies[idx] = movie.copyWith(theaters: remainingTheaters);
                            }
                          }
                          if (MockData.movieSchedules.containsKey(movie.title)) {
                            MockData.movieSchedules[movie.title]?.values.forEach((datesMap) {
                              datesMap.remove(widget.theaterName);
                            });
                          }
                        });
                        await MockData.saveAll();
                      }
                    },
                  ),
                );
              }),
            const SizedBox(height: AppSpacing.xl),

            // Add More Movies Button
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: AppColors.background,
                side: const BorderSide(
                  color: AppColors.divider,
                  style: BorderStyle.solid,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Add More Movies',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildManagedMovieCard({
    required String title,
    required String duration,
    required String imageUrl,
    required String? badgeText,
    required bool isLive,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(Icons.movie, size: 40, color: AppColors.textHint),
                    ),
                  ),
                ),
              ),
              if (badgeText != null)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isLive
                          ? const Color(0xFF16A34A)
                          : AppColors.textWhite.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          badgeText,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isLive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Delete button overlay
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        duration,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastEntryRow(int index, _CastEntry entry, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar placeholder
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              entry.nameCtrl.text.isNotEmpty
                  ? entry.nameCtrl.text[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name field
                TextFormField(
                  controller: entry.nameCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cast Name',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Role selector
                DropdownButtonFormField<String>(
                  value: entry.selectedRole,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(value: 'ACTOR', child: Text('Actor')),
                    DropdownMenuItem(value: 'ACTRESS', child: Text('Actress')),
                    DropdownMenuItem(value: 'DIRECTOR', child: Text('Director')),
                    DropdownMenuItem(value: 'PRODUCER', child: Text('Producer')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => entry.selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => _removeCastMember(index),
            child: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeDurationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    // Allow deleting the colon smoothly
    if (oldValue.text.length == 3 &&
        oldValue.text.endsWith(':') &&
        newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Keep only digits
    String cleanText = newText.replaceAll(RegExp(r'[^0-9]'), '');

    // Max 4 digits (HHMM)
    if (cleanText.length > 4) {
      cleanText = cleanText.substring(0, 4);
    }

    String formattedText = '';

    for (int i = 0; i < cleanText.length; i++) {
      if (i == 2) {
        formattedText += ':';
      }
      formattedText += cleanText[i];
    }

    // Auto-append colon after 2 digits when typing forward
    if (cleanText.length == 2 && newValue.text.length > oldValue.text.length) {
      formattedText += ':';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Simple data holder for a single cast entry row in the form.
class _CastEntry {
  final Key key = UniqueKey();
  final TextEditingController nameCtrl = TextEditingController();
  String selectedRole = 'ACTOR';

  void dispose() => nameCtrl.dispose();
}
