// FIXME
//
// LABEL ADDA GR0,GR1
//       RET
final _expLine = RegExp(r'([A-Z0-9]*)[\t ]+([A-Z]{1,8})[\t ]*(\S*)');
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

const char2bin = <String, int>{
  ' ': 0x20,
  '!': 0x21,
  '"': 0x22,
  '#': 0x23,
  '\$': 0x24,
  '%': 0x25,
  '&': 0x26,
  '\'': 0x27,
  '(': 0x28,
  ')': 0x29,
  '*': 0x2a,
  '+': 0x2b,
  ',': 0x2c,
  '-': 0x2d,
  '.': 0x2e,
  '/': 0x2f,
  '0': 0x30,
  '1': 0x31,
  '2': 0x32,
  '3': 0x33,
  '4': 0x34,
  '5': 0x35,
  '6': 0x36,
  '7': 0x37,
  '8': 0x38,
  '9': 0x39,
  ':': 0x3a,
  ';': 0x3b,
  '<': 0x3c,
  '=': 0x3d,
  '>': 0x3e,
  '?': 0x3f,
  '@': 0x40,
  'A': 0x41,
  'B': 0x42,
  'C': 0x43,
  'D': 0x44,
  'E': 0x45,
  'F': 0x46,
  'G': 0x47,
  'H': 0x48,
  'I': 0x49,
  'J': 0x4a,
  'K': 0x4b,
  'L': 0x4c,
  'M': 0x4d,
  'N': 0x4e,
  'O': 0x4f,
  'P': 0x50,
  'Q': 0x51,
  'R': 0x52,
  'S': 0x53,
  'T': 0x54,
  'U': 0x55,
  'V': 0x56,
  'W': 0x57,
  'X': 0x58,
  'Y': 0x59,
  'Z': 0x5a,
  '[': 0x5b,
  '¥': 0x5c,
  ']': 0x5d,
  '^': 0x5e,
  '_': 0x5f,
  '`': 0x60,
  'a': 0x61,
  'b': 0x62,
  'c': 0x63,
  'd': 0x64,
  'e': 0x65,
  'f': 0x66,
  'g': 0x67,
  'h': 0x68,
  'i': 0x69,
  'j': 0x6a,
  'k': 0x6b,
  'l': 0x6c,
  'm': 0x6d,
  'n': 0x6e,
  'o': 0x6f,
  'p': 0x70,
  'q': 0x71,
  'r': 0x72,
  's': 0x73,
  't': 0x74,
  'u': 0x75,
  'v': 0x76,
  'w': 0x77,
  'x': 0x78,
  'y': 0x79,
  'z': 0x7a,
  '{': 0x7b,
  '|': 0x7c,
  '}': 0x7d,
  '~': 0x7e,
};

class Casl2 {
  List<int> compile(final String s) {
    return this.trans(this.parse(s));
  }

  List<Token> parse(final String s) {
    final Map<String, int> l = {};
    final List<Token> t = [];
    var count = 0;

    for (var m in _expLine.allMatches(s)) {
      final label = m.group(1) ?? '';
      final code = m.group(2) ?? '';
      final operand = m.group(3) ?? '';

      var token = this.nop(label);
      // FIXME
      switch (code) {
        case 'START':
          token = this.start(label, operand);
          break;
        case 'END':
          token = this.end();
          break;
        case 'DS':
          token = this.ds(label, operand);
          break;
        case 'DC':
          token = this.dc(label, operand);
          break;
        case 'LD':
          token = this.ld(label, operand);
          break;
        case 'LAD':
          token = this.lad(label, operand);
          break;
        case 'ST':
          token = this.st(label, operand);
          break;
        case 'ADDA':
          token = this.adda(label, operand);
          break;
        case 'ADDL':
          token = this.addl(label, operand);
          break;
        case 'SUBA':
          token = this.suba(label, operand);
          break;
        case 'SUBL':
          token = this.subl(label, operand);
          break;
        case 'CPA':
          token = this.cpa(label, operand);
          break;
        case 'CPL':
          token = this.cpl(label, operand);
          break;
        case 'JMI':
          token = this.jmi(label, operand);
          break;
        case 'JNZ':
          token = this.jnz(label, operand);
          break;
        case 'JZE':
          token = this.jze(label, operand);
          break;
        case 'JUMP':
          token = this.jump(label, operand);
          break;
        case 'JPL':
          token = this.jpl(label, operand);
          break;
        case 'JOV':
          token = this.jov(label, operand);
          break;
        case 'PUSH':
          token = this.push(label, operand);
          break;
        case 'POP':
          token = this.pop(label, operand);
          break;
        case 'CALL':
          token = this.call(label, operand);
          break;
        case 'RET':
          token = this.ret(label);
          break;
        // case 'NOP':
        // default:
        //   token = _nop(label);
      }
      if (token.hasLabel) {
        l[token.label] = count;
      }
      count += token.size;
      t.add(token);
    }

    for (var token in t) {
      if (token.hasReferenceLabel) {
        final label = l[token.refLabel];
        if (label != null) {
          token.setLabel(label);
        }
      }
    }
    return t;
  }

  List<int> trans(final List<Token> tokens) {
    final List<int> c = [];
    for (var t in tokens) {
      if (t.code.isNotEmpty) {
        c.addAll(t.code);
      }
    }
    return c;
  }

  final start = _start;
  final end = _end;
  final ds = _ds;
  final dc = _dc;
  final nop = _nop;
  final ret = _ret;
  final ld = _ld;
  final lad = _lad;
  final st = _st;
  final adda = _adda;
  final addl = _addl;
  final suba = _suba;
  final subl = _subl;
  final cpa = _cpa;
  final cpl = _cpl;
  final jmi = _jmi;
  final jnz = _jnz;
  final jze = _jze;
  final jump = _jump;
  final jpl = _jpl;
  final jov = _jov;
  final push = _push;
  final pop = _pop;
  final call = _call;
}

Token _start(final String label, final String operand) {
  if (_expADR.hasMatch(operand)) {
    final adr = _expADR.firstMatch(operand)?.group(1) ?? '0';
    return Token([
      0x6400,
      int.parse(adr.replaceFirst('#', '0x')),
    ], label: label);
  }
  if (operand.isEmpty) {
    return Token([], label: label);
  }
  return Token(
    [0x6400, 0],
    label: label,
    refLabel: operand,
    refIndex: 1,
  );
  ;
}

Token _end() => Token([]);

Token _ds(final String label, final String operand) {
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

Token _dc(final String label, final String operand) {
  final ops = <int>[];
  // TODO multi references
  var refL = '';
  var refI = 0;

  {
    final o = operand.split(',');
    for (var i = 0; i < o.length; i++) {
      final op = o[i];
      if (_expADR.hasMatch(op)) {
        final a = _expADR.firstMatch(op)?.group(1) ?? '0';
        final adr = a.replaceFirst('#', '0x');
        ops.add(int.parse(adr));
      } else if (_expStr.hasMatch(op)) {
        final str = _expStr.firstMatch(op)?.group(1) ?? '';
        for (var c in str.split('')) {
          ops.add(char2bin[c] ?? 0);
        }
      } else {
        refI = ops.length;
        refL = op;
        ops.add(0);
      }
    }
  }

  return Token(
    ops,
    label: label,
    refLabel: refL,
    refIndex: refI,
  );
}

Token _ret(final String label) => Token([0x8100], label: label);

Token _nop(final String label) => Token([0], label: label);

Token _ld(final String label, final String operand) {
  return _pattern(label, operand, 0x1400, 0x1000);
}

Token _lad(final String label, final String operand) {
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

Token _st(final String label, final String operand) {
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

Token _adda(final String label, final String operand) {
  return _pattern(label, operand, 0x2400, 0x2000);
}

Token _addl(final String label, final String operand) {
  return _pattern(label, operand, 0x2600, 0x2200);
}

Token _suba(final String label, final String operand) {
  return _pattern(label, operand, 0x2500, 0x2100);
}

Token _subl(final String label, final String operand) {
  return _pattern(label, operand, 0x2700, 0x2300);
}

Token _cpa(final String label, final String operand) {
  return _pattern(label, operand, 0x4400, 0x4000);
}

Token _cpl(final String label, final String operand) {
  return _pattern(label, operand, 0x4500, 0x4100);
}

Token _jmi(final String label, final String operand) {
  return _pattern2(label, operand, 0x6100);
}

Token _jnz(final String label, final String operand) {
  return _pattern2(label, operand, 0x6200);
}

Token _jze(final String label, final String operand) {
  return _pattern2(label, operand, 0x6300);
}

Token _jump(final String label, final String operand) {
  return _pattern2(label, operand, 0x6400);
}

Token _jpl(final String label, final String operand) {
  return _pattern2(label, operand, 0x6500);
}

Token _jov(final String label, final String operand) {
  return _pattern2(label, operand, 0x6600);
}

Token _push(final String label, final String operand) {
  return _pattern2(label, operand, 0x7000);
}

Token _pop(final String label, final String operand) {
  final r = _expGR.firstMatch(operand)?.group(1) ?? '0';
  final op = 0x7100 | (int.parse(r) << 4);

  return Token([op], label: label);
}

Token _call(final String label, final String operand) {
  return _pattern2(label, operand, 0x8000);
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
  return _nop(label);
}
