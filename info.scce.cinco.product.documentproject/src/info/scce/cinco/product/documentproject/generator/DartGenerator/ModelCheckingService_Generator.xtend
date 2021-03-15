package info.scce.cinco.product.documentproject.generator.DartGenerator

import graphmodel.Node
import info.scce.cinco.product.documentproject.constraint.constraint.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.Conclusion
import info.scce.cinco.product.documentproject.constraint.constraint.Constraint
import info.scce.cinco.product.documentproject.constraint.constraint.DateFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.FieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.NumberFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.Premise
import info.scce.cinco.product.documentproject.constraint.constraint.TextFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.constraint.constraint.CheckBoxFieldConstraint
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.EList

class ModelCheckingService_Generator {
	static extension Helper = new Helper()
	def generate(Documents docs)'''
	import 'package:generated_webapp/src/service/notification_service.dart';
	import 'package:http/http.dart' as http;
	import 'documents_service.dart';
	import '../../document_classes.dart';
	import 'dart:convert';
	
	class ModelCheckingService {
		«FOR doc : docs.documents »
		//String variables for XML Validation for «doc.escape.toFirstLower»
		String «doc.escape.toFirstLower»_CFPS = "";
     	String «doc.escape.toFirstLower»_CTLFormula = "«IF !(doc.dependency as Dependency).constraintss.isNullOrEmpty»«getCTLFormula((doc.dependency as Dependency).constraintss.get(0).constraint)»«ENDIF»";				
				
		«ENDFOR»
		
		 final DocumentService _documentService;
		 final NotificationService _notificationService;
		
		 ModelCheckingService(this._documentService, this._notificationService);
		  
	  «FOR doc : docs.documents»
	  modelChecking_«doc.escape»(«doc.escape» doc) async {
	  	«IF !(doc.dependency as Dependency).constraintss.isNullOrEmpty»
	  	var url = 'http://localhost:8000/modelchecking';
	  	print(«doc.escape.toFirstLower»_CFPS);
	  	var modelCheckingJson = {"CFPS":«doc.escape.toFirstLower»_CFPS,"CTLFormula": «doc.escape.toFirstLower»_CTLFormula};
	  	var response = await http.post(url, body: jsonEncode(modelCheckingJson),  headers:{"content-type": "application/json"});
	  	var body = response.body;
	  	print("modelchecking:" + body);
	  	var parsedJson = json.decode(body);
	  	doc.isSat = parsedJson['isSat'];
	  	doc.mc_msg = parsedJson['message'];
	  	_documentService.persist();
	  	if(doc.isSat){
	  		Notification notification = Notification("Model Checking status: ", parsedJson['message']);
	  	  	_notificationService.notify(notification);
	  	}
	  	«ELSE»
	  	print(«doc.escape.toFirstLower»_CFPS);
	  	doc.isSat = true;
	  	doc.mc_msg = "No Model Checking available.";
	  	_documentService.persist();
	  	«ENDIF»
	 }
	  			
	  «ENDFOR»	
	  
	 
	}
	'''
	
	def getCTLFormula(Constraint constraint) {
		'''«FOR premise : constraint.premises SEPARATOR " & "»
		(«generateIf(premise)» => «generateThen(premise)»))«ENDFOR»'''
	}
	
	def generateIf(Premise premise) {
		if(premise.nodes.size >1){
			'''AG((«createPremise(premise.nodes)»)'''
		}else{
			'''AG((<«premise.getElement.escape.toLowerCase.replace("-","_")»>true)'''
		}
	}
	
	def createPremise(EList<Node> nodes) {
		var preNodes = new ArrayList<Node>
		'''«IF nodes.size == 1»<«nodes.get(0).getDepElement.escape.toLowerCase.replace("-","_")»>true«ELSE»«FOR node : nodes SEPARATOR " & "»«FOR preNode : generatePreNodes(node,preNodes)»[«preNode.getDepElement.escape.toLowerCase.replace("-","_")»]«ENDFOR»<«node.getDepElement.escape.toLowerCase.replace("-","_")»>true«ENDFOR»«ENDIF»'''
		
	}
	
	def ArrayList<Node>  generatePreNodes(Node node,ArrayList<Node> preNodes) {
		if(node.incoming.isEmpty){
			return preNodes
		}else{
			var edge = node.incoming.get(0)
			var preNode = edge.sourceElement
			if(!preNodes.contains(preNode)){
				preNodes.add(preNode)
			}
				preNode.generatePreNodes(preNodes)
		}
	}
	
	
	
	
	def Node getElement(Premise premise){
		if(!premise.panels.isNullOrEmpty){
			return (premise.panels.get(0).panel as Panel)
		}else if (!premise.fieldConstraints.isNullOrEmpty){
			return (premise.fieldConstraints.get(0).getFieldConstraint)
		}
	}
	
	def Node getDepElement(Node node){
		if(node instanceof info.scce.cinco.product.documentproject.constraint.constraint.Panel){
			return (node as info.scce.cinco.product.documentproject.constraint.constraint.Panel).panel as Panel
		}else if(node instanceof FieldConstraint){
			return (node as FieldConstraint).fieldConstraint
		}
	}
	
	def Node getElement(Node node){
		if(node instanceof Panel){
			return node as Panel
		}else if(node instanceof info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint){
			return node as info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint
		}
	}
	
	def Node getElement(Conclusion conclusion){
		if(!conclusion.panels.isNullOrEmpty){
			return (conclusion.panels.get(0).panel as Panel)
		}else if (!conclusion.fieldConstraints.isNullOrEmpty){
			return (conclusion.fieldConstraints.get(0).getFieldConstraint)
		}
	}
	
	def info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint getFieldConstraint(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint : return (constraint as TextFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint
			NumberFieldConstraint: return (constraint as NumberFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint
			DateFieldConstraint: return (constraint as DateFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
			ChoiceFieldConstraint: return (constraint as ChoiceFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint
			CheckBoxFieldConstraint: return (constraint as CheckBoxFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint
		}
	}
	
	def generateThen(Premise premise) {
		if(!premise.conclusionSuccessors.isNullOrEmpty){
			var conclusion = premise.conclusionSuccessors.head
			if(conclusion.operator.getName == "ALL"){
				if(premise.nodes.size >1){
					'''«FOR premiseNode :  premise.nodes»[«premiseNode.depElement.escape.toLowerCase.replace("-","_")»]«ENDFOR»[«conclusion.getElement.escape.toLowerCase.replace("-","_")»]true «generateNotEdges(premise.getElement.escape.toLowerCase.replace("-","_"), conclusion.nodes.head)» '''
				}else{
					return '''[«premise.getElement.escape.toLowerCase.replace("-","_")»][«conclusion.getElement.escape.toLowerCase.replace("-","_")»]true «generateNotEdges(premise.getElement.escape.toLowerCase.replace("-","_"), conclusion.nodes.head)» '''
				}
			}else if(conclusion.operator.getName =="EXIST"){
				if(premise.nodes.size >1){
					'''«FOR premiseNode :  premise.nodes»[«premiseNode.depElement.escape.toLowerCase.replace("-","_")»]«ENDFOR»<«conclusion.getElement.escape.toLowerCase.replace("-","_")»>true'''
				}else{
					return '''[«premise.getElement.escape.toLowerCase.replace("-","_")»]<«conclusion.getElement.escape.toLowerCase.replace("-","_")»>true'''
				}
			}
		}
	}
	
	def generateNotEdges(String premise, Node node) {
		if(node instanceof info.scce.cinco.product.documentproject.constraint.constraint.Panel){
			var panel = node as info.scce.cinco.product.documentproject.constraint.constraint.Panel
			var depModel = (panel.panel as Panel).rootElement as Dependency
			var otherElements = new ArrayList
			for(e : depModel.allPanels){
				if(!e.id.equals(node.libraryComponentUID)){
					otherElements.add(e)
				}
			}
			for( e2 : depModel.fieldConstraints){
				if(!e2.id.equals(node.libraryComponentUID)){
					otherElements.add(e2)
				}
			}
			'''«FOR element : otherElements»& ! [«premise»]<«element.getElement.escape.toLowerCase.replace("-","_")»> true«ENDFOR»'''
		}else if(node instanceof TextFieldConstraint){
			var field = node as TextFieldConstraint
			var depModel = (field.fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint).rootElement as Dependency
			var otherElements = new ArrayList
			for(e : depModel.allPanels){
				if(!e.id.equals(node.libraryComponentUID)){
					otherElements.add(e)
				}
			}
			for( e2 : depModel.fieldConstraints){
				if(!e2.id.equals(node.libraryComponentUID)){
					otherElements.add(e2)
				}
			}
			'''«FOR element : otherElements»& ! [«premise»]<«element.getElement.escape.toLowerCase.replace("-","_")»> true«ENDFOR»'''
		}
		else if(node instanceof NumberFieldConstraint){
			var field = node as NumberFieldConstraint
			var depModel = (field.fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint).rootElement as Dependency
			var otherElements = new ArrayList
			for(e : depModel.allPanels){
				if(!e.id.equals(node.libraryComponentUID)){
					otherElements.add(e)
				}
			}
			for( e2 : depModel.fieldConstraints){
				if(!e2.id.equals(node.libraryComponentUID)){
					otherElements.add(e2)
				}
			}
			'''«FOR element : otherElements»& ! [«premise»]<«element.getElement.escape.toLowerCase.replace("-","_")»> true«ENDFOR»'''
		}
		else if(node instanceof DateFieldConstraint){
			var field = node as DateFieldConstraint
			var depModel = (field.fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint).rootElement as Dependency
			var otherElements = new ArrayList
			for(e : depModel.allPanels){
				if(!e.id.equals(node.libraryComponentUID)){
					otherElements.add(e)
				}
			}
			for( e2 : depModel.fieldConstraints){
				if(!e2.id.equals(node.libraryComponentUID)){
					otherElements.add(e2)
				}
			}
			'''«FOR element : otherElements»& ! [«premise»]<«element.getElement.escape.toLowerCase.replace("-","_")»> true«ENDFOR»'''
		}
		else if(node instanceof CheckBoxFieldConstraint){
			var field = node as CheckBoxFieldConstraint
			var depModel = (field.fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint).rootElement as Dependency
			var otherElements = new ArrayList
			for(e : depModel.allPanels){
				if(!e.id.equals(node.libraryComponentUID)){
					otherElements.add(e)
				}
			}
			for( e2 : depModel.fieldConstraints){
				if(!e2.id.equals(node.libraryComponentUID)){
					otherElements.add(e2)
				}
			}
			'''«FOR element : otherElements»& ! [«premise»]<«element.getElement.escape.toLowerCase.replace("-","_")»> true«ENDFOR»'''
		}
		else if(node instanceof ChoiceFieldConstraint){
			var field = node as ChoiceFieldConstraint
			var depModel = (field.fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint).rootElement as Dependency
			var otherElements = new ArrayList
			for(e : depModel.allPanels){
				if(!e.id.equals(node.libraryComponentUID)){
					otherElements.add(e)
				}
			}
			for( e2 : depModel.fieldConstraints){
				if(!e2.id.equals(node.libraryComponentUID)){
					otherElements.add(e2)
				}
			}
			'''«FOR element : otherElements»& ! [«premise»]<«element.getElement.escape.toLowerCase.replace("-","_")»> true«ENDFOR»'''
		}
		
	}
	

	
	
	
}
