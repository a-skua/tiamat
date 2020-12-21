typedef ReplaceLabel = List<int> Function(String label, int addr);

class Token {
  final List<int> code;
  final String label;
  final String refLabel;

  Token(
    this.code, {
    this.label = '',
    this.refLabel = '',
  });

  int get size => this.code.length;
  bool get hasLabel => this.label.isNotEmpty;
  bool get hasReferenceLabel => this.refLabel.isNotEmpty;
}

class Parse {
  // FIXME
  //
  // LABEL ADDA GR0,GR1
  //       RET
  final _expLine = RegExp(r'([A-Z0-9]*)[\t ]+([A-Z]{1,8})[\t ]*([A-Z0-9,#]*)');
  final _expCommonOperand = RegExp(r'(GR[0-7]),?([A-Z0-9#]+)?,?(GR[1-7])?');
  final _expGR = RegExp(r'^GR([0-7])$');
  final _expADR = RegExp(r'^(#?[0-9]+)$');

  List<int> exec(final String s) {
    return this.trans(this.parse(s));
  }

  List<Token> parse(final String s) {
    final List<Token> t = [];

    for (var m in this._expLine.allMatches(s)) {
      final label = m.group(1);
      final code = m.group(2);
      final operand = m.group(3);

      // FIXME
      switch (code) {
        case 'LD':
          t.add(this.ld(label, operand));
          break;
        case 'RET':
          t.add(this.ret(label));
          break;
        case 'NOP':
        default:
          t.add(this.nop(label));
      }
    }
    return t;
  }

  List<int> trans(final List<Token> tokens) {
    final List<int> c = [];
    for (var t in tokens) {
      c.addAll(t.code);
    }
    return c;
  }

  Token ret(final String label) => Token([0x8100], label: label);

  Token nop(final String label) => Token([0], label: label);

  Token ld(final String label, final String operand) {
    final m = this._expCommonOperand.firstMatch(operand);
    final r1 = m.group(1);
    final r2 = m.group(2);
    final x = m.group(3);

    if (r1 == null || r2 == null) {
      return this.nop(label);
    }

    // LD r1,r2
    if (this._expGR.hasMatch(r1) && this._expGR.hasMatch(r2)) {
      var op = 0x14 << 8;
      var r = this._expGR.firstMatch(r1).group(1);
      if (r == null) {
        return this.nop(label);
      }
      op |= int.parse(r) << 4;

      r = this._expGR.firstMatch(r2).group(1);
      if (r == null) {
        return this.nop(label);
      }
      op |= int.parse(r);
      return Token([op], label: label);
    }

    // LD r,adr,x
    if (this._expGR.hasMatch(r1)) {
      var op = 0x10 << 8;
      var r = this._expGR.firstMatch(r1).group(1);
      if (r == null) {
        return this.nop(label);
      }
      op |= int.parse(r) << 4;

      if (x != null && this._expGR.hasMatch(x)) {
        r = this._expGR.firstMatch(x).group(1);
        if (r == null) {
          return this.nop(label);
        }
        op |= int.parse(r);
      }

      if (this._expADR.hasMatch(r2)) {
        var adr = this._expADR.firstMatch(r2).group(1);
        if (adr == null) {
          return this.nop(label);
        }
        adr = adr.replaceFirst('#', '0x');
        return Token([op, int.parse(adr)], label: label);
      }
      return Token(
        [op, 0],
        label: label,
        refLabel: r2,
      );
    }
    return this.nop(label);
  }
}
