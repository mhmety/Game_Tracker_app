import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _played = widget.game.played; // Mevcut durumu başlat
  }

  void _openBottomSheet() {
    showModalBottomSheet(
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
                  const Text(
                    "Oyun Durumu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  RadioListTile<bool>(
                    title: const Text("Oynanacak"),
                    value: false,
                    groupValue: _played,
                    onChanged: (value) {
                      setState(() => _played = value!);
                      setModalState(() {}); // Modal UI'ını da yenile
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text("Oynandı"),
                    value: true,
                    groupValue: _played,
                    onChanged: (value) {
                      setState(() => _played = value!);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _saveGame,
                    icon: const Icon(Icons.check),
                    label: const Text("Oyun Ekle"),
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
    Navigator.of(context).pop(); // BottomSheet kapat

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final game = widget.game;

      await FirestoreService().addGameFromRawg(
        title: game.title,
        description: game.description,
        genres: game.genres,
        played: _played,
        imageUrl: game.imageUrl,
        rating: game.rating,
        releaseYear: game.releaseYear,
      );

      Navigator.of(context).pop(); // Loading kapat

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
      appBar: AppBar(title: const Text('Oyun Detayı')),
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (game.rating != null)
              Text('Puan: ${game.rating!.toStringAsFixed(1)}'),
            if (game.releaseYear != null)
              Text('Çıkış Yılı: ${game.releaseYear}'),
            const SizedBox(height: 8),
            if (game.genres.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: game.genres.map((genre) {
                  return Chip(
                    label: Text(genre),
                    backgroundColor: Colors.grey.shade200,
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            const Text(
              'Açıklama',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              game.description.isNotEmpty
                  ? game.description
                  : 'Açıklama bulunamadı.',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _openBottomSheet,
            icon: const Icon(Icons.add),
            label: const Text('Ekle'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
