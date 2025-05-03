class Game {
  final String id;
  final String title;
  final bool played;

  Game({required this.id, required this.title, this.played = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'played': played,
    };
  }

  factory Game.fromMap(String id, Map<String, dynamic> map) {
    return Game(
      id: id,
      title: map['title'],
      played: map['played'],
    );
  }
}
