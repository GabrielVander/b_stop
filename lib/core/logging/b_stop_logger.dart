abstract interface class BStopLogger {
  void info(String message);

  void debug(String message);

  void trace(String message);

  void warning(String message);

  void error(String message, {Exception? error, StackTrace? stackTrace});
}
