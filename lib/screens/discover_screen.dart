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
  final RawgService _rawgService = RawgService();
  late Future<List<Game>> _popularGamesFuture;
  late Future<List<Game>> _newestGamesFuture;

  List<Game>? _searchResults;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final Color backgroundColor = const Color(0xFF071952);
  final Color cardColor = const Color(0xFF088395);

  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _popularGamesFuture = _rawgService.fetchPopularGames();
    _newestGamesFuture = _rawgService.fetchNewestGames();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final results = await _rawgService.searchGames(query);
      setState(() => _searchResults = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onSubmitted: _performSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search games...',
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: cardColor,
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchResults = null);
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGenreFilterDropdown(List<Game> games) {
    final Set<String> allGenres = games
        .expand((game) => game.genres ?? [])
        .map((genre) => genre.toString()) // Tüm türleri String'e dönüştür
        .toSet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButton<String?>(
        dropdownColor: cardColor,
        value: allGenres.contains(_selectedGenre) || _selectedGenre == null ? _selectedGenre : null,
        hint: const Text('Filter by Genre', style: TextStyle(color: Colors.white70)),
        isExpanded: true,
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('All Games', style: TextStyle(color: Colors.white)),
          ),
          ...allGenres.map(
                (genre) => DropdownMenuItem<String?>(
              value: genre,
              child: Text(genre, style: const TextStyle(color: Colors.white)),
            ),
          )
        ],
        onChanged: (value) {
          setState(() {
            _selectedGenre = value;
          });
        },
      ),
    );
  }

  Widget _buildGameList(List<Game> games) {
    final filteredGames = _selectedGenre == null
        ? games
        : games.where((game) => game.genres?.contains(_selectedGenre) ?? false).toList();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredGames.length,
        itemBuilder: (context, index) {
          final game = filteredGames[index];
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
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  game.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      game.imageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  )
                      : Container(
                    height: 100,
                    color: Colors.grey,
                    child: const Icon(Icons.image_not_supported),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (game.rating != null)
                    Text(
                      '⭐ ${game.rating}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFutureGameSection(String title, Future<List<Game>> future) {
    return FutureBuilder<List<Game>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No games found.', style: TextStyle(color: Colors.white)),
          );
        }

        final games = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            _buildGenreFilterDropdown(games),
            _buildGameList(games),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (_searchResults == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Search Results',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        _searchResults!.isEmpty
            ? const Padding(
          padding: EdgeInsets.all(12),
          child: Text('No results found.', style: TextStyle(color: Colors.white)),
        )
            : _buildGameList(_searchResults!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: const Text('Discover Games', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildSearchResults(),
            _buildFutureGameSection('Popular Games', _popularGamesFuture),
            _buildFutureGameSection('Newest Games', _newestGamesFuture),
          ],
        ),
      ),
    );
  }
}
