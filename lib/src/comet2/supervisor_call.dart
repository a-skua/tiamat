import 'device.dart';
import 'resource.dart';
import 'supervisor_call/read.dart';
import 'supervisor_call/write.dart';

typedef SupervisorCall = void Function(int code);

void supervisorCall(final Resource r, final Device d, final int code) {
  switch (code) {
    case 1:
      read(r, d);
      break;
    case 2:
      write(r, d);
      break;
  }
}

@deprecated
class Supervisor {
  Read read = () => '';
  Write write = (s) {
    print(s);
  };

  void call(final Resource r, final int code) {}
}

@deprecated
const eof = 0xffff;
@deprecated
typedef Read = String Function();
@deprecated
typedef Write = void Function(String s);
