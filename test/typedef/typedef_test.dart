import 'package:tiamat/src/typedef/typedef.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Ok', _testOk);
    test('Err', _testErr);
  });
}

void _testOk() {
  final Result<String, dynamic> result = Ok('ok!');
  expect(result.isOk, equals(true));
  expect(result.isErr, equals(false));
  expect(result.ok, equals('ok!'));
}

void _testErr() {
  final Result<dynamic, String> result = Err('error!');
  expect(result.isOk, equals(false));
  expect(result.isErr, equals(true));
  expect(result.err, equals('error!'));
}
