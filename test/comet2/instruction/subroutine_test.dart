import 'package:tiamat/src/comet2/instruction/subroutine.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('CALL', () {
    group('adr,x', () {
      final tests = [
        _test_call(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('RET', () {
    final tests = [
      _test_ret(),
    ];
    for (final (description, body) in tests) {
      test(description, body);
    }
  });
}

TestCase _test_call() {
  return (
    'CALL #4000,GR1 ; GR1 = 1',
    () async {
      final r = Resource();
      r.memory[0x3000] = 0x8001; // CALL #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.sp = 255;
      r.pr = 0x3000;

      await callSubroutine(r, Device());

      expect(r.pr, equals(0x4001));
      expect(r.sp, equals(254));
      expect(r.memory[254], equals(0x3002));
    }
  );
}

TestCase _test_ret() {
  return (
    'RET',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x8100; // RET

      r.memory[254] = 0x3002;
      r.sp = 254;
      r.pr = 0x4001;

      returnFromSubroutine(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.sp, equals(255));
    }
  );
}
