import 'dart:math';

import 'package:tiamat/src/comet2/instruction/supervisor_call.dart' as ins;
import 'package:tiamat/src/comet2/supervisor_call.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:tiamat/src/comet2/comet2.dart';
import 'package:tiamat/src/charcode/charcode.dart';
import 'package:test/test.dart';

void main() {
  group('supervisor call', () {
    test('read', testSupervisorCallRead);
    test('write', testSupervisorCallWrite);
  });
}

void testSupervisorCallWrite() async {
  final rand = Random();
  for (var i = 0; i < 10; i++) {
    var result = '';

    final device = Device(() => Future(() => 'foo'), (input) => result = input);
    final resource = Resource();
    resource.supervisorCall = (code) => supervisorCall(resource, device, code);

    const operand = 0xf000;
    const r = 0;
    const adr = 0;
    const x = 7;
    const op = operand | r << 4 | x;
    final expected = 'hello, test $i';
    const pr = 0x7fff;
    const fr = 8;

    final buf = rand.nextInt(0x4000) | 0x8000;
    final len = expected.length;

    resource.programRegister.value = pr;
    resource.flagRegister.value = fr;
    resource.generalRegisters[1].value = buf;
    resource.generalRegisters[2].value = len;
    resource.generalRegisters[x].value = 2;
    resource.memory[pr] = op;
    resource.memory[pr + 1] = adr;
    {
      final runes = expected.runes.toList();
      for (var i = 0; i < runes.length; i++) {
        resource.memory[buf + i] = runeAsCode(runes[i]) ?? 0;
      }
    }

    await ins.supervisorCall(resource);
    expect(resource.programRegister.value, equals((pr + 2) & 0xffff));
    expect(resource.flagRegister.value, equals(fr & 7));
    expect(result, equals(expected));
  }
}

void testSupervisorCallRead() async {
  final rand = Random();
  const operand = 0xf000;
  const gr0 = 0;
  const gr7 = 7;
  for (var i = 0; i < 10; i++) {
    final value = 'hello, test $i';
    final device = Device(
      () => Future(() => value),
      (_) {},
    );
    final resource = Resource();
    resource.supervisorCall = (code) => supervisorCall(resource, device, code);
    final op = operand | gr0 << 4 | gr7;

    final adr = 0;
    final pr = 0x7fff;
    final fr = 8;

    final buf = rand.nextInt(0x4000) | 0x8000;
    final len = value.length;

    resource.programRegister.value = 0x7fff;
    resource.flagRegister.value = 8;
    resource.generalRegisters[1].value = buf;
    resource.generalRegisters[2].value = len;
    resource.generalRegisters[gr7].value = 1;
    resource.memory[pr] = op;
    resource.memory[pr + 1] = adr;

    await ins.supervisorCall(resource);
    expect(resource.flagRegister.value, equals(fr & 7));
    expect(resource.programRegister.value, equals((pr + 2) & 0xffff));
    final runes = value.runes.toList();
    for (var i = 0; i < len; i++) {
      expect(resource.memory[buf + i], equals(runeAsCode(runes[i])));
    }
  }
}
