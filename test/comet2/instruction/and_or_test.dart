import 'package:tiamat/src/comet2/instruction/and_or.dart';
import 'package:tiamat/comet2.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('AND', () {
    group('r,adr,x', () {
      final tests = [
        _testAnd1(),
        _testAnd2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testAndGR1(),
        _testAndGR2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('OR', () {
    group('r,adr,x', () {
      final tests = [
        _testOr1(),
        _testOr2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testOrGR1(),
        _testOrGR2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('XOR', () {
    group('r,adr,x', () {
      final tests = [
        _testXor1(),
        _testXor2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testXorGR1(),
        _testXorGR2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _testAnd1() {
  return (
    'AND GR1,#4000,GR2 ; GR1 = #8000, GR2 = #0001, RAM[#4001] = #FFFF (#8000 & #FFFF = #8000)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3012; // AND GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = -1;

      r.gr[1] = -32768;
      r.gr[2] = 1;
      r.pr = 0x3000;

      and(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x8000));
      expect(r.gr[1].signed, equals(-32768));
      expect(r.gr[1].unsigned, equals(0x8000));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAnd2() {
  return (
    'AND GR1,#4000,GR2 ; GR1 = #0000, GR2 = #0001, RAM[#4001] = #FFFF (#0000 & #FFFF = #0000)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3012; // AND GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x8001] = -1;

      r.gr[1] = 0;
      r.gr[2] = 1;
      r.pr = 0x3000;

      and(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testAndGR1() {
  return (
    'AND GR1,GR2 ; GR1 = #8000, GR2 = #FFFF (#8000 & #FFFF = #8000)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3412; // AND GR1,GR2

      r.gr[1] = -32768;
      r.gr[2] = -1;
      r.pr = 0x3000;

      andGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0x8000));
      expect(r.gr[1].signed, equals(-32768));
      expect(r.gr[1].unsigned, equals(0x8000));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAndGR2() {
  return (
    'AND GR1,GR2 ; GR1 = #0000, GR2 = #FFFF (#0000 & #FFFF = #0000)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3412; // AND GR1,GR2

      r.gr[1] = 0;
      r.gr[2] = -1;
      r.pr = 0x3000;

      andGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testOr1() {
  return (
    'OR GR1,#4000,GR2 ; GR1 = #8000, GR2 = #0001, RAM[#4001] = #7FFF (#8000 | #7FFF = #FFFF)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3112; // OR GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = 0x7fff;

      r.gr[1] = -32768;
      r.gr[2] = 1;
      r.pr = 0x3000;

      or(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xffff));
      expect(r.gr[1].signed, equals(-1));
      expect(r.gr[1].unsigned, equals(0xffff));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testOr2() {
  return (
    'OR GR1,#4000,GR2 ; GR1 = 0, GR2 = #0001, RAM[#4001] = 0 (0 | 0 = 0)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3112; // OR GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = 0;

      r.gr[1] = 0;
      r.gr[2] = 1;
      r.pr = 0x3000;

      or(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testOrGR1() {
  return (
    'OR GR1,GR2 ; GR1 = #8000, GR2 = #7FFF (#8000 | #7FFF = #FFFF)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3512; // OR GR1,GR2

      r.gr[1] = -32768;
      r.gr[2] = 32767;
      r.pr = 0x3000;

      orGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0xffff));
      expect(r.gr[1].signed, equals(-1));
      expect(r.gr[1].unsigned, equals(0xffff));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testOrGR2() {
  return (
    'OR GR1,GR2 ; GR1 = 0, GR2 = 0 (0 | 0 = 0)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3512; // OR GR1,GR2

      r.gr[1] = 0;
      r.gr[2] = 0;
      r.pr = 0x3000;

      orGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testXor1() {
  return (
    'XOR GR1,#4000,GR2 ; GR1 = #8000, GR2 = #0001, RAM[#4001] = #7FFF (#8000 ^ #7FFF = #FFFF)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3212; // XOR GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = 0x7fff;

      r.gr[1] = -32768;
      r.gr[2] = 1;
      r.pr = 0x3000;

      exclusiveOr(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xffff));
      expect(r.gr[1].signed, equals(-1));
      expect(r.gr[1].unsigned, equals(0xffff));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testXor2() {
  return (
    'XOR GR1,#4000,GR2 ; GR1 = #8000, GR2 = #0001, RAM[#4001] = #8000 (#8000 ^ #8000 = #0000)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3212; // XOR GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = -32768;

      r.gr[1] = -32768;
      r.gr[2] = 1;
      r.pr = 0x3000;

      exclusiveOr(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testXorGR1() {
  return (
    'XOR GR1,GR2 ; GR1 = #8000, GR2 = #7FFF (#8000 ^ #7FFF = #FFFF)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3612; // XOR GR1,GR2

      r.gr[1] = -32768;
      r.gr[2] = 0x7fff;
      r.pr = 0x3000;

      exclusiveOrGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0xffff));
      expect(r.gr[1].signed, equals(-1));
      expect(r.gr[1].unsigned, equals(0xffff));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testXorGR2() {
  return (
    'XOR GR1,GR2 ; GR1 = #8000, GR2 = #8000 (#8000 ^ #8000 = #0000)',
    () {
      final r = Resource();

      r.memory[0x3000] = 0x3612; // XOR GR1,GR2

      r.gr[1] = -32768;
      r.gr[2] = -32768;
      r.pr = 0x3000;

      exclusiveOrGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}
