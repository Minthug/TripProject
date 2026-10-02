import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/widgets.dart';

import 'repositories.dart';

class BackendScope extends InheritedWidget {
  final NextMateBackend? backend;
  const BackendScope({super.key, required this.backend, required super.child});
  static NextMateBackend? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BackendScope>()?.backend;
  @override
  bool updateShouldNotify(BackendScope oldWidget) =>
      backend != oldWidget.backend;
}

/// Environment configuration is injected at build time, never read from UI.
class BackendConfig {
  final String url;
  final String publishableKey;
  const BackendConfig(this.url, this.publishableKey);

  static const environment = BackendConfig(
    String.fromEnvironment('SUPABASE_URL'),
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  bool get isConfigured => url.isNotEmpty || publishableKey.isNotEmpty;

  void validate() {
    final uri = Uri.tryParse(url);
    final local = uri?.host == 'localhost' || uri?.host == '127.0.0.1';
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && !(local && uri.scheme == 'http')) ||
        !publishableKey.startsWith('sb_publishable_')) {
      throw ArgumentError(
        'Supply a Supabase HTTPS URL (HTTP for localhost) '
        'and an sb_publishable_ key.',
      );
    }
  }
}

/// One injected client shares the authenticated session across repositories.
class NextMateBackend {
  final SupabaseClient client;
  late final auth = AuthRepository(client);
  late final trips = TripRepository(client);
  late final profile = ProfileRepository(client);
  late final stays = TripRowsRepository(client, 'stays');
  late final places = TripRowsRepository(client, 'places', stampCreator: true);
  late final itinerary = ItineraryRepository(client);
  late final reservations = TripRowsRepository(
    client,
    'reservations',
    stampCreator: true,
  );
  late final routes = TripRowsRepository(
    client,
    'saved_routes',
    stampCreator: true,
  );
  late final transit = TripRowsRepository(
    client,
    'transit_sessions',
    personal: true,
  );
  late final alerts = TripRowsRepository(
    client,
    'departure_alerts',
    personal: true,
  );
  late final devices = DeviceRepository(client);
  late final members = MemberRepository(client);
  late final notifications = NotificationRepository(client);

  NextMateBackend(this.client);

  static Future<NextMateBackend?> initialize({
    BackendConfig config = BackendConfig.environment,
  }) async {
    if (!config.isConfigured) return null; // Standalone UI gallery.
    config.validate();
    await Supabase.initialize(
      url: config.url,
      publishableKey: config.publishableKey,
    );
    return NextMateBackend(Supabase.instance.client);
  }
}
