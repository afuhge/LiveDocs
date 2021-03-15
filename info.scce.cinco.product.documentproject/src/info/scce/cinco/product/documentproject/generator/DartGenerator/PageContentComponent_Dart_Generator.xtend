package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.documents.documents.Role
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.List

class PageContentComponent_Dart_Generator {
	protected extension Helper = new Helper
	def generate (List<Role> roles)'''
	import 'package:angular/angular.dart';
	import 'dart:html';
	import 'package:generated_webapp/src/dashboard/dashboard_component.dart';
	import 'package:generated_webapp/src/document_tree_component/document_tree_component.dart';
	import 'package:generated_webapp/src/route_parents.dart';
	import 'package:generated_webapp/src/routes_paths_parent.dart';
	import 'package:generated_webapp/src/service/documents_service.dart';
		import 'package:generated_webapp/src/service/xmlvalidation_service.dart';
	import 'package:generated_webapp/src/service/notification_service.dart';
	import 'package:generated_webapp/src/service/users_service.dart';
	import 'package:generated_webapp/src/user_component/user_component.dart';
	import 'package:angular_router/angular_router.dart';
	import 'src/routes.dart';
	import 'package:generated_webapp/abstract_classes/Document.dart';
	import 'package:generated_webapp/src/service/modelchecking_service.dart';
	
	@Component(
	    selector: 'content',
	    templateUrl: 'pagecontent_component.html',
	    styleUrls: ['pagecontent_component.css'],
	    directives: [coreDirectives,UserComponent, routerDirectives, DashboardComponent, NotificationComponent, DocumentTreeComponent],
	    exports: [RoutePaths, Routes, RoutePathsParent, RoutesParent],
	    providers: [ClassProvider(NotificationService), ClassProvider(DocumentService), ClassProvider(XMLValidationService), ClassProvider(ModelCheckingService)]
	)
	
	
	class PageContentComponent implements OnInit, CanActivate {
	  DocumentService _documentService;
	  UserService _userService;
	  PageContentComponent(this._documentService, this._userService, this._router);
	  final Router _router;
	  Document doc;
	
	  void scrollToTop(){
	    window.scrollTo(0, 0);
	  }
	  
	  bool isEnabled(){
	  «IF !roles.filter[manageUsers].isNullOrEmpty»
	    if(_userService.currentUser != null && «FOR role: roles.filter[manageUsers] SEPARATOR " || "»_userService.currentUser.role.name == "«role.name.toFirstUpper»"«ENDFOR»){
	      return true;
	    }else{
	      return false;
	    }
	    «ELSE»
	    return false;
	    «ENDIF»
	  }
	
	  getUsertext() {
	      if(_userService.currentUser != null){
	       return  _userService.currentUser.firstName + " " + _userService.currentUser.lastName;
	      }
	   }
	
	  void logout(){
	    _userService.currentUser = null;
	    _userService.persist();
	    _router.navigate(RoutePathsParent.login.toUrl());
	  }
	
	  @override
	  void ngOnInit() async {
	    _documentService.sController.stream.listen((id){
	      _documentService.get(id).then((d) => doc= d);
	    });
	  }
	
	  @override
	  Future<bool> canActivate(RouterState current, RouterState next) {
	    if (_userService.currentUser == null) {
	      _router.navigate(RoutePathsParent.login.toUrl());
	      return Future.value(false);
	    } else {
	      return Future.value(true);
	    }
	  }
	
	}
	'''
}