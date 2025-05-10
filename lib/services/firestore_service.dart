import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';

class FirestoreService {
  final CollectionReference gamesRef =
  FirebaseFirestore.instance.collection('games');

  // Firestore'a yeni oyun ekleme
  Future<void> addGameFromRawg({
    required String title,
    required String description,
    required List<String> genres,
    required bool played,
  }) async {
    await gamesRef.add({
      'title': title,
      'description': description,
      'genres': genres,
      'played': played,
      'createdAt': FieldValue.serverTimestamp(), // Tarih sıralama için
    });
  }

  // Firestore'dan oyunları çekme
  Future<List<Game>> getGames() async {
    final snapshot =
    await gamesRef.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Game.fromMap(doc.id, data);
    }).toList();
  }
}
