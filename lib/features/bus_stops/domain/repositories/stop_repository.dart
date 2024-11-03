import 'package:b_stop/features/bus_stops/domain/entities/stop.dart' show Stop;
import 'package:rust_core/rust_core.dart' show FutureResult, Iter;

abstract interface class StopRepository {
  FutureResult<Iter<Stop>, String> fetchAll();
}
