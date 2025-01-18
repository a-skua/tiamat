import 'package:tiamat/src/comet2/instruction/shift.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('SLA', () {
    group('r,adr,x', () {
      final tests = [
        _test_sla_1(),
        _test_sla_2(),
        _test_sla_3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('SRA', () {
    group('r,adr,x', () {
      final tests = [
        _test_sra_1(),
        _test_sra_2(),
        _test_sra_3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('SLL', () {
    group('r,adr,x', () {
      final tests = [
        _test_sll_1(),
        _test_sll_2(),
        _test_sll_3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('SRL', () {
    group('r,adr,x', () {
      final tests = [
        _test_srl_1(),
        _test_srl_2(),
        _test_srl_3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _test_sla_1() {
  return (
    'SLA GR1,3,GR2 ; GR1 = #FFFF, GR2 = 1 (#FFFF << 4 = #FFF0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5012; // SLA GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0xffff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      shiftLeftArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xfff0));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _test_sla_2() {
  return (
    'SLA GR1,3,GR2 ; GR1 = #0FFF, GR2 = 1 (#0FFF << 4 = #FFF0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5012; // SLA GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0xfff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      shiftLeftArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xfff0));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _test_sla_3() {
  return (
    'SLA GR1,3,GR2 ; GR1 = #F000, GR2 = 1 (#F000 << 4 = #0000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5012; // SLA GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = -4096;
      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      shiftLeftArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _test_sra_1() {
  return (
    'SRA GR1,3,GR2 ; GR1 = #8FFF, GR2 = 1 (#8FFF >> 4 = #F8FF)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5112; // SRA GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0x8fff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      shiftRightArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xf8ff));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _test_sra_2() {
  return (
    'SRA GR1,3,GR2 ; GR1 = #0FF0, GR2 = 1 (#0FF0 >> 4 = #00ff)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5112; // SRA GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0xff0;
      r.gr[2] = 1;
      r.pr = 0x3000;

      shiftRightArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xff));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _test_sra_3() {
  return (
    'SRA GR1,3,GR2 ; GR1 = #000F, GR2 = 1 (#F000 >> 4 = #0000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5112; // SRA GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0xf;
      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      shiftRightArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _test_sll_1() {
  return (
    'SLL GR1,3,GR2 ; GR1 = #FFFF, GR2 = 1 (#FFFF << 4 = #FFF0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5212; // SLL GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0xffff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      shiftLeftLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xfff0));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _test_sll_2() {
  return (
    'SLL GR1,3,GR2 ; GR1 = #0FFF, GR2 = 1 (#0FFF << 4 = #FFF0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5212; // SLL GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0xfff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      shiftLeftLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xfff0));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _test_sll_3() {
  return (
    'SLL GR1,3,GR2 ; GR1 = #F000, GR2 = 1 (#F000 << 4 = #0000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5212; // SLL GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = -4096;
      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      shiftLeftLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _test_srl_1() {
  return (
    'SRL GR1,3,GR2 ; GR1 = #8FFF, GR2 = 1 (#8FFF >> 4 = #08FF)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5312; // SRL GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0x8fff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      shiftRightLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x8ff));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _test_srl_2() {
  return (
    'SRL GR1,3,GR2 ; GR1 = #0FF0, GR2 = 1 (#0FF0 >> 4 = #00ff)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5312; // SRL GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0xff0;
      r.gr[2] = 1;
      r.pr = 0x3000;

      shiftRightLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0xff));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _test_srl_3() {
  return (
    'SRL GR1,3,GR2 ; GR1 = #000F, GR2 = 1 (#F000 >> 4 = #0000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x5312; // SRL GR1,3,GR2
      r.memory[0x3001] = 0x0003;

      r.gr[1] = 0xf;
      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      shiftRightLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}
