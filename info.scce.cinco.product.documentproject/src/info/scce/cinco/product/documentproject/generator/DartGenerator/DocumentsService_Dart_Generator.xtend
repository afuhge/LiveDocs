package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.generator.Helper

class DocumentsService_Dart_Generator {
	protected extension Helper = new Helper()
	def generate (Documents docs)'''
		import 'dart:async';
		import 'package:generated_webapp/abstract_classes/Document.dart';
		import 'package:generated_webapp/src/service/users_service.dart';
		import '../user.dart';
		import 'dart:html' as html;
		import 'package:generated_webapp/abstract_classes/Name.dart';
		import 'dart:convert' as converter;
		import '../../document_classes.dart';
		
		class DocumentService {
		
		  final UserService _userService;
		
		  List<User> get users => _userService.users;
		
		  StreamController<int> sController = new StreamController();
		  void notify(int id){
		    sController.add(id);
		  }
		  Future<Document> get(int id) async =>
		      (await getAll()).firstWhere((doc) => doc.id == id, orElse: () => null);
		
		  Future<List<Document>> getAll() async => docs;
		
		 
		List<Document> _docs = <Document>[];
		List<String> _doctypes = <String>[];
		get docs => _docs;
		get doctypes => _doctypes;
		
		DocumentService(this._userService) {
	     «FOR role : docs.roles.filter[!outgoingCreateDocuments.isNullOrEmpty]»
	     if(_userService.currentUser != null && _userService.currentUser?.role >= "«role.name.toFirstUpper»"){
	     	«var edges = role.outgoingCreateDocuments»
	     	«var docNames = edges.map[(targetElement.dependency as Dependency).name]»
	     	«FOR name : docNames.sort»
	     	_doctypes.add("«name.toFirstUpper»");
	     	«ENDFOR»
	     }
	     «ENDFOR»
	     
	       //auslesen aus storage
	      	if (html.window.localStorage['documents'] != null) {
	      	dynamic docsFromStorage = converter.jsonDecode(html.window.localStorage['documents']);
	      	docsFromStorage.forEach((u){
	      		switch (u['__type']){
	      			«generateCases(docs)»
	      		}
	      	});
	      	}
	    }
	   
	       addDocument(Document doc) {
	         docs.add(doc);
	         //reinpacken in storage
	   			persist();
	       }
	   
	     persist(){
	   		Map cache = new  Map();
	   		html.window.localStorage['counter'] = converter.jsonEncode(counter);
	   		html.window.localStorage['documents'] = converter.jsonEncode(docs.map((doc) => doc.toJson(cache)).toList());
	   	}
	}
	
	'''
	
	def generateCases(Documents docs)'''
	«FOR doc : docs.documents»
	case "«doc.escape»" : _docs.add(new «doc.escape».fromJson(u, new Map())); break;
	«ENDFOR»
	'''
	
}
