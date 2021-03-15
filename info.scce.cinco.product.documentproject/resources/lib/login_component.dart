import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:generated_webapp/src/route_parents.dart';
import 'package:generated_webapp/src/routes_paths_parent.dart';
import 'dart:html';

import 'package:generated_webapp/src/service/users_service.dart';
import 'package:generated_webapp/src/user.dart';

@Component(
  selector: 'login',
  templateUrl: 'login_component.html',
  directives: [coreDirectives, routerDirectives,formDirectives ],
  exports: [RoutePathsParent, RoutesParent],
  providers : []
)


class LoginComponent implements OnInit, OnDeactivate, CanActivate{
  final Router _router;
  ControlGroup userdata;
  bool correctLogin = true;
  final UserService _userService;

  @override
  void ngOnInit() {
    querySelector('body').classes.add('login-page');

    userdata = FormBuilder.controlGroup({
      'email': ['', Validators.compose([Validators.required])],
      'password' :['',Validators.compose([Validators.required])],
    });
  }


  @override
  Future<bool> canActivate(RouterState current, RouterState next) {
    if (_userService.currentUser != null) {
      _router.navigate(RoutePathsParent.pagecontent.toUrl());
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  LoginComponent(this._userService, this._router){}

  signIn(dynamic event, ControlGroup userdata){
      var email = userdata.controls['email'].value;
      var pwd = userdata.controls['password'].value;
      bool correctPwd = false;
      bool correctEmail = false;
     for(var i =0; i< _userService.users.length; i++){
       if(_userService.users.elementAt(i).email == email){
         correctEmail = true;
       }
       if(_userService.users.elementAt(i).password == pwd){
         correctPwd = true;
       }
     }

     if(correctPwd && correctEmail){
       correctLogin = true;
       _userService.currentUser = getLoggedInUser(_userService.users, email);
       _userService.persist();
       //redirect auf x
       _router.navigate(RoutePathsParent.pagecontent.toUrl());
     }else{
       correctLogin = false;
       _router.navigate(RoutePathsParent.login.toUrl());
     }
  }



  User getLoggedInUser(List<User> users , String email){
    var user = null;
    for(var i =0; i< users.length; i++){
      if(users.elementAt(i).email == email){
        user = users.elementAt(i);
      }
    }
    return user;
  }

  @override
  void onDeactivate(RouterState current, RouterState next) {
    querySelector('body').classes.remove('login-page');
  }


}