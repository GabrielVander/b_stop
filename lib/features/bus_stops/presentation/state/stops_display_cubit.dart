import 'package:b_stop/features/bus_stops/domain/dtos/stop_output.dart';
import 'package:b_stop/features/bus_stops/domain/use_cases/get_all_bus_stops_use_case.dart' show GetAllBusStopsUseCase;
import 'package:equatable/equatable.dart' show Equatable;
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:latlong2/latlong.dart' show LatLng;

class StopsDisplayCubit extends Cubit<StopsDisplayState> {
  StopsDisplayCubit({required GetAllBusStopsUseCase getAllBusStopsUseCase})
      : _getAllBusStopsUseCase = getAllBusStopsUseCase,
        super(StopsDisplayInitialLoadingState());

  final GetAllBusStopsUseCase _getAllBusStopsUseCase;

  Future<void> loadStops() async {
    emit(StopsDisplayLoadingState());

    (await _getAllBusStopsUseCase.call())
        .inspectErr((_) => emit(StopsDisplayFailedState(errorMessage: 'Unable to display stops')))
        .map((stops) => stops.toList())
        .inspect(
          (stops) => stops.isEmpty
              ? emit(StopsDisplayNoStopsState())
              : emit(StopsDisplayLoadedState(stops: stops.map(StopViewModel.fromOutput).toList())),
        );
  }
}

final class StopViewModel extends Equatable {
  const StopViewModel({required this.id, required this.displayText, required this.coordinates});

  factory StopViewModel.fromOutput(StopOutput output) =>
      StopViewModel(id: output.id, displayText: output.name, coordinates: output.postion);

  final String id;
  final String displayText;
  final LatLng coordinates;

  @override
  List<Object?> get props => [id, displayText, coordinates];
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
