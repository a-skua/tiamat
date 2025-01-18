import 'package:tiamat/src/comet2/instruction/add_sub.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('ADDA', () {
    group('r,adr,x', () {
      final tests = [
        _test_addArithmetic_1(),
        _test_addArithmetic_2(),
        _test_addArithmetic_3(),
        _test_addArithmetic_4(),
        _test_addArithmetic_5(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _test_addArithmeticGR_1(),
        _test_addArithmeticGR_2(),
        _test_addArithmeticGR_3(),
        _test_addArithmeticGR_4(),
        _test_addArithmeticGR_5(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('ADDL', () {
    group('r,adr,x', () {
      final tests = [
        _test_addLogical_1(),
        _test_addLogical_2(),
        _test_addLogical_3(),
        _test_addLogical_4(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _test_addLogicalGR_1(),
        _test_addLogicalGR_2(),
        _test_addLogicalGR_3(),
        _test_addLogicalGR_4(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('SUBA', () {
    group('r,adr,x', () {
      final tests = [
        _test_subArithmetic_1(),
        _test_subArithmetic_2(),
        _test_subArithmetic_3(),
        _test_subArithmetic_4(),
        _test_subArithmetic_5(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _test_subArithmeticGR_1(),
        _test_subArithmeticGR_2(),
        _test_subArithmeticGR_3(),
        _test_subArithmeticGR_4(),
        _test_subArithmeticGR_5(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('SUBL', () {
    group('r,adr,x', () {
      final tests = [
        _test_subLogical_1(),
        _test_subLogical_2(),
        _test_subLogical_3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _test_subLogicalGR_1(),
        _test_subLogicalGR_2(),
        _test_subLogicalGR_3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _test_addArithmetic_1() {
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

TestCase _test_addArithmetic_2() {
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

TestCase _test_addArithmetic_3() {
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

TestCase _test_addArithmetic_4() {
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

TestCase _test_addArithmetic_5() {
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

TestCase _test_addArithmeticGR_1() {
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

TestCase _test_addArithmeticGR_2() {
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

TestCase _test_addArithmeticGR_3() {
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

TestCase _test_addArithmeticGR_4() {
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

TestCase _test_addArithmeticGR_5() {
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

TestCase _test_addLogical_1() {
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

TestCase _test_addLogical_2() {
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

TestCase _test_addLogical_3() {
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

TestCase _test_addLogical_4() {
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

TestCase _test_addLogicalGR_1() {
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

TestCase _test_addLogicalGR_2() {
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

TestCase _test_addLogicalGR_3() {
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

TestCase _test_addLogicalGR_4() {
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

TestCase _test_subArithmetic_1() {
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

TestCase _test_subArithmetic_2() {
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

TestCase _test_subArithmetic_3() {
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

TestCase _test_subArithmetic_4() {
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

TestCase _test_subArithmetic_5() {
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

TestCase _test_subArithmeticGR_1() {
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

TestCase _test_subArithmeticGR_2() {
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

TestCase _test_subArithmeticGR_3() {
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

TestCase _test_subArithmeticGR_4() {
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

TestCase _test_subArithmeticGR_5() {
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

TestCase _test_subLogical_1() {
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

TestCase _test_subLogical_2() {
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

TestCase _test_subLogical_3() {
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

TestCase _test_subLogicalGR_1() {
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

TestCase _test_subLogicalGR_2() {
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

TestCase _test_subLogicalGR_3() {
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
