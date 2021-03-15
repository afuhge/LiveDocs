import 'dart:async';

import 'package:angular/angular.dart';

@Component(
  selector: 'notification',
  template : '''<div style="position:fixed; top: 0; left:0; width:100%; z-index:9999; padding:0px 24px 0px 24px;"><div *ngFor="let notification of notifications" class="alert alert-success alert-dismissible "  style="margin-top:12px; box-shadow: 0px 4px 6px rgba(0,0,0,0.4);">
      <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
<h5><i class="icon fas fa-check"></i>{{notification.title}}</h5>
    {{notification.msg}}
    </div></div>''',
    directives : [coreDirectives]
)

class NotificationComponent{
  List<Notification> notifications = new List();

  final NotificationService _notificationService;
  NotificationComponent(this._notificationService){

    _notificationService.sController.stream.listen((notification){
      if(notifications.indexWhere( (e) => notification.msg == e.msg) == -1){ // element gibts nicht
        notifications.add(notification);
        new Timer(new Duration(seconds: 3), () {
        notifications.remove(notification);
       });
      }


    });

  }
}
class NotificationService{
  StreamController<Notification> sController = new StreamController();
  void notify(Notification msg){
    sController.add(msg);
  }
}


class Notification {
  String title;
  String msg;

  Notification(this.title, this.msg);

}