
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:generated_webapp/abstract_classes/Document.dart';
import 'package:generated_webapp/src/add_user_component/add_user_component.dart';
import 'package:generated_webapp/src/delete_modal_component/delete_modal_component.dart';
import 'package:generated_webapp/src/service/users_service.dart';
import 'package:generated_webapp/src/user_data_modal/user_data_component.dart';

import '../route_parents.dart';
import '../user.dart';
import 'dart:html';

@Component(
    selector: 'searchUser',
    templateUrl: 'search_user_component.html',
    styleUrls: ['search_user_component.css'],
    directives: [coreDirectives, formDirectives, routerDirectives,UserDataComponent, DeleteModalComponent, AddUserComponent])
class SearchUserComponent {
  @Input()
  List<User> users;

  @Input()
  String input;


  final UserService _userService;
  bool showModal = false;

  String panelUrl(int id) => RoutePaths.panel.toUrl(parameters: {idParam: '$id'});

  SearchUserComponent(this._userService);

    List<User> search(List<User> users, String input){
      List<User> searchResults= <User>[];
      users.forEach((user){
        if(user.firstName.contains(input) || user.lastName.contains(input) || user.email.contains(input) || user.role.toString().contains(input)){
          searchResults.add(user);
        }
      });
      return searchResults;
  }
  void sortAscendingFirstName(){
    users.sort(sorter(1, "firstName"));
  }

  void sortDescendingFirstName(){
    users.sort(sorter(0, "firstName"));
  }


  //sort LastName
  void sortAscendingLastName(){
    users.sort(sorter(1, "lastName"));
  }

  void sortDescendingLastName(){
    users.sort(sorter(0, "lastName"));
  }

  //sort Email
  void sortAscendingEmail(){
    users.sort(sorter(1, "email"));
  }

  void sortDescendingEmail(){
    users.sort(sorter(0, "email"));
  }

  //sort Role
  void sortAscendingRole(){
    users.sort(sorter(1, "role"));
  }

  void sortDescendingRole(){
    users.sort(sorter(0, "role"));
  }

  //--------SORTING STUFF-------------- // sortOrder = 1 ascending | 0 descending------------------------------------------
  // partially applicable sorter
  Function(User, User) sorter(int sortOrder, String property) {
    int handleSortOrder(int sortOrder, int sort) {
      if (sortOrder == 1) {
        // a is before b
        if (sort == -1) {
          return -1;
        } else if (sort > 0) {
          // a is after b
          return 1;
        } else {
          // a is same as b
          return 0;
        }
      } else {
        // a is before b
        if (sort == -1) {
          return 1;
        } else if (sort > 0) {
          // a is after b
          return 0;
        } else {
          // a is same as b
          return 0;
        }
      }
    }

    // ignore: missing_return
    return (User a, User b) {
      switch (property) {
        case "firstName":
          int sort = a.firstName.compareTo(b.firstName);
          return handleSortOrder(sortOrder, sort);
        case "lastName":
          int sort = a.lastName.compareTo(b.lastName);
          return handleSortOrder(sortOrder, sort);
        case "email":
          int sort = a.email.compareTo(b.email);
          return handleSortOrder(sortOrder, sort);
        case "role":
          int sort = a.role.toString().compareTo(b.role.toString());
          return handleSortOrder(sortOrder, sort);
        default:
          break;
      }
    };
  }




}
