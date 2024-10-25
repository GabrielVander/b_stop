import 'package:b_stop/features/bus_data_retrieval/data/models/stop_http_model.dart';
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('fromJson', () {
    for (final (:json, :expected) in <({Map<String, dynamic> json, StopHttpModel expected})>[
      (
        json: {
          'stopId': '122EDA3E-EE10-400E-BFE5-80B11DEA8802',
          'name': 'grace',
          'lat': 66.13,
          'lng': -5.99,
        },
        expected: const StopHttpModel(
          stopId: '122EDA3E-EE10-400E-BFE5-80B11DEA8802',
          name: 'grace',
          lat: 66.13,
          lng: -5.99,
        )
      ),
      (
        json: {
          'stopId': '819FC51E-FA0A-401C-969A-D09FCCCE7875',
          'name': 'perform',
          'lat': -92.76,
          'lng': 69.92,
        },
        expected: const StopHttpModel(
          stopId: '819FC51E-FA0A-401C-969A-D09FCCCE7875',
          name: 'perform',
          lat: -92.76,
          lng: 69.92,
        )
      ),
    ]) {
      test('when receiving $json as json then should return $expected', () {
        final StopHttpModel result = StopHttpModel.fromJson(json);

        expect(result, expected);
      });
    }
  });

  group('toEntity', () {
    for (final ({Stop entity, StopHttpModel model}) testCase
        in <({StopHttpModel model, Stop entity})>[
      (
        model: const StopHttpModel(
          stopId: 'BEF7F24D-A781-4AB3-9E16-9E7E09503671',
          name: 'obtained',
          lat: 94.64,
          lng: 18.35,
        ),
        entity: const Stop(
          id: 'BEF7F24D-A781-4AB3-9E16-9E7E09503671',
          name: 'obtained',
          postion: LatLng(94.64, 18.35),
        )
      ),
    ]) {
      final (:model, :entity) = testCase;
      test('given $model then should return $entity', () {
        final Stop result = model.toEntity();

        expect(result, entity);
      });
    }
  });
}
