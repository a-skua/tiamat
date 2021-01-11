import 'dart:html';

const repositoryURL = 'https://github.com/a-skua/tiamat';

Element information(String version) {
  return Element.div()
    ..nodes.addAll([
      Text('$version / '),
      AnchorElement()
        ..target = '_blank'
        ..href = repositoryURL
        ..nodes.add(Text('repository')),
    ]);
}
