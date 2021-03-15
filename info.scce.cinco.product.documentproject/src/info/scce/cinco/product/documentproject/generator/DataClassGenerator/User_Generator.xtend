package info.scce.cinco.product.documentproject.generator.DataClassGenerator

import info.scce.cinco.product.documentproject.documents.documents.Role
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.List

class User_Generator {
	protected extension Helper = new Helper
	
	def generate(List<Role> roles)'''
	import 'package:generated_webapp/abstract_classes/Name.dart';
	import 'package:generated_webapp/abstract_classes/Role.dart';
	import 'package:generated_webapp/role_classes.dart';
	
	class User extends Name{
	  String firstName, lastName, password, email;
	  Role role;
	  User(this.firstName, this.lastName, this.email,this.password, this.role);
	  
	  User.fromJson(dynamic json, Map cache){
	    id = json['id'];
	    cache[id] = this;
	      firstName = json['firstName'];
	      lastName = json['lastName'];
	      email = json['email'];
	      password = json['password'];
	      if (json.containsKey('role') && json['role'] != null) {
	        if (cache.containsKey(json['role']['id'])) {
	          role = cache[json['role']['id']];
	        } else {
	          switch (json['role']['__type']) {
	          	«FOR role : roles»
	          	case "«role.escape»" : 
	          	         role = «role.escape».fromJson(json['role'], cache); break;
	          	«ENDFOR»
	          }
	        }
	      }
	  }
	
	
	 Map<String, dynamic> toJson(Map cache) {
	     Map json = new Map<String, dynamic>();
	     if (cache.containsKey(id)) {
	       json["id"] = id;
	     } else {
	       cache[id] = this;
	      json.addAll(<String, dynamic>{
	         "id": id,
	         "firstName": firstName,
	         "lastName": lastName,
	         "email": email,
	         "password": password,
	         "role": role == null ? null : role.toJson(cache),
	       });
	     };
	     return json;
	   }
	
	  @override
	  String get name => null;
	
	
	}
	'''
}