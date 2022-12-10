import 'dart:async';
import 'resource.dart' show Resource;
import 'device.dart' show Device;
import './instruction.dart';
import 'supervisor_call.dart' show supervisorCall;
import 'package:tiamat/tiamat.dart' show Result;

/// Comet2's [Status]
enum Status {
  running, // running Comet2
  runningOnce,
  pause, // pause Comet2
  wait, // wait input, output and etc.
  exit, // exit program,
}

typedef NoticeResource = void Function(Resource);
typedef NoticeStatus = void Function(Status);

/// make Duration on 0-1000ms.
Duration getDuration([ms = 0]) {
  if (ms < 0) ms = 0;
  if (ms > 1000) ms = 1000;

  return Duration(milliseconds: ms);
}

typedef LoadPoint = int;

/// comet2 interface
abstract class Comet2Interface {
  /// delay milliseconds
  int delay = 0;

  /// computing
  Future<Resource> run([Status]);

  /// load code on compute
  void load(LoadPoint start, Result result);
}

/// implements interface
class Comet2 implements Comet2Interface {
  Comet2({
    NoticeResource? onUpdate,
    NoticeStatus? onChangeStatus,
  }) {
    resource.supervisorCall =
        (final code) => supervisorCall(resource, device, code);
    _onUpdate = onUpdate;
    _onChangeStatus = onChangeStatus;
  }

  /// used [status]
  ///   // ng
  ///   _status = Statsu.wait;
  ///   // ok
  ///   status = Status.wait;
  Status _status = Status.pause;

  /// setter [_status]
  Status get status => _status;

  /// getter [_status]
  set status(final Status s) {
    if (_status != s) {
      _status = s;
      _onChangeStatus?.call(s);
    }
  }

  /// I/O Device.
  ///
  /// Need to change when implementing the emulator.
  Device device = Device();

  NoticeResource? _onUpdate;
  NoticeStatus? _onChangeStatus;

  /// Resource.
  Resource resource = Resource();

  Duration _delay = getDuration();

  @override
  int get delay => _delay.inMilliseconds;

  @override
  set delay(final int ms) => _delay = getDuration(ms);

  @override
  void load(final int start, final Result result) {
    resource.memory.setAll(start, result.code(start));
    resource.programRegister.value = start;
    resource.stackPointer.value = 0xffff; // reset.
  }

  @override
  Future<Resource> run([final s = Status.running]) async {
    status = s;

    if (status == Status.runningOnce) {
      _exec();
      if (_isExit) {
        status = Status.exit;
      } else {
        status = Status.pause;
      }
      return resource;
    }

    while (status == Status.running) {
      await Future.delayed(_delay, _exec);
      if (_isExit) {
        status = Status.exit;
        break;
      }
    }
    return resource;
  }

  /// Running instruction.
  void _exec() {
    final pr = resource.programRegister;
    final ram = resource.memory;

    final ins = instruction(ram[pr.value]);
    ins(resource);
    _onUpdate?.call(resource);
  }

  /// is exit
  bool get _isExit => resource.stackPointer.value == 0;

  /// load nad run
  Future<Resource> loadAndRun(LoadPoint start, Result result) async {
    load(start, result);
    await run();
    return resource;
  }
}
