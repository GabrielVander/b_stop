import 'package:b_stop/features/bus_stops/domain/dtos/stop_output.dart' show StopOutput;
import 'package:rust_core/rust_core.dart' show FutureResult, Iter;

abstract interface class StopRepository {
  FutureResult<Iter<StopOutput>, String> fetchAll();
}
