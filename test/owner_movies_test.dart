import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/data/mock_data.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    MockData.allMovies.clear();
    MockData.movieSchedules.clear();
  });

  test('Owner Movies - allMovies holds all movies added by owner across theaters', () {
    final movie1 = MovieModel(
      id: 'm1',
      title: 'Movie Kairali Only',
      description: 'Desc 1',
      genres: ['Action'],
      duration: '120m',
      rating: 4.5,
      certification: 'UA',
      posterUrl: 'https://example.com/p1.jpg',
      bannerUrl: 'https://example.com/b1.jpg',
      theaters: ['Kairali'],
    );

    final movie2 = MovieModel(
      id: 'm2',
      title: 'Movie Nila Only',
      description: 'Desc 2',
      genres: ['Drama'],
      duration: '110m',
      rating: 4.0,
      certification: 'U',
      posterUrl: 'https://example.com/p2.jpg',
      bannerUrl: 'https://example.com/b2.jpg',
      theaters: ['Nila'],
    );

    final movie3 = MovieModel(
      id: 'm3',
      title: 'Movie Both Theaters',
      description: 'Desc 3',
      genres: ['Thriller'],
      duration: '135m',
      rating: 4.8,
      certification: 'UA',
      posterUrl: 'https://example.com/p3.jpg',
      bannerUrl: 'https://example.com/b3.jpg',
      theaters: ['Kairali', 'Nila'],
    );

    MockData.allMovies.addAll([movie1, movie2, movie3]);

    // All movies displayed by default in Owner Movies section
    expect(MockData.allMovies.length, 3);

    // Kairali filter
    final kairaliMovies = MockData.allMovies.where((m) => m.theaters.contains('Kairali')).toList();
    expect(kairaliMovies.length, 2);
    expect(kairaliMovies.map((m) => m.id), containsAll(['m1', 'm3']));

    // Nila filter
    final nilaMovies = MockData.allMovies.where((m) => m.theaters.contains('Nila')).toList();
    expect(nilaMovies.length, 2);
    expect(nilaMovies.map((m) => m.id), containsAll(['m2', 'm3']));
  });

  test('Owner Movies - filters properly by Scheduled and Not Scheduled status', () {
    final movie1 = MovieModel(
      id: 'm1',
      title: 'Scheduled Movie 1',
      description: 'Desc 1',
      genres: ['Action'],
      duration: '120m',
      rating: 4.5,
      certification: 'UA',
      posterUrl: 'https://example.com/p1.jpg',
      bannerUrl: 'https://example.com/b1.jpg',
      theaters: ['Kairali'],
    );

    final movie2 = MovieModel(
      id: 'm2',
      title: 'Unscheduled Movie 2',
      description: 'Desc 2',
      genres: ['Drama'],
      duration: '110m',
      rating: 4.0,
      certification: 'U',
      posterUrl: 'https://example.com/p2.jpg',
      bannerUrl: 'https://example.com/b2.jpg',
      theaters: ['Nila'],
    );

    final movie3 = MovieModel(
      id: 'm3',
      title: 'Scheduled Movie 3',
      description: 'Desc 3',
      genres: ['Drama'],
      duration: '140m',
      rating: 4.9,
      certification: 'UA',
      posterUrl: 'https://example.com/p3.jpg',
      bannerUrl: 'https://example.com/b3.jpg',
      theaters: ['Kairali', 'Nila'],
    );

    MockData.allMovies.addAll([movie1, movie2, movie3]);

    // Schedule m1 and m3
    MockData.movieSchedules['Scheduled Movie 1'] = {
      'Today': {
        'Kairali': {
          'Screen 01': ['10:00 AM', '01:30 PM'],
        },
      },
    };

    MockData.movieSchedules['Scheduled Movie 3'] = {
      'Today': {
        'Nila': {
          'Screen 02': ['04:30 PM'],
        },
      },
    };

    // Scheduled check
    expect(MockData.isMovieScheduled(movie1.title), isTrue);
    expect(MockData.isMovieScheduled(movie2.title), isFalse);
    expect(MockData.isMovieScheduled(movie3.title), isTrue);

    // Filter Scheduled
    final scheduledMovies = MockData.allMovies
        .where((m) => MockData.isMovieScheduled(m.title))
        .toList();
    expect(scheduledMovies.length, 2);
    expect(scheduledMovies.map((m) => m.id), containsAll(['m1', 'm3']));

    // Filter Not Scheduled
    final notScheduledMovies = MockData.allMovies
        .where((m) => !MockData.isMovieScheduled(m.title))
        .toList();
    expect(notScheduledMovies.length, 1);
    expect(notScheduledMovies.first.id, 'm2');
  });

  test('Owner Movies - Nila Theater displays added and scheduled movies correctly', () {
    final nilaMovie = MovieModel(
      id: 'n1',
      title: 'Kattalan',
      description: 'Desc',
      genres: ['Action'],
      duration: '119m',
      rating: 4.5,
      certification: 'A',
      posterUrl: 'https://example.com/kattalan.jpg',
      bannerUrl: 'https://example.com/kattalan.jpg',
      theaters: ['Nila'],
    );

    final kairaliMovie = MovieModel(
      id: 'k1',
      title: 'Drishyam 3',
      description: 'Desc',
      genres: ['Crime-Thriller'],
      duration: '156m',
      rating: 4.9,
      certification: 'UA',
      posterUrl: 'https://example.com/drishyam3.jpg',
      bannerUrl: 'https://example.com/drishyam3.jpg',
      theaters: ['Kairali'],
    );

    final sharedMovie = MovieModel(
      id: 's1',
      title: 'Karuppu',
      description: 'Desc',
      genres: ['Action'],
      duration: '156m',
      rating: 4.8,
      certification: 'UA',
      posterUrl: 'https://example.com/karuppu.jpg',
      bannerUrl: 'https://example.com/karuppu.jpg',
      theaters: ['Nila Theater', 'Kairali'],
    );

    MockData.allMovies.addAll([nilaMovie, kairaliMovie, sharedMovie]);

    // Schedule Kattalan in Nila Theater on Screen 02
    MockData.movieSchedules['Kattalan'] = {
      'Today': {
        'Nila': {
          'Screen 02': ['10:00 AM', '01:30 PM'],
        },
      },
    };

    // Resilient theater matching
    expect(MockData.theaterMatches('Nila', 'Nila Theater'), isTrue);
    expect(MockData.theaterMatches('Nila Theater', 'Nila'), isTrue);
    expect(MockData.theaterMatches('Kairali', 'Nila'), isFalse);

    // Kattalan is scheduled in Nila
    expect(MockData.isMovieScheduled('Kattalan', 'Nila'), isTrue);
    expect(MockData.isMovieScheduled('Kattalan', 'Kairali'), isFalse);

    // Karuppu is not scheduled in Nila
    expect(MockData.isMovieScheduled('Karuppu', 'Nila'), isFalse);

    // Drishyam 3 is not in Nila
    expect(MockData.isMovieScheduled('Drishyam 3', 'Nila'), isFalse);

    // Movies belonging to Nila Theater (assigned or scheduled)
    bool belongsToNila(MovieModel m) {
      final isAssigned = m.theaters.any((t) => MockData.theaterMatches(t, 'Nila'));
      final isScheduled = MockData.isMovieScheduled(m.title, 'Nila');
      return isAssigned || isScheduled;
    }

    final nilaAll = MockData.allMovies.where(belongsToNila).toList();
    expect(nilaAll.length, 2);
    expect(nilaAll.map((m) => m.title), containsAll(['Kattalan', 'Karuppu']));
    expect(nilaAll.map((m) => m.title), isNot(contains('Drishyam 3')));

    // Scheduled in Nila
    final nilaScheduled = MockData.allMovies.where((m) =>
      belongsToNila(m) && MockData.isMovieScheduled(m.title, 'Nila')
    ).toList();
    expect(nilaScheduled.length, 1);
    expect(nilaScheduled.first.title, 'Kattalan');

    // Not scheduled in Nila
    final nilaNotScheduled = MockData.allMovies.where((m) =>
      belongsToNila(m) && !MockData.isMovieScheduled(m.title, 'Nila')
    ).toList();
    expect(nilaNotScheduled.length, 1);
    expect(nilaNotScheduled.first.title, 'Karuppu');
  });

  test('Categories - Sci-Fi and Animation are removed from all categories', () {
    expect(MockData.categories, isNot(contains('Sci-Fi')));
    expect(MockData.categories, isNot(contains('Animation')));
    expect(MockData.categories, equals(['All Movies', 'Action', 'Drama', 'Crime-Thriller']));
  });

  test('MockData.updateMovieSchedule updates screen and show timings correctly', () async {
    MockData.movieSchedules['Test Movie'] = {
      'Today, 12 Oct': {
        'Kairali': {
          'Screen 01': ['10:00 AM', '01:30 PM'],
        },
      },
    };

    // Update show timings on the same screen
    await MockData.updateMovieSchedule(
      movieTitle: 'Test Movie',
      dateLabel: 'Today, 12 Oct',
      theaterName: 'Kairali',
      oldScreen: 'Screen 01',
      newScreen: 'Screen 01',
      newTimes: ['04:30 PM', '07:30 PM'],
    );

    expect(
      MockData.movieSchedules['Test Movie']?['Today, 12 Oct']?['Kairali']?['Screen 01'],
      equals(['04:30 PM', '07:30 PM']),
    );

    // Move to a different screen (Screen 02)
    await MockData.updateMovieSchedule(
      movieTitle: 'Test Movie',
      dateLabel: 'Today, 12 Oct',
      theaterName: 'Kairali',
      oldScreen: 'Screen 01',
      newScreen: 'Screen 02',
      newTimes: ['11:00 AM', '02:30 PM', '05:30 PM'],
    );

    // Old screen should be removed
    expect(
      MockData.movieSchedules['Test Movie']?['Today, 12 Oct']?['Kairali']?['Screen 01'],
      isNull,
    );
    // New screen should have the new timings
    expect(
      MockData.movieSchedules['Test Movie']?['Today, 12 Oct']?['Kairali']?['Screen 02'],
      equals(['11:00 AM', '02:30 PM', '05:30 PM']),
    );
  });

  test('MockData.saveMovieScheduleMultiScreen updates screen assignments and timings across multiple screens', () async {
    SharedPreferences.setMockInitialValues({});
    MockData.movieSchedules.clear();

    final testMovie = MovieModel(
      id: 'multi_screen_movie',
      title: 'Multi Screen Movie',
      description: 'Desc',
      genres: ['Action'],
      duration: '120m',
      rating: 4.5,
      certification: 'UA',
      posterUrl: 'https://example.com/p.jpg',
      bannerUrl: 'https://example.com/b.jpg',
      theaters: ['Kairali'],
    );
    MockData.allMovies.add(testMovie);

    // Initially schedule only on Screen 01
    MockData.movieSchedules['Multi Screen Movie'] = {
      'Oct 12': {
        'Kairali': {
          'Screen 01': ['10:00 AM', '01:30 PM'],
        },
      },
    };

    // Update schedule: assign to BOTH Screen 01 and Screen 02 with different timings
    await MockData.saveMovieScheduleMultiScreen(
      movieTitle: 'Multi Screen Movie',
      theaterName: 'Kairali',
      dateLabel: 'Oct 12',
      screenTimes: {
        'Screen 01': ['10:00 AM', '04:30 PM'],
        'Screen 02': ['11:00 AM', '05:30 PM', '08:30 PM'],
      },
    );

    // Verify both screens are assigned correctly
    final kairaliSched = MockData.movieSchedules['Multi Screen Movie']?['Oct 12']?['Kairali'];
    expect(kairaliSched, isNotNull);
    expect(kairaliSched?['Screen 01'], equals(['10:00 AM', '04:30 PM']));
    expect(kairaliSched?['Screen 02'], equals(['11:00 AM', '05:30 PM', '08:30 PM']));

    // Verify User module consumption: Screen 01 and Screen 02 scheduled movies
    final screen01Movies = MockData.getScheduledMoviesForScreen('Kairali', 'Screen 01');
    final screen02Movies = MockData.getScheduledMoviesForScreen('Kairali', 'Screen 02');
    expect(screen01Movies.any((m) => m.movie.title == 'Multi Screen Movie'), isTrue);
    expect(screen02Movies.any((m) => m.movie.title == 'Multi Screen Movie'), isTrue);

    // Now unassign Screen 01 and keep only Screen 02
    await MockData.saveMovieScheduleMultiScreen(
      movieTitle: 'Multi Screen Movie',
      theaterName: 'Kairali',
      dateLabel: 'Oct 12',
      screenTimes: {
        'Screen 01': [],
        'Screen 02': ['02:30 PM'],
      },
    );

    final updatedKairaliSched = MockData.movieSchedules['Multi Screen Movie']?['Oct 12']?['Kairali'];
    expect(updatedKairaliSched?['Screen 01'], isNull);
    expect(updatedKairaliSched?['Screen 02'], equals(['02:30 PM']));
  });
}

