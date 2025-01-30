import 'package:tiamat/src/comet2/instruction/load_store.dart';
import 'package:tiamat/comet2.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

void main() {
  group('LD', () {
    group('r.adr.x', () {
      final tests = [
        _testLaod1(),
        _testLaod2(),
        _testLaod3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });

    group('r1,r2', () {
      final tests = [
        _testLaodGR1(),
        _testLaodGR2(),
        _testLaodGR3(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('ST', () {
    group('r.adr.x', () {
      final tests = [
        _testStore(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });

  group('LAD', () {
    group('r,adr,x', () {
      final tests = [
        _testLoadAddress(),
      ];
      for (final (description, body) in tests) {
        test(description, body);
      }
    });
  });
}

TestCase _testLaod1() {
  return (
    'LG GR1,#8000,GR2(#0001) ; RAM[#8001] = #7FFF',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x1012; // LD GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 0x7fff;

      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      load(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x7fff));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testLaod2() {
  return (
    'LG GR1,#8000,GR2(#0001) ; RAM[#8001] = #0000',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x1012; // LD GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 0x0000;

      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      load(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x0000));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testLaod3() {
  return (
    'LG GR1,#8000,GR2(#0001) ; RAM[#8001] = #8000',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x1012; // LD GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;
      r.memory[0x8001] = 0x8000;

      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      load(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x8000));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testLaodGR1() {
  return (
    'LG GR1,GR2 ; GR2 = #7FFF',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x1412; // LD GR1,GR2

      r.gr[2] = 0x7fff;
      r.pr = 0x3000;

      loadGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0x7fff));
      expect(r.sf, equals(false));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testLaodGR2() {
  return (
    'LG GR1,GR2 ; GR2 = #0000',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x1412; // LD GR1,GR2

      r.gr[2] = 0x0000;
      r.pr = 0x3000;

      loadGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0x0000));
      expect(r.sf, equals(false));
      expect(r.zf, equals(true));
    },
  );
}

TestCase _testLaodGR3() {
  return (
    'LG GR1,GR2 ; GR2 = #8000',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x1412; // LD GR1,GR2

      r.gr[2] = 0x8000;
      r.pr = 0x3000;

      loadGR(r, Device());

      expect(r.pr, equals(0x3001));
      expect(r.gr[1], equals(0x8000));
      expect(r.sf, equals(true));
      expect(r.zf, equals(false));
    },
  );
}

TestCase _testStore() {
  return (
    'ST GR1,#8000,GR2(#0001) ; GR1 = #7FFF',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x1112; // ST GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;

      r.gr[1] = 0x7fff;
      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      store(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.memory[0x8001], equals(0x7fff));
    },
  );
}

TestCase _testLoadAddress() {
  return (
    'LAD GR1,#8000,GR2 ; GR2 = #0001',
    () {
      final r = Resource();
      r.memory[0x3000] = 0x1212; // LAD GR1,#8000,GR2
      r.memory[0x3001] = 0x8000;

      r.gr[2] = 0x0001;
      r.pr = 0x3000;

      loadAddress(r, Device());

      expect(r.pr, equals(0x3002));
      expect(r.gr[1], equals(0x8001));
    },
  );
}
