import 'resource.dart';

class Instruction {
  final noOperation = _noOperation;
  final loadMemory = _loadMemory;
  final store = _store;
  final loadAddress = _loadAddress;
  final load = _load;
}

/// NOP
void _noOperation(final Resource r) {
  r.PR += 1;
}

/// LD r, adr, x
void _loadMemory(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final reg = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  final data = r.memory.getWord(adr);
  var flag = 0;
  if (data == 0) {
    flag |= zeroFlag;
  }
  if ((data & (1 << 15)) > 0) {
    flag |= signFlag;
  }
  r.setGR(reg, data);
  r.FR = flag;
}

/// LD r1, r2
void _load(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;

  final data = r.getGR(r2);
  var flag = 0;
  if (data == 0) {
    flag |= zeroFlag;
  }
  if ((data & (1 << 15)) > 0) {
    flag |= signFlag;
  }
  r.setGR(r1, data);
  r.FR = flag;
}

/// ST r, adr, x
void _store(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final reg = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  r.memory.setWord(adr, r.getGR(reg));
}

/// LAD r, adr, x
void _loadAddress(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final reg = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  r.setGR(reg, adr);
}

/// ADDA r, adr, x
// void _addArithmeticMemory(final Resource r) {
//   final cache = r.memory.getWord(r.PR);
//   r.PR += 1;
//
//   final x = cache & 0xf;
//   final reg = (cache >> 4) & 0xf;
//   final adr =
//       x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
//   r.PR += 1;
//
//   final result = r.getGR(reg) + r.memory.getWord(adr);
//   r.setGR(reg, result);
// }

/// ADDA r1, r2
// void _addArithmetic(final Resource r) {
//   final cache = r.memory.getWord(r.PR);
//   r.PR += 1;
//
//   final r2 = cache & 0xf;
//   final r1 = (cache >> 4) & 0xf;
//
//   final result = r.getGR(r1) + r.getGR(r2);
//   r.setGR(r1, result);
// }

/// SUBA r, adr, x
// void _subtractArithmeticMemory(final Resource r) {
//   final cache = r.memory.getWord(r.PR);
//   r.PR += 1;
//
//   final x = cache & 0xf;
//   final reg = (cache >> 4) & 0xf;
//   final adr =
//       x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
//   r.PR += 1;
//   fial result = r.getGR(reg) - r.memory.getWord(adr);
//   r.setGR(reg, result);
// }
