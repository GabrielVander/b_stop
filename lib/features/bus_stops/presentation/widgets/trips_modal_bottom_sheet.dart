import 'package:b_stop/features/bus_stops/presentation/state/trips_departures_display_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rust_core/rust_core.dart';

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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Text(
              title,
              style: TextTheme.of(context).titleMedium,
            ),
            Divider(height: (DividerTheme.of(context).space ?? 16) + 5),
            BlocBuilder<TripsDeparturesDisplayCubit, TripsDeparturesDisplayState>(
              bloc: tripsDeparturesDisplayCubit..getTripsForStop(stopId),
              builder: (context, state) {
                return switch (state) {
                  TripsDeparturesDisplayLoadingState() => const CircularProgressIndicator.adaptive(),
                  TripsDeparturesDisplayFailureState(errorMessage: final errorMessage) =>
                    Center(child: Text('Failed to retrieve data\n$errorMessage')),
                  TripsDeparturesDisplayEmptyState() => const Center(child: Text('No data')),
                  TripsDeparturesDisplayLoadedState(trips: final trips) => Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => const SizedBox(height: 15),
                        itemCount: trips.length,
                        itemBuilder: (context, index) => Row(
                          spacing: 10,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: const BorderRadius.all(Radius.circular(3)),
                                border: Border.all(width: 2),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: Text(
                                trips[index].lineIdentificationText,
                                style: TextTheme.of(context).titleSmall,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                spacing: 5,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        trips[index].displayText,
                                        style: TextTheme.of(context).titleSmall,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(3)),
                                          border: Border.all(),
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: Text(
                                          trips[index].departures.first.timeText,
                                          style: TextTheme.of(context).bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 10,
                                    children: trips[index]
                                        .departures
                                        .slice(1)
                                        .map(
                                          (d) => Container(
                                            decoration: BoxDecoration(
                                              color: d.shouldBeDisabled ? Colors.grey : Colors.black12,
                                              borderRadius: const BorderRadius.all(Radius.circular(3)),
                                            ),
                                            padding: const EdgeInsets.all(3),
                                            child: Text(d.timeText, style: TextTheme.of(context).bodySmall),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}
