import 'package:b_stop/features/bus_data_retrieval/data/models/stop_http_model.dart' show StopHttpModel;
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart' show Stop;
import 'package:flutter_test/flutter_test.dart' show expect, group, test;

void main() {
  group('toEntity', () {
    for (final ({Stop entity, StopHttpModel model}) testCase in <({StopHttpModel model, Stop entity})>[
      (
        model: const StopHttpModel(
          stopId: 'BEF7F24D-A781-4AB3-9E16-9E7E09503671',
          label: 'obtained',
          stopLat: 94.64,
          stopLon: 18.35,
          distance: 0,
          stopName: 'problems',
        ),
        entity: const Stop(
          id: 'BEF7F24D-A781-4AB3-9E16-9E7E09503671',
          name: 'obtained',
          lat: 94.64,
          lon: 18.35,
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
