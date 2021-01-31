import '../node/node.dart';

import 'parse_pattern.dart';

/// An instruction of CASL2, named LD.
void ld(final Root r, final Tree t) => parsePattern1(0x1000, r, t);
