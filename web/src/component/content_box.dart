import 'dart:html';

Element contentBox(String name, Element child) {
  return Element.div()
    ..classes.add('content')
    ..nodes = [
      Element.div()
        ..classes.add('content-name')
        ..nodes.add(Text(name.toUpperCase())),
      child,
    ];
}
