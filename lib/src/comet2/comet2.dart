import 'resource.dart' show Resource;
import 'device.dart' show Device;
import 'instruction.dart' show instruction;
import 'supervisor_call.dart' show SupervisorCall, supervisorCall;

/// COMET2 instance.
class Comet2 {
  /// I/O Device.
  ///
  /// Need to change when implementing the emulator.
  Device device = Device();

  /// Resource.
  final Resource resource = Resource();

  Comet2() {
    this.resource.supervisorCall =
        (final int code) => supervisorCall(this.resource, this.device, code);
  }

  /// Load code on memory.
  void load(final List<int> code) {
    final pr = this.resource.programRegister;
    this.resource.memory.setAll(pr.value, code);
  }

  /// Execute.
  void exec() {
    final sp = this.resource.stackPointer;
    final pr = this.resource.programRegister;
    final ram = this.resource.memory;

    while (sp.value != 0) {
      final op = (ram[pr.value] >> 8) & 0xff;
      instruction(this.resource, op);
    }
  }
}
