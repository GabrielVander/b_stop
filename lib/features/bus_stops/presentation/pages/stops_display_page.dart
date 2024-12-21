import 'package:b_stop/features/bus_stops/presentation/state/stops_display_cubit.dart';
import 'package:b_stop/features/bus_stops/presentation/state/trips_departures_display_cubit.dart';
import 'package:b_stop/features/bus_stops/presentation/widgets/trips_modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

class StopsDisplayPage extends StatelessWidget {
  const StopsDisplayPage({
    required this.stopDisplayCubit,
    required this.tripsDeparturesDisplayCubit,
    super.key,
  });

  final StopsDisplayCubit stopDisplayCubit;
  final TripsDeparturesDisplayCubit tripsDeparturesDisplayCubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<StopsDisplayCubit, StopsDisplayState>(
            bloc: stopDisplayCubit,
            builder: (BuildContext context, StopsDisplayState state) => switch (state) {
              (StopsDisplayInitialLoadingState() || StopsDisplayLoadingState()) => const _Loading(),
              StopsDisplayFailedState(errorMessage: final e) => _Failed(message: e),
              StopsDisplayNoStopsState() => const _NoStops(),
              StopsDisplayLoadedState(stops: final stops) =>
                _MapDisplay(tripsDeparturesDisplayCubit: tripsDeparturesDisplayCubit, stops: stops),
            },
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _Failed extends StatelessWidget {
  const _Failed({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _NoStops extends StatelessWidget {
  const _NoStops();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No stops'));
  }
}

class _MapDisplay extends StatelessWidget {
  const _MapDisplay({
    required this.stops,
    required this.tripsDeparturesDisplayCubit,
  });

  final TripsDeparturesDisplayCubit tripsDeparturesDisplayCubit;
  final List<StopViewModel> stops;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: MapController(),
      options: const MapOptions(initialCenter: LatLng(-22.012, -47.891)),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            rotate: true,
            markers: stops
                .map(
                  (stop) => Marker(
                    key: ValueKey(stop.id),
                    point: stop.point,
                    child: GestureDetector(
                      onDoubleTap: () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        useSafeArea: true,
                        builder: (context) => TripsModalBottomSheet(
                          tripsDeparturesDisplayCubit: tripsDeparturesDisplayCubit..getTripsForStop(stop.id),
                          stopId: stop.id,
                          title: stop.bottomSheetTitle,
                        ),
                      ),
                      child: Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: stop.tooltipText,
                        child: const Icon(Icons.location_on),
                      ),
                    ),
                  ),
                )
                .toList(),
            builder: (context, markers) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: Center(
                child: Text(
                  markers.length.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
