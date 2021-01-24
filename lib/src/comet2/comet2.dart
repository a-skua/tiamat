import 'resource.dart' show Resource;
import 'device.dart' show Device;
import 'instruction.dart' show instruction;
import 'supervisor_call.dart' show SupervisorCall, supervisorCall;

export 'device.dart';

class Comet2 {
  Device device = Device();

  final Resource resource = Resource();

  Comet2() {
    this.resource.supervisorCall =
        (final int code) => supervisorCall(this.resource, this.device, code);
  }

  void load(final List<int> code) {
    final pr = this.resource.programRegister;
    this.resource.memory.setAll(pr.value, code);
  }

  void exec() {
    final sp = this.resource.stackPointer;
    final pr = this.resource.programRegister;
    final ram = this.resource.memory;

    while (sp.value != 0) {
      final op = (ram[pr.value] >> 8) & 0xff;
      instruction(this.resource, op);
    }
  }

  // @deprecated
  // final sv = this.supervisor;

  // @deprecated
  // void exec(final Resource r) {}
}
