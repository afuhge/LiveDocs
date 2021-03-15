import 'package:generated_webapp/abstract_classes/Document.dart';
import 'package:generated_webapp/abstract_classes/Name.dart';

import 'Panel.dart';

abstract class Dependency extends Name {
  Panel start;
  Document doc;

  Dependency.fromDocument(this.doc) :super(){
  }

  Dependency():super(){

  }
  
  Map toJson(Map cache);


}