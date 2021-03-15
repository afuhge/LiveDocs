import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:generated_webapp/src/close_document_modal_component/close_document_modal_component.dart';
import 'package:generated_webapp/src/doctree_switch_component/doctree_switch_component.dart';
import 'package:generated_webapp/src/doctreepanel_component/treepanel_component.dart';
import 'package:generated_webapp/src/info_modal_component/info_modal_component.dart';
import 'package:generated_webapp/src/service/documents_service.dart';
import 'package:generated_webapp/abstract_classes/Document.dart';
import 'dart:html';

import '../routes.dart';

@Component(
  selector:'document-tree',
  templateUrl: 'document_tree_component.html',
  directives: [coreDirectives,formDirectives, routerDirectives, DocTreeSwitchComponent, DocumentTreeComponent, TreePanelComponent, CloseDocumentModalComponent, InfoModalComponent],
  exports: [RoutePaths, Routes],
)

class DocumentTreeComponent{

  DocumentService _documentsService;
  DocumentTreeComponent(this._documentsService){
    treeOpen = true;
  }
  get docs => _documentsService.docs;


  @Input()
  Document doc;

  bool treeOpen;

  void closeDoc(Document doc) {
    doc.isOpen = false;
    _documentsService.persist();
  }

  void openDoc(Document doc) {
    doc.isOpen = true;
    _documentsService.persist();
  }
  String panelUrl(int id) => RoutePaths.panel.toUrl(parameters: {idParam: '$id'});

}
