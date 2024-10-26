import 'package:rust_core/rust_core.dart' show Err, Ok, Result;

Result<T, String> cast<T>(dynamic target) {
  try {
    return Ok<T, String>(target as T);
    // ignore: avoid_catching_errors
  } on TypeError catch (e) {
    return Err<T, String>(e.toString());
  }
}
