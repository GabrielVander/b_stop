import 'package:b_stop/features/bus_stops/domain/entities/stop.dart';
import 'package:rust_core/rust_core.dart';

abstract interface class StopRepository {
  FutureResult<List<Stop>, String> fetchAll();
}
