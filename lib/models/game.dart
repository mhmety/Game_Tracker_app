class Game {
  final String id;
  final String title;
  String description;
  bool played;
  final List<String> genres;

  Game({
    this.id = '',
    required this.title,
    required this.description,
    required this.played,
    required this.genres,
  });

  // Firestore'dan veri çekerken kullanılır
  factory Game.fromMap(String id, Map<String, dynamic> data) {
    return Game(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      played: data['played'] ?? false,
      genres: List<String>.from(data['genres'] ?? []),
    );
  }

  // Firestore'a veri gönderirken kullanılır
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'played': played,
      'genres': genres,
    };
  }
}
