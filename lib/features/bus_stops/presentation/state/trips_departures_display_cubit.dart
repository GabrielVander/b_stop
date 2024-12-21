import 'package:b_stop/src/rust/api/trips.dart';
import 'package:b_stop/src/rust/features/trips/domain/entities/trip.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rust_core/rust_core.dart';

class TripsDeparturesDisplayCubit extends Cubit<TripsDeparturesDisplayState> {
  TripsDeparturesDisplayCubit() : super(TripsDeparturesDisplayLoadingState());

  Future<void> getTripsForStop(String stopId) async {
    emit(TripsDeparturesDisplayLoadingState());
    try {
      final List<Trip> tripModels = await fetchAllForStop(stopId: stopId);

      emit(
        TripsDeparturesDisplayLoadedState(
          trips: tripModels.iter().map<TripViewModel>(TripViewModel.fromEntity).collectList(),
        ),
      );
    } on Exception catch (e) {
      emit(TripsDeparturesDisplayFailureState(errorMessage: e.toString()));
    }
  }
}

sealed class TripsDeparturesDisplayState extends Equatable {}

class TripsDeparturesDisplayLoadingState extends TripsDeparturesDisplayState {
  @override
  List<Object?> get props => [];
}

class TripsDeparturesDisplayFailureState extends TripsDeparturesDisplayState {
  TripsDeparturesDisplayFailureState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class TripsDeparturesDisplayEmptyState extends TripsDeparturesDisplayState {
  TripsDeparturesDisplayEmptyState();

  @override
  List<Object?> get props => [];
}

class TripsDeparturesDisplayLoadedState extends TripsDeparturesDisplayState {
  TripsDeparturesDisplayLoadedState({required this.trips});

  final List<TripViewModel> trips;

  @override
  List<Object?> get props => [trips];
}

class TripViewModel extends Equatable {
  const TripViewModel({
    required this.id,
    required this.identifierText,
    required this.displayText,
    required this.departures,
  });

  factory TripViewModel.fromEntity(Trip model) => TripViewModel(
        id: model.id,
        identifierText: model.lineNumber,
        displayText: model.lineName,
        departures: model.departures.iter().map<DepartureViewModel>(DepartureViewModel.fromEntity).collectList(),
      );

  final String id;
  final String identifierText;
  final String displayText;
  final List<DepartureViewModel> departures;

  @override
  List<Object?> get props => [id, identifierText, displayText, departures];
}

class DepartureViewModel extends Equatable {
  const DepartureViewModel({
    required this.id,
    required this.timeText,
    required this.shouldBeDisabled,
    required this.shouldBeHighlighted,
  });

  factory DepartureViewModel.fromEntity(Departure model) => DepartureViewModel(
        id: model.id,
        timeText: DateFormat.jm().format(model.time.toLocal()),
        shouldBeDisabled: model.isNextDay,
        shouldBeHighlighted: model.isTimeBasedOnGps,
      );

  final String id;
  final String timeText;
  final bool shouldBeDisabled;
  final bool shouldBeHighlighted;

  @override
  List<Object?> get props => [id, timeText, shouldBeDisabled, shouldBeHighlighted];
}
