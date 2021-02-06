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
