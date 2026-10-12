import 'package:flutter_test/flutter_test.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/data/mock_data.dart';

void main() {
  test('MockData allMovies loads and stores properly', () {
    expect(MockData.allMovies, isNotNull);
    final initialCount = MockData.allMovies.length;
    final testMovie = MovieModel(
      id: 'test_123',
      title: 'Smoke Test Movie',
      description: 'Test Description',
      genres: ['Action'],
      duration: '120 mins',
      rating: 4.5,
      certification: 'UA',
      posterUrl: 'https://example.com/poster.jpg',
      bannerUrl: 'https://example.com/banner.jpg',
      theaters: ['Kairali'],
    );

    MockData.allMovies.add(testMovie);
    expect(MockData.allMovies.length, initialCount + 1);
    MockData.allMovies.removeWhere((m) => m.id == 'test_123');
    expect(MockData.allMovies.length, initialCount);
  });
}
