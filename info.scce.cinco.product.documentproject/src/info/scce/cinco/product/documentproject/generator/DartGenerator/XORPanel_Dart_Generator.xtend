package info.scce.cinco.product.documentproject.generator.DartGenerator

import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.generator.Helper

class XORPanel_Dart_Generator {
	protected extension Helper = new Helper()
	
	def generate (XOR xor)'''
	import 'package:angular/angular.dart';
	import 'package:angular_forms/angular_forms.dart';
	import 'package:generated_webapp/abstract_classes/Dependency.dart';
	import 'package:generated_webapp/abstract_classes/Panel.dart';
	import 'package:generated_webapp/src/service/documents_service.dart';
	import 'package:generated_webapp/src/service/xmlvalidation_service.dart';
	import 'package:generated_webapp/src/service/notification_service.dart';
	
	import '../../dependency_classes.dart';
	import '../../panel_classes.dart';
	
	@Component(
	  selector: 'xor-«xor.id.replace("_","-")»',
	  templateUrl: 'XOR«xor.id»_component.html',
	  styleUrls: ['panel_component.css'],
	  directives: [
	    coreDirectives,
	    formDirectives,
	  ],
	  pipes: [commonPipes],
	
	)
	class XOR«xor.id.replace("_", "").replace("-","")»_panel_Component extends AbstractPanelComponent implements OnInit{
	  @Input()
	  XOR_«xor.id.replace("_", "").replace("-","")» panel;
	
	  final XMLValidationService _xmlvalidationService;
	  final DocumentService _documentService;
	  final NotificationService _notificationService;
	
	  @Input()
	  Dependency dep;
	
	
	  XOR«xor.id.replace("_", "").replace("-","")»_panel_Component(this._documentService, this._xmlvalidationService, this._notificationService);
	
	  «generateAddPanelMethod(xor)»
	  
	
	  switchPanelOpen(){
	    panel.panelOpen = ! panel.panelOpen;
	    _documentService.persist();
	  }
	
	  @override
	  get doc => dep.doc;
	  
	   @override
	    void ngOnInit() {
	  		«generateSetPreCondition(xor)»
	    }
	}
	'''
	
	def generateAddPanelMethod(XOR xor) '''
	«FOR panel : xor.panels»
	addPanel«panel.escape.toFirstUpper»(){
		panel.submitTime = DateTime.now();
		panel.panelOpen = false;
		(dep as «panel.rootElement.escape»).continueXOR_«xor.id.replace("_", "").replace("-","")»(_documentService,_notificationService, "«panel.escape.toFirstLower»");
		print((dep as «panel.rootElement.escape»).transformDOMStructure());
		_xmlvalidationService.document_«panel.rootElement.escape»_transformedDOM = (dep as «panel.rootElement.escape»).transformDOMStructure();
		_xmlvalidationService.validateXML_Document_«panel.rootElement.escape»(doc);
	}
	«ENDFOR»
	'''
	
	
}