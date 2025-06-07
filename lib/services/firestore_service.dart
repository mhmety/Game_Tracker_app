import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _gamesRef => _firestore.collection('games');

  CollectionReference get _userGamesRef {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");
    return _firestore.collection('users').doc(user.uid).collection('games');
  }

  CollectionReference get _discoverRef => _firestore.collection('discover');

  // Genel (ortak) oyun ekleme
  Future<void> addGameFromRawg({
    required String title,
    required String description,
    required List<String> genres,
    required bool played,
    String? imageUrl,
    double? rating,
    int? releaseYear,
    String? userId,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'genres': genres,
      'played': played,
      'imageUrl': imageUrl,
      'rating': rating,
      'releaseYear': releaseYear,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (userId != null) {
      data['userId'] = userId;
    }
    await _gamesRef.add(data);
  }

  // Kullanıcıya özel oyun ekleme
  Future<void> addUserGame({
    required String title,
    required String description,
    required List<String> genres,
    required bool played,
    String? imageUrl,
    double? rating,
    int? releaseYear,
  }) async {
    await _userGamesRef.add({
      'title': title,
      'description': description,
      'userDescription': '', // ilk eklemede boş olabilir
      'genres': genres,
      'played': played,
      'imageUrl': imageUrl,
      'rating': rating,
      'releaseYear': releaseYear,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Keşfet kısmına oyun ekleme
  Future<void> addToDiscover({
    required String title,
    required String description,
    required List<String> genres,
    required String platform,
    String? imageUrl,
    double? rating,
    int? releaseYear,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış.");

    await _discoverRef.add({
      'title': title,
      'description': description,
      'genres': genres,
      'platform': platform,
      'imageUrl': imageUrl,
      'rating': rating,
      'releaseYear': releaseYear,
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Kullanıcının özel oyunlarını çekme
  Future<List<Game>> getUserGames() async {
    final snapshot = await _userGamesRef
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Game.fromMap(doc.id, data);
    }).toList();
  }

  // Genel (games koleksiyonu) oyun listesini çekme
  Future<List<Game>> getGames() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _gamesRef
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Game.fromMap(doc.id, data);
    }).toList();
  }

  // Keşfet kısmındaki oyunları çekme
  Future<List<Game>> getDiscoverGames() async {
    final snapshot = await _discoverRef
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Game.fromMap(doc.id, data);
    }).toList();
  }

  // Kullanıcı oyununu güncelleme
  Future<void> updateUserGame(Game game) async {
    if (game.id == null || game.id!.isEmpty) {
      throw Exception('Oyun ID\'si eksik, güncelleme yapılamaz.');
    }

    await _userGamesRef.doc(game.id).update({
      'userDescription': game.userDescription,
      'played': game.played,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Kullanıcı oyununu silme
  Future<void> deleteUserGame(String gameId) async {
    await _userGamesRef.doc(gameId).delete();
  }
}
