import 'package:tiamat/src/typedef/typedef.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Ok', testOk);
    test('Err', testErr);
  });
}

void testOk() {
  final result = Ok('ok!');
  expect(result.isOk, equals(true));
  expect(result.isErr, equals(false));
  expect(result.ok, equals('ok!'));
}

void testErr() {
  final result = Err('error!');
  expect(result.isOk, equals(false));
  expect(result.isErr, equals(true));
  expect(result.err, equals('error!'));
}
