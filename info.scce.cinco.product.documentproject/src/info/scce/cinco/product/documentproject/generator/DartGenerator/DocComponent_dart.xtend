package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.documents.documents.Role

class DocComponent_dart {
	protected extension Helper = new Helper
	def generate(Documents doc)'''
	import 'package:angular/angular.dart';
	import 'package:angular_forms/angular_forms.dart';
	import 'package:angular_router/angular_router.dart';
	import 'package:generated_webapp/src/panel/panel_component.dart';
	import 'package:generated_webapp/src/search_document_component/search_document_component.dart';
	import 'package:generated_webapp/src/service/documents_service.dart';
	import 'package:generated_webapp/src/create_document_component/create_document_component.dart';
	import 'package:generated_webapp/src/service/users_service.dart';
	import '../routes_paths.dart';
	import '../routes.dart';
	import '../routes_paths_parent.dart';
	import 'package:generated_webapp/abstract_classes/Document.dart';
	
	import 'dart:html';
	
	@Component(
	  selector :'my-docs',
	  templateUrl : 'doc_component.html',
	  styleUrls : ['doc_component.css'],
	  directives: [coreDirectives, routerDirectives, PanelComponent, CreateDocumentComponent, SearchDocumentComponent, formDirectives],
	  exports: [RoutePaths, Routes],
	)
	
	class DocComponent implements CanActivate, OnActivate, OnInit{
	  @override
	  Future<bool> canActivate(RouterState current, RouterState next) {
	
	    if (_userService.currentUser == null) {
	      _router.navigate(RoutePathsParent.login.toUrl());
	      return Future.value(false);
	    } else {
	      isActivated = true;
	      return Future.value(true);
	    }
	
	  }
	  ControlGroup myPanel;
	  bool isActivated = false;
	  final DocumentService _docservice;
	  final UserService _userService;
	  final Router _router;
	  DocComponent(this._docservice, this._router, this._userService);
	   get docs => _docservice.docs;
	   get docTypes => _docservice.doctypes;
	  String panelUrl(int id) => RoutePaths.panel.toUrl(parameters: {idParam: '$id'});
	
	  @override
	  void onActivate(RouterState previous, RouterState current) {
	    isActivated = true;
	  }
	
	  @override
	  void ngOnInit() {
	    myPanel = FormBuilder.controlGroup({
	      "search" : ["", Validators.compose([Validators.required])],
	    });
	  }
	  
	  bool isEnabled(){
		  «FOR canWrite : doc.allCanWriteElements AFTER 'else { return false; }'»
		  if(_userService.currentUser.role >= "«canWrite.name.toFirstUpper»"){
		  	return true;
		  }
		  «ENDFOR»
		      
		}
	
	  hasPermission(Document doc){
	    if((doc.creator.id == _userService.currentUser.id) || ((_userService.currentUser.role >=  doc.creator.role.name) &&  !(doc.creator.role.name == _userService.currentUser.role.name))){
	      return true;
	    }
	    else{
	      return false;
	    }
	  }
	
	  hasNoPermission(List<Document> docs){
	    var hasPermission = 0;
	    docs.forEach((doc){
	      if((doc.creator.id == _userService.currentUser.id) || ((_userService.currentUser.role >=  doc.creator.role.name) &&  !(doc.creator.role.name == _userService.currentUser.role.name))){
	        hasPermission++;
	      }
	    });
	    if(hasPermission == 0){
	      return true;
	    }else{
	      return false;
	    }
	  }
	
	  //sort fileName
	  void sortAscending(){
	    docs.sort(sorter(1, "fileName"));
	  }
	
	  void sortDescending(){
	    docs.sort(sorter(0, "fileName"));
	  }
	
	}
	//--------SORTING STUFF-------------- // sortOrder = 1 ascending | 0 descending------------------------------------------
	// partially applicable sorter
	Function(Document, Document) sorter(int sortOrder, String property) {
	  int handleSortOrder(int sortOrder, int sort) {
	    if (sortOrder == 1) {
	      // a is before b
	      if (sort == -1) {
	        return -1;
	      } else if (sort > 0) {
	        // a is after b
	        return 1;
	      } else {
	        // a is same as b
	        return 0;
	      }
	    } else {
	      // a is before b
	      if (sort == -1) {
	        return 1;
	      } else if (sort > 0) {
	        // a is after b
	        return 0;
	      } else {
	        // a is same as b
	        return 0;
	      }
	    }
	  }
	
	  // ignore: missing_return
	  return (Document a, Document b) {
	    switch (property) {
	      case "fileName":
	        int sort = a.fileName.compareTo(b.fileName);
	        return handleSortOrder(sortOrder, sort);
	      default:
	        break;
	    }
	  };
	}
	
	'''
	
	def Iterable<Role> allCanWriteElements(Documents documents){
		return documents.roles.filter[!outgoingCreateDocuments.isNullOrEmpty];
	}
}