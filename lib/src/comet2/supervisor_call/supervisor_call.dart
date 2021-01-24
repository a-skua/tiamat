import '../device.dart';
import '../resource.dart';
import 'read.dart';
import 'write.dart';

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
