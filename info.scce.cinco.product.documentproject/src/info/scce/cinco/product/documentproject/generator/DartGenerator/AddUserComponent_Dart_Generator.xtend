package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.documents.documents.Role
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.List

class AddUserComponent_Dart_Generator {
	protected extension Helper = new Helper
	
	def generate (List<Role> roles)'''
	import 'dart:async';
	
	import 'package:angular/angular.dart';
	import 'package:angular_forms/angular_forms.dart';
	import 'package:generated_webapp/src/service/notification_service.dart';
	import 'package:generated_webapp/src/service/users_service.dart';
	import '../../role_classes.dart';
	import '../user.dart';
	
	
	@Component(
	    selector: 'add-user',
	    templateUrl: 'add_user_component.html',
	    styleUrls: ['add_user_component.css'],
	    directives: [coreDirectives, formDirectives]
	)
	class AddUserComponent implements OnInit{
	  bool showModal = false;
	  ControlGroup userdata;
	  bool submitted = false;
	  final NotificationService _nService;
	  final UserService _userService;
	  List<User> get users => _userService.users;
	  List<String> get roles => _userService.roles;
	
	  AddUserComponent(this._nService, this._userService){}
	  @override
	  void ngOnInit() {
	    submitted = false;
	    userdata = FormBuilder.controlGroup({
	      'firstName': ['', Validators.compose([Validators.required, Validators.nullValidator])],
	      'lastName': ['', Validators.compose([Validators.required, Validators.nullValidator])],
	      'password' :['',Validators.compose([Validators.required, Validators.minLength(5)])],
	      'email' :['', Validators.compose([Validators.required, Validators.pattern("^[a-zA-Z0-9.!#\$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\$")])],
	      'role' : [roles.first, Validators.compose([Validators.required])],
	    });
	  }
	
	
	  void close(){
	    showModal=false;
	    userdata.reset();
	  }
	
	  void submit(dynamic event, ControlGroup userdata) async{
	    submitted = true;
	    User newUser = User(userdata.controls['firstName'].value, userdata.controls['lastName'].value, userdata.controls['email'].value, userdata.controls['password'].value, getRole(userdata.controls['role'].value));
	    _userService.addUser(newUser);
	    Notification notification = Notification("Success!", "User added.");
	    _nService.notify(notification);
	    new Timer(new Duration(seconds: 3), () {
	      submitted = false;
	    });
	    showModal=false;
	    userdata.reset();
	    event.stopPropagation();
	  }
	  
	  getRole(value) {
	  «FOR role : roles»
	 	if(value == "«role.name.toFirstUpper»"){
	  	  return «role.escape»();
	  	}
	  «ENDFOR»
	  }
	
	
	}
	'''
}