import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:game_tracker/models/game.dart';

class RawgService {
  static const String apiKey = '3943be01282741bb89747b01605aabce';
  static const String apiUrl = 'https://api.rawg.io/api/games';

  // Arama yap ve temel oyun bilgilerini döndür
  Future<List<Game>> fetchGames(String query) async {
    final response = await http.get(
      Uri.parse('$apiUrl?key=$apiKey&page_size=10&search=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List games = data['results'];

      return Future.wait(games.map((game) async {
        final List<dynamic>? genreList = game['genres'];
        final genres = genreList != null
            ? genreList.map((g) => g['name'].toString()).toList()
            : <String>[];

        // Detay verisini al (açıklama için)
        final gameDetails = await fetchGameDetails(game['id']);

        return Game(
          title: game['name'] ?? 'No title',
          description: gameDetails['description_raw'] ?? 'Açıklama bulunamadı',
          genres: genres,
          played: false, // Kullanıcıya özel: başlangıçta false
          imageUrl: game['background_image'],
          rating: game['rating']?.toDouble(),
          releaseYear: game['released'] != null
              ? DateTime.tryParse(game['released'])?.year
              : null,
          userDescription: null, // Kullanıcıya özel: veritabanında tutulmalı
        );
      }).toList());
    } else {
      throw Exception('Failed to load games');
    }
  }

  // Oyun detaylarını getir (özellikle açıklama için)
  Future<Map<String, dynamic>> fetchGameDetails(int gameId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/$gameId?key=$apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {}; // Açıklama yoksa boş dön
    }
  }
}
