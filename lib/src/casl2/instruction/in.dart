import '../node/node.dart';
import 'util.dart';

/// A macro of CASL2, named IN.
///
/// ```casl2
/// LABEL   IN      IBUF,LEN
/// ```
/// Expand to:
/// ```casl2
/// LABEL   PUSH    0,GR1
///         PUSH    0,GR2
///         LAD     GR1,IBUF
///         LAD     GR2,LEN
///         SVC     1
///         POP     GR2
///         POP
/// ```
