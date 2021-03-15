import 'dart:html' as html;
import 'dart:convert' as converter;

int counter = 1;
dynamic counterStorage = converter.jsonDecode(html.window.localStorage['counter']);

abstract class Name {
  int id;

  String get name;

  Name() {

    this.id = counter++;
  }

}