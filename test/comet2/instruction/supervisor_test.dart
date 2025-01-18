import 'package:tiamat/typedef.dart';
import 'package:tiamat/src/comet2/instruction/supervisor.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:tiamat/src/casl2/charcode.dart';
import 'package:test/test.dart';

typedef TestCase = (String, void Function());

final class TestDevice implements Device {
  late final readFn = () {};

  late Future<Result<String, DeviceError>> Function(int) _read;
  late Future<Result<void, DeviceError>> Function(String) _write;

  @override
  Future<Result<String, DeviceError>> read(int len) {
    return _read(len);
  }

  @override
  Future<Result<void, DeviceError>> write(String str) {
    return _write(str);
  }
}

void main() {
  group('SVC', () {
    final tests = [
      _test_svc_read_1(),
      _test_svc_read_2(),
      _test_svc_write_1(),
      _test_svc_write_2(),
    ];
    for (final (description, body) in tests) {
      test(description, body);
    }
  });
}

TestCase _test_svc_read_1() {
  return (
    'SVC 0,GR7 ; GR7 = 1, LEN = 32, INPUT = "Hello, World!"',
    () async {
      final r = Resource();
      r.memory[0x3000] = 0xf007; // SVC 0,GR7
      r.memory[0x3001] = 0;

      r.gr[1] = 100;
      r.gr[2] = 32;
      r.gr[7] = 1;
      r.pr = 0x3000;

      await supervisorCall(
          r,
          TestDevice()
            .._read = (int len) async {
              expect(len, equals(32));
              return Ok('Hello, World!');
            });

      expect(r.pr, equals(0x3002));
      expect(r.memory.sublist(100, 132), equals(() {
        final words = List.filled(32, 0);
        final buf = 'Hello, World!'.reals;
        buf.add(-1);
        words.setAll(0, buf);
        return words;
      }()));
    }
  );
}

TestCase _test_svc_read_2() {
  return (
    'SVC 0,GR7 ; GR7 = 1, LEN = 5, INPUT = "Hello, World!"',
    () async {
      final r = Resource();
      r.memory[0x3000] = 0xf007; // SVC 0,GR7
      r.memory[0x3001] = 0;

      r.gr[1] = 100;
      r.gr[2] = 5;
      r.gr[7] = 1;
      r.pr = 0x3000;

      await supervisorCall(
          r,
          TestDevice()
            .._read = (int len) async {
              expect(len, equals(5));
              return Ok('Hello, World!');
            });

      expect(r.pr, equals(0x3002));
      expect(r.memory.sublist(100, 132), equals(() {
        final words = List.filled(32, 0);
        final buf = 'Hell'.reals;
        buf.add(-1);
        words.setAll(0, buf);
        return words;
      }()));
    }
  );
}

TestCase _test_svc_write_1() {
  return (
    'SVC 1,GR7 ; GR7 = 1, LEN = 32, OUTPUT = "Hello, World!"',
    () async {
      final r = Resource();
      r.memory[0x3000] = 0xf007; // SVC 1,GR7
      r.memory[0x3001] = 1;
      r.memory.setAll(100, () {
        final buf = 'Hello, World!'.reals;
        buf.add(-1);
        return buf;
      }());

      r.gr[1] = 100;
      r.gr[2] = 32;
      r.gr[7] = 1;
      r.pr = 0x3000;

      await supervisorCall(
          r,
          TestDevice()
            .._write = (String str) async {
              expect(str, equals('Hello, World!'));
              return Ok(null);
            });

      expect(r.pr, equals(0x3002));
    }
  );
}

TestCase _test_svc_write_2() {
  return (
    'SVC 1,GR7 ; GR7 = 1, LEN = 32, OUTPUT = "Hell"',
    () async {
      final r = Resource();
      r.memory[0x3000] = 0xf007; // SVC 1,GR7
      r.memory[0x3001] = 1;
      r.memory.setAll(100, () {
        final buf = 'Hello, World!'.reals;
        buf.add(-1);
        return buf;
      }());

      r.gr[1] = 100;
      r.gr[2] = 4;
      r.gr[7] = 1;
      r.pr = 0x3000;

      await supervisorCall(
          r,
          TestDevice()
            .._write = (String str) async {
              expect(str, equals('Hell'));
              return Ok(null);
            });

      expect(r.pr, equals(0x3002));
    }
  );
}
