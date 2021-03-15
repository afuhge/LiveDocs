import 'dart:async';
import 'package:angular/angular.dart';
import 'package:generated_webapp/src/service/notification_service.dart';
import 'package:generated_webapp/src/service/users_service.dart';
import '../user.dart';

@Component(
  selector: 'delete',
  templateUrl: 'delete_modal_component.html',
  directives:[coreDirectives],
)

class DeleteModalComponent{
  @Input()
  User user;

  bool clickYes = false;
  bool showModal = false;
  bool deleted = false;
  final NotificationService _nService;
  final UserService _userService;

  DeleteModalComponent(this._nService, this._userService);

  void delete(dynamic event, User user) async {
    deleted = true;
     _userService.deleteUser(user);
    Notification notification = Notification("Success!", "User deleted.");
    _nService.notify(notification);
    new Timer(new Duration(seconds: 3), () {
      deleted = false;
    });
    showModal=false;
    event.stopPropagation();
  }


}