import 'package:tiamat/src/comet2/instruction/jump.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('JMI', () {
    group('adr,x', () {
      final tests = [
        _test_jmi_1(),
        _test_jmi_2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JNZ', () {
    group('adr,x', () {
      final tests = [
        _test_jnz_1(),
        _test_jnz_2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JZE', () {
    group('adr,x', () {
      final tests = [
        _test_jze_1(),
        _test_jze_2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JUMP', () {
    group('adr,x', () {
      final tests = [
        _test_jump(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JPL', () {
    group('adr,x', () {
      final tests = [
        _test_jpl_1(),
        _test_jpl_2(),
        _test_jpl_3(),
        _test_jpl_4(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JOV', () {
    group('adr,x', () {
      final tests = [
        _test_jov_1(),
        _test_jov_2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _test_jmi_1() {
  return (
    'JMI #4000,GR1 ; SF = 0, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6101; // JMI #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.sf = false;
      r.pr = 0x3000;

      jumpOnMinus(r, Device());

      expect(r.pr, equals(0x3002));
    },
  );
}

TestCase _test_jmi_2() {
  return (
    'JMI #4000,GR1 ; SF = 1, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6101; // JMI #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.sf = true;
      r.pr = 0x3000;

      jumpOnMinus(r, Device());

      expect(r.pr, equals(0x4001));
    },
  );
}

TestCase _test_jnz_1() {
  return (
    'JNZ #4000,GR1 ; ZF = 0, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6201; // JNZ #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.zf = false;
      r.pr = 0x3000;

      jumpOnNonZero(r, Device());

      expect(r.pr, equals(0x4001));
    },
  );
}

TestCase _test_jnz_2() {
  return (
    'JNZ #4000,GR1 ; ZF = 1, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6201; // JNZ #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.zf = true;
      r.pr = 0x3000;

      jumpOnNonZero(r, Device());

      expect(r.pr, equals(0x3002));
    },
  );
}

TestCase _test_jze_1() {
  return (
    'JZE #4000,GR1 ; ZF = 0, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6301; // JZE #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.zf = false;
      r.pr = 0x3000;

      jumpOnZero(r, Device());

      expect(r.pr, equals(0x3002));
    },
  );
}

TestCase _test_jze_2() {
  return (
    'JZE #4000,GR1 ; ZF = 1, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6301; // JZE #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.zf = true;
      r.pr = 0x3000;

      jumpOnZero(r, Device());

      expect(r.pr, equals(0x4001));
    },
  );
}

TestCase _test_jump() {
  return (
    'JUMP #4000,GR1 ; GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6401; // JUMP #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.pr = 0x3000;

      unconditionalJump(r, Device());

      expect(r.pr, equals(0x4001));
    },
  );
}

TestCase _test_jpl_1() {
  return (
    'JPL #4000,GR1 ; SF = 0, ZF = 0, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6501; // JPL #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.sf = false;
      r.zf = false;
      r.pr = 0x3000;

      jumpOnPlus(r, Device());

      expect(r.pr, equals(0x4001));
    },
  );
}

TestCase _test_jpl_2() {
  return (
    'JPL #4000,GR1 ; SF = 1, ZF = 0, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6501; // JPL #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.sf = true;
      r.zf = false;
      r.pr = 0x3000;

      jumpOnPlus(r, Device());

      expect(r.pr, equals(0x3002));
    },
  );
}

TestCase _test_jpl_3() {
  return (
    'JPL #4000,GR1 ; SF = 0, ZF = 1, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6501; // JPL #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.sf = false;
      r.zf = true;
      r.pr = 0x3000;

      jumpOnPlus(r, Device());

      expect(r.pr, equals(0x3002));
    },
  );
}

TestCase _test_jpl_4() {
  return (
    'JPL #4000,GR1 ; SF = 1, ZF = 1, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6501; // JPL #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.sf = true;
      r.zf = true;
      r.pr = 0x3000;

      jumpOnPlus(r, Device());

      expect(r.pr, equals(0x3002));
    },
  );
}

TestCase _test_jov_1() {
  return (
    'JOV #4000,GR1 ; OF = 0, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6601; // JOV #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.of = false;
      r.pr = 0x3000;

      jumpOnOverflow(r, Device());

      expect(r.pr, equals(0x3002));
    },
  );
}

TestCase _test_jov_2() {
  return (
    'JOV #4000,GR1 ; OF = 1, GR1 = 1',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x6601; // JOV #4000,GR1
      r.memory[0x3001] = 0x4000;

      r.gr[1] = 1;
      r.of = true;
      r.pr = 0x3000;

      jumpOnOverflow(r, Device());

      expect(r.pr, equals(0x4001));
    },
  );
}
