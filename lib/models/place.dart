import 'package:latlong2/latlong.dart';

/// A geocoded place returned by the search provider.
///
/// Search results come from MapTiler Geocoding (OpenStreetMap data); they are
/// provider data, not vehicle or positioning data.
class Place {
  final String id;
  final String name;
  final String address;
  final LatLng coordinates;

  const Place({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
  });

  /// Builds a [Place] from a MapTiler/Mapbox-style geocoding feature.
  factory Place.fromMapTilerFeature(Map<String, dynamic> feature) {
    final center = feature['center'];
    if (center is! List || center.length < 2) {
      throw const FormatException('Geocoding feature has no center');
    }
    final longitude = (center[0] as num).toDouble();
    final latitude = (center[1] as num).toDouble();

    final text = (feature['text'] as String?)?.trim() ?? '';
    final placeName = (feature['place_name'] as String?)?.trim() ?? '';
    final name = text.isNotEmpty ? text : placeName;
    if (name.isEmpty) {
      throw const FormatException('Geocoding feature has no name');
    }

    return Place(
      id: (feature['id'] as String?) ?? '$latitude,$longitude',
      name: name,
      address: placeName.isNotEmpty ? placeName : name,
      coordinates: LatLng(latitude, longitude),
    );
  }

  @override
  String toString() => '$name ($address)';
}
