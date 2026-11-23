import 'dart:math' as math;

class ServiceZone {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String district;

  const ServiceZone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.district,
  });
}

const List<ServiceZone> serviceZones = [
  ServiceZone(
    id: 'indiranagar',
    name: 'Indiranagar Central',
    lat: 12.9784,
    lng: 77.6408,
    district: 'East Metro',
  ),
  ServiceZone(
    id: 'mg-road',
    name: 'MG Road / Shivajinagar',
    lat: 12.9756,
    lng: 77.6066,
    district: 'Central Core',
  ),
  ServiceZone(
    id: 'koramangala',
    name: 'Koramangala 4th Block',
    lat: 12.9352,
    lng: 77.6245,
    district: 'South East',
  ),
  ServiceZone(
    id: 'marathahalli',
    name: 'Marathahalli Bridge',
    lat: 12.9591,
    lng: 77.6974,
    district: 'Outer Ring East',
  ),
  ServiceZone(
    id: 'hsr-layout',
    name: 'HSR Layout Sector 2',
    lat: 12.9121,
    lng: 77.6446,
    district: 'South Corridor',
  ),
  ServiceZone(
    id: 'jayanagar',
    name: 'Jayanagar 3rd Block',
    lat: 12.9299,
    lng: 77.5838,
    district: 'South Metro',
  ),
  ServiceZone(
    id: 'whitefield',
    name: 'Whitefield ITPL',
    lat: 12.9855,
    lng: 77.7363,
    district: 'Far East (10.4 km)',
  ),
  ServiceZone(
    id: 'yelahanka',
    name: 'Yelahanka New Town',
    lat: 13.1007,
    lng: 77.5963,
    district: 'North Suburb (14.4 km)',
  ),
];

double haversineDistanceKm(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  double toRad(double deg) => deg * math.pi / 180.0;
  const double earthRadiusKm = 6371.0;
  final dLat = toRad(lat2 - lat1);
  final dLng = toRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(toRad(lat1)) *
          math.cos(toRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return (earthRadiusKm * c * 10).round() / 10.0;
}
