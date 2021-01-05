import 'dart:html';

import './src/app.dart';

void main() {
  final appElement = querySelector('#app');
  if (appElement != null) {
    appElement.nodes.add(app());
  }
}
