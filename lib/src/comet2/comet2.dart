import 'resource.dart' show Resource;
import 'device.dart' show Device;
import 'instruction.dart' show instruction;
import 'supervisor_call.dart' show SupervisorCall, supervisorCall;

/// COMET2 instance.
class Comet2 {
  /// [_entryPoint]: program entry point
  int _entryPoint = 0;

  /// [_startPoint]: program start point
  int _startPoint = 0;

  /// I/O Device.
  ///
  /// Need to change when implementing the emulator.
  Device device = Device();

  /// Resource.
  final Resource resource = Resource();

  /// COMET2 is active
  bool _isActive = true;

  Comet2() {
    this.resource.supervisorCall =
        (final int code) => supervisorCall(this.resource, this.device, code);
  }

  /// init environment
  void init({
    required final int entry,
    required final int start,
  }) {
    _entryPoint = entry;
    _startPoint = start;
  }

  /// Load code on memory.
  void load(final List<int> code) {
    final pr = this.resource.programRegister;
    this.resource.memory.setAll(_startPoint, code);
  }

  /// To stop COMET2.
  void stop() {
    this._isActive = false;
  }

  /// Execute.
  void exec() {
    final sp = this.resource.stackPointer;
    final pr = this.resource.programRegister;
    final ram = this.resource.memory;

    this._isActive = true;

    pr.value = _entryPoint;
    while (this._isActive && sp.value != 0) {
      final op = (ram[pr.value] >> 8) & 0xff;
      instruction(this.resource, op);
    }
  }
}
