import 'package:b_stop/core/utils/cast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_core/src/result/result.dart';

void main() {
  group('cast', () {
    test('when given an uncastable type should return Err', () {
      final Result<String, String> result = cast<String>(12);

      expect(
        result,
        const Err<String, String>("type 'int' is not a subtype of type 'String' in type cast"),
      );
    });

    test('when given a castable type should return Ok', () {
      final Result<int, String> result = cast<int>(12);

      expect(result, const Ok<int, String>(12));
      expect(result.unwrap().runtimeType, int);
    });
  });
}

