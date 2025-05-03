import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';

class FirestoreService {
  final gamesRef = FirebaseFirestore.instance.collection('games');

  Stream<List<Game>> getGames() {
    return gamesRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Game.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> addGame(String title) async {
    await gamesRef.add({'title': title, 'played': false});
  }

  Future<void> togglePlayed(Game game) async {
    await gamesRef.doc(game.id).update({'played': !game.played});
  }

  Future<void> deleteGame(String id) async {
    await gamesRef.doc(id).delete();
  }
}
