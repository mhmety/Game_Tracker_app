import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class RawgService {
  final String apiKey = '3943be01282741bb89747b01605aabce';

  Future<List<Game>> fetchGames(String genre, {int page = 1}) async {
    final url = Uri.parse(
      'https://api.rawg.io/api/games?genres=$genre&page=$page&page_size=20&key=$apiKey',
    );
    return _fetchAndParseGames(url);
  }

  Future<List<Game>> searchGames(String query, {int page = 1}) async {
    final url = Uri.parse(
      'https://api.rawg.io/api/games?search=$query&page=$page&page_size=20&key=$apiKey',
    );
    return _fetchAndParseGames(url);
  }

  Future<List<Game>> fetchNewestGames({int page = 1}) async {
    final url = Uri.parse(
      'https://api.rawg.io/api/games?ordering=-released&page=$page&page_size=20&key=$apiKey',
    );
    return _fetchAndParseGames(url);
  }

  Future<List<Game>> fetchPopularGames({int page = 1}) async {
    final url = Uri.parse(
      'https://api.rawg.io/api/games?ordering=-rating&page=$page&page_size=20&key=$apiKey',
    );
    return _fetchAndParseGames(url);
  }

  Future<List<Game>> _fetchAndParseGames(Uri url) async {
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List results = json.decode(response.body)['results'];
        return results.map((raw) {
          return Game(
            id: raw['id'].toString(),
            title: raw['name'] ?? 'Unknown',
            description: '', // 🔴 Detayda ayrı alınacak
            played: false,
            genres: (raw['genres'] as List<dynamic>?)
                ?.map((g) => g['name'].toString())
                .toList() ??
                [],
            imageUrl: raw['background_image'],
            rating: (raw['rating'] as num?)?.toDouble(),
            released: raw['released'],
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch games: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching games: $e');
    }
  }

  /// ✅ Detaylı açıklama, sistem bilgileri, geliştirici vs. almak için
  Future<Game> fetchGameDetails(String id) async {
    final url = Uri.parse(
      'https://api.rawg.io/api/games/$id?key=$apiKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final raw = json.decode(response.body);
        return Game(
          id: raw['id'].toString(),
          title: raw['name'] ?? 'Unknown',
          description: raw['description'] ?? '',
          played: false,
          genres: (raw['genres'] as List<dynamic>?)
              ?.map((g) => g['name'].toString())
              .toList() ??
              [],
          imageUrl: raw['background_image'],
          rating: (raw['rating'] as num?)?.toDouble(),
          released: raw['released'],
        );
      } else {
        throw Exception('Failed to fetch game details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching game details: $e');
    }
  }
}
