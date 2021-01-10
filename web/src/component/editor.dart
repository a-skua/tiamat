import 'dart:html';

class Editor {
  var _editor = TextAreaElement();

  Editor(final String initCode) {
    this._editor = TextAreaElement()
      ..classes.add('editor')
      ..nodes.add(Text(initCode))
      ..onKeyDown.listen((e) {
        const tabCode = 9;
        if (e.keyCode != tabCode) {
          return;
        }
        e.preventDefault();

        final target = e.target;
        if (target != null && target is TextAreaElement) {
          final position = target.selectionStart ?? 0;
          final value = target.value ?? '';
          final previousText = value.substring(0, position);
          final nextText = value.substring(position);
          target.value = '$previousText\t$nextText';
          target.selectionEnd = position + 1;
        }
      });
  }
  Element render() {
    return this._editor;
  }

  String get value => this._editor.value ?? '';
  void set value(String v) => this._editor.value = v;
}
