import 'package:booking/models/movie_model.dart';
import 'package:booking/models/cast_model.dart';
import 'package:booking/models/theater_model.dart';
import 'package:booking/models/booking_model.dart';

/// ============================================================
/// Mock Data — Static data matching the Figma design exactly
/// ============================================================

class MockData {
  // ── Featured movies for the hero carousel ──
  static const List<MovieModel> featuredMovies = [
    MovieModel(
      id: '1',
      title: 'Chronicles of Neon',
      description:
          'Experience the epic saga that redefined a generation, now in stunning 4K laser projection.',
      genres: ['IMAX', 'Sci-Fi'],
      duration: '2h 15m',
      rating: 4.9,
      certification: 'UA',
      posterUrl: 'https://picsum.photos/seed/neon1/400/600',
      bannerUrl: 'https://picsum.photos/seed/neon1/800/500',
    ),
    MovieModel(
      id: '5',
      title: 'Neon Echoes 2049',
      description:
          'In a world where memories can be bought and sold, a detective uncovers a long-buried secret that could plunge what\'s left of society into chaos.',
      genres: ['SCI-FI', 'ADVENTURE', '4K UHD'],
      duration: '2h 44m',
      rating: 9.2,
      certification: 'UA',
      posterUrl: 'https://picsum.photos/seed/echoes/400/600',
      bannerUrl: 'https://picsum.photos/seed/echoes/800/500',
    ),
  ];

  // ── All movies for the grid ──
  static const List<MovieModel> allMovies = [
    MovieModel(
      id: '1',
      title: 'Chronicles of Neon',
      description:
          'Experience the epic saga that redefined a generation, now in stunning 4K laser projection.',
      genres: ['Thriller'],
      duration: '2h 15m',
      rating: 4.9,
      certification: 'UA',
      posterUrl: 'https://cdn.district.in/movies-assets/images/cinema/Drishyam-3_Poster-0d2290e0-4469-11f1-9e72-b3859bd2479f%20(1)-6495a2d0-5360-11f1-8c65-299184906c19.jpg',
      bannerUrl: 'https://picsum.photos/seed/neon1/800/500',
    ),
    MovieModel(
      id: '2',
      title: 'Shadow Reign',
      description: 'A dark lord rises from the ashes to reclaim his throne.',
      genres: ['Action'],
      duration: '1h 45m',
      rating: 4.7,
      certification: 'A',
      posterUrl: 'https://m.media-amazon.com/images/M/MV5BNzllNmRlN2EtMDQyOC00ODJjLTg4OWQtZDNmNGU3YzlkNjc1XkEyXkFqcGc@._V1_QL75_UX190_CR0,0,190,281_.jpg',
      bannerUrl: 'https://picsum.photos/seed/shadow2/800/500',
    ),
    MovieModel(
      id: '3',
      title: 'Cosmic Drift',
      description:
          'An animated journey through the stars and beyond imagination.',
      genres: ['Animation'],
      duration: '1h 30m',
      rating: 4.5,
      certification: 'U',
      posterUrl: 'https://m.media-amazon.com/images/M/MV5BZTFjYzIxNDUtMGJjNy00OTdmLWExNGUtM2FkNzhlYmUzYzk0XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
      bannerUrl: 'https://picsum.photos/seed/cosmic3/800/500',
    ),
    MovieModel(
      id: '4',
      title: 'The Last Ritual',
      description:
          'Two souls intertwined across centuries in a dramatic tale of love and sacrifice.',
      genres: ['Drama'],
      duration: '2h 40m',
      rating: 4.8,
      certification: 'UA',
      posterUrl: 'https://pbs.twimg.com/media/G9lBYhzaMAA9WI5.jpg',
      bannerUrl: 'https://picsum.photos/seed/ritual4/800/500',
    ),
  ];

  // ── Category filters ──
  static const List<String> categories = [
    'All Movies',
    'Action',
    'Drama',
    'Sci-Fi',
    'Animation',
    'Thriller',
  ];

  // ── Cast & Crew for detail screen ──
  static const List<CastModel> cast = [
    CastModel(
      name: 'Ethan Vance',
      role: 'ACTOR',
      imageUrl: 'https://picsum.photos/seed/ethan/200/200',
    ),
    CastModel(
      name: 'Clara Sol',
      role: 'ACTOR',
      imageUrl: 'https://picsum.photos/seed/clara/200/200',
    ),
    CastModel(
      name: 'Marc Juro',
      role: 'DIRECTOR',
      imageUrl: 'https://picsum.photos/seed/marc/200/200',
    ),
  ];

  // ── Theaters & Showtimes ──
  static const List<TheaterModel> theaters = [
    TheaterModel(
      name: 'CinePremium IMAX - Downtown',
      type: 'IMAX',
      showtimes: ['14:30', '17:45', '21:00'],
    ),
    TheaterModel(
      name: 'Grand Screen Multiplex',
      type: 'Standard',
      showtimes: ['16:00', '19:30', '22:15'],
    ),
  ];

  // ── Mock Bookings (matching Figma Booking Detail screen) ──
  static final List<BookingModel> bookings = [
    const BookingModel(
      id: 'CP-9928-X821',
      movieTitle: 'Neon Horizon',
      moviePosterUrl: 'https://picsum.photos/seed/neonhorizon/400/600',
      date: 'Oct 24, 2023',
      time: '19:30',
      cinema: 'Screen 04',
      seats: ['H12', 'H13'],
      totalAmount: 32.00,
      experience: 'IMAX 2D EXPERIENCE',
      isConfirmed: true,
      isHistory: false,
    ),
    const BookingModel(
      id: 'CP-9929-X822',
      movieTitle: 'Midnight Jazz',
      moviePosterUrl: 'https://picsum.photos/seed/midnightjazz/400/600',
      date: 'Oct 28, 2023',
      time: '21:00',
      cinema: 'Lounge C',
      seats: ['B4'],
      totalAmount: 16.00,
      experience: 'STANDARD EXPERIENCE',
      isConfirmed: true,
      isHistory: false,
    ),
    const BookingModel(
      id: 'CP-9930-X823',
      movieTitle: 'Interstellar Odyssey',
      moviePosterUrl: 'https://picsum.photos/seed/interstellar/400/600',
      date: 'Oct 24, 2023',
      time: '08:30 PM',
      cinema: 'Hall 04 • IMAX',
      seats: ['H12', 'H13'],
      totalAmount: 32.00,
      experience: 'IMAX 3D EXPERIENCE',
      isConfirmed: true,
      isHistory: true,
    ),
    const BookingModel(
      id: 'CP-9931-X824',
      movieTitle: 'The Last Script',
      moviePosterUrl: 'https://picsum.photos/seed/ritual4/400/600',
      date: 'Oct 28, 2023',
      time: '06:15 PM',
      cinema: 'Screen 02',
      seats: ['F04'],
      totalAmount: 15.00,
      experience: 'STANDARD EXPERIENCE',
      isConfirmed: true,
      isHistory: true,
    ),
  ];
}

