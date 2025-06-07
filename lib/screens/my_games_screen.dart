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
  final TextEditingController _searchController = TextEditingController();
  List<Game> _allGames = [];
  List<Game> _filteredGames = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filter = 'Tümü';

  final Color backgroundColor = const Color(0xFF071952);
  final Color cardColor = const Color(0xFF088395);
  final Color accentColor = const Color(0xFF35A29F);
  final Color textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    try {
      final games = await FirestoreService().getGames();
      setState(() {
        _allGames = games;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  void _togglePlayed(Game game, bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('games')
          .doc(game.id)
          .update({'played': value});
      setState(() {
        game.played = value;
        _applyFilters();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Durum güncellenemedi: $e')),
      );
    }
  }

  void _deleteGame(Game game) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text('Silmek istediğinizden emin misiniz?', style: TextStyle(color: textColor)),
        content: Text('Bu işlem geri alınamaz.', style: TextStyle(color: textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Evet', style: TextStyle(color: accentColor)),
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: const Text('My Games'),
        foregroundColor: textColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Oyun ara...',
                hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: textColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: TextStyle(color: textColor),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['Tümü', 'Oynandı', 'Oynanacak'].map((label) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(label, style: TextStyle(color: textColor)),
                    selected: _filter == label,
                    onSelected: (_) {
                      setState(() {
                        _filter = label;
                        _applyFilters();
                      });
                    },
                    selectedColor: accentColor,
                    backgroundColor: cardColor,
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredGames.length,
              itemBuilder: (context, index) {
                final game = _filteredGames[index];
                return GestureDetector(
                  onLongPress: () => _deleteGame(game),
                  child: Card(
                    color: cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ExpansionTile(
                      iconColor: textColor,
                      collapsedIconColor: textColor,
                      title: Text(game.title, style: TextStyle(color: textColor)),
                      leading: game.imageUrl != null && game.imageUrl!.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          game.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(Icons.videogame_asset, size: 40, color: textColor),
                      subtitle: game.userDescription != null &&
                          game.userDescription!.isNotEmpty
                          ? Text(game.userDescription!, style: TextStyle(color: textColor))
                          : null,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: TextEditingController(text: game.userDescription),
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Kendi notunu gir',
                                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                                  filled: true,
                                  fillColor: backgroundColor,
                                  border: const OutlineInputBorder(),
                                ),
                                style: TextStyle(color: textColor),
                                onSubmitted: (value) async {
                                  final updatedNote = value.trim();
                                  if (updatedNote != game.userDescription) {
                                    await FirebaseFirestore.instance
                                        .collection('games')
                                        .doc(game.id)
                                        .update({'userDescription': updatedNote});
                                    setState(() {
                                      game.userDescription = updatedNote;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Oynandı mı?', style: TextStyle(color: textColor)),
                                  Switch(
                                    value: game.played,
                                    onChanged: (val) => _togglePlayed(game, val),
                                    activeColor: accentColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
