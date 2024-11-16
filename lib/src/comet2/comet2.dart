import 'dart:async';
import 'resource.dart' show Resource;
import 'device.dart';
import './instruction.dart';
import 'supervisor_call.dart' show supervisorCall;
import 'package:tiamat/src/casl2/compiler/word.dart' show Real;

export 'device.dart';

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
abstract class Comet2 {
  /// delay milliseconds
  int delay = 0;

  /// computing
  Future<Resource> run([Status]);

  /// load code on compute
  void load(LoadPoint start, List<Real> words);

  factory Comet2(
    Device device, {
    NoticeResource? onUpdate,
    NoticeStatus? onChangeStatus,
  }) =>
      _Comet2(device, onUpdate: onUpdate, onChangeStatus: onChangeStatus);
}

/// implements interface
class _Comet2 implements Comet2 {
  /// I/O Device.
  ///
  /// Need to change when implementing the emulator.
  final Device device;

  NoticeResource? _onUpdate;
  NoticeStatus? _onChangeStatus;

  _Comet2(
    this.device, {
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

  /// Resource.
  Resource resource = Resource();

  Duration _delay = getDuration();

  @override
  int get delay => _delay.inMilliseconds;

  @override
  set delay(final int ms) => _delay = getDuration(ms);

  @override
  void load(final int start, final List<Real> words) {
    resource.memory.setAll(start, words);
    resource.programRegister.value = start;
    resource.stackPointer.value = 0xffff; // reset.
  }

  @override
  Future<Resource> run([final s = Status.running]) async {
    status = s;

    if (status == Status.runningOnce) {
      await _exec();
      if (_isExit) {
        status = Status.exit;
      } else {
        status = Status.pause;
      }
      return resource;
    }

    while (status == Status.running) {
      await Future.delayed(_delay);
      await _exec();
      if (_isExit) {
        status = Status.exit;
        break;
      }
    }
    return resource;
  }

  /// Running instruction.
  Future<void> _exec() async {
    final pr = resource.programRegister;
    final ram = resource.memory;

    final ins = instruction(ram[pr.value]);
    await ins(resource);
    _onUpdate?.call(resource);
  }

  /// is exit
  bool get _isExit => resource.stackPointer.value == 0;

  /// load nad run
  Future<Resource> loadAndRun(LoadPoint start, List<Real> words) async {
    load(start, words);
    await run();
    return resource;
  }
}
