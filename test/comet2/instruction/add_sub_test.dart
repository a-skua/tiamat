import 'package:tiamat/src/comet2/instruction/add_sub.dart';
import 'package:tiamat/comet2.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('ADDA', () {
    group('r,adr,x', () {
      final tests = [
        _testAddArithmetic1(),
        _testAddArithmetic2(),
        _testAddArithmetic3(),
        _testAddArithmetic4(),
        _testAddArithmetic5(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testAddArithmeticGR1(),
        _testAddArithmeticGR2(),
        _testAddArithmeticGR3(),
        _testAddArithmeticGR4(),
        _testAddArithmeticGR5(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('ADDL', () {
    group('r,adr,x', () {
      final tests = [
        _testAddLogical1(),
        _testAddLogical2(),
        _testAddLogical3(),
        _testAddLogical4(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testAddLogicalGR1(),
        _testAddLogicalGR2(),
        _testAddLogicalGR3(),
        _testAddLogicalGR4(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('SUBA', () {
    group('r,adr,x', () {
      final tests = [
        _testSubArithmetic1(),
        _testSubArithmetic2(),
        _testSubArithmetic3(),
        _testSubArithmetic4(),
        _testSubArithmetic5(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testSubArithmeticGR1(),
        _testSubArithmeticGR2(),
        _testSubArithmeticGR3(),
        _testSubArithmeticGR4(),
        _testSubArithmeticGR5(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('SUBL', () {
    group('r,adr,x', () {
      final tests = [
        _testSubLogical1(),
        _testSubLogical2(),
        _testSubLogical3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testSubLogicalGR1(),
        _testSubLogicalGR2(),
        _testSubLogicalGR3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _testAddArithmetic1() {
  return (
    'ADDA GR1,#8000,GR2 ; GR1 = -1, GR2 = #0001, RAM[#8001] = 2 (-1 + 2 = 1)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2012; // ADDA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 2;

      r.gr[1] = -1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(1));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddArithmetic2() {
  return (
    'ADDA GR1,#8000,GR2 ; GR1 = -1, GR2 = #0001, RAM[#8001] = -1 (-1 + -1 = -2)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2012; // ADDA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = -1;

      r.gr[1] = -1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(-2));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddArithmetic3() {
  return (
    'ADDA GR1,#8000,GR2 ; GR1 = -1, GR2 = #0001, RAM[#8001] = 1 (-1 + 1 = 0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2012; // ADDA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 1;

      r.gr[1] = -1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testAddArithmetic4() {
  return (
    'ADDA GR1,#8000,GR2 ; GR1 = #7FFF, GR2 = #0001, RAM[#8001] = 1 (0x7fff + 1 = 0x8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2012; // ADDA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 1;

      r.gr[1] = 0x7fff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x8000));
      expect(r.gr[1].unsigned, equals(0x8000));
      expect(r.gr[1].signed, equals(-32768));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddArithmetic5() {
  return (
    'ADDA GR1,#8000,GR2 ; GR1 = #8000, GR2 = #0001, RAM[#8001] = #FFFF (0x8000 + 0xfffff = 0x7fff)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2012; // ADDA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 0xffff;

      r.gr[1] = 0x8000;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(-32769));
      expect(r.gr[1].unsigned, equals(32767));
      expect(r.gr[1].signed, equals(32767));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddArithmeticGR1() {
  return (
    'ADDA GR1,GR2 ; GR1 = -1, GR2 = 2 (-1 + 2 = 1)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2412; // ADDA GR1,GR2

      r.gr[1] = -1;
      r.gr[2] = 2;
      r.pr = 0x3000;

      addArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(1));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddArithmeticGR2() {
  return (
    'ADDA GR1,GR2 ; GR1 = -1, GR2 = -1 (-1 + -1 = -2)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2412; // ADDA GR1,GR2

      r.gr[1] = -1;
      r.gr[2] = -1;
      r.pr = 0x3000;

      addArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(-2));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddArithmeticGR3() {
  return (
    'ADDA GR1,GR2 ; GR1 = -1, GR2 = 1 (-1 + 1 = 0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2412; // ADDA GR1,GR2

      r.gr[1] = -1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testAddArithmeticGR4() {
  return (
    'ADDA GR1,GR2 ; GR1 = #7FFF, GR2 = 1 (0x7fff + 1 = 0x8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2412; // ADDA GR1,GR2

      r.gr[1] = 0x7fff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0x8000));
      expect(r.gr[1].unsigned, equals(0x8000));
      expect(r.gr[1].signed, equals(-32768));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddArithmeticGR5() {
  return (
    'ADDA GR1,GR2 ; GR1 = #8000, GR2 = #FFFF (0x8000 + 0xfffff = 0x7fff)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2412; // ADDA GR1,GR2

      r.gr[1] = 0x8000;
      r.gr[2] = 0xffff;
      r.pr = 0x3000;

      addArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(-32769));
      expect(r.gr[1].unsigned, equals(32767));
      expect(r.gr[1].signed, equals(32767));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddLogical1() {
  return (
    'ADDL GR1,#8000,GR2 ; GR1 = -1, GR2 = #0001, RAM[#8001] = 2 (-1 + 2 = 0x10001)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2212; // ADDL GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 2;

      r.gr[1] = -1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x10001));
      expect(r.gr[1].unsigned, equals(1));
      expect(r.gr[1].signed, equals(1));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddLogical2() {
  return (
    'ADDL GR1,#8000,GR2 ; GR1 = -1, GR2 = #0001, RAM[#8001] = 1 (-1 + 1 = 0x10000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2212; // ADDL GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 1;

      r.gr[1] = -1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x10000));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testAddLogical3() {
  return (
    'ADDL GR1,#8000,GR2 ; GR1 = 1, GR2 = #0001, RAM[#8001] = 2 (1 + 2 = 3)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2212; // ADDL GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 2;

      r.gr[1] = 1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(3));
      expect(r.gr[1].unsigned, equals(3));
      expect(r.gr[1].signed, equals(3));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddLogical4() {
  return (
    'ADDL GR1,#8000,GR2 ; GR1 = 0, GR2 = #0001, RAM[#8001] = 0 (0 + 0 = 0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2212; // ADDL GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 0;

      r.gr[1] = 0;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testAddLogicalGR1() {
  return (
    'ADDL GR1,GR2 ; GR1 = -1, GR2 = 2 (-1 + 2 = 0x10001)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2612; // ADDL GR1,GR2

      r.gr[1] = -1;
      r.gr[2] = 2;
      r.pr = 0x3000;

      addLogicalGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0x10001));
      expect(r.gr[1].unsigned, equals(1));
      expect(r.gr[1].signed, equals(1));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddLogicalGR2() {
  return (
    'ADDL GR1,GR2 ; GR1 = -1, GR2 = 1 (-1 + 1 = 0x10000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2612; // ADDL GR1,GR2

      r.gr[1] = -1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      addLogicalGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0x10000));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testAddLogicalGR3() {
  return (
    'ADDL GR1,GR2 ; GR1 = 1, GR2 = 2 (1 + 2 = 3)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2612; // ADDL GR1,GR2

      r.gr[1] = 1;
      r.gr[2] = 2;
      r.pr = 0x3000;

      addLogicalGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(3));
      expect(r.gr[1].unsigned, equals(3));
      expect(r.gr[1].signed, equals(3));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testAddLogicalGR4() {
  return (
    'ADDL GR1,GR2 ; GR1 = 0, GR2 = 0 (0 + 0 = 0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2612; // ADDL GR1,GR2

      r.gr[1] = 0;
      r.gr[2] = 0;
      r.pr = 0x3000;

      addLogicalGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0));
      expect(r.gr[1].unsigned, equals(0));
      expect(r.gr[1].signed, equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testSubArithmetic1() {
  return (
    'SUBA, GR1,#8000,GR2 ; GR1 = 2, GR2 = #0001, RAM[#8001] = 1 (2 - 1 = 1)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2112; // SUBA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 1;

      r.gr[1] = 2;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(1));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubArithmetic2() {
  return (
    'SUBA, GR1,#8000,GR2 ; GR1 = 1, GR2 = #0001, RAM[#8001] = 2 (1 - 2 = -1)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2112; // SUBA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 2;

      r.gr[1] = 1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(-1));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubArithmetic3() {
  return (
    'SUBA, GR1,#8000,GR2 ; GR1 = 1, GR2 = #0001, RAM[#8001] = 1 (1 - 1 = 0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2112; // SUBA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 1;

      r.gr[1] = 1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testSubArithmetic4() {
  return (
    'SUBA, GR1,#8000,GR2 ; GR1 = #7FFF, GR2 = #0001, RAM[#8001] = -1 (0x7fff - (-1) = 0x8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2112; // SUBA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = -1;

      r.gr[1] = 0x7fff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(32768));
      expect(r.gr[1].signed, equals(-32768));
      expect(r.gr[1].unsigned, equals(0x8000));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubArithmetic5() {
  return (
    'SUBA, GR1,#8000,GR2 ; GR1 = #8000, GR2 = #0001, RAM[#8001] = #7FFF (0x8000 - 0x7fff = 0x10000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2112; // SUBA GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 0x7fff;

      r.gr[1] = 0x8000;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractArithmetic(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(-65535));
      expect(r.gr[1].signed, equals(1));
      expect(r.gr[1].unsigned, equals(1));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubArithmeticGR1() {
  return (
    'SUBA, GR1,GR2 ; GR1 = 2, GR2 = 1 (2 - 1 = 1)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2512; // SUBA GR1,GR2

      r.gr[1] = 2;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(1));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubArithmeticGR2() {
  return (
    'SUBA, GR1,GR2 ; GR1 = 1, GR2 = 2 (1 - 2 = -1)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2512; // SUBA GR1,GR2

      r.gr[1] = 1;
      r.gr[2] = 2;
      r.pr = 0x3000;

      subtractArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(-1));
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubArithmeticGR3() {
  return (
    'SUBA, GR1,GR2 ; GR1 = 1, GR2 = 1 (1 - 1 = 0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2512; // SUBA GR1,GR2

      r.gr[1] = 1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testSubArithmeticGR4() {
  return (
    'SUBA, GR1,GR2 ; GR1 = #7FFF, GR2 = -1 (0x7fff - (-1) = 0x8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2112; // SUBA GR1,GR2

      r.gr[1] = 0x7fff;
      r.gr[2] = -1;
      r.pr = 0x3000;

      subtractArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(32768));
      expect(r.gr[1].signed, equals(-32768));
      expect(r.gr[1].unsigned, equals(0x8000));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubArithmeticGR5() {
  return (
    'SUBA, GR1,GR2 ; GR1 = #8000, GR2 = #7FFF (0x8000 - 0x7fff = 0x10000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2512; // SUBA GR1,GR2

      r.gr[1] = 0x8000;
      r.gr[2] = 0x7fff;
      r.pr = 0x3000;

      subtractArithmeticGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(-65535));
      expect(r.gr[1].signed, equals(1));
      expect(r.gr[1].unsigned, equals(1));
      expect(r.of, equals(true));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubLogical1() {
  return (
    'SUBL GR1,#8000,GR2 ; GR1 = 2, GR2 = #0001, RAM[#8001] = 1 (2 - 1 = 1)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2312; // SUBL GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 1;

      r.gr[1] = 2;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(1));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubLogical2() {
  return (
    'SUBL GR1,#8000,GR2 ; GR1 = 1, GR2 = #0001, RAM[#8001] = 2 (1 - 2 = 0xffff)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2312; // SUBL GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 2;

      r.gr[1] = 1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(-1));
      expect(r.gr[1].signed, equals(-1));
      expect(r.gr[1].unsigned, equals(0xffff));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubLogical3() {
  return (
    'SUBL GR1,#8000,GR2 ; GR1 = 1, GR2 = #0001, RAM[#8001] = 1 (1 - 1 = 0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2312; // SUBL GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 1;

      r.gr[1] = 1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractLogical(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testSubLogicalGR1() {
  return (
    'SUBL GR1,GR2 ; GR1 = 2, GR2 = 1 (2 - 1 = 1)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2712; // SUBL GR1,GR2

      r.gr[1] = 2;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractLogicalGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(1));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubLogicalGR2() {
  return (
    'SUBL GR1,GR2 ; GR1 = 1, GR2 = 2 (1 - 2 = 0xffff)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2712; // SUBL GR1,GR2

      r.gr[1] = 1;
      r.gr[2] = 2;
      r.pr = 0x3000;

      subtractLogicalGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(-1));
      expect(r.gr[1].signed, equals(-1));
      expect(r.gr[1].unsigned, equals(0xffff));
      expect(r.of, equals(true));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testSubLogicalGR3() {
  return (
    'SUBL GR1,GR2 ; GR1 = 1, GR2 = 1 (1 - 1 = 0)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x2712; // SUBL GR1,GR2

      r.gr[1] = 1;
      r.gr[2] = 1;
      r.pr = 0x3000;

      subtractLogicalGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0));
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}
