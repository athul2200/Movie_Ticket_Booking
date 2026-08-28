import 'package:flutter/material.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/models/booking_model.dart';
import 'package:booking/widgets/bottom_nav_bar.dart';
import 'package:booking/screens/role_selection/role_selection_screen.dart';
import 'package:booking/screens/movie_detail/movie_detail_screen.dart';
import 'package:booking/screens/seat_selection/seat_selection_screen.dart';
import 'package:booking/screens/booking_detail/booking_detail_screen.dart';
import 'package:booking/screens/payment/payment_screen.dart';
import 'package:booking/screens/owner/main/owner_main_screen.dart';
import 'package:booking/screens/admin/admin_dashboard.dart';
import 'package:booking/screens/splash/splash_screen.dart';
import 'package:booking/screens/network/no_internet_screen.dart';
/// ============================================================
/// App Router — Named route definitions
/// ============================================================

class FastPageRoute<T> extends MaterialPageRoute<T> {
  FastPageRoute({required super.builder, super.settings});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 150);
}

class AppRouter {
  static const String roleSelection = '/';
  static const String home = '/home';
  static const String movieDetail = '/movie-detail';
  static const String seatSelection = '/seat-selection';
  static const String payment = '/payment';
  static const String bookingDetail = '/booking-detail';
  static const String owner = '/owner';
  static const String admin = '/admin';
  static const String splash = '/splash';
  static const String noInternet = '/no-internet';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return FastPageRoute(builder: (_) => const SplashScreen(), settings: settings);

      case noInternet:
        return FastPageRoute(builder: (_) => const NoInternetScreen(), settings: settings);

      case roleSelection:
        return FastPageRoute(builder: (_) => const RoleSelectionScreen(), settings: settings);

      case home:
        return FastPageRoute(builder: (_) => const BottomNavBar(), settings: settings);

      case movieDetail:
        final movie = settings.arguments as MovieModel;
        return FastPageRoute(
          builder: (_) => MovieDetailScreen(movie: movie),
          settings: settings,
        );

      case seatSelection:
        final args = settings.arguments as Map<String, String>;
        return FastPageRoute(
          builder: (_) => SeatSelectionScreen(
            movieTitle: args['movieTitle'] ?? '',
            showtime: args['showtime'] ?? '',
            cinema: args['cinema'] ?? '',
            screen: args['screen'] ?? '',
            format: args['format'] ?? '',
            date: args['date'] ?? '',
          ),
          settings: settings,
        );

      case payment:
        final booking = settings.arguments as BookingModel;
        return FastPageRoute(
          builder: (_) => PaymentScreen(booking: booking),
          settings: settings,
        );

      case bookingDetail:
        final booking = settings.arguments as BookingModel;
        return FastPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
          settings: settings,
        );

      case owner:
        final theaterName = settings.arguments as String? ?? 'Kairali';
        return FastPageRoute(builder: (_) => OwnerMainScreen(theaterName: theaterName), settings: settings);

      case admin:
        return FastPageRoute(builder: (_) => const AdminDashboard(), settings: settings);

      default:
        return FastPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
