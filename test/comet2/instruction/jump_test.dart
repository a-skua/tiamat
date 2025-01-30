import 'package:tiamat/src/comet2/instruction/jump.dart';
import 'package:tiamat/comet2.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('JMI', () {
    group('adr,x', () {
      final tests = [
        _testJmi1(),
        _testJmi2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JNZ', () {
    group('adr,x', () {
      final tests = [
        _testJnz1(),
        _testJnz2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JZE', () {
    group('adr,x', () {
      final tests = [
        _testJze1(),
        _testJze2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JUMP', () {
    group('adr,x', () {
      final tests = [
        _testJump(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JPL', () {
    group('adr,x', () {
      final tests = [
        _testJpl1(),
        _testJpl2(),
        _testJpl3(),
        _testJpl4(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('JOV', () {
    group('adr,x', () {
      final tests = [
        _testJov1(),
        _testJov2(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _testJmi1() {
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

TestCase _testJmi2() {
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

TestCase _testJnz1() {
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

TestCase _testJnz2() {
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

TestCase _testJze1() {
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

TestCase _testJze2() {
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

TestCase _testJump() {
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

TestCase _testJpl1() {
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

TestCase _testJpl2() {
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

TestCase _testJpl3() {
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

TestCase _testJpl4() {
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

TestCase _testJov1() {
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

TestCase _testJov2() {
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
