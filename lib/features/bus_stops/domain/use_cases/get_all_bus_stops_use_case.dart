import 'package:b_stop/core/logging/b_stop_logger.dart' show BStopLogger;
import 'package:b_stop/core/logging/b_stop_logger_factory.dart' show BStopLoggerFactory;
import 'package:b_stop/features/bus_stops/domain/entities/stop.dart' show Stop;
import 'package:b_stop/features/bus_stops/domain/repositories/stop_repository.dart' show StopRepository;
import 'package:rust_core/rust_core.dart' show FutureResult, FutureResultExtension, Iter;

class GetAllBusStopsUseCase {
  GetAllBusStopsUseCase({required StopRepository stopRepository}) : _stopRepository = stopRepository;

  final BStopLogger _logger = BStopLoggerFactory.standard();
  final StopRepository _stopRepository;

  FutureResult<Iter<Stop>, String> call() async {
    _logger.info('Getting all bus stops...');

    return _stopRepository.fetchAll().inspectErr(_logger.warning).mapErr((_) => 'Unable to get all stops');
  }
}
