package info.scce.cinco.product.documentproject.generator.DataClassGenerator

import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.documents.documents.Role
import java.util.ArrayList

class RoleClasses_Generator {
	
	protected extension Helper = new Helper
	def generate(Documents docs)'''
		import 'package:generated_webapp/abstract_classes/Role.dart';
		
		«FOR role: docs.roles» 
			class «role.escape» extends Role {
				
				«role.escape»() : super(){}
				
			 	@override
			  	get name => "«role.name.toFirstUpper»";
			  
			 	@override
			 	bool operator >=(String role) {
«««			 	obere hierachie
			 	  «IF role.incomingTransitions.isNullOrEmpty»return true;«ENDIF»
«««			 	 untere hierachie
			 	  «IF role.outgoingTransitions.isNullOrEmpty && !role.incomingTransitions.isNullOrEmpty»
				 	  if(role == "«role.name.toFirstUpper»"){
				 	  	return true;
				 	  }else {
				 	  	return false;
				 	  }
			 	  «ENDIF»
«««			 	  mittlere ebene
			 	  «IF (!role.incomingTransitions.isNullOrEmpty && !role.outgoingTransitions.empty)»
				  if(«FOR role1 : getLowerRoles(role) SEPARATOR " || "»role == "«role1.name.toFirstUpper»"«ENDFOR»){
				  	return false;
				  }
				  else{
				  	return true;
				  }
			 	  «ENDIF»
			 	}
			 	
			 	Map toJson(Map cache) {
			 			Map json = new Map<String, dynamic>();
			 			if (cache.containsKey(id)) {
			 				json["id"]=id;
			 			} else {
			 				cache[id] = this;
			 				json["id"] = id;
			 				json["__type"] = "«role.escape»";
			 			}
			 			return json;
			 	}
			 	
			 	«role.escape».fromJson(dynamic json, Map cache) {
			 			id = json['id'];
			 			cache[id] = this;
			 	}
			}
			
		«ENDFOR»
	'''
	
	def getLowerRoles(Role role){
		var ArrayList<Role> lowerRoles = new ArrayList
		lowerRoles = collectLowerRolesRecursive(role, lowerRoles)
		return lowerRoles
	}
	
	def collectLowerRolesRecursive(Role role, ArrayList<Role> lowerRoles) {
		var Role lowerRole = null
		if(!role.outgoingTransitions.isNullOrEmpty){
			for(edge : role.outgoingTransitions){
				lowerRole = edge.targetElement
				lowerRoles.add(lowerRole)
			}
			collectLowerRolesRecursive(lowerRole, lowerRoles)
		}
		return lowerRoles
		
	}
	
}
