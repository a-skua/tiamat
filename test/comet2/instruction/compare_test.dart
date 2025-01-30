import 'package:tiamat/src/comet2/instruction/compare.dart';
import 'package:tiamat/comet2.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('CPA', () {
    group('r,adr,x', () {
      final tests = [
        _testCpa1(),
        _testCpa2(),
        _testCpa3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testCpaGR1(),
        _testCpaGR2(),
        _testCpaGR3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('CPL', () {
    group('r,adr,x', () {
      final tests = [
        _testCpl1(),
        _testCpl2(),
        _testCpl3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testCplGR1(),
        _testCplGR2(),
        _testCplGR3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _testCpa1() {
  return (
    'CPA GR1,#4000,GR2 ; GR1 = #8000, GR2 = #0001 RAM[#4001] = #7FFF (#8000 < #7FFF)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4012; // CPA GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = 0x7FFF;

      r.gr[1] = 0x8000;
      r.gr[2] = 1;
      r.pr = 0x3000;

      compareArithmetic(r, Device());

      expect(r.pr, 0x3002);
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    }
  );
}

TestCase _testCpa2() {
  return (
    'CPA GR1,#4000,GR2 ; GR1 = #8000, GR2 = #0001 RAM[#4001] = #8000 (#8000 = #8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4012; // CPA GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = -32768;

      r.gr[1] = 0x8000;
      r.gr[2] = 1;
      r.pr = 0x3000;

      compareArithmetic(r, Device());

      expect(r.pr, 0x3002);
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    }
  );
}

TestCase _testCpa3() {
  return (
    'CPA GR1,#4000,GR2 ; GR1 = #7FFF, GR2 = #0001 RAM[#4001] = #8000 (#7FFF > #8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4012; // CPA GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = 0x8000;

      r.gr[1] = 0x7fff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      compareArithmetic(r, Device());

      expect(r.pr, 0x3002);
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    }
  );
}

TestCase _testCpaGR1() {
  return (
    'CPA GR1,GR2 ; GR1 = #8000, GR2 = = #7FFF (#8000 < #7FFF)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4412; // CPA GR1,GR2

      r.gr[1] = 0x8000;
      r.gr[2] = 0x7fff;
      r.pr = 0x3000;

      compareArithmeticGR(r, Device());

      expect(r.pr, 0x3001);
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    }
  );
}

TestCase _testCpaGR2() {
  return (
    'CPA GR1,GR2 ; GR1 = #8000, GR2 = #8000 (#8000 = #8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4412; // CPA GR1,GR2

      r.gr[1] = 0x8000;
      r.gr[2] = -32768;
      r.pr = 0x3000;

      compareArithmeticGR(r, Device());

      expect(r.pr, 0x3001);
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    }
  );
}

TestCase _testCpaGR3() {
  return (
    'CPA GR1,GR2 ; GR1 = #7FFF, GR2 = = #8000 (#7FFF > #8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4412; // CPA GR1,GR2

      r.gr[1] = 0x7fff;
      r.gr[2] = 0x8000;
      r.pr = 0x3000;

      compareArithmeticGR(r, Device());

      expect(r.pr, 0x3001);
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    }
  );
}

TestCase _testCpl1() {
  return (
    'CPL GR1,#4000,GR2 ; GR1 = #8000, GR2 = #0001 RAM[#4001] = #7FFF (#8000 > #7FFF)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4112; // CPL GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = 0x7FFF;

      r.gr[1] = 0x8000;
      r.gr[2] = 1;
      r.pr = 0x3000;

      compareLogical(r, Device());

      expect(r.pr, 0x3002);
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    }
  );
}

TestCase _testCpl2() {
  return (
    'CPL GR1,#4000,GR2 ; GR1 = #8000, GR2 = #0001 RAM[#4001] = #8000 (#8000 = #8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4112; // CPL GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = -32768;

      r.gr[1] = 0x8000;
      r.gr[2] = 1;
      r.pr = 0x3000;

      compareLogical(r, Device());

      expect(r.pr, 0x3002);
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    }
  );
}

TestCase _testCpl3() {
  return (
    'CPL GR1,#4000,GR2 ; GR1 = #7FFF, GR2 = #0001 RAM[#4001] = #8000 (#7FFF < #8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4112; // CPL GR1,#4000,GR2
      r.memory[0x3001] = 0x4000;
      r.memory[0x4001] = 0x8000;

      r.gr[1] = 0x7fff;
      r.gr[2] = 1;
      r.pr = 0x3000;

      compareLogical(r, Device());

      expect(r.pr, 0x3002);
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    }
  );
}

TestCase _testCplGR1() {
  return (
    'CPL GR1,GR2 ; GR1 = #8000, GR2 = = #7FFF (#8000 > #7FFF)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4512; // CPL GR1,GR2

      r.gr[1] = 0x8000;
      r.gr[2] = 0x7fff;
      r.pr = 0x3000;

      compareLogicalGR(r, Device());

      expect(r.pr, 0x3001);
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    }
  );
}

TestCase _testCplGR2() {
  return (
    'CPL GR1,GR2 ; GR1 = #8000, GR2 = #8000 (#8000 = #8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4512; // CPL GR1,GR2

      r.gr[1] = 0x8000;
      r.gr[2] = -32768;
      r.pr = 0x3000;

      compareLogicalGR(r, Device());

      expect(r.pr, 0x3001);
      expect(r.of, equals(false));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    }
  );
}

TestCase _testCplGR3() {
  return (
    'CPL GR1,GR2 ; GR1 = #7FFF, GR2 = = #8000 (#7FFF < #8000)',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x4512; // CPL GR1,GR2

      r.gr[1] = 0x7fff;
      r.gr[2] = 0x8000;
      r.pr = 0x3000;

      compareLogicalGR(r, Device());

      expect(r.pr, 0x3001);
      expect(r.of, equals(false));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    }
  );
}
