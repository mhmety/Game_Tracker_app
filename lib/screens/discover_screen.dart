import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/rawg_service.dart';
import 'add_game_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RawgService _rawgService = RawgService();

  List<Game> _searchResults = [];
  List<Game> _allGames = [];
  List<Game> _popularGames = [];
  List<Game> _newestGames = [];

  String? _popularFilter;
  String? _newestFilter;
  String? _popularFilteredGenre;
  String? _latestFilteredGenre;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialGames();
  }

  Future<void> _loadInitialGames() async {
    setState(() => _isLoading = true);
    try {
      final games = await _rawgService.fetchGames('');
      _allGames = games;

      _popularGames = List.from(games)..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      _newestGames = List.from(games)..sort((a, b) => (b.releaseYear ?? 0).compareTo(a.releaseYear ?? 0));
    } catch (e) {
      debugPrint('Hata: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _searchGames(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    final results = await _rawgService.fetchGames(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  List<Game> _applyFilter(List<Game> games, String? genre) {
    if (genre == null) return games;
    return games.where((g) => g.genres.contains(genre)).toList();
  }

  void _openFilterDialog(String listType) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        final allGenres = _allGames.expand((g) => g.genres).toSet().toList();

        return AlertDialog(
          title: const Text('Kategori Seç'),
          content: SingleChildScrollView(
            child: Column(
              children: allGenres.map((genre) {
                return ListTile(
                  title: Text(genre),
                  onTap: () {
                    Navigator.pop(context, genre); // Seçilen filtreyi döndür
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (listType == 'popular') {
          _popularFilteredGenre = selected;
        } else if (listType == 'latest') {
          _latestFilteredGenre = selected;
        }
      });
    }
  }

  Widget _buildGameCard(Game game) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddGameScreen(game: game),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (game.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  game.imageUrl!,
                  height: 90,
                  width: 160,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              game.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _shortenText(game.description),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }


  String _shortenText(String text, [int maxLength = 100]) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength).trim() + '...';
  }

  @override
  Widget build(BuildContext context) {
    final filteredPopular = _applyFilter(_popularGames, _popularFilteredGenre);
    final filteredNewest = _applyFilter(_newestGames, _latestFilteredGenre);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keşfet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: _searchGames,
              decoration: InputDecoration(
                hintText: 'Oyun ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Arama Sonuçları
            if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final game = _searchResults[index];
                    return ListTile(
                      leading: game.imageUrl != null
                          ? Image.network(game.imageUrl!, width: 50)
                          : null,
                      title: Text(game.title),
                      subtitle: Text(_shortenText(game.description, 50)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddGameScreen(game: game),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView(
                  children: [
                    _buildSection(
                      title: 'En Popüler Oyunlar',
                      games: filteredPopular,
                      onFilterPressed: () => _openFilterDialog('popular'),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Yeni Çıkanlar',
                      games: filteredNewest,
                      onFilterPressed: () => _openFilterDialog('newest'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Game> games,
    required VoidCallback onFilterPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: onFilterPressed,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: games.length,
            itemBuilder: (context, index) => _buildGameCard(games[index]),
          ),
        ),
      ],
    );
  }
}
