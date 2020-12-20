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
    final List<int> instructions = [];
    for (var m in this._expLine.allMatches(s)) {
      // final label = m.group(1);
      final code = m.group(2);
      final operand = m.group(3);

      // FIXME
      switch (code) {
        case 'LD':
          instructions.addAll(this.ld(operand));
          break;
        case 'RET':
          instructions.add(0x81 << 8);
          break;
        case 'NOP':
        default:
          instructions.add(0);
      }
    }
    return instructions;
  }

  List<int> ld(final String operand) {
    final m = this._expCommonOperand.firstMatch(operand);
    final r1 = m.group(1);
    final r2 = m.group(2);
    final x = m.group(3);

    if (r1 == null || r2 == null) {
      return [];
    }

    // LD r1,r2
    if (this._expGR.hasMatch(r1) && this._expGR.hasMatch(r2)) {
      var op = 0x14 << 8;
      var r = this._expGR.firstMatch(r1).group(1);
      if (r == null) {
        return [];
      }
      op |= int.parse(r) << 4;

      r = this._expGR.firstMatch(r2).group(1);
      if (r == null) {
        return [];
      }
      op |= int.parse(r);
      return [op];
    }

    // LD r,adr,x
    if (this._expGR.hasMatch(r1)) {
      var op = 0x10 << 8;
      var r = this._expGR.firstMatch(r1).group(1);
      if (r == null) {
        return [];
      }
      op |= int.parse(r) << 4;

      if (x != null && this._expGR.hasMatch(x)) {
        r = this._expGR.firstMatch(x).group(1);
        if (r == null) {
          return [];
        }
        op |= int.parse(r);
      }

      var adr = this._expADR.firstMatch(r2).group(1);
      if (adr == null) {
        return [];
      }
      adr = adr.replaceFirst('#', '0x');
      return [op, int.parse(adr)];
    }
    return [];
  }
}
