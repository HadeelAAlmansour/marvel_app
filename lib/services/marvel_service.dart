import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../models/character.dart';

class MarvelService {
  final String publicKey = "b2ceca6a9b3cd63452a87e1cde3df096";
  final String privateKey = "e556c6f82ffc761490dbbdaef85fc47ac9710b13";
  final Dio _dio =
      Dio(BaseOptions(baseUrl: "https://gateway.marvel.com/v1/public/"));

  // توليد الـ hash
  String generateHash(String ts) {
    final bytes = utf8.encode(ts + privateKey + publicKey);
    return md5.convert(bytes).toString();
  }

  Future<List<Character>> fetchCharacters(
      {int offset = 0, int limit = 20}) async {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = generateHash(ts);

    try {
      final response = await _dio.get(
        "characters",
        queryParameters: {
          "apikey": publicKey,
          "ts": ts,
          "hash": hash,
          "limit": limit,
          "offset": offset,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final results = data['results'] as List;
        return results.map((json) => Character.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching characters: $e");
    }
    return [];
  }

  // fetch image for a single item (comic/series/story/event)
  Future<String> fetchItemImage(String resourceURI) async {
    if (resourceURI.isEmpty) return "";
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = generateHash(ts);

    try {
      final response = await _dio.get(
        resourceURI,
        queryParameters: {"apikey": publicKey, "ts": ts, "hash": hash},
      );

      final data = response.data['data']['results'][0];
      if (data['thumbnail'] != null) {
        return "${data['thumbnail']['path']}.${data['thumbnail']['extension']}";
      }
    } catch (e) {
      print("Error fetching item image: $e");
    }
    return "";
  }
}
