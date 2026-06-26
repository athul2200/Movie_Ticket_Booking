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
/// ============================================================
/// App Router — Named route definitions
/// ============================================================

class AppRouter {
  static const String roleSelection = '/';
  static const String home = '/home';
  static const String movieDetail = '/movie-detail';
  static const String seatSelection = '/seat-selection';
  static const String payment = '/payment';
  static const String bookingDetail = '/booking-detail';
  static const String owner = '/owner';
  static const String admin = '/admin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const BottomNavBar());

      case movieDetail:
        final movie = settings.arguments as MovieModel;
        return MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movie: movie),
        );

      case seatSelection:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => SeatSelectionScreen(
            movieTitle: args['movieTitle'] ?? '',
            showtime: args['showtime'] ?? '',
            cinema: args['cinema'] ?? '',
            screen: args['screen'] ?? '',
            format: args['format'] ?? '',
            date: args['date'] ?? '',
          ),
        );

      case payment:
        final booking = settings.arguments as BookingModel;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(booking: booking),
        );

      case bookingDetail:
        final booking = settings.arguments as BookingModel;
        return MaterialPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
        );

      case owner:
        return MaterialPageRoute(builder: (_) => const OwnerMainScreen());

      case admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
