import 'package:b_stop/features/bus_stops/presentation/state/trips_departures_display_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripsModalBottomSheet extends StatelessWidget {
  const TripsModalBottomSheet({
    required this.stopId,
    required this.title,
    required this.tripsDeparturesDisplayCubit,
    this.height = 300,
    super.key,
  });

  final TripsDeparturesDisplayCubit tripsDeparturesDisplayCubit;
  final String stopId;
  final String title;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Text(title),
          Expanded(
            child: BlocBuilder<TripsDeparturesDisplayCubit, TripsDeparturesDisplayState>(
              bloc: tripsDeparturesDisplayCubit..getTripsForStop(stopId),
              builder: (context, state) {
                return switch (state) {
                  TripsDeparturesDisplayLoadingState() => const CircularProgressIndicator.adaptive(),
                  TripsDeparturesDisplayFailureState(errorMessage: final errorMessage) =>
                    Center(child: Text('Failed to retrieve data\n$errorMessage')),
                  TripsDeparturesDisplayEmptyState() => const Center(child: Text('No data')),
                  TripsDeparturesDisplayLoadedState(trips: final trips) => ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                      itemCount: trips.length,
                      itemBuilder: (context, index) => Row(
                        spacing: 20,
                        children: [
                          Container(
                            decoration: const BoxDecoration(color: Colors.yellow),
                            child: Text(trips[index].lineNumber),
                          ),
                          Text(trips[index].lineName),
                          Text(trips[index].departures[0].time),
                        ],
                      ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
