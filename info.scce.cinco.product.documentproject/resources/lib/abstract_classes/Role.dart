import 'Name.dart';

abstract class Role extends Name {
      Role(): super(){

      }
      
      bool operator >=(String role);
      Map toJson(Map cache);
}