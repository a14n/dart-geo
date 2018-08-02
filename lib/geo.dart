// Copyright (c) 2014, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math' as math;

import 'package:meta/meta.dart';

// see http://www.movable-type.co.uk/scripts/latlong.html

num degToRad(num deg) => deg * (math.pi / 180.0);
num radToDeg(num rad) => rad * (180.0 / math.pi);

/// The coordinates in Degrees
@immutable
class LatLng {
  const LatLng(
    this.lat,
    this.lng,
  ); //:assert(lat != null), assert(lng != null);

  final num lat;
  final num lng;

  bool isCloseTo(LatLng other, {num maxMargin = 1.0E-9}) {
    assert(other != null);
    assert(maxMargin != null && maxMargin >= 0);
    final margin = math.max((lat - other.lat).abs(), (lng - other.lng).abs());
    return margin <= maxMargin;
  }

  @override
  String toString() => 'LatLng(lat:$lat, lng:$lng)';

  @override
  int get hashCode => lat.hashCode + lng.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LatLng && lat == other.lat && lng == other.lng;
}

const earthRadius = 6371000.0;

num computeDistanceBetween(
  LatLng p1,
  LatLng p2, {
  num radius = earthRadius,
}) {
  assert(p1 != null);
  assert(p2 != null);
  assert(radius != null);
  return computeDistanceHaversine(p1, p2, radius: radius);
}

num computeDistanceHaversine(
  LatLng p1,
  LatLng p2, {
  num radius = earthRadius,
}) {
  assert(p1 != null);
  assert(p2 != null);
  assert(radius != null);
  final sDLat = math.sin((degToRad(p2.lat) - degToRad(p1.lat)) / 2);
  final sDLng = math.sin((degToRad(p2.lng) - degToRad(p1.lng)) / 2);
  final a = sDLat * sDLat +
      sDLng * sDLng * math.cos(degToRad(p1.lat)) * math.cos(degToRad(p2.lat));
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return radius * c;
}

num computeDistanceSphericalLawCosines(
  LatLng p1,
  LatLng p2, {
  num radius = earthRadius,
}) {
  assert(p1 != null);
  assert(p2 != null);
  assert(radius != null);
  final cosLat1 = math.cos(degToRad(p1.lat));
  final sinLat1 = math.sin(degToRad(p1.lat));
  final cosLat2 = math.cos(degToRad(p2.lat));
  final sinLat2 = math.sin(degToRad(p2.lat));
  return radius *
      math.acos(
          cosLat1 * cosLat2 * math.cos(degToRad(p1.lng) - degToRad(p2.lng)) +
              sinLat1 * sinLat2);
}

num computeDistanceEquirectangularApproximation(
  LatLng p1,
  LatLng p2, {
  num radius = earthRadius,
}) {
  assert(p1 != null);
  assert(p2 != null);
  assert(radius != null);
  final x = (degToRad(p2.lng) - degToRad(p1.lng)) *
      math.cos((degToRad(p1.lat) + degToRad(p2.lat)) / 2);
  final y = degToRad(p2.lat) - degToRad(p1.lat);
  return radius * math.sqrt(x * x + y * y);
}

num computeHeading(LatLng p1, LatLng p2) {
  assert(p1 != null);
  assert(p2 != null);
  final dLng = degToRad(p2.lng) - degToRad(p1.lng);
  final y = math.sin(dLng) * math.cos(degToRad(p2.lat));
  final x = math.cos(degToRad(p1.lat)) * math.sin(degToRad(p2.lat)) -
      math.sin(degToRad(p1.lat)) * math.cos(degToRad(p2.lat)) * math.cos(dLng);
  return radToDeg(math.atan2(y, x));
}

LatLng computeOffset(
  LatLng from,
  num distance,
  num heading, {
  num radius = earthRadius,
}) {
  assert(from != null);
  assert(distance != null);
  assert(heading != null);
  assert(radius != null);
  final h = degToRad(heading);
  final a = distance / radius;
  final lat2 = math.asin(math.sin(degToRad(from.lat)) * math.cos(a) +
      math.cos(degToRad(from.lat)) * math.sin(a) * math.cos(h));
  final lng2 = degToRad(from.lng) +
      math.atan2(math.sin(h) * math.sin(a) * math.cos(degToRad(from.lat)),
          math.cos(a) - math.sin(degToRad(from.lat)) * math.sin(lat2));
  return new LatLng(radToDeg(lat2), radToDeg(lng2));
}
