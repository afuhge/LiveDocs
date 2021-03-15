// wurzelknoten start aller documente
import 'Dependency.dart';
import 'Name.dart';
import 'package:generated_webapp/src/user.dart';

abstract class Document extends Name {
  Dependency startDependency;
  User creator;
  DateTime creationDate;
  bool isOpen;
  String fileName;
  bool valid = false;
  String validMsg = "";
  bool isSat = false;
  String mc_msg = "";

  Document( ): super() {

  }

  Map<String, dynamic> toJson(Map cache);


}