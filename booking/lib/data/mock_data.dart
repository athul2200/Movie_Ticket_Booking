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
      title: 'Drishyam 3',
      description:
          'Experience the epic saga that redefined a generation, now in stunning 4K laser projection.',
      genres: ['IMAX', 'Sci-Fi'],
      duration: '2h 36m',
      rating: 4.9,
      certification: 'UA',
      posterUrl: 'https://preview.redd.it/drishyam-3-new-poster-v0-aml2q7qvcnjg1.jpeg?width=640&crop=smart&auto=webp&s=4187e069f30ef3f23473295952ed900831cdcd9e',
      bannerUrl: 'https://preview.redd.it/drishyam-3-new-poster-v0-aml2q7qvcnjg1.jpeg?width=640&crop=smart&auto=webp&s=4187e069f30ef3f23473295952ed900831cdcd9e',
    ),
    MovieModel(
      id: '2',
      title: 'Michael',
      description:
          'Experience the epic saga that redefined a generation, now in stunning 4K laser projection.',
      genres: ['IMAX', 'Sci-Fi'],
      duration: '2h 7m',
      rating: 4.9,
      certification: 'UA',
      posterUrl: 'https://www.mjvibe.com/wp-content/uploads/2026/03/Michael-New-Poster-March-00.jpg',
      bannerUrl: 'https://www.mjvibe.com/wp-content/uploads/2026/03/Michael-New-Poster-March-00.jpg',
    ),
    MovieModel(
      id: '3',
      title: 'Kattalan',
      description:
          'Experience the epic saga that redefined a generation, now in stunning 4K laser projection.',
      genres: ['IMAX', 'Sci-Fi'],
      duration: '1h 59m',
      rating: 4.9,
      certification: 'A',
      posterUrl: 'https://mir-s3-cdn-cf.behance.net/project_modules/1400_webp/172db4236457869.6a1a99d1dd2ca.jpg',
      bannerUrl: 'https://static.toiimg.com/thumb/resizemode-4,width-1280,height-720,msid-131402320/131402320.jpg',
    ),
    MovieModel(
      id: '4',
      title: 'Karuppu',
      description:
          'In a world where memories can be bought and sold, a detective uncovers a long-buried secret that could plunge what\'s left of society into chaos.',
      genres: ['SCI-FI', 'ADVENTURE', '4K UHD'],
      duration: '2h 36m',
      rating: 9.2,
      certification: 'UA',
      posterUrl: 'https://pbs.twimg.com/media/G9lBYhzaMAA9WI5.jpg',
      bannerUrl: 'https://pbs.twimg.com/media/Gwg_4BxbEAQvlmw.jpg',
    ),
  ];

  // ── All movies for the grid ──
  static const List<MovieModel> allMovies = [
    MovieModel(
      id: '1',
      title: 'Drishyam 3',
      description:
          'Drishyam 3 is a 2026 Indian Malayalam-language crime drama film written and directed by Jeethu Joseph. Produced by Antony Perumbavoor for Aashirvad Cinemas, it is a sequel to Drishyam 2 (2021) and the third installment in the Drishyam film series.',
      genres: ['Crime-Thriller'],
      duration: '2h 36m',
      rating: 4.9,
      certification: 'UA',
      posterUrl: 'https://cdn.district.in/movies-assets/images/cinema/Drishyam-3_Poster-0d2290e0-4469-11f1-9e72-b3859bd2479f%20(1)-6495a2d0-5360-11f1-8c65-299184906c19.jpg',
      bannerUrl: 'https://preview.redd.it/drishyam-3-new-poster-v0-aml2q7qvcnjg1.jpeg?width=640&crop=smart&auto=webp&s=4187e069f30ef3f23473295952ed900831cdcd9e',
    ),
    MovieModel(
      id: '2',
      title: 'Michael',
      description: 'The biographical musical drama Michael (2026) traces the life of American singer-songwriter Michael Jackson.',
      genres: ['Drama '],
      duration: '2h 7m',
      rating: 4.7,
      certification: 'UA',
      posterUrl: 'https://m.media-amazon.com/images/M/MV5BNzllNmRlN2EtMDQyOC00ODJjLTg4OWQtZDNmNGU3YzlkNjc1XkEyXkFqcGc@._V1_QL75_UX190_CR0,0,190,281_.jpg',
      bannerUrl: 'https://www.mjvibe.com/wp-content/uploads/2026/03/Michael-New-Poster-March-00.jpg',
    ),
    MovieModel(
      id: '3',
      title: 'Kattalan',
      description:
          'Kattalan is a 2026 Indian Malayalam-language action thriller film written and directed by Paul George, and produced by Shareef Muhammed under the banner of Cubes Entertainments.',
      genres: ['Action'],
      duration: '1h 59m',
      rating: 4.5,
      certification: 'A',
      posterUrl: 'https://m.media-amazon.com/images/M/MV5BOWFhNWNjN2MtOThjMi00ZTFmLWE1MmMtNDI1N2FhYzk2NmQ3XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
      bannerUrl: 'https://static.toiimg.com/thumb/resizemode-4,width-1280,height-720,msid-131402320/131402320.jpg',
    ),
    MovieModel(
      id: '4',
      title: 'Karuppu',
      description:
          'Karuppu (2026) is a Tamil-language fantasy action film directed by and starring RJ Balaji alongside Suriya and Trisha Krishnan. The movie follows the guardian deity Vettai Karuppu, who descends to Earth and takes the human form of a lawyer to dismantle a deeply corrupt legal system.',
      genres: ['Action'],
      duration: '2h 36m',
      rating: 4.8,
      certification: 'UA',
      posterUrl: 'https://pbs.twimg.com/media/G9lBYhzaMAA9WI5.jpg',
      bannerUrl: 'https://pbs.twimg.com/media/Gwg_4BxbEAQvlmw.jpg',
    ),
  ];

  // ── Category filters ──
  static const List<String> categories = [
    'All Movies',
    'Action',
    'Drama',
    'Crime-Thriller',
    'Sci-Fi',
    'Animation',
    
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

