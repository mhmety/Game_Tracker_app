import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import 'add_game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Game Tracker')),
      body: StreamBuilder<List<Game>>(
        stream: firestore.getGames(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final games = snapshot.data!;
          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return ListTile(
                title: Text(game.title),
                trailing: IconButton(
                  icon: Icon(
                    game.played ? Icons.check_box : Icons.check_box_outline_blank,
                  ),
                  onPressed: () => firestore.togglePlayed(game),
                ),
                onLongPress: () => firestore.deleteGame(game.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddGameScreen()),
        ),
      ),
    );
  }
}
