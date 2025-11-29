import 'dart:js_interop';
import 'dart:typed_data';
import 'package:tiamat/tiamat.dart';

@JS('__dart_bin')
external set result(JSUint16Array value);

@JS('__dart_start')
external set start(int value);

void main(List<String> args) {
  final asm = switch (args) {
    [final asm] => asm,
    _ => throw Exception('Usage: dart build.dart <assembly_code>'),
  };

  final casl2 = Casl2.fromString(asm);

  final (words, labels) = switch (casl2.build()) {
    Ok<(List<Real>, Map<String, Address>), dynamic> ok => ok.unwrap,
    Err err => throw Exception(err.err),
  };

  result = Uint16List.fromList(words).toJS;
  start = labels['MAIN'] ?? 0;
}
