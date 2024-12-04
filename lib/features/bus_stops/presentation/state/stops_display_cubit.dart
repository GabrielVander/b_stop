import 'package:b_stop/core/logging/b_stop_logger.dart';
import 'package:b_stop/core/logging/b_stop_logger_factory.dart';
import 'package:b_stop/features/bus_stops/domain/dtos/stop_output.dart';
import 'package:b_stop/features/bus_stops/domain/use_cases/get_all_bus_stops_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:rust_core/rust_core.dart';

class StopsDisplayCubit extends Cubit<StopsDisplayState> {
  StopsDisplayCubit({required GetAllBusStopsUseCase getAllBusStopsUseCase})
      : _getAllBusStopsUseCase = getAllBusStopsUseCase,
        super(StopsDisplayInitialLoadingState());

  final BStopLogger _logger = BStopLoggerFactory.standard();
  final GetAllBusStopsUseCase _getAllBusStopsUseCase;

  Future<void> loadStops() async {
    _logger.info('Loading stops...');
    emit(StopsDisplayLoadingState());

    final busStopsResult = await _getBusStops();

    switch (busStopsResult) {
      case Err():
        emit(StopsDisplayFailedState(errorMessage: 'Unable to display stops'));
      case Ok(:final ok):
        _processStops(ok);
    }
  }

  void _processStops(List<StopOutput> ok) {
    _logger.info('Processing ${ok.length} stops...');

    if (ok.isEmpty) {
      _logger.info('No stops retrieved');
      return emit(StopsDisplayNoStopsState());
    }

    final stopViewModels = _parseStops(ok);
    _logger.info('Stops loaded');
    return emit(StopsDisplayLoadedState(stops: stopViewModels));
  }

  List<StopViewModel> _parseStops(List<StopOutput> ok) => ok.map(StopViewModel.fromOutput).toList();

  Future<Result<List<StopOutput>, String>> _getBusStops() async =>
      (await _getAllBusStopsUseCase.call()).map((s) => s.toList()).inspectErr(_logger.warning);
}

final class StopViewModel extends Equatable {
  const StopViewModel({
    required this.id,
    required this.tooltipText,
    required this.point,
    required this.bottomSheetTitle,
  });

  factory StopViewModel.fromOutput(StopOutput output) =>
      StopViewModel(id: output.id, tooltipText: output.name, point: output.postion, bottomSheetTitle: output.name);

  final String id;
  final String tooltipText;
  final String bottomSheetTitle;
  final LatLng point;

  @override
  List<Object?> get props => [id, tooltipText, point];
}

sealed class StopsDisplayState extends Equatable {}

final class StopsDisplayInitialLoadingState extends StopsDisplayState {
  @override
  List<Object?> get props => [];
}

final class StopsDisplayLoadingState extends StopsDisplayState {
  @override
  List<Object?> get props => [];
}

final class StopsDisplayFailedState extends StopsDisplayState {
  StopsDisplayFailedState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

final class StopsDisplayNoStopsState extends StopsDisplayState {
  @override
  List<Object?> get props => [];
}

final class StopsDisplayLoadedState extends StopsDisplayState {
  StopsDisplayLoadedState({required this.stops});

  final List<StopViewModel> stops;

  @override
  List<Object?> get props => [stops];
}
