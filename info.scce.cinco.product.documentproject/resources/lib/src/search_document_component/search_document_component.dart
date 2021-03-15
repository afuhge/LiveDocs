
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:generated_webapp/abstract_classes/Document.dart';
import 'package:generated_webapp/src/service/users_service.dart';

import '../route_parents.dart';
import '../user.dart';

@Component(
    selector: 'search',
    templateUrl: 'search_document_component.html',
    styleUrls: ['search_document_component.css'],
    directives: [coreDirectives, formDirectives, routerDirectives])
class SearchDocumentComponent {
  @Input()
  List<Document> docs;

  @Input()
  String input;


  final UserService _userService;
  bool showModal = false;

  String panelUrl(int id) => RoutePaths.panel.toUrl(parameters: {idParam: '$id'});

  SearchDocumentComponent(this._userService);

    List<Document> search(List<Document> docs, String input){
      List<Document> searchResults= <Document>[];
      docs.forEach((doc){
        if(doc.fileName.contains(input)){
          searchResults.add(doc);
        }
      });
      return searchResults;
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



}
