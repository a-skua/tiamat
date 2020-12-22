// FIXME
//
// LABEL ADDA GR0,GR1
//       RET
final _expLine = RegExp(r'([A-Z0-9]*)[\t ]+([A-Z]{1,8})[\t ]*([A-Z0-9,#]*)');
final _expCommonOperand = RegExp(r'(GR[0-7]),?([A-Z0-9#]+)?,?(GR[1-7])?');
final _expGR = RegExp(r'^GR([0-7])$');
final _expADR = RegExp(r'^(#?[0-9]+)$');

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

class Parser {
  List<int> exec(final String s) {
    return this.trans(this.parse(s));
  }

  List<Token> parse(final String s) {
    final Map<String, int> l = {};
    final List<Token> t = [];
    var count = 0;

    for (var m in _expLine.allMatches(s)) {
      final label = m.group(1);
      final code = m.group(2);
      final operand = m.group(3);

      var token = _nop(label);
      // FIXME
      switch (code) {
        case 'START':
          token = this.start(label, operand);
          break;
        case 'END':
          token = this.end();
          break;
        case 'LD':
          token = this.ld(label, operand);
          break;
        case 'LAD':
          token = this.lad(label, operand);
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
  final nop = _nop;
  final ret = _ret;
  final ld = _ld;
  final lad = _lad;
}

Token _start(final String label, final String operand) {
  if (_expADR.hasMatch(operand)) {
    var adr = _expADR.firstMatch(operand).group(1);
    if (adr == null) {
      return _nop(label);
    }
    adr = adr.replaceFirst('#', '0x');
    return Token([0x6400, int.parse(adr)], label: label);
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

Token _ret(final String label) => Token([0x8100], label: label);

Token _nop(final String label) => Token([0], label: label);

Token _ld(final String label, final String operand) {
  final m = _expCommonOperand.firstMatch(operand);
  final r1 = m.group(1);
  final r2 = m.group(2);
  final x = m.group(3);

  if (r1 == null || r2 == null) {
    return _nop(label);
  }

  // LD r1,r2
  if (_expGR.hasMatch(r1) && _expGR.hasMatch(r2)) {
    var op = 0x14 << 8;
    var r = _expGR.firstMatch(r1).group(1);
    if (r == null) {
      return _nop(label);
    }
    op |= int.parse(r) << 4;

    r = _expGR.firstMatch(r2).group(1);
    if (r == null) {
      return _nop(label);
    }
    op |= int.parse(r);
    return Token([op], label: label);
  }

  // LD r,adr,x
  if (_expGR.hasMatch(r1)) {
    var op = 0x10 << 8;
    var r = _expGR.firstMatch(r1).group(1);
    if (r == null) {
      return _nop(label);
    }
    op |= int.parse(r) << 4;

    if (x != null && _expGR.hasMatch(x)) {
      r = _expGR.firstMatch(x).group(1);
      if (r == null) {
        return _nop(label);
      }
      op |= int.parse(r);
    }

    if (_expADR.hasMatch(r2)) {
      var adr = _expADR.firstMatch(r2).group(1);
      if (adr == null) {
        return _nop(label);
      }
      adr = adr.replaceFirst('#', '0x');
      return Token([op, int.parse(adr)], label: label);
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

Token _lad(final String label, final String operand) {
  final m = _expCommonOperand.firstMatch(operand);
  final r = m.group(1);
  final adr = m.group(2);
  final x = m.group(3);

  if (r == null || adr == null) {
    return _nop(label);
  }

  var op = 0x1200;
  if (_expGR.hasMatch(r)) {
    final gr = _expGR.firstMatch(r).group(1);
    if (gr == null) {
      return _nop(label);
    }
    op |= int.parse(gr) << 4;
  }

  if (x != null && _expGR.hasMatch(x)) {
    final gr = _expGR.firstMatch(x).group(1);
    if (gr == null) {
      return _nop(label);
    }
    op |= int.parse(gr);
  }

  if (_expADR.hasMatch(adr)) {
    var a = _expADR.firstMatch(adr).group(1);
    if (a == null) {
      return _nop(label);
    }
    a = a.replaceFirst('#', '0x');
    return Token([op, int.parse(a)], label: label);
  }
  return Token(
    [op, 0],
    label: label,
    refLabel: adr,
    refIndex: 1,
  );
}
