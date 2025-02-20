import 'dart:async';
import './instruction/instruction.dart';
import './resource/resource.dart';

export './resource/resource.dart';

/// [Real] Word of COMET2
typedef Real = int;

/// Memory [Address] of COMET2
typedef Address = Real;

/// Comet2's [Status]
enum Status {
  running, // running Comet2
  runningOnce,
  pause, // pause Comet2
  wait, // wait input, output and etc.
  exit, // exit program,
}

/// comet2 interface
final class Comet2 {
  final Resource resource = Resource();
  Device device = Device();

  Comet2(List<Real> words, [Address start = 0]) {
    resource.memory.setAll(start, words);
  }

  void init(Address pr, [Real sp = 0xffff]) {
    resource.pr = pr;
    resource.sp = sp;
  }

  Iterable<Future<void> Function()> step() sync* {
    final sp = resource.sp;
    resource.push(resource.pr);
    while (sp != resource.sp) {
      final ins = instruction(resource.memory[resource.pr]);
      yield () => ins(resource, device);
    }
  }

  Future<void> run(Address pr) async {
    init(pr);
    for (final ins in step()) {
      await ins();
    }
  }
}
