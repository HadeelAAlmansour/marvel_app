import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/character.dart';
import '../services/marvel_service.dart';

class CharacterDetailScreen extends StatefulWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  _CharacterDetailScreenState createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  final MarvelService _service = MarvelService();
  late Character character;

  @override
  void initState() {
    super.initState();
    character = widget.character;
  }

  // Build each section: Comics, Series, Stories, Events
  Widget _buildSection(String title, List<Map<String, String>> items) {
    if (items.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(title.toUpperCase(),
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return FutureBuilder<String>(
                future: item['image']!.isEmpty
                    ? _service.fetchItemImage(item['resourceURI']!)
                    : Future.value(item['image']),
                builder: (context, snapshot) {
                  final imageUrl = snapshot.data ?? "";
                  if (imageUrl.isNotEmpty && item['image']!.isEmpty) {
                    item['image'] = imageUrl; // cache loaded image
                  }
                  return GestureDetector(
                    onTap: () {
                      if (imageUrl.isNotEmpty) {
                        // Show enlarged image in a dialog
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(0),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.85),
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Center(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: IconButton(
                                    icon: Icon(Icons.close,
                                        color: Colors.white, size: 30),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            image: imageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(height: 4),
                        SizedBox(
                          width: 120,
                          child: Text(
                            item['name'] ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Build related links section
  Widget _buildRelatedLinks(Map<String, String> urls) {
    if (urls.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text("Related Links".toUpperCase(),
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        for (var entry in urls.entries)
          InkWell(
            onTap: () async {
              final uri = Uri.parse(entry.value);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Could not open the link")),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(entry.key,
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main character image with back button
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: character.getThumbnailUrl(),
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, color: Colors.red),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(character.name,
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                  SizedBox(height: 16),
                  Text("Description",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    character.description.isNotEmpty
                        ? character.description
                        : "No description available.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  _buildSection('Comics', character.comics),
                  _buildSection('Series', character.series),
                  _buildSection('Stories', character.stories),
                  _buildSection('Events', character.events),
                  _buildRelatedLinks(character.urls),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
