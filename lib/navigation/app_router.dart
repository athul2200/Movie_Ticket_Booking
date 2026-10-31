import 'package:flutter/material.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/models/booking_model.dart';
import 'package:booking/widgets/bottom_nav_bar.dart';
import 'package:booking/screens/auth/login_screen.dart';
import 'package:booking/screens/auth/signup_screen.dart';
import 'package:booking/screens/movie_detail/movie_detail_screen.dart';
import 'package:booking/screens/seat_selection/seat_selection_screen.dart';
import 'package:booking/screens/booking_detail/booking_detail_screen.dart';
import 'package:booking/screens/payment/payment_screen.dart';
import 'package:booking/screens/owner/main/owner_main_screen.dart';
import 'package:booking/screens/admin/admin_dashboard.dart';
import 'package:booking/screens/splash/splash_screen.dart';
import 'package:booking/screens/network/no_internet_screen.dart';
import 'package:booking/services/auth_service.dart';
import 'package:booking/data/mock_data.dart';

// ============================================================
// App Router — Named route definitions and role-based guards
//
// Route guards are a secondary UX layer (not server-side enforcement).
// Firestore Security Rules in the Firebase Console are the authoritative
// access-control layer.
//
// Guard logic:
//   /home  → requires UserRole.user  + isActive
//   /owner → requires UserRole.owner + isActive + valid assignedTheater
//              AND the route argument must match the Firestore theater
//   /admin → requires UserRole.admin + isActive
// ============================================================

class FastPageRoute<T> extends MaterialPageRoute<T> {
  FastPageRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 150);
}

class AppRouter {
  // ── Route name constants ─────────────────────────────────────────────────
  static const String splash        = '/splash';
  static const String login         = '/login';
  static const String signup        = '/signup';
  static const String root = '/';
  static const String home          = '/home';
  static const String movieDetail   = '/movie-detail';
  static const String seatSelection = '/seat-selection';
  static const String payment       = '/payment';
  static const String bookingDetail = '/booking-detail';
  static const String owner         = '/owner';
  static const String admin         = '/admin';
  static const String noInternet    = '/no-internet';

  // ── Route generator ──────────────────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      // ── Unauthenticated routes (no guard) ─────────────────────────────
      case splash:
        return FastPageRoute(
          builder: (_) => const SplashScreen(), settings: settings,
        );

      case login:
        return FastPageRoute(
          builder: (_) => const LoginScreen(), settings: settings,
        );

      case signup:
        return FastPageRoute(
          builder: (_) => const SignupScreen(), settings: settings,
        );

      case noInternet:
        return FastPageRoute(
          builder: (_) => const NoInternetScreen(), settings: settings,
        );

      // Keep the root path working by forwarding it through the active
      // startup, connectivity, and authentication checks.
      case root:
        return FastPageRoute(
          builder: (_) => const SplashScreen(), settings: settings,
        );

      // ── Protected: User ───────────────────────────────────────────────
      case home:
        final profile = AuthService.instance.cachedProfile;
        if (profile == null ||
            profile.role != UserRole.user ||
            !profile.isActive) {
          return _redirectToLogin(settings);
        }
        return FastPageRoute(
          builder: (_) => const BottomNavBar(), settings: settings,
        );

      // ── Movie detail / seat / payment / booking (no auth guard) ───────
      // These screens are accessible during a logged-in session and do not
      // require an extra profile check because the user already passed the
      // /home guard. Adding a guard here would break deep-links and in-flow
      // navigation (payment screen, booking detail reached from within session).
      case movieDetail:
        final movie = settings.arguments as MovieModel;
        final currentMovie = MockData.allMovies.firstWhere(
          (m) =>
              m.id == movie.id ||
              m.title.trim().toLowerCase() == movie.title.trim().toLowerCase(),
          orElse: () => movie,
        );
        if (!currentMovie.isActive) {
          return _unavailableMovieRoute(settings);
        }
        return FastPageRoute(
          builder: (_) => MovieDetailScreen(movie: currentMovie),
          settings: settings,
        );

      case seatSelection:
        final args = settings.arguments as Map<String, String>;
        return FastPageRoute(
          builder: (_) => SeatSelectionScreen(
            movieTitle: args['movieTitle'] ?? '',
            showtime:   args['showtime']   ?? '',
            cinema:     args['cinema']     ?? '',
            screen:     args['screen']     ?? '',
            format:     args['format']     ?? '',
            date:       args['date']       ?? '',
          ),
          settings: settings,
        );

      case payment:
        final booking = settings.arguments as BookingModel;
        return FastPageRoute(
          builder: (_) => PaymentScreen(booking: booking), settings: settings,
        );

      case bookingDetail:
        final booking = settings.arguments as BookingModel;
        return FastPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
          settings: settings,
        );

      // ── Protected: Owner ──────────────────────────────────────────────
      case owner:
        final profile = AuthService.instance.cachedProfile;
        final profileTheater = profile?.assignedTheater;

        // Validate role, active status, and theater assignment.
        if (profile == null ||
            profile.role != UserRole.owner ||
            !profile.isActive ||
            profileTheater == null ||
            profileTheater.trim().isEmpty) {
          return _redirectToLogin(settings);
        }

        // Validate that the requested route argument matches the Firestore theater.
        // This prevents an owner from changing the theater by editing the argument.
        // No default — if the argument is absent or mismatched, deny access.
        final requestedTheater = settings.arguments as String?;
        if (requestedTheater == null || requestedTheater != profileTheater) {
          return _redirectToLogin(settings);
        }

        return FastPageRoute(
          builder: (_) => OwnerMainScreen(theaterName: profileTheater),
          settings: settings,
        );

      // ── Protected: Admin ──────────────────────────────────────────────
      case admin:
        final profile = AuthService.instance.cachedProfile;
        if (profile == null ||
            profile.role != UserRole.admin ||
            !profile.isActive) {
          return _redirectToLogin(settings);
        }
        return FastPageRoute(
          builder: (_) => const AdminDashboard(), settings: settings,
        );

      // ── Unknown route ─────────────────────────────────────────────────
      default:
        return FastPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  static FastPageRoute<dynamic> _redirectToLogin(RouteSettings settings) {
    return FastPageRoute(
      builder: (_) => const LoginScreen(), settings: settings,
    );
  }

  static FastPageRoute<dynamic> _unavailableMovieRoute(RouteSettings settings) {
    return FastPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'This movie is currently unavailable.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      settings: settings,
    );
  }
}
