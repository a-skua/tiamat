import '../util/charcode.dart';

// FIXME
//
// LABEL ADDA GR0,GR1
//       RET
final _expCommonOperand = RegExp(r'(GR[0-7]),?([A-Z0-9#]+)?,?(GR[1-7])?');
final _expADRX = RegExp(r'([A-Z0-9#]+),?(GR[1-7])?');
final _expGR = RegExp(r'^GR([0-7])$');
final _expADR = RegExp(r'^(#?[0-9A-F]+)$');
final _expStr = RegExp('\'([^\']*)\'');

class Token {
  final List<int> _code;
  final String label;
  final String refLabel;
  final int refIndex;

  Token(
    this._code, {
    this.label = '',
    this.refLabel = '',
    this.refIndex = 0,
  });

  int get size => this.code.length;
  bool get hasLabel => this.label.isNotEmpty;
  bool get hasReferenceLabel => this.refLabel.isNotEmpty;
  List<int> get code => this._code;
  void setLabel(final int label) => this._code[this.refIndex] = label;
}

Token ds(final String label, final String operand) {
  if (_expADR.hasMatch(operand)) {
    final adr = operand.replaceFirst('#', '0x');
    return Token(
      List.filled(int.parse(adr), 0),
      label: label,
    );
  }
  return Token(
    [],
    label: label,
  );
}

enum _DCState {
  string,
  decimal,
  hexadecimal,
  label,
  metaChar,
  eof,
}

class _DCToken {
  final List<int> runes;
  final _DCState state;
  _DCToken(this.runes, this.state);
}

Token dc(final String label, final String operand) {
  var state = _DCState.eof;
  var tokens = <_DCToken>[];

  final quote = '\''.runes.first;
  final sharp = '#'.runes.first;
  final comma = ','.runes.first;
  final minus = '-'.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;
  final startHex = 'A'.runes.first;
  final endHex = 'F'.runes.first;
  final startLabel = 'A'.runes.first;
  final endLabel = 'Z'.runes.first;

  for (final c in operand.runes) {
    switch (state) {
      case _DCState.decimal:
        if (c == comma) {
          state = _DCState.eof;
          break;
        }
        if (c >= startNum && c <= endNum) {
          tokens.last.runes.add(c);
        }
        break;
      case _DCState.hexadecimal:
        if (c == comma) {
          state = _DCState.eof;
          break;
        }
        if ((c >= startNum && c <= endNum) || (c >= startHex && c <= endHex)) {
          tokens.last.runes.add(c);
        }
        break;
      case _DCState.label:
        if (c == comma) {
          state = _DCState.eof;
          break;
        }
        if ((c >= startLabel && c <= endLabel) ||
            (c >= startNum && c <= endNum)) {
          tokens.last.runes.add(c);
        }
        break;
      case _DCState.string:
        if (c == quote) {
          state = _DCState.metaChar;
          break;
        }
        tokens.last.runes.add(c);
        break;
      case _DCState.metaChar:
        if (c == quote) {
          state = _DCState.string;
          tokens.last.runes.add(c);
        } else if (c == comma) {
          state = _DCState.eof;
        }
        break;
      case _DCState.eof:
        if (c == quote) {
          state = _DCState.string;
          tokens.add(_DCToken([], state));
          break;
        }
        if (c == sharp) {
          state = _DCState.hexadecimal;
        } else if (c == minus) {
          state = _DCState.decimal;
        } else if (c >= startNum && c <= endNum) {
          state = _DCState.decimal;
        } else if (c >= startLabel && c <= endLabel) {
          state = _DCState.label;
        } else {
          break;
        }
        tokens.add(_DCToken([c], state));
        break;
    }
  }
  final code = <int>[];
  // TODO multi references
  var refL = '';
  var refI = 0;

  for (final t in tokens) {
    switch (t.state) {
      case _DCState.string:
        for (final c in t.runes) {
          code.add(char2code[String.fromCharCode(c)] ?? 0);
        }
        break;
      case _DCState.decimal:
        code.add(int.parse(String.fromCharCodes(t.runes)));
        break;
      case _DCState.hexadecimal:
        code.add(int.parse(
          String.fromCharCodes(t.runes).replaceFirst('#', '0x'),
        ));
        break;
      case _DCState.label:
        // TODO
        refL = String.fromCharCodes(t.runes);
        refI = code.length;
        code.add(0);
        break;
    }
  }

  return Token(
    code,
    label: label,
    refLabel: refL,
    refIndex: refI,
  );
}

Token input(final String label, final String operand) {
  final s = operand.split(',');
  if (s.length != 2) {
    return nop(label);
  }
  final buf = s[0];
  final len = s[1];
  // TODO bug
  if (!_expADR.hasMatch(len)) {
    return nop(label);
  }

  final op = [
    0x7001,
    0,
    0x7002,
    0,
  ];
  var refLabel = '';
  var refIndex = 0;

  if (_expADR.hasMatch(buf)) {
    final adr = buf.replaceFirst('#', '0x');
    op.addAll([0x1210, int.parse(adr)]);
  } else {
    op.addAll([0x1210, 0]);
    refLabel = buf;
    refIndex = 5;
  }

  {
    final adr = len.replaceFirst('#', '0x');
    op.addAll([0x1220, int.parse(adr)]);
  }

  op.addAll([
    0xf000,
    1,
    0x7120,
    0x7110,
  ]);

  return Token(
    op,
    label: label,
    refLabel: refLabel,
    refIndex: refIndex,
  );
}

Token output(final String label, final String operand) {
  final s = operand.split(',');
  if (s.length != 2) {
    return nop(label);
  }
  final buf = s[0];
  final len = s[1];
  // TODO bug
  if (!_expADR.hasMatch(len)) {
    return nop(label);
  }

  final op = [
    0x7001,
    0,
    0x7002,
    0,
  ];
  var refLabel = '';
  var refIndex = 0;

  if (_expADR.hasMatch(buf)) {
    final adr = buf.replaceFirst('#', '0x');
    op.addAll([0x1210, int.parse(adr)]);
  } else {
    op.addAll([0x1210, 0]);
    refLabel = buf;
    refIndex = 5;
  }

  {
    final adr = len.replaceFirst('#', '0x');
    op.addAll([0x1220, int.parse(adr)]);
  }

  op.addAll([
    0xf000,
    2,
    0x7120,
    0x7110,
  ]);

  return Token(
    op,
    label: label,
    refLabel: refLabel,
    refIndex: refIndex,
  );
}

Token rpush(final String label) => Token([
      0x7001,
      0,
      0x7002,
      0,
      0x7003,
      0,
      0x7004,
      0,
      0x7005,
      0,
      0x7006,
      0,
      0x7007,
      0,
    ], label: label);

Token rpop(final String label) => Token([
      0x7170,
      0x7160,
      0x7150,
      0x7140,
      0x7130,
      0x7120,
      0x7110,
    ], label: label);

Token ret(final String label) => Token([0x8100], label: label);

Token nop(final String label) => Token([0], label: label);

Token ld(final String label, final String operand) {
  return _pattern(label, operand, 0x1400, 0x1000);
}

Token lad(final String label, final String operand) {
  final m = _expCommonOperand.firstMatch(operand);
  final r = m?.group(1) ?? '';
  final adr = m?.group(2) ?? '';
  final x = m?.group(3) ?? '';

  var op = 0x1200;
  if (_expGR.hasMatch(r)) {
    final gr = _expGR.firstMatch(r)?.group(1) ?? '0';
    op |= int.parse(gr) << 4;
  }

  if (_expGR.hasMatch(x)) {
    final gr = _expGR.firstMatch(x)?.group(1) ?? '0';
    op |= int.parse(gr);
  }

  if (_expADR.hasMatch(adr)) {
    final a = _expADR.firstMatch(adr)?.group(1) ?? '0';
    return Token([
      op,
      int.parse(a.replaceFirst('#', '0x')),
    ], label: label);
  }
  return Token(
    [op, 0],
    label: label,
    refLabel: adr,
    refIndex: 1,
  );
}

Token st(final String label, final String operand) {
  final m = _expCommonOperand.firstMatch(operand);
  final r = m?.group(1) ?? '';
  final adr = m?.group(2) ?? '';
  final x = m?.group(3) ?? '';

  var op = 0x1100;
  if (_expGR.hasMatch(r)) {
    final gr = _expGR.firstMatch(r)?.group(1) ?? '0';
    op |= int.parse(gr) << 4;
  }

  if (_expGR.hasMatch(x)) {
    final gr = _expGR.firstMatch(x)?.group(1) ?? '0';
    op |= int.parse(gr);
  }

  if (_expADR.hasMatch(adr)) {
    final a = _expADR.firstMatch(adr)?.group(1) ?? '0';
    return Token([
      op,
      int.parse(a.replaceFirst('#', '0x')),
    ], label: label);
  }
  return Token(
    [op, 0],
    label: label,
    refLabel: adr,
    refIndex: 1,
  );
}

Token adda(final String label, final String operand) {
  return _pattern(label, operand, 0x2400, 0x2000);
}

Token addl(final String label, final String operand) {
  return _pattern(label, operand, 0x2600, 0x2200);
}

Token suba(final String label, final String operand) {
  return _pattern(label, operand, 0x2500, 0x2100);
}

Token subl(final String label, final String operand) {
  return _pattern(label, operand, 0x2700, 0x2300);
}

Token and(final String label, final String operand) {
  return _pattern(label, operand, 0x3400, 0x3000);
}

Token or(final String label, final String operand) {
  return _pattern(label, operand, 0x3500, 0x3100);
}

Token xor(final String label, final String operand) {
  return _pattern(label, operand, 0x3600, 0x3200);
}

Token cpa(final String label, final String operand) {
  return _pattern(label, operand, 0x4400, 0x4000);
}

Token cpl(final String label, final String operand) {
  return _pattern(label, operand, 0x4500, 0x4100);
}

Token sla(final String label, final String operand) {
  // TODO
  final t = _pattern(label, operand, 0, 0x5000);
  if (t.size == 1) {
    t.code[0] = 0;
  }
  return t;
}

Token sra(final String label, final String operand) {
  // TODO
  final t = _pattern(label, operand, 0, 0x5100);
  if (t.size == 1) {
    t.code[0] = 0;
  }
  return t;
}

Token sll(final String label, final String operand) {
  // TODO
  final t = _pattern(label, operand, 0, 0x5200);
  if (t.size == 1) {
    t.code[0] = 0;
  }
  return t;
}

Token srl(final String label, final String operand) {
  // TODO
  final t = _pattern(label, operand, 0, 0x5300);
  if (t.size == 1) {
    t.code[0] = 0;
  }
  return t;
}

Token jmi(final String label, final String operand) {
  return _pattern2(label, operand, 0x6100);
}

Token jnz(final String label, final String operand) {
  return _pattern2(label, operand, 0x6200);
}

Token jze(final String label, final String operand) {
  return _pattern2(label, operand, 0x6300);
}

Token jump(final String label, final String operand) {
  return _pattern2(label, operand, 0x6400);
}

Token jpl(final String label, final String operand) {
  return _pattern2(label, operand, 0x6500);
}

Token jov(final String label, final String operand) {
  return _pattern2(label, operand, 0x6600);
}

Token push(final String label, final String operand) {
  return _pattern2(label, operand, 0x7000);
}

Token pop(final String label, final String operand) {
  final r = _expGR.firstMatch(operand)?.group(1) ?? '0';
  final op = 0x7100 | (int.parse(r) << 4);

  return Token([op], label: label);
}

Token call(final String label, final String operand) {
  return _pattern2(label, operand, 0x8000);
}

Token svc(final String label, final String operand) {
  return _pattern2(label, operand, 0xf000);
}

Token _pattern2(final String label, final String operand, final int code) {
  final m = _expADRX.firstMatch(operand);
  final adr = m?.group(1) ?? '';
  final x = m?.group(2) ?? '';

  var op = code;
  if (_expGR.hasMatch(x)) {
    final gr = _expGR.firstMatch(x)?.group(1) ?? '0';
    op |= int.parse(gr);
  }

  if (_expADR.hasMatch(adr)) {
    final a = _expADR.firstMatch(adr)?.group(1) ?? '0';
    return Token([
      op,
      int.parse(a.replaceFirst('#', '0x')),
    ], label: label);
  }
  return Token(
    [op, 0],
    label: label,
    refLabel: adr,
    refIndex: 1,
  );
}

Token _pattern(final String label, final String operand, final int codeR1R2,
    final int codeRAdrX) {
  final m = _expCommonOperand.firstMatch(operand);
  final r1 = m?.group(1) ?? '';
  final r2 = m?.group(2) ?? '';
  final x = m?.group(3) ?? '';

  // CODE r1,r2
  if (_expGR.hasMatch(r1) && _expGR.hasMatch(r2)) {
    var op = codeR1R2;
    {
      final r = _expGR.firstMatch(r1)?.group(1) ?? '0';
      op |= int.parse(r) << 4;
    }

    {
      final r = _expGR.firstMatch(r2)?.group(1) ?? '0';
      op |= int.parse(r);
    }
    return Token([op], label: label);
  }

  // CODE r,adr,x
  if (_expGR.hasMatch(r1)) {
    var op = codeRAdrX;
    {
      final r = _expGR.firstMatch(r1)?.group(1) ?? '0';
      op |= int.parse(r) << 4;
    }

    if (_expGR.hasMatch(x)) {
      final r = _expGR.firstMatch(x)?.group(1) ?? '0';
      op |= int.parse(r);
    }

    if (_expADR.hasMatch(r2)) {
      final adr = _expADR.firstMatch(r2)?.group(1) ?? '0';
      final a = adr.replaceFirst('#', '0x');
      return Token(
        [op, int.parse(a)],
        label: label,
      );
    }
    return Token(
      [op, 0],
      label: label,
      refLabel: r2,
      refIndex: 1,
    );
  }
  return nop(label);
}
