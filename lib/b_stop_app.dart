import 'package:b_stop/features/bus_stops/presentation/state/stops_display_cubit.dart';
import 'package:b_stop/stops_display_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BStopApp extends StatelessWidget {
  const BStopApp({required this.stopDisplayCubit, super.key});

  final StopsDisplayCubit stopDisplayCubit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<StopsDisplayCubit>.value(
        value: stopDisplayCubit..loadStops(),
        child: StopsDisplayPage(stopDisplayCubit: stopDisplayCubit),
      ),
    );
  }
}
