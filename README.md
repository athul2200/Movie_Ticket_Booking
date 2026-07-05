# Movix — Movie Ticket Booking App

A modern, premium-quality movie ticket booking application built with Flutter. The app provides two distinct experiences: a **User module** for browsing and booking tickets, and an **Owner/Admin module** for theater management.

---

## 📱 Screenshots

> Run the app on a device or emulator to see it in action.

---

## ✨ Features

### 🎬 User Module
- **Splash Screen:** Branded loading screen with animated transitions.
- **Role Selection:** Choose between User and Owner roles at launch.
- **Home Screen:** Immersive auto-sliding hero carousel showcasing featured movies, with category filter chips and a full movie grid.
- **Movie Catalog:** Filter movies by genre (Action, Drama, Crime-Thriller, etc.) or browse the complete catalog.
- **Movie Details:** Full synopsis, duration, rating, certification, cast & crew, play trailer link, and rating scores (Rotten Tomatoes, IMDB, Metacritic).
- **Smart Showtime Filtering:** IST (Indian Standard Time) aware showtime filtering — expired shows (within 30 minutes before start) are automatically hidden for the current day. Future dates show all available showtimes.
- **Seat Selection:** Interactive seat map for selecting preferred seats.
- **Payment:** Checkout and payment flow for confirmed bookings.
- **Booking Detail:** Full booking summary with QR code and seat details.
- **My Bookings:** History of all past and upcoming bookings.
- **Upcoming:** Browse movies coming soon.
- **Profile:** User profile screen.

### 🏢 Owner / Admin Module
- **Admin Dashboard:** Theater management overview.
- **Movies Management:** Add, update, and remove movies from the catalog.
- **Screens Management:** Track screen availability, seat counts, and operational status.
- **Schedule Management:** Configure showtimes and map movies to specific screens.

### 🌐 Connectivity
- **Real-time Network Monitoring:** Uses `connectivity_plus` + `internet_connection_checker_plus` for true internet reachability (not just interface status).
- **Offline Banner:** A non-intrusive animated banner appears when the device goes offline — with proper layout to prevent overflow on all screen sizes.
- **No Internet Screen:** Dedicated screen when the app is launched with no connection.

---

## 🛠️ Tech Stack & Packages

| Package | Purpose |
|---|---|
| [Flutter](https://flutter.dev/) | Cross-platform UI framework |
| `google_fonts` | Modern typography (premium font rendering) |
| `carousel_slider` | Infinite-looping hero banners |
| `smooth_page_indicator` | Animated page indicators |
| `image_picker` | Image selection from gallery/camera |
| `url_launcher` | Opening external links (trailers, etc.) |
| `connectivity_plus` | Network interface monitoring |
| `internet_connection_checker_plus` | True internet reachability checks |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.11.3`)
- A connected Android/iOS device or emulator

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd movie_ticket_booking/booking
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## 🗺️ App Navigation (Routes)

| Route | Screen |
|---|---|
| `/splash` | Splash / loading screen |
| `/` | Role selection (User or Owner) |
| `/home` | Main home screen with bottom nav bar |
| `/movie-detail` | Movie details & showtime selection |
| `/seat-selection` | Interactive seat map |
| `/payment` | Payment checkout |
| `/booking-detail` | Booking confirmation & summary |
| `/owner` | Owner main screen |
| `/admin` | Admin dashboard |
| `/no-internet` | No internet connection screen |

---

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants (spacing, sizes, etc.)
│   ├── theme/           # AppTheme, AppColors, typography
│   └── utils/
│       └── ist_time_utils.dart   # IST timezone helpers & showtime filtering
├── data/
│   └── mock_data.dart   # Static mock data (movies, theaters, cast)
├── layout/              # Shared layout components
├── models/              # Data classes (MovieModel, TheaterModel, BookingModel, etc.)
├── navigation/
│   └── app_router.dart  # Named route definitions and route generation
├── screens/
│   ├── admin/           # Admin dashboard
│   ├── booking_detail/  # Booking confirmation screen
│   ├── home/            # Home feed & movie grid
│   ├── movie_detail/    # Movie details & IST-aware showtime picker
│   ├── my_bookings/     # User bookings list
│   ├── network/         # No internet screen
│   ├── owner/           # Owner theater management screens
│   ├── payment/         # Payment screen
│   ├── profile/         # User profile
│   ├── role_selection/  # Role picker
│   ├── seat_selection/  # Seat map
│   ├── splash/          # Splash screen
│   └── upcoming/        # Upcoming movies
├── services/
│   └── network_service.dart  # Singleton real-time connectivity monitor
├── widgets/
│   ├── network_overlay.dart  # Global offline banner overlay
│   └── ...                   # Reusable UI components
├── main.dart            # App entry point (User mode)
└── main_admin.dart      # App entry point (Admin mode)
```

---

## 🕒 IST Showtime Filtering

The app is timezone-aware and uses **Indian Standard Time (IST, UTC+5:30)** for all date and showtime logic — regardless of the device's local timezone setting.

- Shows are hidden **30 minutes before** their start time on the current day.
- Future dates always show all available showtimes.
- The filter refreshes automatically every 60 seconds while the detail screen is open.

---

## 🧪 Testing

Run unit tests with:
```bash
flutter test
```

To run the IST time utility tests specifically:
```bash
flutter test test/time_test.dart
```

---

*Built with ❤️ using Flutter.*
