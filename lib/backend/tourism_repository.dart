import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'repositories.dart';

class TourPlace {
  const TourPlace({
    required this.contentId,
    required this.language,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String contentId;
  final String language;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  factory TourPlace.fromJson(Json json) => TourPlace(
    contentId: json['contentId'] as String,
    language: json['language'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );
}

class TourismRepository extends Repository {
  TourismRepository(super.client);

  Future<List<TourPlace>> search(
    String keyword, {
    String language = 'en',
  }) async {
    userId;
    final query = keyword.trim();
    if (query.length < 2 ||
        query.length > 80 ||
        !{'en', 'ja'}.contains(language)) {
      throw const RepositoryException(FailureKind.invalid);
    }
    try {
      final response = await client.functions.invoke(
        'tourism-search',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keyword': query, 'language': language}),
      );
      final data = response.data;
      if (data is! Map || data['places'] is! List) {
        throw const RepositoryException(FailureKind.unavailable);
      }
      return (data['places'] as List)
          .map(
            (item) =>
                TourPlace.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on FunctionException {
      throw const RepositoryException(FailureKind.unavailable);
    } on FormatException {
      throw const RepositoryException(FailureKind.unavailable);
    } on TypeError {
      throw const RepositoryException(FailureKind.unavailable);
    }
  }
}
