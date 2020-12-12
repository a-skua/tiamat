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

  r.setGR(reg, r.memory.getWord(adr));
}

/// LD r1, r2
void _load(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;

  r.setGR(r1, r.getGR(r2));
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
