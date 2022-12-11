import '../device.dart';
import '../resource.dart';
import 'read.dart';
import 'write.dart';

typedef SupervisorCall = Future<void> Function(int code);

Future<void> supervisorCall(
    final Resource r, final Device d, final int code) async {
  switch (code) {
    case 1:
      await read(r, d);
      return;
    case 2:
      await write(r, d);
      return;
  }
}
