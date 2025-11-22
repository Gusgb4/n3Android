import 'dart:math';
import 'package:geolocator/geolocator.dart';

class MockLocationReading {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final bool isMockProvider;

  MockLocationReading({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.isMockProvider,
  });
}

class MockLocationService {
  // Coordenadas da sala (Católica Joinville)

  static const double classroomLat = -26.304677694575613;
  static const double classroomLon = -48.849600049138274;

  // Parâmetros de validação
  static const double allowedRadiusMeters = 50.0;
  static const double maxAllowedAccuracy = 50.0;

  /// Captura a posição atual (via GPS real)
  Future<MockLocationReading> getReading() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // API moderna do geolocator (13.0.4+)
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return MockLocationReading(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracyMeters: pos.accuracy,
      isMockProvider: pos.isMocked,
    );
  }

  /// Calcula a distância real entre aluno e sala (Haversine)
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // Raio da Terra (em metros)
    final phi1 = lat1 * pi / 180.0;
    final phi2 = lat2 * pi / 180.0;
    final dPhi = (lat2 - lat1) * pi / 180.0;
    final dLambda = (lon2 - lon1) * pi / 180.0;

    final a =
        sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  /// Verifica se a localização é válida e dentro do raio
  Future<bool> isInsideAllowedArea(MockLocationReading reading) async {
    final distance = _haversineDistance(
      reading.latitude,
      reading.longitude,
      classroomLat,
      classroomLon,
    );

    // Log simples para debug
    // ignore: avoid_print
    print('Distancia até a sala: ${distance.toStringAsFixed(2)} m');

    return distance <= allowedRadiusMeters &&
        reading.accuracyMeters <= maxAllowedAccuracy &&
        !reading.isMockProvider;
  }
}
