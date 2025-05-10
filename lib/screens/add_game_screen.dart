import 'package:flutter/material.dart';
import 'package:game_tracker/screens/my_games_screen.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';

class AddGameScreen extends StatefulWidget {
  final Game game;

  const AddGameScreen({super.key, required this.game});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _descriptionController = TextEditingController();
  bool _played = false;

  Future<void> _saveGame() async {
    // oyun eklenmeden önce bir gösterge istersen:
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newGame = Game(
        title: widget.game.title,
        description: _descriptionController.text.isEmpty
            ? 'Açıklama eklenmedi'
            : _descriptionController.text,
        played: _played,
        genres: widget.game.genres,
      );

      await FirestoreService().addGameFromRawg(
        title: newGame.title,
        description: newGame.description,
        genres: newGame.genres,
        played: newGame.played,
      );

      Navigator.of(context).pop(); // loading dialogu kapat

      // Doğrudan MyGamesScreen'e yönlendir
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyGamesScreen()),
            (route) => false,
      );
    } catch (e) {
      Navigator.of(context).pop(); // loading dialogu kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oyun eklenemedi: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama (isteğe bağlı)'),
            ),
            const SizedBox(height: 20),
            RadioListTile<bool>(
              title: const Text('Oynanacak'),
              value: false,
              groupValue: _played,
              onChanged: (value) => setState(() => _played = value!),
            ),
            RadioListTile<bool>(
              title: const Text('Oynandı'),
              value: true,
              groupValue: _played,
              onChanged: (value) => setState(() => _played = value!),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveGame();
              },
              child: const Text('Oyun Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
