package info.scce.cinco.product.documentproject.generator.DataClassGenerator

import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.documents.documents.Document
import java.util.ArrayList
import java.util.stream.Collectors
import java.util.List
import graphmodel.IdentifiableElement

/**
 * Generates a Document class for each document in the Documents model.
*/
class DocumentClasses_Generator {
	
	protected extension Helper = new Helper
	
	def generate (Documents docs)'''
		import 'package:generated_webapp/abstract_classes/Document.dart';
		import 'dependency_classes.dart';
		import 'package:generated_webapp/src/user.dart';
		
		«FOR doc: docs.documents»
		
		 class «doc.escape» extends Document {
		 				 @override
		 				 String get name => "«(doc.dependency as Dependency).name.toFirstUpper»";
		 				 
		 				 «doc.escape»(){
		 				 	«IF (doc.dependency as Dependency).constraintss.isNullOrEmpty»
		 				 	 isSat = true;
		 				 	«ENDIF»
		 				 	 startDependency = «(doc.dependency as Dependency).escape»(this);
		 				 }
		 				 
		 				 «generateToJson(doc)»
		 				 
		 				 «generateFromJson(doc)»
		 			}
		
		
			
		«ENDFOR»
		
	'''
	
	
	
	
	def generateFromJson(Document doc)'''
	«doc.escape».fromJson(dynamic json, Map cache){
		id = json['id'];
		cache[id] = this;
		if(json.containsKey('creator') && json['creator'] != null){
			if(cache.containsKey(json['creator']['id'])){
				creator = cache[json['creator']['id']];
			}else{
				creator = json['creator'] == null ? null : User.fromJson(json['creator'],cache);
			}
		}
		if(json.containsKey('creationDate') && json['creationDate'] != null) {
			creationDate = DateTime.parse(json['creationDate']);
		}
	 	isOpen = json['isOpen'];
	 	valid = json['valid'];
	 	isSat = json['isSat'];
	 	mc_msg = json['mc_msg'];
	 	validMsg = json['validMsg'];
	 	fileName = json['fileName'];
	 	if(json.containsKey('startDependency') && json['startDependency'] != null){
	 		if(cache.containsKey(json['startDependency']['id'])){
	 			startDependency = cache[json['startDependency']['id']];
	 		}else{
	 			startDependency = «(doc.dependency as Dependency).escape».fromJson(json['startDependency'], cache);
	 		}
		}
	}
	'''
	
		
	
	def generateToJson(Document doc)'''
	Map<String, dynamic> toJson(Map cache)  {
		Map json = new Map<String, dynamic>();
		if (cache.containsKey(id)) {
		 	json["id"]=id;
		} else {
			cache[id] = this;
			json["id"] = id;
			json["__type"] ="«doc.escape»";
			json["creator"] = creator?.toJson(cache);
			json["creationDate"] = creationDate?.toIso8601String();
			json["isOpen"] = isOpen;
			json["valid"] = valid;
			json["isSat"] = isSat;
			json["mc_msg"] = mc_msg;
			json["validMsg"] = validMsg;
			json["fileName"]= fileName;
			json["startDependency"] = startDependency.toJson(cache);
		}
		return json;
	}
	'''
	
	
	
	
}
