class Game {
  final String id;
  final String title;
  String description;
  String? userDescription;
  bool played;
  final List<String> genres;
  final String? imageUrl;
  final double? rating;
  final String? released;

  Game({
    required this.id,
    required this.title,
    required this.description,
    this.userDescription,
    required this.played,
    required this.genres,
    this.imageUrl,
    this.rating,
    this.released,
  });

  int? get releaseYear {
    if (released == null || released!.isEmpty) return null;
    try {
      return DateTime.parse(released!).year;
    } catch (e) {
      print("Invalid release date format: $released");
      return null;
    }
  }

  factory Game.fromMap(String id, Map<String, dynamic> data) {
    return Game(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userDescription: data['userDescription'],
      played: data['played'] ?? false,
      genres: List<String>.from(data['genres'] ?? []),
      imageUrl: data['imageUrl'],
      rating: (data['rating'] as num?)?.toDouble(),
      released: data['released'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'userDescription': userDescription ?? '',
      'played': played,
      'genres': genres,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (rating != null) 'rating': rating,
      if (released != null) 'released': released,
    };
  }
}
