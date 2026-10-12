import '../backend/backend.dart';
import '../backend/repositories.dart';

/// The signed-in screens read the same trip data as the repositories.
class LiveTripData {
  const LiveTripData({
    required this.trip,
    required this.trips,
    required this.days,
    required this.itemsByDay,
    required this.places,
  });

  final Trip trip;
  final List<Trip> trips;
  final List<String> days;
  final Map<String, List<Json>> itemsByDay;
  final Map<String, Json> places;

  List<Json> itemsFor(String day) => itemsByDay[day] ?? const [];

  String placeName(Json item) =>
      places[item['place_id']]?['display_name'] as String? ?? '삭제된 장소';

  String get currentDay {
    final today = _date(DateTime.now());
    if (today.compareTo(trip.startDate) < 0) return trip.startDate;
    if (today.compareTo(trip.endDate) > 0) return trip.endDate;
    return today;
  }

  static Future<LiveTripData?> load(
    NextMateBackend backend, {
    String? selectedTripId,
  }) async {
    final trips = await backend.trips.list(limit: 100);
    if (trips.isEmpty) return null;
    final today = _date(DateTime.now());
    final active =
        trips
            .where(
              (entry) =>
                  entry.startDate.compareTo(today) <= 0 &&
                  entry.endDate.compareTo(today) >= 0,
            )
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final upcoming =
        trips.where((entry) => entry.startDate.compareTo(today) > 0).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final past =
        trips.where((entry) => entry.endDate.compareTo(today) < 0).toList()
          ..sort((a, b) => b.endDate.compareTo(a.endDate));
    final trip =
        trips.where((entry) => entry.id == selectedTripId).firstOrNull ??
        active.firstOrNull ??
        upcoming.firstOrNull ??
        past.first;

    Future<List<Json>> allRows(TripRowsRepository repository) async {
      final rows = <Json>[];
      while (true) {
        final page = await repository.list(
          trip.id,
          offset: rows.length,
          limit: 100,
        );
        rows.addAll(page);
        if (page.length < 100) return rows;
      }
    }

    final itinerary = await allRows(backend.itinerary);
    final places = await allRows(backend.places);
    final itemsByDay = <String, List<Json>>{};
    for (final item in itinerary) {
      final day = item['scheduled_date'] as String;
      itemsByDay.putIfAbsent(day, () => []).add(item);
    }
    for (final items in itemsByDay.values) {
      items.sort(
        (a, b) => (a['position'] as int).compareTo(b['position'] as int),
      );
    }

    final days = <String>[];
    var date = DateTime.parse(trip.startDate);
    final end = DateTime.parse(trip.endDate);
    while (!date.isAfter(end)) {
      days.add(_date(date));
      date = date.add(const Duration(days: 1));
    }

    return LiveTripData(
      trip: trip,
      trips: trips,
      days: days,
      itemsByDay: itemsByDay,
      places: {for (final place in places) place['id'] as String: place},
    );
  }
}

String _date(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
