import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';
import '../services/firestore_service.dart';

class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({super.key});

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen> {
  List<Game> _allGames = [];
  List<Game> _filteredGames = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filter = 'Tümü';

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  void _showEditUserNoteDialog(Game game) {
    final controller = TextEditingController(text: game.userDescription);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kendi Notun'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Kendi yorumunu gir'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedNote = controller.text.trim();
              if (updatedNote != game.userDescription) {
                await FirebaseFirestore.instance
                    .collection('games')
                    .doc(game.id)
                    .update({'userNote': updatedNote});
                setState(() {
                  game.userDescription = updatedNote;
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _loadGames() async {
    try {
      final games = await FirestoreService().getGames();
      setState(() {
        _allGames = games;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oyunlar alınamadı: $e')),
      );
    }
  }

  void _applyFilters() {
    List<Game> filtered = _allGames;

    if (_filter == 'Oynandı') {
      filtered = filtered.where((g) => g.played).toList();
    } else if (_filter == 'Oynanacak') {
      filtered = filtered.where((g) => !g.played).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((g) => g.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredGames = filtered;
    });
  }

  void _showGameDetails(Game game) {
    final controller = TextEditingController(text: game.description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(game.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final updatedDescription = controller.text.trim();
                if (updatedDescription != game.description) {
                  await FirebaseFirestore.instance.collection('games').doc(game.id).update({
                    'description': updatedDescription,
                  });
                  setState(() {
                    game.description = updatedDescription;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Oyun silme işlemi
  void _deleteGame(Game game) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silmek istediğinizden emin misiniz?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Evet'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      try {
        await FirebaseFirestore.instance.collection('games').doc(game.id).delete();
        setState(() {
          _allGames.removeWhere((g) => g.id == game.id);
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oyun başarıyla silindi.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oyun silinemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyunlarım'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGames,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Oyunlarda ara...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: const Text('Tümü'),
                  selected: _filter == 'Tümü',
                  onSelected: (_) {
                    _filter = 'Tümü';
                    _applyFilters();
                  },
                ),
                FilterChip(
                  label: const Text('Oynandı'),
                  selected: _filter == 'Oynandı',
                  onSelected: (_) {
                    _filter = 'Oynandı';
                    _applyFilters();
                  },
                ),
                FilterChip(
                  label: const Text('Oynanacak'),
                  selected: _filter == 'Oynanacak',
                  onSelected: (_) {
                    _filter = 'Oynanacak';
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredGames.isEmpty
                ? const Center(child: Text('Oyun bulunamadı.'))
                : ListView.builder(
              itemCount: _filteredGames.length,
              itemBuilder: (context, index) {
                final game = _filteredGames[index];
                return GestureDetector(
                  onLongPress: () => _deleteGame(game), // Uzun basıldığında silme işlemi
                  child: ExpansionTile(
                    leading: game.imageUrl != null && game.imageUrl!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        game.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                      ),
                    )
                        : const Icon(Icons.image_not_supported),
                    title: Text(game.title),
                    subtitle: Text(game.genres.join(', ')),
                    trailing: IconButton(
                      icon: Icon(
                        game.played ? Icons.check_circle : Icons.schedule,
                        color: game.played ? Colors.green : Colors.orange,
                      ),
                      onPressed: () async {
                        final newStatus = !game.played;
                        final confirmation = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              newStatus
                                  ? 'Oynandı olarak işaretlensin mi?'
                                  : 'Oynanacak olarak işaretlensin mi?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('İptal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Evet'),
                              ),
                            ],
                          ),
                        );

                        if (confirmation == true) {
                          await FirebaseFirestore.instance
                              .collection('games')
                              .doc(game.id)
                              .update({'played': newStatus});
                          setState(() {
                            game.played = newStatus;
                          });
                        }
                      },
                    ),
                    children: [
                      ListTile(
                        subtitle: Text(
                          game.userDescription?.isNotEmpty == true
                              ? game.userDescription!
                              : 'Henüz bir not eklenmemiş.',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_note),
                          onPressed: () {
                            _showEditUserNoteDialog(game);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
