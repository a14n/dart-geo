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

library latlng;

import 'dart:math';

// see http://www.movable-type.co.uk/scripts/latlong.html

num degToRad(num deg) => deg * (PI / 180.0);
num radToDeg(num rad) => rad * (180.0 / PI);

typedef T _Supplier<T>();
class _CachedValue<T> {
  final _Supplier<T> load;
  T _value;
  bool _computed = false;

  _CachedValue(this.load);

  T get value {
    if (!_computed) {
      _value = load();
      _computed = true;
    }
    return _value;
  }

  void invalidate() {
    _value = null;
    _computed = false;
  }
}

/// The coordinates in Degrees
class LatLng {
  final _CachedValue<num> _latInRad, _lngInRad;
  final _CachedValue<num> _latInDeg, _lngInDeg;

  LatLng._(num lat, num lng, bool isDeg) :
      _latInRad = new _CachedValue<num>(() => isDeg ? degToRad(lat) : lat),
      _lngInRad = new _CachedValue<num>(() => isDeg ? degToRad(lng) : lng),
      _latInDeg = new _CachedValue<num>(() => isDeg ? lat : radToDeg(lat)),
      _lngInDeg = new _CachedValue<num>(() => isDeg ? lng : radToDeg(lng)) {
    if (this.lat < -90 || 90 < this.lat)
      throw new RangeError.range(this.lat, -90, 90);
    if (this.lng < -180 || 180 < this.lng)
      throw new RangeError.range(this.lng, -180, 180);
  }
  LatLng(num lat, num lng) : this._(lat, lng, true);
  LatLng.rad(num lat, num lng) : this._(lat, lng, false);

  num get latInRad => _latInRad.value;
  num get lngInRad => _lngInRad.value;

  num get lat => _latInDeg.value;
  num get lng => _lngInDeg.value;

  String toString() => 'LatLng(lat:$lat, lng:$lng)';

  int get hashCode => lat.hashCode + lng.hashCode;

  operator ==(Object other) =>
      other is LatLng && lat == other.lat && lng == other.lng;
}

const EARTH_RADIUS = 6371000.0;

double computeDistanceBetween(LatLng p1, LatLng p2,
                              [num radius = EARTH_RADIUS]) =>
    computeDistanceHaversine(p1, p2, radius);

double computeDistanceHaversine(LatLng p1, LatLng p2,
                                [num radius = EARTH_RADIUS]) {
  final sDLat = sin((p2.latInRad - p1.latInRad) / 2);
  final sDLng = sin((p2.lngInRad - p1.lngInRad) / 2);
  final a = sDLat * sDLat + sDLng * sDLng * cos(p1.latInRad) * cos(p2.latInRad);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return (radius != null ? radius : EARTH_RADIUS) * c;
}

double computeDistanceSphericalLawCosines(LatLng p1, LatLng p2,
                                          [num radius = EARTH_RADIUS]) {
  final cosLat1 = cos(p1.latInRad);
  final sinLat1 = sin(p1.latInRad);
  final cosLat2 = cos(p2.latInRad);
  final sinLat2 = sin(p2.latInRad);

  return (radius != null ? radius : EARTH_RADIUS) *
      acos(cosLat1 * cosLat2 * cos(p1.lngInRad - p2.lngInRad) +
          sinLat1 * sinLat2);
}

double computeDistanceEquirectangularApproximation(LatLng p1, LatLng p2,
                                                   [num radius = EARTH_RADIUS]){
  var x = (p2.lngInRad - p1.lngInRad) * cos((p1.latInRad + p2.latInRad) / 2);
  var y = p2.latInRad - p1.latInRad;
  return (radius != null ? radius : EARTH_RADIUS) * sqrt(x * x + y * y);
}

double computeHeading(LatLng p1, LatLng p2) {
  final dLng = p2.lngInRad - p1.lngInRad;

  final y = sin(dLng) * cos(p2.latInRad);
  final x = cos(p1.latInRad) * sin(p2.latInRad) -
      sin(p1.latInRad) * cos(p2.latInRad) * cos(dLng);
  return radToDeg(atan2(y, x));
}

LatLng computeOffset(LatLng from, num distance, num heading,
                     [num radius = EARTH_RADIUS]) {
  final h = degToRad(heading);

  final a = distance / (radius != null ? radius : EARTH_RADIUS);

  final lat2 = asin(sin(from.latInRad) * cos(a) +
      cos(from.latInRad) * sin(a) * cos(h) );
  final lng2 = from.lngInRad +
      atan2(sin(h) * sin(a) * cos(from.latInRad),
          cos(a) - sin(from.latInRad) * sin(lat2));
  return new LatLng.rad(lat2, lng2);
}
