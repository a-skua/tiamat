import 'package:tiamat/src/casl2/typedef.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Ok', testResultOk);
    test('Err', testResultErr);
  });
}

void testResultOk() {
  final result = Result.ok('ok!');
  expect(result.isOk, equals(true));
  expect(result.isError, equals(false));
  expect(result.ok, equals('ok!'));
}

void testResultErr() {
  final result = Result.err('error!');
  expect(result.isOk, equals(false));
  expect(result.isError, equals(true));
  expect(result.error, equals('error!'));
}
