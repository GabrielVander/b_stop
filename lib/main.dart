import 'package:b_stop/b_stop_app.dart';
import 'package:b_stop/features/bus_data_retrieval/data/repositories/stop_repository_http_impl.dart';
import 'package:b_stop/features/bus_stops/domain/repositories/stop_repository.dart';
import 'package:b_stop/features/bus_stops/domain/use_cases/get_all_bus_stops_use_case.dart';
import 'package:b_stop/features/bus_stops/presentation/state/stops_display_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final Dio dioClient = Dio()..interceptors.add(LogInterceptor());

Future<void> main() async {
  await dotenv.load();

  final HttpStopsEndpoint stopsEndpoint = HttpStopsEndpoint(url: dotenv.get('HTTP_STOPS_URL'));
  final StopRepository stopRepository = StopRepositoryHttpImpl(dioClient, stopsEndpoint);
  final GetAllBusStopsUseCase getAllBusStopsUseCase = GetAllBusStopsUseCase(stopRepository: stopRepository);
  final StopsDisplayCubit stopDisplayCubit = StopsDisplayCubit(getAllBusStopsUseCase: getAllBusStopsUseCase);

  runApp(BStopApp(stopDisplayCubit: stopDisplayCubit));
}
