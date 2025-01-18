import 'package:tiamat/casl2.dart' show Real, Address;
import 'dart:async';
import './instruction.dart';
import './resource.dart';

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

  void init(Address start, [Real sp = 0xffff]) {
    resource.pr = start;
    resource.sp = sp;
  }

  Iterable<Future<void> Function()> step() sync* {
    final sp = resource.sp;
    resource.sp -= 1;
    while (sp != resource.sp) {
      final ins = instruction(resource.memory[resource.pr]);
      yield () => ins(resource, device);
    }
  }

  Future<void> run(Address start) async {
    init(start);
    for (final ins in step()) {
      await ins();
    }
  }
}
