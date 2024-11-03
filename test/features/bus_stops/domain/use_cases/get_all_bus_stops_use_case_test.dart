import 'package:b_stop/features/bus_stops/domain/dtos/stop_output.dart' show StopOutput;
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart' show Stop;
import 'package:b_stop/features/bus_stops/domain/repositories/stop_repository.dart' show StopRepository;
import 'package:b_stop/features/bus_stops/domain/use_cases/get_all_bus_stops_use_case.dart' show GetAllBusStopsUseCase;
import 'package:flutter_test/flutter_test.dart' show equals, expect, test;
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:mocktail/mocktail.dart' show Mock, when;
import 'package:rust_core/rust_core.dart' show Err, IterableExtension, Ok;

void main() {
  test('given failure within repository should return Err', () async {
    final mockStopRepository = _MockStopRepository();
    final useCase = GetAllBusStopsUseCase(stopRepository: mockStopRepository);

    when(mockStopRepository.fetchAll).thenAnswer((_) async => Future.value(const Err('vocals')));

    final result = await useCase.call();

    expect(result.isErr(), true);
    expect(result.unwrapErr(), 'Unable to get all stops');
  });

  for (final testCase in [
    (<Stop>[], <StopOutput>[]),
    (
      [const Stop(id: '8436EB2D-CAEA-4958-95E8-4A06C6AC3DF2', name: 'function', lat: 58.95, lon: 99.53)],
      [const StopOutput(id: '8436EB2D-CAEA-4958-95E8-4A06C6AC3DF2', name: 'function', postion: LatLng(58.95, 99.53))]
    ),
    (
      [
        const Stop(id: '4868D809-D8B3-4381-9616-CC6C656A4417', name: 'bunny', lat: 3.53, lon: -41.34),
        const Stop(id: '387D948E-EAA7-4DF8-AA3E-2D92923C78E5', name: 'staying', lat: -36.75, lon: 54.12),
        const Stop(id: 'C8B05469-E579-4340-9B30-F1A6E7D5840B', name: 'variable', lat: -34.93, lon: -2.41),
      ],
      [
        const StopOutput(id: '4868D809-D8B3-4381-9616-CC6C656A4417', name: 'bunny', postion: LatLng(3.53, -41.34)),
        const StopOutput(id: '387D948E-EAA7-4DF8-AA3E-2D92923C78E5', name: 'staying', postion: LatLng(-36.75, 54.12)),
        const StopOutput(id: 'C8B05469-E579-4340-9B30-F1A6E7D5840B', name: 'variable', postion: LatLng(-34.93, -2.41)),
      ]
    ),
  ]) {
    test('given stop repository returns ${testCase.$1}, then should return Ok(${testCase.$2})', () async {
      final mockStopRepository = _MockStopRepository();
      final useCase = GetAllBusStopsUseCase(stopRepository: mockStopRepository);

      when(mockStopRepository.fetchAll).thenAnswer((_) async => Future.value(Ok(testCase.$1.iter())));

      final result = await useCase.call();

      expect(result.isOk(), true);
      expect(result.unwrap(), equals(testCase.$2.iter()));
    });
  }
}

class _MockStopRepository extends Mock implements StopRepository {}
