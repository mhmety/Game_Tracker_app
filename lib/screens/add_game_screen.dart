import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';
import 'main_tab_screen.dart';

class AddGameScreen extends StatefulWidget {
  final Game game;

  const AddGameScreen({super.key, required this.game});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  bool _played = false;

  final Color darkBlue = const Color(0xFF071952);
  final Color turquoise = const Color(0xFF088395);
  final Color lightTurquoise = const Color(0xFF35A29F);

  @override
  void initState() {
    super.initState();
    _played = widget.game.played;
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      backgroundColor: darkBlue,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Oyun Durumu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RadioListTile<bool>(
                    title: const Text("Oynanacak", style: TextStyle(color: Colors.white)),
                    value: false,
                    groupValue: _played,
                    activeColor: turquoise,
                    onChanged: (value) {
                      setState(() => _played = value!);
                      setModalState(() {});
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text("Oynandı", style: TextStyle(color: Colors.white)),
                    value: true,
                    groupValue: _played,
                    activeColor: turquoise,
                    onChanged: (value) {
                      setState(() => _played = value!);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _saveGame,
                    icon: Icon(Icons.check, color: lightTurquoise),
                    label: const Text("Oyun Ekle", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: turquoise,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(45),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveGame() async {
    Navigator.of(context).pop(); // BottomSheet'i kapat

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş yapmanız gerekiyor.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final game = widget.game;
      final firestoreService = FirestoreService();

      await firestoreService.addGameFromRawg(
        title: game.title,
        description: game.description,
        genres: game.genres,
        played: _played,
        imageUrl: game.imageUrl,
        rating: game.rating,
        releaseYear: game.releaseYear,
        userId: user.uid,
      );

      await firestoreService.addUserGame(
        title: game.title,
        description: game.description,
        genres: game.genres,
        played: _played,
        imageUrl: game.imageUrl,
        rating: game.rating,
        releaseYear: game.releaseYear,
      );

      Navigator.of(context).pop(); // Loading dialog'u kapat

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oyun başarıyla eklendi!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
            (route) => false,
      );
    } catch (e) {
      Navigator.of(context).pop(); // Loading kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text('Oyun Detayı', style: TextStyle(color: Colors.white)),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (game.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  game.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              game.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (game.rating != null)
              Text(
                'Puan: ${game.rating!.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white),
              ),
            if (game.releaseYear != null)
              Text(
                'Çıkış Yılı: ${game.releaseYear}',
                style: const TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 8),
            if (game.genres.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: game.genres.map((genre) {
                  return Chip(
                    label: Text(genre, style: const TextStyle(color: Colors.white)),
                    backgroundColor: turquoise.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: turquoise),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            const Text(
              'Açıklama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              game.description.isNotEmpty ? game.description : 'Açıklama bulunamadı.',
              style: const TextStyle(fontSize: 14, color: Colors.white),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _openBottomSheet,
            icon: Icon(Icons.add, color: lightTurquoise),
            label: const Text('Ekle', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: turquoise,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
