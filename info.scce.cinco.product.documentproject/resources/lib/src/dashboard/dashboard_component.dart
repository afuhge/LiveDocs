import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:generated_webapp/src/docs/doc_component.dart';
import 'package:generated_webapp/src/panel/panel_component.dart';
import 'package:generated_webapp/src/search_document_component/search_document_component.dart';
import 'package:generated_webapp/src/service/documents_service.dart';
import 'package:generated_webapp/src/service/users_service.dart';
import '../routes_paths.dart';
import '../routes.dart';
import '../routes_paths_parent.dart';
import 'package:generated_webapp/abstract_classes/Document.dart';

import 'dart:html';
@Component(
    selector :'my-dashboard',
    styleUrls: ['dashboard_component.css'],
    templateUrl: 'dashboard_component.html',
    directives: [coreDirectives,DocComponent, PanelComponent, routerDirectives, SearchDocumentComponent, formDirectives],
  exports: [RoutePaths, Routes],
)

class DashboardComponent implements CanActivate, OnInit{
  DocumentService _documentService;
  final UserService _userService;
  final Router _router;
  DashboardComponent(this._documentService, this._userService, this._router);
  get docs => _documentService.docs;
  ControlGroup myPanel1, myPanel2;

  String panelUrl(int id) => RoutePaths.panel.toUrl(parameters: {idParam: '$id'});

  @override
  void ngOnInit() {
    myPanel1 = FormBuilder.controlGroup({
      "search" : ["", Validators.compose([Validators.required])],
    });

    myPanel2 = FormBuilder.controlGroup({
      "search" : ["", Validators.compose([Validators.required])],
    });
  }

  List<Document> openedDocs(){
    List<Document> openedDocs = <Document>[];
    docs.forEach((doc){
      if(doc.isOpen){
        openedDocs.add(doc);
      }
    });
    return openedDocs;
  }

  List<Document> closedDocs(){
    List<Document> closedDocs = <Document>[];
    docs.forEach((doc){
      if(!doc.isOpen){
        closedDocs.add(doc);
      }
    });
    return closedDocs;
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
  void sortAscendingOpened(){
    docs.sort(sorter(1, "fileName"));
  }

  void sortDescendingOpened(){
    docs.sort(sorter(0, "fileName"));
  }

  //sort fileName
  void sortAscendingClosed(){
    docs.sort(sorter(1, "fileName"));
  }

  void sortDescendingClosed(){
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