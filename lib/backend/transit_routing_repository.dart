import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'repositories.dart';

class TransitRoutingRepository extends Repository {
  TransitRoutingRepository(super.client);

  Future<List<Json>> findRoutes({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    userId;
    try {
      final response = await client.functions.invoke(
        'transit-route',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'startLatitude': startLatitude,
          'startLongitude': startLongitude,
          'endLatitude': endLatitude,
          'endLongitude': endLongitude,
        }),
      );
      final payload = response.data;
      if (payload is! Map || payload['routes'] is! List) {
        throw const RepositoryException(FailureKind.unavailable);
      }
      return (payload['routes'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
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
