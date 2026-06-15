# Movix - Movie Ticket Booking App

A modern, visually appealing movie ticket booking application built with Flutter. The application provides two distinct experiences: one for standard users to browse and book tickets, and another for theater owners to manage their inventory and schedules.

## 📱 Features

### User Module
- **Home Screen:** Discover new and featured movies with an immersive auto-sliding hero carousel.
- **Movie Catalog:** Filter movies by categories (Action, Sci-Fi, Drama, etc.) or browse the full grid.
- **Movie Details:** View detailed information including synopsis, duration, rating, certification, and high-quality banners.
- **Ticket Booking:** Seamlessly book movie tickets for upcoming shows.

### Owner (Admin) Module
- **Admin Dashboard:** Overview of the theater management system.
- **Movies Management:** Add, update, and remove movies from the catalog.
- **Screens Management:** Track screen availability, seat counts, and status.
- **Schedule Management:** Configure showtimes and map movies to specific screens.

## 🛠️ Tech Stack & Packages

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **UI & Theming:** Custom dark/premium theme inspired by modern theater designs.
- **Key Packages:**
  - `carousel_slider`: For infinite-looping hero banners.
  - `smooth_page_indicator`: For beautiful, animated page indicators.
  - `google_fonts`: For modern and responsive typography.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A connected device or an emulator

### Installation

1. Clone this repository to your local machine.
2. Navigate to the project directory:
   ```bash
   cd movie_ticket_booking/booking
   ```
3. Install the required dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

The project is structured into modular feature-based directories under `lib/`:
- `core/`: Themes, constants, and shared configurations.
- `data/`: Mock data and models used across the application.
- `models/`: Data classes (e.g., `MovieModel`).
- `screens/`: Contains all the UI screens grouped by feature (`home`, `movie_detail`, `owner/`).
- `widgets/`: Reusable UI components (e.g., `HeroBanner`, `MovieCard`, `CategoryChips`).

---
*Developed with Flutter.*
