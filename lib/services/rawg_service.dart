import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:game_tracker/models/game.dart';

class RawgService {
  static const String apiKey = '3943be01282741bb89747b01605aabce';
  static const String apiUrl = 'https://api.rawg.io/api/games';

  Future<List<Game>> fetchGames(String query) async {
    final response = await http.get(
      Uri.parse('$apiUrl?key=$apiKey&page_size=10&search=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List games = data['results'];

      return games.map((game) {
        final List<dynamic>? genreList = game['genres'];
        final genres = genreList != null
            ? genreList.map((g) => g['name'].toString()).toList()
            : <String>[];

        return Game(
          title: game['name'] ?? 'No title',
          description: game['slug'] ?? '',
          genres: genres,
          played: false,
        );
      }).toList();
    } else {
      throw Exception('Failed to load games');
    }
  }
}
