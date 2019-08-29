import 'package:geo/geo.dart';

void computeDistance() {
  const p1 = LatLng(0, 0);
  const p2 = LatLng(3600, 3600);
  print(computeDistanceBetween(p1, p2));
}

void decodePath() {
  print(const PolylineCodec().decode('_p~iF~ps|U_ulLnnqC_mqNvxq`@'));
  // LatLng(38.5, -120.2),
  // LatLng(40.7, -120.95),
  // LatLng(43.252, -126.453),
}

void encodePath() {
  print(const PolylineCodec().encode(const [
    LatLng(38.5, -120.2),
    LatLng(40.7, -120.95),
    LatLng(43.252, -126.453),
  ]));
  // _p~iF~ps|U_ulLnnqC_mqNvxq`@
}
