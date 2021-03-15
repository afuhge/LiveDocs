package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency

class DocumentTreeComponent_Dart {
	static extension Helper = new Helper()
	
	def generate(Documents doc)'''
	import 'package:angular/angular.dart';
	import 'package:angular_router/angular_router.dart';
	import 'package:generated_webapp/src/close_document_modal_component/close_document_modal_component.dart';
	import 'package:generated_webapp/src/doctree_switch_component/doctree_switch_component.dart';
	import 'package:generated_webapp/src/doctreepanel_component/treepanel_component.dart';
	import 'package:generated_webapp/src/service/documents_service.dart';
	import 'package:generated_webapp/abstract_classes/Document.dart';
	import 'package:generated_webapp/src/service/xmlvalidation_service.dart';
	import 'dart:html';
	
	import '../routes.dart';
	
	@Component(
	  selector:'document-tree',
	  templateUrl: 'document_tree_component.html',
	  directives: [coreDirectives, routerDirectives, DocTreeSwitchComponent, DocumentTreeComponent, TreePanelComponent, CloseDocumentModalComponent],
	  exports: [RoutePaths, Routes],
	)
	
	class DocumentTreeComponent{
	
	  DocumentService _documentsService;
	  XMLValidationService _xmlValidationService;
	  DocumentTreeComponent(this._documentsService, this._xmlValidationService){
	    treeOpen = true;
	  }
	  get docs => _documentsService.docs;
	
	
	  @Input()
	  Document doc;
	
	  bool treeOpen;
	  bool docValid = false;
	
	  String getMsg(Document doc){
	  	«generateDocumentComparison(doc)»
	    
	  }
	
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
	'''
	
	def generateDocumentComparison(Documents docs) '''
	«FOR doc : docs.documents BEFORE "if(" SEPARATOR "else if("»
	doc.name == "«(doc.dependency as Dependency).name.toFirstUpper»"){
		if(_xmlValidationService.«doc.escape.toFirstLower»_msg.length == 0){
			docValid = false;
		}else{
			if(_xmlValidationService.«doc.escape.toFirstLower»_msg.substring(0, _xmlValidationService.«doc.escape.toFirstLower»_msg.indexOf("#"))== "true"){
				docValid = true;
			}else{
			    docValid = false;
			}
		}
		var msg = _xmlValidationService.«doc.escape.toFirstLower»_msg.substring(_xmlValidationService.«doc.escape.toFirstLower»_msg.indexOf("#")+1, _xmlValidationService.«doc.escape.toFirstLower»_msg.length);
		return msg;
	}
	«ENDFOR»
	
	'''
	
}