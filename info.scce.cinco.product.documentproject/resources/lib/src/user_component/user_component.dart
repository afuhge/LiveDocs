import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:generated_webapp/src/add_user_component/add_user_component.dart';
import 'package:generated_webapp/src/dashboard/dashboard_component.dart';
import 'package:generated_webapp/src/delete_modal_component/delete_modal_component.dart';
import 'package:generated_webapp/src/search_document_component/search_document_component.dart';
import 'package:generated_webapp/src/search_user_component/search_user_component.dart';
import 'package:generated_webapp/src/service/notification_service.dart';
import 'package:generated_webapp/src/service/users_service.dart';
import 'package:generated_webapp/src/user.dart';
import 'package:generated_webapp/src/user_data_modal/user_data_component.dart';

import '../routes_paths_parent.dart';
import 'dart:html';

@Component(
  selector :'my-user',
  templateUrl: 'user_component.html',
  styleUrls: ['user_component.css'],
  directives: [coreDirectives, UserDataComponent, DeleteModalComponent,DashboardComponent, routerDirectives, AddUserComponent, formDirectives, SearchUserComponent]
)

class UserComponent implements  OnInit, CanActivate{
  final UserService _userService;
  final NotificationService _notification;
  UserComponent(this._userService, this._notification, this._router){}
  final Router _router;
  List<User> get users => _userService.users;

  ControlGroup searchContent;



  @override
  void ngOnInit() {
    searchContent = FormBuilder.controlGroup({
      "search" : ["", Validators.compose([Validators.required])],
    });
  }

  //sort FirstName
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

  @override
  Future<bool> canActivate(RouterState current, RouterState next) {
    if (_userService.currentUser == null) {
      _router.navigate(RoutePathsParent.login.toUrl());
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
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

