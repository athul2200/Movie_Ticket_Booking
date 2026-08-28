import 'package:booking/models/movie_model.dart';
import 'package:booking/models/cast_model.dart' as cast_model;

import 'package:booking/models/theater_model.dart';
import 'package:booking/models/booking_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
/// Mock Data — Static data matching the Figma design exactly
/// ============================================================

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

  // ── Category filters ──
  static List<String> categories = [
    'All Movies',
    'Action',
    'Drama',
    'Crime-Thriller',
    'Sci-Fi',
    'Animation',
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

  // ── Mock Bookings (matching Figma Booking Detail screen) ──
  static final List<BookingModel> bookings = [

  ];

  // ── Global Movie Schedules (Movie -> DateLabel -> Theater -> Screen -> Times) ──
  static Map<String, Map<String, Map<String, Map<String, List<String>>>>> movieSchedules = {};

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
  static Map<String, List<String>> blockedSeats = {};

  // ── Persistence Methods ──

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final allMoviesJson = prefs.getString('allMovies');
    if (allMoviesJson != null) {
      final List decoded = json.decode(allMoviesJson);
      final loaded = decoded.map((e) => MovieModel.fromJson(e)).where((m) => !isDefaultMovie(m)).toList();
      allMovies = deduplicateMovies(loaded);
    } else {
      allMovies = [];
    }

    final featuredMoviesJson = prefs.getString('featuredMovies');
    if (featuredMoviesJson != null) {
      final List decoded = json.decode(featuredMoviesJson);
      final loaded = decoded.map((e) => MovieModel.fromJson(e)).where((m) => !isDefaultMovie(m)).toList();
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
  }

  static Future<void> saveAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('allMovies', json.encode(allMovies.map((e) => e.toJson()).toList()));
    await prefs.setString('featuredMovies', json.encode(featuredMovies.map((e) => e.toJson()).toList()));
    await prefs.setString('theaters', json.encode(theaters.map((e) => e.toJson()).toList()));
    await prefs.setString('bookings', json.encode(bookings.map((e) => e.toJson()).toList()));
    await prefs.setString('movieSchedules', json.encode(movieSchedules));
    await prefs.setString('screenPrices', json.encode(screenPrices));
    await prefs.setString('blockedSeats', json.encode(blockedSeats));
    await prefs.setString(
      'movieCast',
      json.encode(movieCast.map((k, v) => MapEntry(k, v.map((c) => c.toJson()).toList()))),
    );
    await prefs.setString('movieRatings', json.encode(movieRatings));
  }
}
