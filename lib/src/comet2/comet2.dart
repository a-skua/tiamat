import 'dart:async';
import 'resource.dart' show Resource;
import 'device.dart' show Device;
import './instruction.dart';
import 'supervisor_call.dart' show supervisorCall;
import 'package:tiamat/tiamat.dart' show Result;

/// Comet2's [Status]
enum Status {
  running, // running Comet2
  pause, // pause Comet2
  wait, // wait input, output and etc.
  exit, // exit program,
}

typedef Notice = void Function(Resource);

class Comet2 {
  Status status = Status.pause;

  /// I/O Device.
  ///
  /// Need to change when implementing the emulator.
  Device device = Device();

  /// Resource.
  Resource resource = Resource();

  Duration _delay = Duration();

  /// set milliseconds
  set delay(final int ms) {
    _delay = Duration(milliseconds: ms);
  }

  Notice? _onUpdate;
  Notice? _onExit;

  Comet2({
    Notice? onUpdate,
    Notice? onExit,
  }) {
    resource.supervisorCall =
        (final code) => supervisorCall(resource, device, code);
    _onUpdate = onUpdate;
    _onExit = onExit;
  }

  void load(final Result result) {
    final start = result.env.startPoint;
    resource.memory.setAll(start, result.code);
    resource.programRegister.value =
        result.start?.position ?? result.env.startPoint;
    resource.stackPointer.value = 0xffff; // reset.
  }

  void run() {
    status = Status.running;
    _exec();
  }

  /// running a opecode.
  Future<void> runOnce() async {
    status = Status.running;
    await _exec();
    if (status == Status.running) {
      status = Status.pause;
    }
  }

  void loadAndRun(final Result result) {
    load(result);
    run();
  }

  Future<void> _exec() {
    return Future(() {
      if (status != Status.running) {
        return;
      }
      if (resource.stackPointer.value == 0) {
        status = Status.exit;
        _onExit?.call(resource);
        return;
      }

      final pr = resource.programRegister;
      final ram = resource.memory;

      final ins = instruction(ram[pr.value]);
      ins(resource);

      // Future(_exec);
      Future.delayed(_delay, _exec);

      _onUpdate?.call(resource);
    });
  }
}
