class Character {
  final int id;
  final String name;
  final String description;
  final String thumbnail;
  final List<Map<String, String>> comics;
  final List<Map<String, String>> series;
  final List<Map<String, String>> stories;
  final List<Map<String, String>> events;
  final Map<String, String> urls;

  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
    required this.comics,
    required this.series,
    required this.stories,
    required this.events,
    required this.urls,
  });

  // Factory constructor to create a Character instance from JSON
  factory Character.fromJson(Map<String, dynamic> json) {
    // Build the full thumbnail URL if available
    String thumbPath = json['thumbnail'] != null
        ? "${json['thumbnail']['path']}.${json['thumbnail']['extension']}"
        : ""; // Use empty string if no thumbnail

    // Parse related URLs from JSON
    Map<String, String> parsedUrls = {};
    if (json['urls'] != null) {
      for (var u in json['urls']) {
        parsedUrls[u['type']] = u['url'];
      }
    }

    List<Map<String, String>> parseItems(dynamic list) {
      final itemsList = (list?['items'] as List? ?? []);
      return itemsList.map<Map<String, String>>((item) {
        return {
          "name": item['name']?.toString() ?? "",
          "resourceURI": item['resourceURI']?.toString() ?? "",
          "image": "" // Image will be lazy-loaded later
        };
      }).toList();
    }

    return Character(
      id: json['id'] ?? 0,
      name: json['name'] ?? "No name",
      description: json['description'] ?? "",
      thumbnail: thumbPath,
      comics: parseItems(json['comics']),
      series: parseItems(json['series']),
      stories: parseItems(json['stories']),
      events: parseItems(json['events']),
      urls: parsedUrls,
    );
  }

  String getThumbnailUrl() => thumbnail;
}
