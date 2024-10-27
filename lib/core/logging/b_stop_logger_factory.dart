import 'package:b_stop/core/logging/b_stop_logger.dart';
import 'package:b_stop/core/logging/impl/b_stop_logger_source_horizon_impl.dart';

abstract class BStopLoggerFactory {
  static BStopLogger standard() => BStopLoggerSourceHorizonImpl();
}
