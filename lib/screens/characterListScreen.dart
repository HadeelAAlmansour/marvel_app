import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/marvel_service.dart';
import 'character_detail_screen.dart';

class CharacterListScreen extends StatefulWidget {
  @override
  _CharacterListScreenState createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final MarvelService _marvelService = MarvelService();
  List<Character> _characters = [];
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchCharacters();
    }
  }

  Future<void> _fetchCharacters() async {
    setState(() => _isLoading = true);
    final newCharacters =
        await _marvelService.fetchCharacters(offset: _offset, limit: _limit);
    setState(() {
      _characters.addAll(newCharacters);
      _offset += _limit;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.asset("Images/marvel_logo.png", height: 40),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.red.shade900),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CharacterSearchDelegate(_characters),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _characters.length,
        itemBuilder: (context, index) {
          final character = _characters[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CharacterDetailScreen(character: character),
                ),
              );
            },
            child: Stack(
              children: [
                Image.network(
                  character.thumbnail,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  left: 25,
                  child: ClipPath(
                    clipper: ParallelogramClipper(),
                    child: Container(
                      width: 180,
                      height: 40,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          character.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// متوازي الأضلاع للصندوق الأبيض
class ParallelogramClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double skew = 15;
    Path path = Path();
    path.moveTo(skew, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - skew, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// البحث
class CharacterSearchDelegate extends SearchDelegate {
  final List<Character> characters;

  CharacterSearchDelegate(this.characters);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = characters
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildCharacterList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = characters
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildCharacterList(suggestions);
  }

  Widget _buildCharacterList(List<Character> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final character = list[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CharacterDetailScreen(character: character),
              ),
            );
          },
          child: Stack(
            children: [
              Image.network(
                character.thumbnail,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 25,
                left: 25,
                child: ClipPath(
                  clipper: ParallelogramClipper(),
                  child: Container(
                    width: 180,
                    height: 40,
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        character.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
