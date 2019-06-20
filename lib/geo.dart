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

import 'dart:convert';
import 'dart:math' as math;

import 'package:meta/meta.dart';

// see http://www.movable-type.co.uk/scripts/latlong.html

/// Convert degrees to radians
num degToRad(num deg) => deg * (math.pi / 180.0);

/// Convert radians to degrees
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

/// The radius of earth in meters
const earthRadius = 6371000.0;

/// Compute distance between 2 points.
///
/// The computation is the same as [computeDistanceHaversine].
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

/// Compute distance between 2 points according to [Haversine formula](https://en.wikipedia.org/wiki/Haversine_formula).
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

/// Compute distance between 2 points according to [Spherical law of cosines](https://en.wikipedia.org/wiki/Spherical_law_of_cosines).
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

/// Compute heading from [p1] to [p2]. The result is between -180 exclusive and 180 inclusive.
///
/// * `computeHeading(LatLng(0, 0), LatLng(1, 0))` returns `0.0` (north direction).
/// * `computeHeading(LatLng(0, 0), LatLng(0, 1))` returns `90.0` (east direction).
/// * `computeHeading(LatLng(1, 0), LatLng(0, 0))` returns `180.0` (south direction).
/// * `computeHeading(LatLng(0, 0), LatLng(0, -1))` returns `-90.0` (west direction).
num computeHeading(LatLng p1, LatLng p2) {
  assert(p1 != null);
  assert(p2 != null);
  final dLng = degToRad(p2.lng) - degToRad(p1.lng);
  final y = math.sin(dLng) * math.cos(degToRad(p2.lat));
  final x = math.cos(degToRad(p1.lat)) * math.sin(degToRad(p2.lat)) -
      math.sin(degToRad(p1.lat)) * math.cos(degToRad(p2.lat)) * math.cos(dLng);
  return radToDeg(math.atan2(y, x));
}

/// Compute the [LatLng] resulting from moving a [distance] (in meters) from [origin] in the specified [heading] (expressed in degrees clockwise from north).
LatLng computeOffset(
  LatLng origin,
  num distance,
  num heading, {
  num radius = earthRadius,
}) {
  assert(origin != null);
  assert(distance != null);
  assert(heading != null);
  assert(radius != null);
  final h = degToRad(heading);
  final a = distance / radius;
  final lat2 = math.asin(math.sin(degToRad(origin.lat)) * math.cos(a) +
      math.cos(degToRad(origin.lat)) * math.sin(a) * math.cos(h));
  final lng2 = degToRad(origin.lng) +
      math.atan2(math.sin(h) * math.sin(a) * math.cos(degToRad(origin.lat)),
          math.cos(a) - math.sin(degToRad(origin.lat)) * math.sin(lat2));
  return LatLng(radToDeg(lat2), radToDeg(lng2));
}

/// A codec to convert list of location from/to string according to the [Encoded Polyline Algorithm Format](https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
class PolylineCodec extends Codec<List<LatLng>, String> {
  const PolylineCodec();

  @override
  Converter<String, List<LatLng>> get decoder => const _PolylineDecoder();

  @override
  Converter<List<LatLng>, String> get encoder => const _PolylineEncoder();
}

class _PolylineDecoder extends Converter<String, List<LatLng>> {
  const _PolylineDecoder();

  @override
  List<LatLng> convert(String input) {
    final chunks = ascii.encode(input).map((e) => e - 63).toList();
    final step5chunks = chunks
        .fold<List<List<int>>>([[]], (t, e) {
          t.last.insert(0, e & 0x1F);
          if (e < 0x20) {
            t.add([]);
          }
          return t;
        })
        .map((e) => e.fold<int>(0, (t, e) => t * 0x20 + e))
        .toList()
          ..removeLast();
    final numbers = step5chunks.map((step5) {
      final negative = step5 & 0x1 == 0x1;
      var step4 = step5;
      if (negative) step4 ^= 0xffffffff;
      var step3 = step4 >> 1;
      if (negative) step3 |= 0x80000000;
      final step2 = negative ? _twoComplement(step3) : step3;
      return (negative ? -step2 : step2) / 1e5;
    }).toList();
    final result = <LatLng>[];
    var previous = const LatLng(0, 0);
    for (var i = 0; i < numbers.length; i += 2) {
      final lat = numbers[i];
      final lng = numbers[i + 1];
      previous = LatLng(previous.lat + lat, previous.lng + lng);
      result.add(previous);
    }
    return result;
  }
}

class _PolylineEncoder extends Converter<List<LatLng>, String> {
  const _PolylineEncoder();

  @override
  String convert(List<LatLng> input) {
    final deltas = <LatLng>[];
    var previous = const LatLng(0, 0);
    for (var latlng in input) {
      deltas.add(LatLng(latlng.lat - previous.lat, latlng.lng - previous.lng));
      previous = latlng;
    }
    return deltas.map((e) => '${_encode(e.lat)}${_encode(e.lng)}').join();
  }

  String _encode(num value) {
    final step2 = (value * 1e5).round();
    final step3 = step2.isNegative ? _twoComplement(step2.abs()) : step2;
    final step4 = (step3 << 1) & 0xffffffff;
    final step5 = value < 0 ? step4 ^ 0xffffffff : step4;
    final chuncks = <int>[];
    if (step5 == 0) {
      chuncks.add(0);
    } else {
      for (var v = step5; v > 0;) {
        final q = v % 0x20;
        v = v ~/ 0x20;
        chuncks.add(v > 0 ? q | 0x20 : q);
      }
    }
    final step10 = chuncks.map((e) => e + 63).toList();
    return ascii.decode(step10);
  }
}

int _twoComplement(int value) => (value ^ 0xffffffff) + 1;
