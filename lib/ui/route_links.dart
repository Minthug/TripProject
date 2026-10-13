/// Uber handles pickup from its own current-location flow; the app does not
/// assume that a previously visited place is the rider's exact pickup point.
Uri uberRideRequestUri({
  required String destinationName,
  required double destinationLatitude,
  required double destinationLongitude,
  String? destinationAddress,
}) => Uri(
  scheme: 'uber',
  host: 'riderequest',
  queryParameters: {
    'pickup': 'my_location',
    'dropoff[latitude]': '$destinationLatitude',
    'dropoff[longitude]': '$destinationLongitude',
    'dropoff[nickname]': destinationName,
    if (destinationAddress != null && destinationAddress.isNotEmpty)
      'dropoff[formatted_address]': destinationAddress,
  },
);

final uberDownloadUri = Uri.parse('https://www.uber.com/kr/ko/download/');
final uberAppUri = Uri.parse('uber://');
