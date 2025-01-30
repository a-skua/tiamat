import 'package:tiamat/src/comet2/instruction/no_operation.dart';
import 'package:tiamat/comet2.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('NOP', () {
    final tests = [
      _testNop(),
    ];
    for (final (description, body) in tests) {
      test(description, body);
    }
  });
}

TestCase _testNop() {
  return (
    'NOP',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x0000; // NOP

      r.pr = 0x3000;

      noOperation(r, Device());

      expect(r.pr, equals(0x3001));
    }
  );
}
