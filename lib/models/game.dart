class Game {
  final String id;
  final String title;
  String description;
  String? userDescription;
  bool played;
  final List<String> genres;
  final String? imageUrl;
  final double? rating;
  final int? releaseYear;

  Game({
    this.id = '',
    required this.title,
    required this.description,
    required this.userDescription,
    required this.played,
    required this.genres,
    this.imageUrl,
    this.rating,
    this.releaseYear,
  });

  factory Game.fromMap(String id, Map<String, dynamic> data) {
    return Game(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userDescription: data['userDescription'] ?? '',
      played: data['played'] ?? false,
      genres: List<String>.from(data['genres'] ?? []),
      imageUrl: data['imageUrl'],
      rating: (data['rating'] as num?)?.toDouble(),
      releaseYear: data['releaseYear'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'userDescription': userDescription,
      'played': played,
      'genres': genres,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (rating != null) 'rating': rating,
      if (releaseYear != null) 'releaseYear': releaseYear,
    };
  }
}
