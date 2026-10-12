import 'package:booking/models/movie_model.dart';
import 'package:booking/models/cast_model.dart' as cast_model;
import 'package:booking/models/seat_row_model.dart';

import 'package:booking/models/theater_model.dart';
import 'package:booking/models/booking_model.dart';
import 'package:booking/models/user_model.dart';
import 'package:booking/models/review_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// Mock Data — Static data matching the Figma design exactly
/// ============================================================

/// Data model representing a scheduled movie and its showtimes for a specific screen
class ScheduledMovieInfo {
  final MovieModel movie;
  final List<String> showtimes;

  const ScheduledMovieInfo({
    required this.movie,
    required this.showtimes,
  });
}

class MockData {
  // ── Static Default Filters ──
  static final Set<String> _staticDefaultIds = {'1', '2', '3', '4'};
  static final Set<String> _staticDefaultTitles = {
    'drishyam 3',
    'michael',
    'kattalan',
    'karuppu',
  };

  static bool isDefaultMovie(MovieModel m) {
    return _staticDefaultIds.contains(m.id) ||
        _staticDefaultTitles.contains(m.title.trim().toLowerCase());
  }

  static List<MovieModel> deduplicateMovies(List<MovieModel> movies) {
    final seen = <String>{};
    final result = <MovieModel>[];
    for (final movie in movies) {
      final key = movie.title.trim().toLowerCase();
      if (key.isNotEmpty && !seen.contains(key)) {
        seen.add(key);
        result.add(movie);
      }
    }
    return result;
  }

  // ── Featured movies for the hero carousel ──
  static List<MovieModel> featuredMovies = [];

  // ── All movies for the grid ──
  static List<MovieModel> allMovies = [];

  /// Syncs featuredMovies items with the latest MovieModel objects in allMovies
  static void syncFeaturedMovies() {
    for (int i = 0; i < featuredMovies.length; i++) {
      final feat = featuredMovies[i];
      final matchIndex = allMovies.indexWhere(
        (m) => m.id == feat.id || m.title.trim().toLowerCase() == feat.title.trim().toLowerCase(),
      );
      if (matchIndex != -1) {
        featuredMovies[i] = allMovies[matchIndex];
      }
    }
  }

  /// Only movies with isActive == true — use this in ALL user-facing screens.
  static List<MovieModel> get activeMovies =>
      allMovies.where((m) => m.isActive).toList();

  /// Active movies that also have at least one scheduled showtime.
  static List<MovieModel> get activeScheduledMovies =>
      allMovies.where((m) => m.isActive && isMovieScheduled(m.title)).toList();

  // ── Category filters ──
  static List<String> categories = [
    'All Movies',
    'Action',
    'Drama',
    'Crime-Thriller',
  ];

  // ── Cast & Crew for detail screen ──
  static List<cast_model.CastModel> cast = [
    cast_model.CastModel(
      name: 'Ethan Vance',
      role: 'ACTOR',
      imageUrl: 'https://picsum.photos/seed/ethan/200/200',
    ),
    cast_model.CastModel(
      name: 'Clara Sol',
      role: 'ACTOR',
      imageUrl: 'https://picsum.photos/seed/clara/200/200',
    ),
    cast_model.CastModel(
      name: 'Marc Juro',
      role: 'DIRECTOR',
      imageUrl: 'https://picsum.photos/seed/marc/200/200',
    ),
  ];

  // ── Theaters & Showtimes ──
  static List<TheaterModel> theaters = [
    TheaterModel(
      name: 'Kairali',
      type: '',
      showtimes: ['10:00 AM', '11:00 AM', '01:30 PM', '02:30 PM', '04:30 PM', '05:30 PM', '07:30 PM', '08:30 PM', '09:30 PM', '11:20 PM'],
    ),
    TheaterModel(
      name: 'Nila',
      type: '',
      showtimes: ['10:00 AM', '11:00 AM', '01:30 PM', '02:30 PM', '04:30 PM', '05:30 PM', '07:30 PM', '08:30 PM', '09:30 PM', '11:20 PM'],
    ),
  ];

  // ── Mock Bookings ──
  static final List<BookingModel> bookings = [];

  // ── Application Registered Users ──
  static List<UserModel> users = [];

  // ── Moderation Review Queue ──
  static List<ReviewModel> reviews = [];

  // ── Analytics & Statistics Helpers ──
  static double get totalRevenue {
    double total = 0;
    for (final b in bookings) {
      if (b.status != 'Cancelled') {
        total += b.totalAmount;
      }
    }
    return total;
  }

  static int get todayBookingsCount {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final todayStr = '${months[now.month - 1]} ${now.day}';
    return bookings.where((b) {
      final isTodayDate = b.date.toLowerCase().contains(todayStr.toLowerCase()) || b.date.toLowerCase().contains('today');
      return isTodayDate && b.status != 'Cancelled';
    }).length;
  }

  static int get activeMoviesCount => allMovies.where((m) => m.isActive).length;

  // ── Global Movie Schedules (Movie -> DateLabel -> Theater -> Screen -> Times) ──
  static Map<String, Map<String, Map<String, Map<String, List<String>>>>> movieSchedules = {};

  /// Case-insensitive, resilient theater name comparison that also handles
  /// trailing "Theater" or "• Screen" prefixes/suffixes.
  static bool theaterMatches(String t1, String t2) {
    String clean(String s) => s
        .split('•')
        .first
        .replaceAll(RegExp(r'\btheater\b', caseSensitive: false), '')
        .trim()
        .toLowerCase();
    final c1 = clean(t1);
    final c2 = clean(t2);
    return c1 == c2 || t1.trim().toLowerCase() == t2.trim().toLowerCase();
  }

  /// Checks if a movie has at least 1 active scheduled showtime in any theater/screen/date (or in a specific theater if provided).
  static bool isMovieScheduled(String movieTitle, [String? theaterName]) {
    if (movieSchedules.isEmpty) return false;
    final target = movieTitle.trim().toLowerCase();
    for (final entry in movieSchedules.entries) {
      if (entry.key.trim().toLowerCase() == target) {
        final dates = entry.value;
        for (final dateEntry in dates.values) {
          for (final theaterEntry in dateEntry.entries) {
            final matchesTheater = theaterName == null ||
                theaterName.trim().toLowerCase() == 'all' ||
                theaterMatches(theaterEntry.key, theaterName);
            if (matchesTheater) {
              for (final timesList in theaterEntry.value.values) {
                if (timesList.isNotEmpty) {
                  return true;
                }
              }
            }
          }
        }
      }
    }
    return false;
  }

  /// Returns a list of [ScheduledMovieInfo] containing all movies and their
  /// scheduled showtimes for a specific theater and screen name.
  static List<ScheduledMovieInfo> getScheduledMoviesForScreen(
    String theaterName,
    String screenName,
  ) {
    if (movieSchedules.isEmpty) return [];

    final targetScreen = screenName.trim().toLowerCase();
    final Map<String, Set<String>> movieShowtimesMap = {};

    movieSchedules.forEach((movieTitle, datesMap) {
      datesMap.forEach((dateLabel, theatersMap) {
        theatersMap.forEach((thName, screensMap) {
          if (theaterMatches(thName, theaterName)) {
            screensMap.forEach((scName, times) {
              if (scName.trim().toLowerCase() == targetScreen && times.isNotEmpty) {
                movieShowtimesMap.putIfAbsent(movieTitle, () => <String>{});
                movieShowtimesMap[movieTitle]!.addAll(times);
              }
            });
          }
        });
      });
    });

    final List<ScheduledMovieInfo> result = [];
    movieShowtimesMap.forEach((title, timesSet) {
      final movie = allMovies.firstWhere(
        (m) => m.title.trim().toLowerCase() == title.trim().toLowerCase(),
        orElse: () => MovieModel(
          id: title,
          title: title,
          description: '',
          genres: ['Drama'],
          duration: '120 mins',
          rating: 4.5,
          certification: 'UA',
          posterUrl:
              'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?q=80&w=1000&auto=format&fit=crop',
          bannerUrl:
              'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?q=80&w=1000&auto=format&fit=crop',
          theaters: [theaterName],
        ),
      );
      final sortedTimes = timesSet.toList()..sort();
      result.add(ScheduledMovieInfo(
        movie: movie,
        showtimes: sortedTimes,
      ));
    });

    return result;
  }

  /// Updates a movie's schedule entry: optionally moves it to a different
  /// screen and/or replaces the show timings.  Cleans up empty map nodes so
  /// subsequent reads stay consistent.  Persists via [saveAll].
  static Future<void> updateMovieSchedule({
    required String movieTitle,
    required String theaterName,
    required String dateLabel,
    required String oldScreen,
    required String newScreen,
    required List<String> newTimes,
  }) async {
    final titleKey = movieTitle.trim().toLowerCase();

    // Find the exact key used in movieSchedules (preserves original casing)
    final schedKey = movieSchedules.keys.firstWhere(
      (k) => k.trim().toLowerCase() == titleKey,
      orElse: () => movieTitle,
    );

    movieSchedules.putIfAbsent(schedKey, () => {});
    movieSchedules[schedKey]!.putIfAbsent(dateLabel, () => {});

    // Find the exact theater key stored in the map
    final dateMap = movieSchedules[schedKey]![dateLabel]!;
    String? theaterKey;
    for (final k in dateMap.keys) {
      if (theaterMatches(k, theaterName)) {
        theaterKey = k;
        break;
      }
    }
    theaterKey ??= theaterName;
    dateMap.putIfAbsent(theaterKey, () => {});

    final screenMap = dateMap[theaterKey]!;

    // Remove old screen entry (the times are now replaced by newScreen/newTimes)
    if (oldScreen != newScreen) {
      screenMap.remove(oldScreen);
    }

    // Write new times (or clear if empty to allow full removal)
    if (newTimes.isEmpty) {
      screenMap.remove(newScreen);
    } else {
      screenMap[newScreen] = List<String>.from(newTimes);
    }

    // Clean up empty nodes
    if (screenMap.isEmpty) dateMap.remove(theaterKey);
    if (dateMap.isEmpty) movieSchedules[schedKey]!.remove(dateLabel);
    if (movieSchedules[schedKey]!.isEmpty) movieSchedules.remove(schedKey);

    await saveAll();
  }

  /// Returns the list of screens for a theater, defaulting to ['Screen 01', 'Screen 02'].
  static List<String> getTheaterScreens(String theaterName) {
    for (final entry in screenPrices.entries) {
      if (theaterMatches(entry.key, theaterName) && entry.value.isNotEmpty) {
        return entry.value.keys.toList();
      }
    }
    for (final entry in screenLayouts.entries) {
      if (theaterMatches(entry.key, theaterName) && entry.value.isNotEmpty) {
        return entry.value.keys.toList();
      }
    }
    return ['Screen 01', 'Screen 02'];
  }

  /// Updates or sets schedules for a movie across all screens in a theater for a given date.
  /// If a screen's times list is empty, that screen is unassigned/removed.
  static Future<void> saveMovieScheduleMultiScreen({
    required String movieTitle,
    required String theaterName,
    required String dateLabel,
    required Map<String, List<String>> screenTimes,
  }) async {
    final titleKey = movieTitle.trim().toLowerCase();

    final schedKey = movieSchedules.keys.firstWhere(
      (k) => k.trim().toLowerCase() == titleKey,
      orElse: () => movieTitle,
    );

    movieSchedules.putIfAbsent(schedKey, () => {});
    movieSchedules[schedKey]!.putIfAbsent(dateLabel, () => {});

    final dateMap = movieSchedules[schedKey]![dateLabel]!;
    String? theaterKey;
    for (final k in dateMap.keys) {
      if (theaterMatches(k, theaterName)) {
        theaterKey = k;
        break;
      }
    }
    theaterKey ??= theaterName;
    dateMap.putIfAbsent(theaterKey, () => {});

    final screenMap = dateMap[theaterKey]!;

    screenTimes.forEach((screen, times) {
      if (times.isEmpty) {
        screenMap.remove(screen);
      } else {
        screenMap[screen] = List<String>.from(times);
      }
    });

    // Clean up empty nodes
    if (screenMap.isEmpty) dateMap.remove(theaterKey);
    if (dateMap.isEmpty) movieSchedules[schedKey]!.remove(dateLabel);
    if (movieSchedules[schedKey]!.isEmpty) movieSchedules.remove(schedKey);

    // Keep theater in movie.theaters if it has active schedules, or ensure it's there
    final movieIdx = allMovies.indexWhere(
      (m) => m.title.trim().toLowerCase() == titleKey,
    );
    if (movieIdx != -1) {
      final currentMovie = allMovies[movieIdx];
      final hasActiveSchedules = isMovieScheduled(movieTitle, theaterName);
      if (hasActiveSchedules) {
        if (!currentMovie.theaters.any((t) => theaterMatches(t, theaterName))) {
          final updated = currentMovie.copyWith(
            theaters: [...currentMovie.theaters, theaterName],
          );
          allMovies[movieIdx] = updated;
          final featIdx = featuredMovies.indexWhere(
            (m) => m.id == currentMovie.id || m.title.trim().toLowerCase() == titleKey,
          );
          if (featIdx != -1) {
            featuredMovies[featIdx] = updated;
          }
        }
      }
    }

    await saveAll();
  }

  static void _seedDefaultSchedulesIfNeeded() {
    // Do not auto-seed default movies for Screen 01 and Screen 02.
    // Screen 01 and Screen 02 start empty so that only owner-scheduled movies appear.
    return;
  }

  // ── Per-Movie Cast (Movie title -> List<CastModel>) ──
  static Map<String, List<cast_model.CastModel>> movieCast = {};

  // ── Per-Movie User Ratings (Movie title -> List<double>) ──
  static Map<String, List<double>> movieRatings = {};

  static double getAverageRating(MovieModel movie) {
    final ratings = movieRatings[movie.title];
    if (ratings != null && ratings.isNotEmpty) {
      final sum = ratings.reduce((a, b) => a + b);
      final avg = sum / ratings.length;
      return double.parse(avg.toStringAsFixed(1));
    }
    return movie.rating;
  }

  static int getReviewCount(MovieModel movie) {
    final ratings = movieRatings[movie.title];
    return ratings?.length ?? 0;
  }

  static Future<void> addMovieRating(String movieTitle, double rating) async {
    movieRatings.putIfAbsent(movieTitle, () => []);
    movieRatings[movieTitle]!.add(rating);
    await saveAll();
  }

  // ── Global Screen Prices (Theater -> Screen -> Price) ──
  static Map<String, Map<String, double>> screenPrices = {
    'Kairali': {
      'Screen 01': 130.00,
      'Screen 02': 105.00,
    },
    'Nila': {
      'Screen 01': 105.00,
      'Screen 02': 130.00,
    },
  };

  // ── Global Blocked Seats (AuditoriumKey -> List of seat IDs) ──
  // Key format: "cinema|||screen|||showtime"  (triple-pipe to avoid clashes with spaces/colons)
  static Map<String, List<String>> blockedSeats = {};

  /// Canonical key used to store/lookup blocked seats for a specific slot.
  static String blockedSeatKey(String cinema, String screen, String showtime) =>
      '${cinema.trim().toLowerCase()}|||${screen.trim().toLowerCase()}|||${showtime.trim().toLowerCase()}';

  /// Returns blocked seat IDs for an exact cinema + screen + showtime combination.
  /// If [showtime] is omitted, returns all blocked seats for cinema + screen across
  /// every showtime (used by owner module overview).
  static Set<String> getBlockedSeats(String cinema, String screen, [String? showtime]) {
    final result = <String>{};
    final targetCinema = cinema.trim().toLowerCase();
    final targetScreen = screen.trim().toLowerCase();
    final targetShowtime = showtime?.trim().toLowerCase();

    for (final entry in blockedSeats.entries) {
      // Support both old underscore-separated keys and new pipe-separated keys
      final key = entry.key.trim().toLowerCase();
      String c, s, t;

      if (key.contains('|||')) {
        final parts = key.split('|||');
        c = parts.isNotEmpty ? parts[0] : '';
        s = parts.length >= 2 ? parts[1] : '';
        t = parts.length >= 3 ? parts[2] : '';
      } else {
        // Legacy underscore key: "cinema_screen_showtime"
        final parts = key.split('_');
        c = parts.isNotEmpty ? parts[0] : '';
        s = parts.length >= 2 ? parts[1] : '';
        t = parts.length >= 3 ? parts.sublist(2).join('_') : '';
      }

      final matchesCinema = c == targetCinema;
      final matchesScreen = s == targetScreen;
      // If no showtime requested → include all showtimes (owner overview).
      // If showtime requested → must match exactly.
      final matchesTime = targetShowtime == null || t == targetShowtime;

      if (matchesCinema && matchesScreen && matchesTime) {
        result.addAll(entry.value);
      }
    }
    return result;
  }

  // ── Seating Layouts (Theater -> Screen -> List<SeatRow>) ──
  // Held purely in memory; mutated live by the layout editor.
  static Map<String, Map<String, List<SeatRow>>> screenLayouts = {
    'Kairali': {
      'Screen 01': _defaultRows(),
      'Screen 02': _defaultRows(),
    },
    'Nila': {
      'Screen 01': _defaultRows(),
      'Screen 02': _defaultRows(),
    },
  };

  /// Builds the standard default layout: rows A–J with 16 seats each,
  /// matching the user-facing seat selection screen.
  static List<SeatRow> _defaultRows() {
    return ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
        .map((r) => SeatRow(rowName: r, seatCount: 16))
        .toList();
  }

  /// Returns a fresh default layout used to reset a screen.
  static List<SeatRow> defaultLayoutFor(String screenName) => _defaultRows();

  /// Resilient lookup for layout by cinema and screen name.
  static List<SeatRow> getLayout(String cinema, String screen) {
    final direct = screenLayouts[cinema]?[screen];
    if (direct != null && direct.isNotEmpty) return direct;

    final cleanedCinema = cinema.split('•').first.trim().toLowerCase();
    final cleanedScreen = screen.trim().toLowerCase();

    for (final theaterEntry in screenLayouts.entries) {
      if (theaterEntry.key.trim().toLowerCase() == cleanedCinema) {
        for (final screenEntry in theaterEntry.value.entries) {
          if (screenEntry.key.trim().toLowerCase() == cleanedScreen) {
            return screenEntry.value;
          }
        }
        for (final screenEntry in theaterEntry.value.entries) {
          final sKey = screenEntry.key.replaceAll(RegExp(r'[^0-9]'), '');
          final targetKey = screen.replaceAll(RegExp(r'[^0-9]'), '');
          if (sKey.isNotEmpty && sKey == targetKey) {
            return screenEntry.value;
          }
        }
      }
    }

    return defaultLayoutFor(screen);
  }

  // ── Persistence Methods ──

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final allMoviesJson = prefs.getString('allMovies');
    if (allMoviesJson != null) {
      final List decoded = json.decode(allMoviesJson);
      final loaded = decoded.map((e) => MovieModel.fromJson(e)).toList();
      allMovies = deduplicateMovies(loaded);
    } else {
      allMovies = [];
    }

    final featuredMoviesJson = prefs.getString('featuredMovies');
    if (featuredMoviesJson != null) {
      final List decoded = json.decode(featuredMoviesJson);
      final loaded = decoded.map((e) => MovieModel.fromJson(e)).toList();
      featuredMovies = deduplicateMovies(loaded);
    } else {
      featuredMovies = [];
    }

    final theatersJson = prefs.getString('theaters');
    if (theatersJson != null) {
      final List decoded = json.decode(theatersJson);
      theaters = decoded.map((e) => TheaterModel.fromJson(e)).toList();
    }

    final bookingsJson = prefs.getString('bookings');
    if (bookingsJson != null) {
      final List decoded = json.decode(bookingsJson);
      bookings.clear();
      bookings.addAll(decoded.map((e) => BookingModel.fromJson(e)).toList());
    }

    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      final List decoded = json.decode(usersJson);
      users = decoded.map((e) => UserModel.fromJson(e)).toList();
    }

    final reviewsJson = prefs.getString('reviews');
    if (reviewsJson != null) {
      final List decoded = json.decode(reviewsJson);
      reviews = decoded.map((e) => ReviewModel.fromJson(e)).toList();
    }

    final movieSchedulesJson = prefs.getString('movieSchedules');
    if (movieSchedulesJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(movieSchedulesJson);
        final Map<String, Map<String, Map<String, Map<String, List<String>>>>> parsed = {};
        decoded.forEach((movie, dates) {
          if (dates is Map<String, dynamic>) {
            parsed[movie] = {};
            dates.forEach((date, theatersMap) {
              if (theatersMap is Map<String, dynamic>) {
                parsed[movie]![date] = {};
                theatersMap.forEach((theater, screens) {
                  if (screens is Map<String, dynamic>) {
                    parsed[movie]![date]![theater] = {};
                    screens.forEach((screen, times) {
                      if (times is List) {
                        parsed[movie]![date]![theater]![screen] =
                            times.map((t) => t.toString()).toList();
                      }
                    });
                  }
                });
              }
            });
          }
        });
        movieSchedules = parsed;
      } catch (e) {
        // Fallback to empty if parse fails
      }
    }
    _seedDefaultSchedulesIfNeeded();

    final movieCastJson = prefs.getString('movieCast');
    if (movieCastJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(movieCastJson);
        final Map<String, List<cast_model.CastModel>> parsed = {};
        decoded.forEach((movieTitle, castList) {
          if (castList is List) {
            parsed[movieTitle] = castList
                .map((e) => cast_model.CastModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        });
        movieCast = parsed;
      } catch (e) {
        // Fallback to empty
      }
    }

    final movieRatingsJson = prefs.getString('movieRatings');
    if (movieRatingsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(movieRatingsJson);
        final Map<String, List<double>> parsed = {};
        decoded.forEach((movieTitle, list) {
          if (list is List) {
            parsed[movieTitle] = list.map((e) => (e as num).toDouble()).toList();
          }
        });
        movieRatings = parsed;
      } catch (e) {
        // Fallback to empty
      }
    }

    final screenPricesJson = prefs.getString('screenPrices');
    if (screenPricesJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(screenPricesJson);
        final Map<String, Map<String, double>> parsed = {};
        decoded.forEach((theater, screens) {
          if (screens is Map<String, dynamic>) {
            parsed[theater] = {};
            screens.forEach((screen, price) {
              parsed[theater]![screen] = (price as num).toDouble();
            });
          }
        });
        screenPrices = parsed;
      } catch (e) {
        // Fallback to defaults
      }
    }

    final blockedSeatsJson = prefs.getString('blockedSeats');
    if (blockedSeatsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(blockedSeatsJson);
        final Map<String, List<String>> parsed = {};
        decoded.forEach((key, list) {
          if (list is List) {
            parsed[key] = list.map((e) => e.toString()).toList();
          }
        });
        blockedSeats = parsed;
      } catch (e) {
        // Fallback
      }
    }

    final screenLayoutsJson = prefs.getString('screenLayouts');
    if (screenLayoutsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(screenLayoutsJson);
        final Map<String, Map<String, List<SeatRow>>> parsed = {};
        decoded.forEach((theater, screens) {
          if (screens is Map<String, dynamic>) {
            parsed[theater] = {};
            screens.forEach((screen, rowsList) {
              if (rowsList is List) {
                parsed[theater]![screen] = rowsList
                    .map((r) => SeatRow.fromJson(r as Map<String, dynamic>))
                    .toList();
              }
            });
          }
        });
        if (parsed.isNotEmpty) {
          screenLayouts = parsed;
        }
      } catch (e) {
        // Fallback to defaults
      }
    }
  }

  static Future<void> saveAll() async {
    syncFeaturedMovies();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('allMovies', json.encode(allMovies.map((e) => e.toJson()).toList()));
    await prefs.setString('featuredMovies', json.encode(featuredMovies.map((e) => e.toJson()).toList()));
    await prefs.setString('theaters', json.encode(theaters.map((e) => e.toJson()).toList()));
    await prefs.setString('bookings', json.encode(bookings.map((e) => e.toJson()).toList()));
    await prefs.setString('users', json.encode(users.map((e) => e.toJson()).toList()));
    await prefs.setString('reviews', json.encode(reviews.map((e) => e.toJson()).toList()));
    await prefs.setString('movieSchedules', json.encode(movieSchedules));
    await prefs.setString('screenPrices', json.encode(screenPrices));
    await prefs.setString('blockedSeats', json.encode(blockedSeats));
    await prefs.setString(
      'movieCast',
      json.encode(movieCast.map((k, v) => MapEntry(k, v.map((c) => c.toJson()).toList()))),
    );
    await prefs.setString('movieRatings', json.encode(movieRatings));

    final Map<String, dynamic> encodedLayouts = {};
    screenLayouts.forEach((theater, screens) {
      final Map<String, dynamic> screensMap = {};
      screens.forEach((screen, rows) {
        screensMap[screen] = rows.map((r) => r.toJson()).toList();
      });
      encodedLayouts[theater] = screensMap;
    });
    await prefs.setString('screenLayouts', json.encode(encodedLayouts));
  }
}

