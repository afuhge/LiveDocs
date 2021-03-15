import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:generated_webapp/src/service/notification_service.dart';
import 'package:generated_webapp/src/service/users_service.dart';

import '../user.dart';

@Component(
    selector: 'my-user-data',
    templateUrl: 'user_data_component.html',
    styleUrls: ['user_data_component.css'],
    directives: [coreDirectives, formDirectives])
class UserDataComponent implements OnInit {
  @Input()
  User user;

  ControlGroup userdata;
  bool submitted = false;
  bool showModal = false;
  final NotificationService _nService;
  final UserService _userService;
   List<String> get roles => _userService.roles;

  UserDataComponent(this._nService, this._userService) {}

  @override
  void ngOnInit() {
    userdata = FormBuilder.controlGroup({
      'firstName': [
        user.firstName,
        Validators.compose([Validators.required, Validators.nullValidator])
      ],
      'lastName': [
        user.lastName,
        Validators.compose([Validators.required, Validators.nullValidator])
      ],
      'password': [
        user.password,
        Validators.compose([Validators.required, Validators.minLength(5)])
      ],
      'email': [
        user.email,
        Validators.compose([
          Validators.required,
          Validators.pattern(
              "^[a-zA-Z0-9.!#\$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\$")
        ])
      ],
       'role' : [roles.first, Validators.compose([Validators.required])],
    });
  }

  Future<void> delete(User user) async {
    await _userService.users.remove(user);
  }

  submit(dynamic event, ControlGroup userdata) async {
    submitted = true;
   _userService.editUser(user, userdata);
   Notification notification = Notification("Success!", "User edited.");
    _nService.notify(notification);
    new Timer(new Duration(seconds: 3), () {
      submitted = false;
    });
    showModal = false;
    event.stopPropagation();
  }

}
