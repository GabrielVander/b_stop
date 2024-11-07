import 'dart:async';

import 'package:b_stop/features/bus_stops/domain/dtos/stop_output.dart' show StopOutput;
import 'package:b_stop/features/bus_stops/domain/use_cases/get_all_bus_stops_use_case.dart' show GetAllBusStopsUseCase;
import 'package:b_stop/features/bus_stops/presentation/state/stops_display_cubit.dart'
    show
        StopViewModel,
        StopsDisplayCubit,
        StopsDisplayFailedState,
        StopsDisplayInitialLoadingState,
        StopsDisplayLoadedState,
        StopsDisplayLoadingState,
        StopsDisplayNoStopsState;
import 'package:flutter_test/flutter_test.dart'
    show emits, emitsInOrder, equals, expect, expectLater, setUp, tearDown, test;
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart' show Mock, when;
import 'package:rust_core/rust_core.dart' show Err, FutureResult, IterableExtension, Ok;

void main() {
  late GetAllBusStopsUseCase getAllBusStopsUseCase;
  late StopsDisplayCubit cubit;

  setUp(() {
    getAllBusStopsUseCase = _MockGetAllBusStopsUseCase();
    cubit = StopsDisplayCubit(getAllBusStopsUseCase: getAllBusStopsUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be StopsDisplayInitialLoadingState', () {
    expect(cubit.state, equals(StopsDisplayInitialLoadingState()));
  });

  test(
    'given get all stops use case fails then state should be StopsDisplayInitialLoadingState -> StopsDisplayLoadingState -> StopsDisplayFailedState',
    () async {
      when(getAllBusStopsUseCase.call).thenAnswer((_) => FutureResult.value(const Err('court')));

      expect(cubit.state, equals(StopsDisplayInitialLoadingState()));
      unawaited(expectLater(cubit.stream, emits(StopsDisplayLoadingState())));
      await cubit.loadStops();
      expect(cubit.state, equals(StopsDisplayFailedState(errorMessage: 'Unable to display stops')));
    },
  );

  test(
    'given get all stops use case returns [] then state should be StopsDisplayInitialLoadingState -> StopsDisplayLoadingState -> StopsDisplayNoStopsState',
    () async {
      when(getAllBusStopsUseCase.call).thenAnswer((_) => FutureResult.value(Ok(<StopOutput>[].iter())));

      expect(cubit.state, equals(StopsDisplayInitialLoadingState()));
      unawaited(expectLater(cubit.stream, emitsInOrder([StopsDisplayLoadingState(), StopsDisplayNoStopsState()])));
      await cubit.loadStops();
    },
  );

  test(
    'given get all stops use case returns some stops then state should be StopsDisplayInitialLoadingState -> StopsDisplayLoadingState -> StopsDisplayLoadedState',
    () async {
      final stops = [
        const StopOutput(id: 'B17009F4-ACC6-46D2-8E26-C3409D62D81C', name: 'cooper', postion: LatLng(99.62, -97.70)),
        const StopOutput(id: '5DC37DDE-6461-40FA-B6E2-F45BBF43CA95', name: 'cloth', postion: LatLng(-12.65, 57.45)),
        const StopOutput(id: '839A2447-7146-4587-B146-A849371004FC', name: 'charge', postion: LatLng(75.40, -78.74)),
      ];
      final expectedViewModels = [
        const StopViewModel(
          id: 'B17009F4-ACC6-46D2-8E26-C3409D62D81C',
          displayText: 'cooper',
          coordinates: LatLng(99.62, -97.70),
        ),
        const StopViewModel(
          id: '5DC37DDE-6461-40FA-B6E2-F45BBF43CA95',
          displayText: 'cloth',
          coordinates: LatLng(-12.65, 57.45),
        ),
        const StopViewModel(
          id: '839A2447-7146-4587-B146-A849371004FC',
          displayText: 'charge',
          coordinates: LatLng(75.40, -78.74),
        ),
      ];

      when(getAllBusStopsUseCase.call).thenAnswer((_) => FutureResult.value(Ok(stops.iter())));

      expect(cubit.state, equals(StopsDisplayInitialLoadingState()));
      unawaited(
        expectLater(
          cubit.stream,
          emitsInOrder([StopsDisplayLoadingState(), StopsDisplayLoadedState(stops: expectedViewModels)]),
        ),
      );
      await cubit.loadStops();
    },
  );
}

class _MockGetAllBusStopsUseCase extends Mock implements GetAllBusStopsUseCase {}
