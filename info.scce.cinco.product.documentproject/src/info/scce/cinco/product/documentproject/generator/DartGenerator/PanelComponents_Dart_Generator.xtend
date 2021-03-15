package info.scce.cinco.product.documentproject.generator.DartGenerator

import graphmodel.Edge
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.Field
import info.scce.cinco.product.documentproject.template.template.Panel
import info.scce.cinco.product.documentproject.template.template.PanelRead
import info.scce.cinco.product.documentproject.template.template.Role
import java.util.ArrayList
import java.util.List
import java.util.stream.Collectors
import org.eclipse.emf.common.util.EList

class PanelComponents_Dart_Generator {
	
	protected extension Helper = new Helper
	def generate (info.scce.cinco.product.documentproject.dependency.dependency.Panel panel)'''
		import 'package:angular/angular.dart';
		import 'package:angular_forms/angular_forms.dart';
		import 'package:generated_webapp/abstract_classes/Dependency.dart';
		import 'package:generated_webapp/dependency_classes.dart';
		import 'package:generated_webapp/abstract_classes/Panel.dart';
		import 'package:generated_webapp/src/«panel.escape.toFirstLower»Log_modal_component/«panel.escape.toFirstLower»Log_modal_component.dart';
		import 'package:generated_webapp/src/service/notification_service.dart';
		import 'package:generated_webapp/src/panels_switch_component/panels_switch_component.dart';
		import 'package:generated_webapp/src/service/users_service.dart';
		import 'package:generated_webapp/src/service/xmlvalidation_service.dart';
		import 'package:generated_webapp/src/service/documents_service.dart';
		import '../../panel_classes.dart';
		import 'package:intl/intl.dart';
		import 'package:generated_webapp/src/service/modelchecking_service.dart';
		
		
		«generateChoiceFieldContents(panel.tmplPanel)»
		@Component(
			selector: '«panel.escape.toFirstLower.replace("_","-")»', 
			templateUrl: '«panel.escape.toFirstLower»_component.html', 
			styleUrls: ['panel_component.css'],
			directives :[coreDirectives, formDirectives, «panel.escape»LogModalComponent «panel.tmplPanel.generatePanelSwitch»],
			pipes: [commonPipes],
		)
		
		class «panel.escape»Component extends AbstractPanelComponent implements OnInit{
			@Input()
			«panel.escape» panel;
			
			@Input()
			Dependency dep;
			
			ControlGroup myPanel;
			final NotificationService _notificationService;
			final UserService _userService;
			final XMLValidationService _xmlvalidationService;
			final DocumentService _documentService;
			final ModelCheckingService _modelCheckingService;
			
			get currentRole => _userService.currentUser.role;
		  
		  	«generateChoiceFieldContentsGetter(panel.tmplPanel)»
		  
		  	«panel.escape»Component(this._notificationService, this._userService, this._documentService, this._xmlvalidationService, this._modelCheckingService) {}
		
			submit(ControlGroup myPanel) async {
				panel.submitTime = DateTime.now();
				panel.panelOpen = false;
			 	(dep as «panel.rootElement.escape»).continue«panel.escape»(myPanel, _documentService, _notificationService, _userService);
				_xmlvalidationService.document_«panel.rootElement.escape»_transformedDOM = (dep as «panel.rootElement.escape»).transformDOMStructure();
				_xmlvalidationService.validateXML_Document_«panel.rootElement.escape»(doc);
				_modelCheckingService.document_«panel.rootElement.escape»_CFPS = (dep as «panel.rootElement.escape»).transformDOMToCFPS();
				_modelCheckingService.modelChecking_Document_«panel.rootElement.escape»(doc);
			}
			
			switchPanelOpen(){
				panel.panelOpen = ! panel.panelOpen;
				_documentService.persist();
			}
			
			bool isEnabled(){
				«IF !panel.tmplPanel.allIncomingEdges.getRole.nullOrEmpty»
				if(«FOR role : panel.tmplPanel.allIncomingEdges.getRole SEPARATOR " || "»_userService.currentUser.role >= "«role.name.toFirstUpper»"«ENDFOR»){
					return true;
				}else{
					return false;
				}
				«ELSE»
				return false;
				«ENDIF»
			}
			
				
		
		  @override
		  void ngOnInit() {
		  	«generateSetPreCondition(panel)»
		    myPanel = FormBuilder.controlGroup({
		    «FOR field : panel.tmplPanel.fields»
		    	«IF ! (field instanceof DateField)»
		    	"«field.escape»" : [panel.«field.escape», Validators.compose([«FOR validator: generateValidators(field) SEPARATOR ", "»«validator»«ENDFOR»])],
		   		«ELSE»
		   		"«field.escape»" : [DateFormat('yyyy-MM-dd').format(panel.«field.escape»), Validators.compose([«FOR validator: generateValidators(field) SEPARATOR ", "»«validator»«ENDFOR»])],
		   		«ENDIF»
		    «ENDFOR»
		    });
		  }
		  
		  @override
		  get doc => dep.doc;
		
		}
		
	'''
	
	def dispatch getGetRole(ArrayList<Edge> edges) {
		var roles = new ArrayList()
		for(edge : edges){
			roles.add((edge.sourceElement as Role).role)
		}
		var allRoles = roles.stream().distinct().collect(Collectors.toList());
		return allRoles
	}
	
	def dispatch getGetRole(EList<PanelRead> reads) {
		var roles = new ArrayList()
		for(edge : reads){
			roles.add((edge.sourceElement as Role).role)
		}
		var allRoles = roles.stream().distinct().collect(Collectors.toList());
		return allRoles
	}
	
	def ArrayList<Edge> allIncomingEdges(Panel panel){
		var allEdges = new ArrayList()
		allEdges.addAll(panel.incoming)
		for(field : panel.fields){
			allEdges.addAll(field.incoming)
		}
		return allEdges
	}
	
	
	def generatePanelSwitch(Panel panel){
		if(!panel.dependencys.isNullOrEmpty){
			return ''', PanelsSwitchComponent'''
		}
	}
	
	def generateChoiceFieldContentsGetter(Panel panel) {
		if(!panel.fields.nullOrEmpty){
			'''«FOR choiceField : panel.fields.filter(ChoiceField)»
			List<String> get «choiceField.label.escapeLabel»Contents => _«choiceField.label.escapeLabel»Contents;
			«ENDFOR»'''
		}
	}
	
	def generateChoiceFieldContents(Panel panel) '''
	«IF !panel.fields.nullOrEmpty»«FOR choiceField : panel.fields.filter(ChoiceField)»const List<String> _«choiceField.label.escapeLabel»Contents = [«FOR content : choiceField.content SEPARATOR ","»"«content»"«ENDFOR»];
	«ENDFOR»«ENDIF»'''
	
	def generateContent(Panel panel)'''«FOR field : panel.fields SEPARATOR ","»"«field.escape»" : panel.«field.escape».toString()«ENDFOR»'''
	
	def generateValidators(Field field) {
		var List<String> validators = new ArrayList<String>()
		var validation = field.validation
		if(validation !== null){
			if(validation.min != -1) validators.add('''Validators.minLength(«validation.min»)''')
			if(validation.max != -1) validators.add('''Validators.maxLength(«validation.max»)''')
			if(validation.required) validators.add('''Validators.required''')
		}
		
		return validators
	}
	
}
