import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/rawg_service.dart';
import 'add_game_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Game> _searchResults = [];
  bool _isLoading = false;

  void _searchGames() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await RawgService().fetchGames(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oyunlar alınamadı: $e')),
      );
    }
  }

  void _openAddGameScreen(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGameScreen(game: game),
      ),
    ).then((added) {
      if (added == true) {
        setState(() {}); // Ekranı yenile
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keşfet'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Oyun ara...',
                    ),
                    onSubmitted: (_) => _searchGames(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchGames,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? const Center(child: Text('Oyun araması yapın'))
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final game = _searchResults[index];
                return ListTile(
                  title: Text(game.title),
                  subtitle: Text(game.genres.join(', ')),
                  onTap: () => _openAddGameScreen(game),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
