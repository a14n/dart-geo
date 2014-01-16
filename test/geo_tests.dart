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

library geo_tests;

import 'dart:math' show PI;

import 'package:geo/geo.dart';
import 'package:unittest/unittest.dart';

main() {
  group('computeDistanceBetween', (){
    test('distance to the same point is 0',(){
      final p = new LatLng(0, 0);
      expect(computeDistanceBetween(p, p), equals(0));
    });

    test('distance between 0,0 and 90,0 is around 10,000km',(){
      final p1 = new LatLng(0, 0);
      final p2 = new LatLng(90, 0);
      expect(computeDistanceBetween(p1, p2) ~/ 1000000, equals(10));
    });

    test('distance between 0,-90 and 0,90 is around 20,000km',(){
      final p1 = new LatLng(0, -90);
      final p2 = new LatLng(0, 90);
      expect(computeDistanceBetween(p1, p2) ~/ 1000000, equals(20));
    });

    test('distance between 0,-180 and 0,180 is 0',(){
      final p1 = new LatLng(0, -180);
      final p2 = new LatLng(0, 180);
      expect(computeDistanceBetween(p1, p2).toInt(), equals(0));
    });
  });

  group('computeHeading', (){
    test('heading to the same point is 0',(){
      final p = new LatLng(0, 0);
      expect(computeHeading(p, p), equals(0));
    });

    test('heading between 0,0 and 90,0 is 0',(){
      final p1 = new LatLng(0, 0);
      final p2 = new LatLng(90, 0);
      expect(computeHeading(p1, p2), equals(0));
    });

    test('heading between 0,0 and -90,0 is 180',(){
      final p1 = new LatLng(0, 0);
      final p2 = new LatLng(-90, 0);
      expect(computeHeading(p1, p2), equals(180));
    });

    test('heading between 0,-90 and 0,90 is -90',(){
      final p1 = new LatLng(0, -90);
      final p2 = new LatLng(0, 90);
      expect(computeHeading(p1, p2), equals(90));
    });

    test('heading between 0,-180 and 0,180 is -90',(){
      final p1 = new LatLng(0, -180);
      final p2 = new LatLng(0, 180);
      expect(computeHeading(p1, p2), equals(-90));
    });
  });

  group('computeOffset', (){
    test('offset from 0,0 with heading 0 and distance 10,000,000 is 0,90',(){
      final p1 = new LatLng(0, 0);
      final p2 = computeOffset(p1, EARTH_RADIUS * PI / 2, 0);
      expect(p2.lat, equals(90));
      expect(p2.lng, equals(0));
    });

    test('offset from 0,0 with heading 180 and distance 5,000,000 is 0,-45',(){
      final p1 = new LatLng(0, 0);
      final p2 = computeOffset(p1, EARTH_RADIUS * PI / 4, 180);
      expect(p2.lat.round(), equals(-45));
      expect(p2.lng.round(), equals(0));
    });

    test('offset from 0,0 with heading 180 and distance 10,000,000 is 0,-90',(){
      final p1 = new LatLng(0, 0);
      final p2 = computeOffset(p1, EARTH_RADIUS * PI / 2, 180);
      expect(p2.lat.round(), equals(-90));
      // expect(p2.lng, equals(0));
    });

    test('offset from 0,0 with heading 90 and distance 5,000,000 is 45,0',(){
      final p1 = new LatLng(0, 0);
      final p2 = computeOffset(p1, EARTH_RADIUS * PI / 4, 90);
      expect(p2.lat.round(), equals(0));
      expect(p2.lng.round(), equals(45));
    });
  });
}