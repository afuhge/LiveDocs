package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.documents.documents.Role
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.List

class UserService_Dart_Generator {
	protected extension Helper = new Helper
	def generate (List<Role> roles)'''
		import 'package:angular_forms/angular_forms.dart';
		import '../user.dart';
		import 'dart:html' as html;
		import 'dart:convert' as converter;
		import 'package:generated_webapp/abstract_classes/Name.dart';
		import '../../role_classes.dart';
		
		class UserService {
		  List<User> _users = <User>[];
		  List<String> _roles = <String> [«FOR role : roles SEPARATOR ", "»"«role.name»"  «ENDFOR»];
		  get users => _users;
		  get roles => _roles;
		  User currentUser;
		
			UserService(){
			       Map cache = new Map();
			    if (html.window.localStorage['users'] != null) {
			      dynamic usersFromStorage = converter.jsonDecode(html.window.localStorage['users']);
			      usersFromStorage.forEach((u){
			        users.add(User.fromJson(u,cache));
			      });
			     } else {
			    	_users.addAll([
			    	«FOR role : roles SEPARATOR ","»
			    	User("«role.name.toFirstLower.replace(" ", "")»", "«role.name.toFirstLower.replace(" ","")»", "«role.name.toFirstLower.replace(" ", "")»", "pwd", «role.escape»())
			    	«ENDFOR»
			    	]);
			    	_persistUsers();
			    }
			    if(html.window.localStorage['currentUser']!= null){
			    	dynamic currentUserFromStorage = converter.jsonDecode(html.window.localStorage['currentUser']);
			    	if(cache.containsKey(currentUserFromStorage['id'])){
			    		currentUser = cache[currentUserFromStorage['id']];
			    	}else {
			    		currentUser = currentUser =
			    		currentUserFromStorage == null ? null : User.fromJson(
			    		currentUserFromStorage, cache);
			    	}
			    }
			  }
			  
			  persist(){
			  	Map cache = new  Map();
			  	html.window.localStorage['currentUser'] = converter.jsonEncode(currentUser?.toJson(cache));
			  	html.window.localStorage['counter'] = converter.jsonEncode(counter);
			  	_persistUsers();
			  }
			  
			 _persistUsers() {
			 	Map cache = new  Map();
			 	html.window.localStorage['users'] = converter.jsonEncode(_users.map((user) => user.toJson(cache)).toList());
			  }
			
			  addUser(User user){
			    _users.add(user);
			  //reinpacken
			  	persist();
			  }
			
			  deleteUser(User user){
			    _users.remove(user);
			    persist();
			  }
			
			  editUser(User user, ControlGroup userdata){
			    user.firstName = userdata.controls['firstName'].value;
			    user.lastName = userdata.controls['lastName'].value;
			    user.password = userdata.controls['password'].value;
			    user.email = userdata.controls['email'].value;
			    user.role = getRole(userdata.controls['role'].value);
			    persist();
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
