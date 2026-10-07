import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_redirect.dart';

typedef Json = Map<String, dynamic>;

enum FailureKind { unauthenticated, forbidden, conflict, invalid, unavailable }

class RepositoryException implements Exception {
  final FailureKind kind;
  const RepositoryException(this.kind);
  @override
  String toString() => 'RepositoryException: ${kind.name}';
}

Future<T> request<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on PostgrestException catch (error) {
    throw RepositoryException(switch (error.code) {
      '42501' => FailureKind.forbidden,
      '23505' => FailureKind.conflict,
      '23503' || '23514' || '22007' || '22P02' => FailureKind.invalid,
      _ => FailureKind.unavailable,
    });
  } on AuthException {
    throw const RepositoryException(FailureKind.unauthenticated);
  }
}

abstract class Repository {
  final SupabaseClient client;
  Repository(this.client);
  String get userId =>
      client.auth.currentUser?.id ??
      (throw const RepositoryException(FailureKind.unauthenticated));
}

class AuthRepository extends Repository {
  AuthRepository(super.client);
  Stream<AuthState> get changes => client.auth.onAuthStateChange;
  Session? get session => client.auth.currentSession;
  Future<AuthResponse> signUp(
    String email,
    String password, {
    String? redirectTo,
  }) => request(
    () => client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: redirectTo,
    ),
  );
  Future<AuthResponse> signIn(String email, String password) => request(
    () =>
        client.auth.signInWithPassword(email: email.trim(), password: password),
  );
  Future<bool> signInWithOAuth(OAuthProvider provider) => request(
    () => client.auth.signInWithOAuth(
      provider,
      redirectTo: authRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    ),
  );
  Future<void> signOut() => request(() => client.auth.signOut());
  Future<void> resetPassword(String email, {required String redirectTo}) =>
      request(
        () => client.auth.resetPasswordForEmail(
          email.trim(),
          redirectTo: redirectTo,
        ),
      );
  Future<UserResponse> updatePassword(String password) {
    userId;
    return request(
      () => client.auth.updateUser(UserAttributes(password: password)),
    );
  }
}

class Trip {
  final String id,
      ownerId,
      title,
      destinationName,
      startDate,
      endDate,
      timeZoneId;
  const Trip({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.destinationName,
    required this.startDate,
    required this.endDate,
    required this.timeZoneId,
  });
  factory Trip.fromJson(Json json) => Trip(
    id: json['id'] as String,
    ownerId: json['owner_id'] as String,
    title: json['title'] as String,
    destinationName: json['destination_name'] as String,
    startDate: json['start_date'] as String,
    endDate: json['end_date'] as String,
    timeZoneId: json['time_zone_id'] as String,
  );
}

class TripInput {
  final String title, destinationName, startDate, endDate, timeZoneId;
  const TripInput({
    required this.title,
    required this.destinationName,
    required this.startDate,
    required this.endDate,
    required this.timeZoneId,
  });
  Json toJson() {
    for (final value in [startDate, endDate]) {
      final parsed = DateTime.tryParse(value);
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
          parsed == null ||
          parsed.toIso8601String().substring(0, 10) != value) {
        throw const RepositoryException(FailureKind.invalid);
      }
    }
    if (title.trim().isEmpty ||
        destinationName.trim().isEmpty ||
        timeZoneId.trim().isEmpty ||
        endDate.compareTo(startDate) < 0) {
      throw const RepositoryException(FailureKind.invalid);
    }
    return {
      'title': title.trim(),
      'destination_name': destinationName.trim(),
      'start_date': startDate,
      'end_date': endDate,
      'time_zone_id': timeZoneId,
    };
  }
}

class TripRepository extends Repository {
  TripRepository(super.client);
  Future<List<Trip>> list({int offset = 0, int limit = 50}) {
    userId;
    checkPage(offset, limit);
    return request(
      () async =>
          (await client
                  .from('trips')
                  .select()
                  .order('start_date')
                  .order('id')
                  .range(offset, offset + limit - 1))
              .map(Trip.fromJson)
              .toList(),
    );
  }

  Future<Trip?> get(String id) {
    userId;
    return request(() async {
      final row = await client
          .from('trips')
          .select()
          .eq('id', id)
          .maybeSingle();
      return row == null ? null : Trip.fromJson(row);
    });
  }

  Future<Trip> create(TripInput input) => request(
    () async => Trip.fromJson(
      await client
          .from('trips')
          .insert({...input.toJson(), 'owner_id': userId})
          .select()
          .single(),
    ),
  );
  Future<Trip> update(String id, TripInput input) {
    userId;
    return request(
      () async => Trip.fromJson(
        await client
            .from('trips')
            .update(input.toJson())
            .eq('id', id)
            .select()
            .single(),
      ),
    );
  }

  Future<bool> delete(String id) {
    userId;
    return request(
      () async =>
          (await client.from('trips').delete().eq('id', id).select('id'))
              .isNotEmpty,
    );
  }
}

void checkPage(int offset, int limit) {
  if (offset < 0 || limit < 1 || limit > 100) {
    throw const RepositoryException(FailureKind.invalid);
  }
}

/// Payloads use documented SQL column names. Identity and generated columns
/// are never accepted from callers; authorization remains enforced by RLS.
Json editable(Json input) {
  const reserved = {
    'id',
    'trip_id',
    'user_id',
    'owner_id',
    'created_by',
    'created_at',
    'updated_at',
    'location',
    'entrance_location',
  };
  if (input.keys.any(reserved.contains) || input.isEmpty) {
    throw const RepositoryException(FailureKind.invalid);
  }
  return Map.of(input);
}

class TripRowsRepository extends Repository {
  final String table;
  final bool stampCreator, personal;
  TripRowsRepository(
    super.client,
    this.table, {
    this.stampCreator = false,
    this.personal = false,
  });

  Future<List<Json>> list(String tripId, {int offset = 0, int limit = 50}) {
    final uid = userId;
    checkPage(offset, limit);
    return request(() async {
      var query = client.from(table).select().eq('trip_id', tripId);
      if (personal) query = query.eq('user_id', uid);
      return await query.order('id').range(offset, offset + limit - 1);
    });
  }

  Future<Json?> get(String tripId, String id) {
    final uid = userId;
    return request(() async {
      var query = client
          .from(table)
          .select()
          .eq('trip_id', tripId)
          .eq('id', id);
      if (personal) query = query.eq('user_id', uid);
      return await query.maybeSingle();
    });
  }

  Future<Json> create(String tripId, Json input) {
    final uid = userId;
    return request(
      () async => await client
          .from(table)
          .insert({
            ...editable(input),
            'trip_id': tripId,
            if (stampCreator) 'created_by': uid,
            if (personal) 'user_id': uid,
          })
          .select()
          .single(),
    );
  }

  Future<Json> update(String tripId, String id, Json changes) {
    final uid = userId;
    return request(() async {
      var query = client
          .from(table)
          .update(editable(changes))
          .eq('trip_id', tripId)
          .eq('id', id);
      if (personal) query = query.eq('user_id', uid);
      return await query.select().single();
    });
  }

  Future<bool> delete(String tripId, String id) {
    final uid = userId;
    return request(() async {
      var query = client
          .from(table)
          .delete()
          .eq('trip_id', tripId)
          .eq('id', id);
      if (personal) query = query.eq('user_id', uid);
      return (await query.select('id')).isNotEmpty;
    });
  }
}

class ItineraryRepository extends TripRowsRepository {
  ItineraryRepository(SupabaseClient client)
    : super(client, 'itinerary_items', stampCreator: true);

  /// Atomically creates a name-only place and schedules it for a trip day.
  Future<Json> addDraftPlace(
    String tripId,
    String date,
    String name, {
    String? notes,
  }) {
    userId;
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        parsedDate.toIso8601String().substring(0, 10) != date ||
        name.trim().isEmpty ||
        name.trim().length > 120) {
      throw const RepositoryException(FailureKind.invalid);
    }
    return request(
      () async =>
          await client.rpc(
                'add_draft_itinerary_item',
                params: {
                  'p_trip_id': tripId,
                  'p_scheduled_date': date,
                  'p_display_name': name.trim(),
                  'p_notes': notes?.trim(),
                },
              )
              as Json,
    );
  }

  /// Atomically schedules an official TourAPI search result.
  Future<Json> addTourPlace(
    String tripId,
    String date, {
    required String contentId,
    required String language,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) {
    userId;
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        parsedDate.toIso8601String().substring(0, 10) != date ||
        !RegExp(r'^\d{1,30}$').hasMatch(contentId) ||
        !{'en', 'ja'}.contains(language) ||
        name.trim().isEmpty ||
        name.trim().length > 120 ||
        address.trim().isEmpty ||
        !latitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        !longitude.isFinite ||
        longitude < -180 ||
        longitude > 180) {
      throw const RepositoryException(FailureKind.invalid);
    }
    return request(
      () async =>
          await client.rpc(
                'add_tour_itinerary_item',
                params: {
                  'p_trip_id': tripId,
                  'p_scheduled_date': date,
                  'p_content_id': contentId,
                  'p_language': language,
                  'p_display_name': name.trim(),
                  'p_address': address.trim(),
                  'p_latitude': latitude,
                  'p_longitude': longitude,
                },
              )
              as Json,
    );
  }

  Future<List<Json>> day(String tripId, String date) {
    userId;
    return request(
      () async => await client
          .from(table)
          .select()
          .eq('trip_id', tripId)
          .eq('scheduled_date', date)
          .order('position'),
    );
  }

  Future<Json> move(String tripId, String id, String date, int position) =>
      update(tripId, id, {'scheduled_date': date, 'position': position});
  Future<Json> skip(String tripId, String id) =>
      update(tripId, id, {'progress_status': 'skipped'});
}

class ProfileRepository extends Repository {
  ProfileRepository(super.client);
  Future<Json> getProfile() => request(
    () async =>
        await client.from('profiles').select().eq('id', userId).single(),
  );
  Future<Json> getPreferences() => request(
    () async => await client
        .from('user_preferences')
        .select()
        .eq('user_id', userId)
        .single(),
  );
  Future<Json> updateProfile(Json changes) => request(
    () async => await client
        .from('profiles')
        .update(editable(changes))
        .eq('id', userId)
        .select()
        .single(),
  );
  Future<Json> updatePreferences(Json changes) => request(
    () async => await client
        .from('user_preferences')
        .update(editable(changes))
        .eq('user_id', userId)
        .select()
        .single(),
  );
}

class DeviceRepository extends Repository {
  DeviceRepository(super.client);
  Future<List<Json>> list() => request(
    () async => await client
        .from('user_devices')
        .select()
        .eq('user_id', userId)
        .order('id'),
  );
  Future<Json> register(Json input) => request(
    () async => await client
        .from('user_devices')
        .upsert({
          ...editable(input),
          'user_id': userId,
        }, onConflict: 'user_id,device_identifier')
        .select()
        .single(),
  );
  Future<bool> delete(String id) => request(
    () async =>
        (await client
                .from('user_devices')
                .delete()
                .eq('user_id', userId)
                .eq('id', id)
                .select('id'))
            .isNotEmpty,
  );
}

class MemberRepository extends Repository {
  MemberRepository(super.client);
  Future<List<Json>> list(String tripId) {
    userId;
    return request(
      () async => await client
          .from('trip_members')
          .select()
          .eq('trip_id', tripId)
          .order('joined_at'),
    );
  }

  Future<Json> updateRole(String tripId, String memberId, String role) {
    userId;
    if (!{'editor', 'viewer'}.contains(role)) {
      throw const RepositoryException(FailureKind.invalid);
    }
    return request(
      () async => await client
          .from('trip_members')
          .update({'role': role})
          .eq('trip_id', tripId)
          .eq('user_id', memberId)
          .select()
          .single(),
    );
  }

  Future<bool> remove(String tripId, String memberId) {
    userId;
    return request(
      () async =>
          (await client
                  .from('trip_members')
                  .delete()
                  .eq('trip_id', tripId)
                  .eq('user_id', memberId)
                  .select('user_id'))
              .isNotEmpty,
    );
  }

  Future<List<Json>> invitations(String tripId) {
    userId;
    return request(
      () async => await client
          .from('trip_invitations')
          .select('id,trip_id,invitee_email,role,status,expires_at,created_at')
          .eq('trip_id', tripId)
          .order('created_at'),
    );
  }
}

/// Delivery writes belong to trusted push workers, never the mobile client.
class NotificationRepository extends Repository {
  NotificationRepository(super.client);
  Future<List<Json>> list({int offset = 0, int limit = 50}) {
    final uid = userId;
    checkPage(offset, limit);
    return request(
      () async => await client
          .from('notification_deliveries')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .order('id')
          .range(offset, offset + limit - 1),
    );
  }
}
