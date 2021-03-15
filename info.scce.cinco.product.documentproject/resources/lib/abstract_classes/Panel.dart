import 'package:generated_webapp/abstract_classes/Document.dart';
import 'package:generated_webapp/abstract_classes/Name.dart';

import 'Dependency.dart';

abstract class  Panel extends Name{
  Panel next;
  bool isSubmitted = false;
  bool panelOpen = true;
  DateTime submitTime = DateTime.now();
  Document doc;
  String preCondition ="";

  Panel.fromDocument(this.doc) : super(){

  }

  Panel(): super(){

  }

  List<Dependency> dependencies = <Dependency>[];
  Map<String, dynamic> toJson(Map cache);

}

abstract class AbstractPanelComponent {
   get doc;
}