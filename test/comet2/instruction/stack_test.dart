import 'package:tiamat/src/comet2/instruction/stack.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('PUSH', () {
    group('adr,x', () {
      final tests = [
        _testPush(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('POP', () {
    group('r', () {
      final tests = [
        _testPop(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _testPush() {
  return (
    'PUSH 0,GR1 ; GR1 = 1',
    () async {
      final r = Resource();
      r.memory[0x3000] = 0x7001; // PUSH 0,GR1
      r.memory[0x3001] = 0;

      r.gr[1] = 1;
      r.sp = 255;
      r.pr = 0x3000;

      await push(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.sp, equals(254));
      expect(r.memory[254], equals(1));
    }
  );
}

TestCase _testPop() {
  return (
    'POP GR1',
    () async {
      final r = Resource();
      r.memory[0x3000] = 0x7110; // POP GR1

      r.memory[254] = 1;
      r.sp = 254;
      r.pr = 0x3000;

      await pop(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.sp, equals(255));
      expect(r.gr[1], equals(1));
    }
  );
}
