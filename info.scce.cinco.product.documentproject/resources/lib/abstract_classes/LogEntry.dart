import 'package:generated_webapp/src/user.dart';

abstract class LogEntry {
  User user;
  DateTime date;
  Map<String,String> content = Map();

  LogEntry() {

  }

}