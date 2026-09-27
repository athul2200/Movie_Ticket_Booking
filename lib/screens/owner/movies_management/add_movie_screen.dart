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
import 'package:booking/widgets/app_image.dart';

/// ============================================================
/// Add / Edit Movie Screen — Pure form for entering movie details
/// (No running movies list shown here)
/// ============================================================

class AddMovieScreen extends StatefulWidget {
  final String theaterName;
  final MovieModel? movieToEdit;

  const AddMovieScreen({
    super.key,
    this.theaterName = 'Kairali',
    this.movieToEdit,
  });

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _trailerCtrl;
  late final TextEditingController _posterUrlCtrl;

  String _selectedLanguage = 'English';
  String _selectedCertification = 'UA';
  String _posterSource = 'URL';
  String? _uploadedPosterPath;

  final List<_CastEntry> _castMembers = [];

  @override
  void initState() {
    super.initState();
    final movie = widget.movieToEdit;

    _titleCtrl = TextEditingController(text: movie?.title ?? '');
    _descriptionCtrl = TextEditingController(text: movie?.description ?? '');
    _durationCtrl = TextEditingController(text: movie?.duration ?? '');
    _trailerCtrl = TextEditingController(text: movie?.trailerUrl ?? '');
    _posterUrlCtrl = TextEditingController();

    if (movie != null) {
      final isUrl = movie.posterUrl.startsWith('http://') ||
          movie.posterUrl.startsWith('https://') ||
          movie.posterUrl.startsWith('blob:') ||
          movie.posterUrl.startsWith('data:');

      if (isUrl) {
        _posterSource = 'URL';
        _posterUrlCtrl.text = movie.posterUrl;
      } else {
        _posterSource = 'Upload';
        _uploadedPosterPath = movie.posterUrl;
      }

      if (movie.genres.isNotEmpty) {
        _selectedLanguage = movie.genres.first;
        if (!['English', 'Malayalam', 'Tamil', 'Hindi', 'Telugu'].contains(_selectedLanguage)) {
          _selectedLanguage = 'English';
        }
      }
      if (movie.certification.isNotEmpty) {
        _selectedCertification = movie.certification;
        if (!['U', 'UA'].contains(_selectedCertification)) {
          _selectedCertification = 'UA';
        }
      }

      final existingCast = MockData.movieCast[movie.title] ?? [];
      for (final c in existingCast) {
        final entry = _CastEntry();
        entry.nameCtrl.text = c.name;
        entry.selectedRole = c.role;
        _castMembers.add(entry);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _durationCtrl.dispose();
    _trailerCtrl.dispose();
    _posterUrlCtrl.dispose();
    for (final c in _castMembers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCastMember() {
    setState(() => _castMembers.add(_CastEntry()));
  }

  void _removeCastMember(int index) {
    if (index >= 0 && index < _castMembers.length) {
      final removed = _castMembers.removeAt(index);
      setState(() {});
      removed.dispose();
    }
  }

  Future<void> _pickPosterImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _uploadedPosterPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_posterSource == 'URL' && _posterUrlCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a poster URL.')),
        );
        return;
      } else if (_posterSource == 'Upload' && _uploadedPosterPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a poster image from device.')),
        );
        return;
      }

      final String poster = _posterSource == 'URL'
          ? _posterUrlCtrl.text.trim()
          : _uploadedPosterPath!;
      final String updatedTitle = _titleCtrl.text.trim();

      if (widget.movieToEdit != null) {
        final movieToEdit = widget.movieToEdit!;
        final existingIndex = MockData.allMovies.indexWhere((m) => m.id == movieToEdit.id);
        final currentTheaters = existingIndex != -1 ? MockData.allMovies[existingIndex].theaters : [widget.theaterName];
        final updatedTheaters = Set<String>.from(currentTheaters)..add(widget.theaterName);

        final updatedMovie = MovieModel(
          id: movieToEdit.id,
          title: updatedTitle,
          description: _descriptionCtrl.text.trim(),
          genres: [_selectedLanguage],
          duration: _durationCtrl.text.trim(),
          rating: movieToEdit.rating,
          certification: _selectedCertification,
          posterUrl: poster,
          bannerUrl: poster,
          trailerUrl: _trailerCtrl.text.trim(),
          theaters: updatedTheaters.toList(),
          isActive: movieToEdit.isActive,
        );

        if (existingIndex != -1) {
          MockData.allMovies[existingIndex] = updatedMovie;
        }
        final featIndex = MockData.featuredMovies.indexWhere((m) => m.id == movieToEdit.id);
        if (featIndex != -1) {
          MockData.featuredMovies[featIndex] = updatedMovie;
        }

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
              content: Text('Movie updated successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
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
            isActive: true,
          );

          MockData.allMovies.insert(0, newMovie);
          MockData.featuredMovies.insert(0, newMovie);
        }

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
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movieToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(title: isEdit ? 'Edit Movie' : 'Add New Movie'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title & Subtitle ──
              Text(
                isEdit ? 'Edit Movie Details' : 'Enter Movie Details',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Fill in the information below to ${isEdit ? "update" : "add"} a movie for ${widget.theaterName}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Movie Name ──
              Text('Movie Name', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              AdminTextField(
                controller: _titleCtrl,
                hintText: 'e.g. Interstellar',
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Description ──
              Text('Movie Description', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              AdminTextField(
                controller: _descriptionCtrl,
                hintText: 'Enter synopsis or overview...',
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Poster Selection ──
              Text('Movie Poster', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  // ignore: deprecated_member_use
                  Radio<String>(
                    value: 'URL',
                    // ignore: deprecated_member_use
                    groupValue: _posterSource,
                    activeColor: AppColors.primary,
                    // ignore: deprecated_member_use
                    onChanged: (val) => setState(() => _posterSource = val!),
                  ),
                  const Text('Image URL'),
                  const SizedBox(width: AppSpacing.md),
                  // ignore: deprecated_member_use
                  Radio<String>(
                    value: 'Upload',
                    // ignore: deprecated_member_use
                    groupValue: _posterSource,
                    activeColor: AppColors.primary,
                    // ignore: deprecated_member_use
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
                  prefixIcon: const Icon(Icons.link, color: AppColors.textSecondary, size: 20),
                )
              else if (_uploadedPosterPath == null)
                GestureDetector(
                  onTap: _pickPosterImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 32),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tap to select image from device gallery',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md - 1),
                        child: AppImage(
                          urlOrPath: _uploadedPosterPath!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _pickPosterImage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _uploadedPosterPath = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),

              // ── Language & Certification ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Language', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.xs),
                        AdminDropdown<String>(
                          value: _selectedLanguage,
                          items: const [
                            DropdownMenuItem(value: 'English', child: Text('English')),
                            DropdownMenuItem(value: 'Malayalam', child: Text('Malayalam')),
                            DropdownMenuItem(value: 'Tamil', child: Text('Tamil')),
                            DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                            DropdownMenuItem(value: 'Telugu', child: Text('Telugu')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedLanguage = val);
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
                        Text('Sensor Certificate', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.xs),
                        AdminDropdown<String>(
                          value: _selectedCertification,
                          items: const [
                            DropdownMenuItem(value: 'UA', child: Text('UA')),
                            DropdownMenuItem(value: 'U', child: Text('U')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCertification = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Duration ──
              Text('Duration', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              AdminTextField(
                controller: _durationCtrl,
                keyboardType: TextInputType.datetime,
                inputFormatters: [TimeDurationFormatter()],
                hintText: 'HH:MM (e.g. 02:30)',
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                suffixIcon: const Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Trailer Link ──
              Text('YouTube Trailer Link', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              AdminTextField(
                controller: _trailerCtrl,
                hintText: 'https://youtube.com/watch?v=...',
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                prefixIcon: const Icon(Icons.play_circle_outline, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Cast Members ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cast & Crew', style: Theme.of(context).textTheme.bodyMedium),
                  TextButton.icon(
                    onPressed: _addCastMember,
                    icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (_castMembers.isNotEmpty)
                ..._castMembers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final castEntry = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AdminTextField(
                            controller: castEntry.nameCtrl,
                            hintText: 'Name',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          flex: 2,
                          child: AdminDropdown<String>(
                            value: castEntry.selectedRole,
                            items: const [
                              DropdownMenuItem(value: 'ACTOR', child: Text('ACTOR')),
                              DropdownMenuItem(value: 'DIRECTOR', child: Text('DIRECTOR')),
                              DropdownMenuItem(value: 'WRITER', child: Text('WRITER')),
                              DropdownMenuItem(value: 'PRODUCER', child: Text('PRODUCER')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => castEntry.selectedRole = val);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                          onPressed: () => _removeCastMember(idx),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.xxl),

              // ── Save / Submit Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: Text(
                    isEdit ? 'Save Changes' : 'Add Movie',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _CastEntry {
  final TextEditingController nameCtrl = TextEditingController();
  String selectedRole = 'ACTOR';

  void dispose() {
    nameCtrl.dispose();
  }
}

class TimeDurationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(':', '');
    if (text.length > 4) text = text.substring(0, 4);
    var newText = text;
    if (text.length >= 3) {
      newText = '${text.substring(0, 2)}:${text.substring(2)}';
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
