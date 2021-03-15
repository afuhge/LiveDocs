package info.scce.cinco.product.documentproject.generator.DataClassGenerator

import graphmodel.Node
import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.Else
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Must
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.PanelToConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.generator.Helper
import info.scce.cinco.product.documentproject.template.template.CheckBoxField
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.NumberField
import info.scce.cinco.product.documentproject.template.template.TextField
import java.util.ArrayList
import java.util.List
import java.util.stream.Collectors
import org.eclipse.emf.common.util.EList
import graphmodel.Container

class DependencyClasses_Generator {
	protected extension Helper = new Helper
	
	def generate (Documents docs)'''
		import 'package:angular_forms/angular_forms.dart';
		import 'package:generated_webapp/abstract_classes/Dependency.dart';
		import 'package:generated_webapp/panel_classes.dart';
		import 'package:generated_webapp/panel_logs_classes.dart';
		import 'package:generated_webapp/src/service/notification_service.dart';
		import 'package:generated_webapp/src/service/users_service.dart';
		import 'abstract_classes/Document.dart';
		import 'abstract_classes/Panel.dart';
		import 'dart:core';
		import 'package:generated_webapp/src/service/documents_service.dart';
		import 'document_classes.dart';
		import 'package:collection/collection.dart';
		import 'dart:html' as html;
		
		«FOR dep : getAllDependencies(docs)»
			class «dep.escape» extends Dependency {
				
				//Model Checking
				«generateTransformDOMToCFPS(dep)»
				«generateCreateExtraEdgeMethod()»
				«generateCreateEdgeMethod()»
				«generateCreateEdgeFieldConstraintMethod()»
				«generateCreateStateMethod()»
				«generateCreateStateFieldConstraintMethod()»
				«generateConcreteFieldConstraintExistsMethod()»
				
				
				
				//XML Validation
				«generateTransformDOM(dep)»
				«generatePreCondition()»
				«generateConcretePanelExistsMethod»
				
							
				
				«FOR panel : dep.allPanels»
				«generatePanelXORExistsMethod(panel)»
				«generatePanelExistsMethod(panel)»
				«ENDFOR»
				«FOR and : dep.ANDs»
				«generatePanelANDExistsMethod(and)»
				«ENDFOR»
				«FOR or : dep.ORs»
				«generatePanelORExistsMethod(or)»
				«ENDFOR»
				
«««				//Persistence
				«generateToJson(dep)»
				
				«generateFromJson(dep)»
				
				//Document content + workflow
				
				@override
				get name => "«dep.name.toFirstUpper»";
				  
				Panel current;
				  
				«generateAllPanelVariables(dep)»
				
				«generateDepConstructor(dep)»
				 
				«generateContinuePanel(dep)»
				«generateContinueXORPanel(dep)»
				  
				«generateAddLogEntryPanel(dep)»
			}
			
		«ENDFOR»
	'''
	
	def generateTransformDOMToCFPS(Dependency dep)
	'''
	String transformDOMToCFPS(){
		«IF dep.constraintss.isEmpty»
		return «generateInvertedCommas»«generateInvertedCommas»;
		«ELSE»
		return «generateInvertedCommas»<cfps>
			<ppg>
			<isMain>true</isMain>
			<name>«IF dep.name.isNullOrEmpty»MyCFPS«ELSE»«dep.name»«ENDIF»</name>
			<states>
			«createExtraStartState(dep)»
«««			create states for dep elements
			«FOR panel : dep.allPanels»
			${createState("«panel.escape.toUpperCase.replace("_","-")»", «getStateClass(panel)»)}
			«ENDFOR»
			«FOR fieldConstraint : dep.fieldConstraints»
			${createStateFieldConstraint("«fieldConstraint.createPreCondition»", "«fieldConstraint.escape»", «getStateClass(fieldConstraint)»)}
			«ENDFOR»
			<state>
				<id>end</id>
				<name>end</name>
				<stateClass>end</stateClass>
				<stateLabels></stateLabels>
				</state>
			</states>
			
			<edges>
			«createEdgesFromExtraStartState(dep)» «««			create extra edges from extra states
			«createEdgesToExtraEndState(dep)»
			«FOR pair : dep.pairs» «««			 "normal" edges between panels
			${createEdge(«pair»)}
			«ENDFOR»
			«FOR pair : dep.pairsWithFieldConstraintasTarget» «««			 create edge between fieldconstraints and panel
			${createEdgeFieldConstraintTarget(«pair»)}
			«ENDFOR»
			«FOR pair : dep.pairsWithFieldConstraintasSource»
			${createEdgeFieldConstraintSource(«pair»)}
			«ENDFOR»
			</edges>
			</ppg>
			</cfps>
			«generateInvertedCommas»;
		«ENDIF»
	}
	'''
	
	def createEdgesToExtraEndState(Dependency dep)'''
	«FOR panel : dep.findLastPanel»
	${createExtraEdge("«panel.escape.toUpperCase.replace("_","-")»")}
	«ENDFOR»
	'''
	
	def createEdgesFromExtraStartState(Dependency dep) {
		if(dep.findFirstPanel instanceof AND){
			'''«FOR panel : (dep.findFirstPanel as AND).panels»
			<edge>
				<sourceId>start</sourceId>
				<targetId>«panel.escape.toLowerCase.replace("-","_")»</targetId>
				<label>start</label>
				<isMust>true</isMust>
				<isProcessCall>false</isProcessCall>
			</edge>
			«ENDFOR»'''
			
		}else if(dep.findFirstPanel instanceof OR){
			'''«FOR panel : (dep.findFirstPanel as OR).panels»
			<edge>
				<sourceId>start</sourceId>
				<targetId>«panel.escape.toLowerCase.replace("-","_")»</targetId>
				<label>start</label>
				<isMust>true</isMust>
				<isProcessCall>false</isProcessCall>
			</edge>
			«ENDFOR»'''
		}
	}
	
	def createExtraStartState(Dependency dep) {
		if(dep.findFirstPanel instanceof AND || dep.findFirstPanel instanceof OR){
			return '''
			<state>
				<id>start</id>
				<name>start</name>
				<stateClass>start</stateClass>
				<stateLabels></stateLabels>
			</state>'''
		}
	}
	
	
	def List<String> getPairsWithFieldConstraintasSource(Dependency dep){
		var Node target = null
		var FieldConstraint source = null
		var pairs = new ArrayList<String>();
		for(fieldConstraint : dep.fieldConstraints){
			source = fieldConstraint
				for(edge : fieldConstraint.outgoingMusts){
					if(edge.targetElement instanceof Panel){
						target = edge.targetElement as Panel
						pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«source.createPreCondition»","«target.escape.toUpperCase.replace("_","-")»"''')
					}else if(edge.targetElement instanceof AND){
						for(targetAnd : (edge.targetElement as AND).panels){
							pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«source.createPreCondition»","«targetAnd.escape.toUpperCase.replace("_","-")»"''')
						}
					}else if(edge.targetElement instanceof OR){
						for(targetOR : (edge.targetElement as OR).panels){
							pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«source.createPreCondition»","«targetOR.escape.toUpperCase.replace("_","-")»"''')
						}
					}else if(edge.targetElement instanceof XOR){
						for(targetXOR : (edge.targetElement as XOR).panels){
							pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«source.createPreCondition»","«targetXOR.escape.toUpperCase.replace("_","-")»"''')
						}
					}
				}
		}
		return pairs
	}
	
	def List<String> getPairsWithFieldConstraintasTarget(Dependency dep){
		var FieldConstraint target = null
		var Node source = null
		var pairs = new ArrayList<String>();
		for(fieldConstraint : dep.fieldConstraints){
			target = fieldConstraint
			for(edge : fieldConstraint.incoming){
				if(edge.sourceElement instanceof Panel){
					source = edge.sourceElement as Panel
					pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«target.createPreCondition»","«target.escape.toUpperCase.replace("_","-")»"''')
				}else if(edge.sourceElement instanceof AND){
					for(sourceAND : (edge.sourceElement as AND).panels){
						pairs.add('''"«sourceAND.escape.toUpperCase.replace("_","-")»","«target.createPreCondition»","«target.escape.toUpperCase.replace("_","-")»"''')
					}
				}else if(edge.sourceElement instanceof OR){
					for(sourceOR : (edge.sourceElement as OR).panels){
						pairs.add('''"«sourceOR.escape.toUpperCase.replace("_","-")»","«target.createPreCondition»","«target.escape.toUpperCase.replace("_","-")»"''')
					}
				}else if(edge.sourceElement instanceof XOR){
					for(sourceXOR : (edge.sourceElement as XOR).panels){
						pairs.add('''"«sourceXOR.escape.toUpperCase.replace("_","-")»","«target.createPreCondition»","«target.escape.toUpperCase.replace("_","-")»"''')
					}
				}
			}
		}
		return pairs
	}
	
	def String createPreCondition(FieldConstraint constraint){
		var preCondition = ""
		var label = constraint.label
		var operator = constraint.operator
		var value = constraint.value
		preCondition +='''«label»_«operator»_«value»'''
		
		return preCondition
	}
	

	
	/***
	 * "«pair.escape.toUpperCase.replace("_","-")»", "«pair.escape.toUpperCase.replace("_","-")»" */
	def List<String> getPairs(Dependency dep){
		var Panel target = null
		var Panel source = null
		var pairs = new ArrayList<String>();
		for(edge : dep.getEdges(Must) + dep.getEdges(Else)){
			// Panel ->
			if(edge.sourceElement instanceof Panel){
				source = edge.sourceElement as Panel
				if(edge.targetElement instanceof AND){
					for(targetAnd : (edge.targetElement as AND).panels){
						pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«targetAnd.escape.toUpperCase.replace("_","-")»"''')
					}
				}else if (edge.targetElement instanceof OR){
					for(targetOR : (edge.targetElement as OR).panels){
						pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«targetOR.escape.toUpperCase.replace("_","-")»"''')
					}
				}
				else if (edge.targetElement instanceof XOR){
					for(targetXOR : (edge.targetElement as XOR).panels){
						pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«targetXOR.escape.toUpperCase.replace("_","-")»"''')
					}
				}else if(edge.targetElement instanceof Panel){
					target = edge.targetElement as Panel
					pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«target.escape.toUpperCase.replace("_","-")»"''')
					
				}
			}
			
			// -> Panel
			if(edge.targetElement instanceof Panel){
				target = edge.targetElement as Panel
				if(edge.sourceElement instanceof AND){
					for(sourceAND : (edge.sourceElement as AND).panels){
						pairs.add('''"«sourceAND.escape.toUpperCase.replace("_","-")»","«target.escape.toUpperCase.replace("_","-")»"''')
					}
				}else if(edge.sourceElement instanceof OR){
					for(sourceOR : (edge.sourceElement as OR).panels){
						pairs.add('''"«sourceOR.escape.toUpperCase.replace("_","-")»","«target.escape.toUpperCase.replace("_","-")»"''')
					}
				}
				else if(edge.sourceElement instanceof XOR){
					for(sourceXOR : (edge.sourceElement as XOR).panels){
						pairs.add('''"«sourceXOR.escape.toUpperCase.replace("_","-")»","«target.escape.toUpperCase.replace("_","-")»"''')
					}
				}else if(edge.sourceElement instanceof Panel){
					source = edge.sourceElement as Panel
					pairs.add('''"«source.escape.toUpperCase.replace("_","-")»","«target.escape.toUpperCase.replace("_","-")»"''')
					
				}
			}
		}
		var List<String> allPairs = pairs.stream().distinct().collect(Collectors.toList());
		return allPairs
	}
	
	def getStateClass(Panel panel) {
		if(panel.container instanceof Dependency){
			//end
			if(panel.outgoing.isEmpty && !panel.incoming.isEmpty){
				if((panel.container as Dependency).findLastPanel.length == 1){
					return '''"normal"'''
				}else{
					return '''"normal"'''
				}
			}
			//start
			if(!panel.outgoing.isEmpty && panel.incoming.isEmpty){
				return '''"start"'''
			}
			//normal
			if(!panel.outgoing.isEmpty && !panel.incoming.isEmpty){
				return '''"normal"'''
			}
		}else if (panel.container instanceof AND || panel.container instanceof OR){
			return '''"normal"'''
		} else if (panel.container instanceof XOR) {
			var xor = panel.container as XOR
			if (xor.outgoing.isEmpty && !xor.incoming.isEmpty) { // ende
				return '''"normal"'''
			}
			if (!xor.outgoing.isEmpty && xor.incoming.isEmpty) { // start
				return '''"start"'''
			}
			if (!xor.outgoing.isEmpty && !xor.incoming.isEmpty) { // normal
				return '''"normal"'''
			}
		}
	}
	
	def getStateClass(FieldConstraint fieldConstraint) {
			//end
			if(fieldConstraint.outgoing.isEmpty && !fieldConstraint.incoming.isEmpty){
				return '''"normal"'''
			}
			//start
			if(!fieldConstraint.outgoing.isEmpty && fieldConstraint.incoming.isEmpty){
				return '''"start"'''
			}
			//normal
			if(!fieldConstraint.outgoing.isEmpty && !fieldConstraint.incoming.isEmpty){
				return '''"normal"'''
			}
	}
	
	
	def generateCreateStateMethod()'''
	String createState(String panelName, String stateClass){
		if(concretePanelExists(panelName)){
			return «generateInvertedCommas»
				<state>
					<id>${panelName.toLowerCase().replaceAll("-","_")}</id>
					<name>${panelName.toLowerCase().replaceAll("-","_")}</name>
					<stateClass>${stateClass}</stateClass>
					<stateLabels></stateLabels>
		        </state>
		      «generateInvertedCommas»;
		}
		return "";
	}
	'''
	
	
	def generateCreateStateFieldConstraintMethod()'''
	String createStateFieldConstraint(String fieldConstraintPreCondition, String fieldID, String stateClass){
		if(concreteFieldConstraintExists(fieldConstraintPreCondition)){
			return «generateInvertedCommas»
				<state>
					<id>${fieldID.toLowerCase().replaceAll("-","_")}</id>
					<name>${fieldID.toLowerCase().replaceAll("-","_")}</name>
					<stateClass>${stateClass}</stateClass>
					<stateLabels></stateLabels>
		        </state>
		      «generateInvertedCommas»;
		}
		return "";
	}
	'''
	
	def generateCreateExtraEdgeMethod()'''
	String createExtraEdge(String panelName){
		if(concretePanelExists(panelName)){
			return «generateInvertedCommas»
			   	<edge>
				    <sourceId>${panelName.toLowerCase().replaceAll("-","_")}</sourceId>
					<targetId>end</targetId>
					<label>${panelName.toLowerCase().replaceAll("-","_")}</label>
					<isMust>true</isMust>
					<isProcessCall>false</isProcessCall>
				</edge>
			     «generateInvertedCommas»;
		}
		return "";
	}
	'''
	
	def generateCreateEdgeMethod()'''
	String createEdge(String panelName, String panelName2){
		if(concretePanelExists(panelName) && concretePanelExists(panelName2)){
			return «generateInvertedCommas»
		    	<edge>
				    <sourceId>${panelName.toLowerCase().replaceAll("-","_")}</sourceId>
					<targetId>${panelName2.toLowerCase().replaceAll("-","_")}</targetId>
					<label>${panelName.toLowerCase().replaceAll("-","_")}</label>
					<isMust>true</isMust>
					<isProcessCall>false</isProcessCall>
				</edge>
			      «generateInvertedCommas»;
		}
		return "";
	}
	'''
	
	def String generateConcreteFieldConstraintExistsMethod()'''
			bool concreteFieldConstraintExists(String fieldConstraintPreCondition){
				var eq = const Equality().equals;
				var panels = html.document.querySelectorAll('.panel');
				var exists = false;
				panels.forEach((panel) {
					if(panel.getAttribute("preCondition") != null){
						if(!eq(panel.getAttribute("preCondition"), '')){
								if(panel.getAttribute("preCondition").contains(fieldConstraintPreCondition)){
								exists = true;
							}
						}
					}
				});
				return exists;
			}
	'''
	
	
	def String generateCreateEdgeFieldConstraintMethod()'''
	String createEdgeFieldConstraintSource(String fieldID, String fieldPreCondition, String target){
			if(concreteFieldConstraintExists(fieldPreCondition) && concretePanelExists(target)){
				return «generateInvertedCommas»
			    	<edge>
					    <sourceId>${fieldID.toLowerCase().replaceAll("-","_")}</sourceId>
						<targetId>${target.toLowerCase().replaceAll("-","_")}</targetId>
						<label>${fieldID.toLowerCase().replaceAll("-","_")}</label>
						<isMust>true</isMust>
						<isProcessCall>false</isProcessCall>
					</edge>
				      «generateInvertedCommas»;
	
			}else {
				return "";
			}
		}
	
		String createEdgeFieldConstraintTarget(String source, String fieldPreCondition, String fieldID){
			if(concreteFieldConstraintExists(fieldPreCondition) && concretePanelExists(source)){
				return «generateInvertedCommas»
			    	<edge>
					    <sourceId>${source.toLowerCase().replaceAll("-","_")}</sourceId>
						<targetId>${fieldID.toLowerCase().replaceAll("-","_")}</targetId>
						<label>${source.toLowerCase().replaceAll("-","_")}</label>
						<isMust>true</isMust>
						<isProcessCall>false</isProcessCall>
					</edge>
				      «generateInvertedCommas»;
	
			}else {
				return "";
			}
		}
	'''
	
	
	
	
	/**
	 * This methods generates the root tag of a transformed DOM
	 */
	def generateTransformDOM(Dependency dep) '''
		transformDOMStructure(){
		return «generateInvertedCommas()»
			<«dep.escape.toLowerCase.replace("_","-")»>
		 		«generatePanelDOMStructure(dep)»
		 </«dep.escape.toLowerCase.replace("_","-")»>«generateInvertedCommas()»;
		}
	'''
	/**
	 * Generates panel tags and its input
	 */
	def generatePanelDOMStructure(Dependency dep)'''
		«IF (dep.findFirstPanel).concreteElement instanceof Panel»
		«generateFirstPanelDOM((dep.findFirstPanel).concreteElement as Panel)»
		«ELSE»
		«generatePanelInOperatorContainer((dep.findFirstPanel).concreteElement)»
		«ENDIF»
	'''
	
	def generateFirstPanelDOM(Node panel) '''${panelExists_«panel.escape.replace("-","")»("«panel.escape.toUpperCase.replace("_","-")»")}'''
	
	/**
	 * Generates panel tags and its input
	 */
	def generatePanelDOM(List<Node> nodes)'''
	«FOR node : nodes»
		«IF node.concreteElement instanceof Panel»
		${panelExists_«(node.concreteElement as Panel).escape.replace("-","")»("«node.escape.toUpperCase.replace("_","-")»")}
		«ELSE»
		«generatePanelInOperatorContainer(node.concreteElement)»
		«ENDIF»
		«ENDFOR»
	'''
	
	def generatePanelInOperatorContainer(Node node) {
		if(node instanceof AND){
			return '''
			${panelExistsAND«(node as AND).id.replace("-","")»_«FOR panel: (node as AND).panels SEPARATOR "_"»«panel.escape.replace("-","_")»«ENDFOR»(«FOR panel : (node as AND).panels SEPARATOR ","»"«panel.escape.toUpperCase.replace("_","-")»"«ENDFOR»)}
				'''
		}else if(node instanceof OR){
			return '''
			${panelExistsOR«(node as OR).id.replace("-","")»_«FOR panel: (node as OR).panels SEPARATOR "_"»«panel.escape.replace("-","_")»«ENDFOR»(«FOR panel : (node as OR).panels SEPARATOR ","»"«panel.escape.toUpperCase.replace("_","-")»"«ENDFOR»)}
				'''
		}else if (node instanceof XOR){
			return '''
				<«node.concreteElement.tag» «setPreCondition(node.concreteElement)»>
			«FOR panel : (node as XOR).panels»
				${panelExistsXOR«(node as XOR).id.replace("-","")»_«panel.escape.replace("-","")»("«panel.escape.toUpperCase.replace("_","-")»")}
				«ENDFOR»
				</«node.concreteElement.tag»>
				'''
		}
	}
	
	def generatePanelExistsMethod(Panel panel)'''
		String panelExists_«panel.escape.replace("-","")»(String panelName){
			if(concretePanelExists(panelName)){
				if(«panel.concreteElement.escape.toFirstLower».getPanelInput() == ""){
					return «generateInvertedCommas»<«panel.concreteElement.tag» «setPreCondition(panel.concreteElement)»>«generatePanelDOM(panel.concreteElement.next)»</«panel.concreteElement.tag»>«generateInvertedCommas»;
				}else{
					return «generateInvertedCommas»
					<«panel.concreteElement.tag» «setPreCondition(panel.concreteElement)»>
					${«panel.concreteElement.escape.toFirstLower».getPanelInput()}
					«generatePanelDOM(panel.concreteElement.next)»
					</«panel.concreteElement.tag»>«generateInvertedCommas»;
				}
			}
			return "";
		}
	'''
	
	
	def generatePanelORExistsMethod(OR or)'''
		String panelExistsOR«(or.id.replace("-",""))»_«FOR panel1: or.panels SEPARATOR "_"»«panel1.escape.replace("-","_")»«ENDFOR»(«generateParameter(or)»){
			if(«generateConcreteExistsIfOR(or)»){
					return «generateInvertedCommas»
					<«or.concreteElement.tag» «setPreCondition(or.concreteElement)»>
					«FOR panelInOR : or.panels»
					<«panelInOR.concreteElement.tag»>${«panelInOR.concreteElement.escape.toFirstLower».getPanelInput()}«generatePanelDOM(or.concreteElement.next)»</«panelInOR.concreteElement.tag»>
					«ENDFOR»
					</«or.concreteElement.tag»>
					«generateInvertedCommas»;
			}
			return "";
		}
	'''
	
	def generatePanelANDExistsMethod(AND and)'''
		String panelExistsAND«and.id.replace("-","")»_«FOR panel1: and.panels SEPARATOR "_"»«panel1.escape.replace("-","_")»«ENDFOR»(«generateParameter(and)»){
			if(«generateConcreteExistsIfAND(and)»){
					return «generateInvertedCommas»
					<«and.concreteElement.tag» «setPreCondition(and.concreteElement)»>
					«FOR panelInAND : and.panels»
					<«panelInAND.concreteElement.tag»>${«panelInAND.concreteElement.escape.toFirstLower».getPanelInput()}«IF panelInAND.equals(and.panels.last)»«generatePanelDOM(and.concreteElement.next)»«ENDIF»</«panelInAND.concreteElement.tag»>
					«ENDFOR»
					</«and.concreteElement.tag»>
					«generateInvertedCommas»;
			}
			return "";
		}
	'''
	def generateConcreteExistsIfAND(AND and) '''«FOR panel : and.panels SEPARATOR " && "»concretePanelExists(panelName_«panel.escape»)«ENDFOR»'''
	def generateParameter(AND and) '''«FOR panel : and.panels SEPARATOR ","»String panelName_«panel.escape»«ENDFOR»'''
	def generateConcreteExistsIfOR(OR and) '''«FOR panel : and.panels SEPARATOR " && "»concretePanelExists(panelName_«panel.escape»)«ENDFOR»'''
	def generateParameter(OR and) '''«FOR panel : and.panels SEPARATOR ","»String panelName_«panel.escape»«ENDFOR»'''
	
	def generatePanelXORExistsMethod(Panel panel)'''
	«IF panel.container instanceof XOR»
		String panelExistsXOR«(panel.container as XOR).id.replace("-","")»_«panel.escape.replace("-","")»(String panelName){
			if(concretePanelExists(panelName)){
				if(«panel.concreteElement.escape.toFirstLower».getPanelInput() == ""){
					return «generateInvertedCommas»<«panel.concreteElement.tag» «setPreCondition(panel.concreteElement)»>«generatePanelDOM((panel.container as XOR).concreteElement.next)»</«panel.concreteElement.tag»>«generateInvertedCommas»;
				}else{
					return «generateInvertedCommas»
					<«panel.concreteElement.tag» «setPreCondition(panel.concreteElement)»>
					${«panel.concreteElement.escape.toFirstLower».getPanelInput()}
					«generatePanelDOM((panel.container as XOR).concreteElement.next)»
					</«panel.concreteElement.tag»>«generateInvertedCommas»;
				}
			}
			return "";
		}
		«ENDIF»
	'''
	
	def generatePanelORExistsMethod(Panel panel)'''
	«IF panel.container instanceof OR»
		String panelExistsOR«(panel.container as OR).id.replace("-","")»_«panel.escape.replace("-","")»(String panelName){
			if(concretePanelExists(panelName)){
				if(«panel.concreteElement.escape.toFirstLower».getPanelInput() == ""){
					return «generateInvertedCommas»<«panel.concreteElement.tag» «setPreCondition(panel.concreteElement)»>«generatePanelDOM((panel.container as OR).concreteElement.next)»</«panel.concreteElement.tag»>«generateInvertedCommas»;
				}else{
					return «generateInvertedCommas»
					<«panel.concreteElement.tag» «setPreCondition(panel.concreteElement)»>
					${«panel.concreteElement.escape.toFirstLower».getPanelInput()}
					«generatePanelDOM((panel.container as OR).concreteElement.next)»
					</«panel.concreteElement.tag»>«generateInvertedCommas»;
				}
			}
			return "";
		}
		«ENDIF»
	'''
	
	def generateConcretePanelExistsMethod()'''
	bool concretePanelExists(panelName){
				var eq = const Equality().equals;
				var panels = html.document.querySelectorAll('.panel');
				var panelX = null;
				panels.forEach((panel) {
					if(eq(panel.tagName, panelName)){
						panelX = panel;
					}
				});
				if(panelX != null){
					return true;
				}else{
					return false;
				}
			}
	'''
	
	
	def generatePreCondition()'''
	String setPreCondition(String panelName) {
			var eq = const Equality().equals;
			var panels = html.document.querySelectorAll('.panel');
			var panelX = null;
			panels.forEach((panel) {
				if(eq(panel.tagName, panelName)){
					panelX = panel;
				}
			});
			if(panelX != null){
				if(panelX.getAttribute("preCondition") != null){
					if(!eq(panelX.getAttribute("preCondition"), '')){
						return " preCondition='${panelX.getAttribute("preCondition")}'";
					}else{
						return "";
					}
				}
			}
			return "";
	}
	'''
	
	def List<Node> getNext(Node node){
		var nextNodes = new ArrayList<Node>()
		for(edge : node.outgoing){
			var target = edge.targetElement
			if(target instanceof FieldConstraint){
				var constraint = target as FieldConstraint
				var edges = constraint.outgoing
				for(edge1 : edges){
					var newTarget = edge1.targetElement
					nextNodes.add(newTarget)
				}
			}else{
				nextNodes.add(target)
			}
		}
		return nextNodes
		
	}
	
	def getTag(Node node){
		switch(node){
			AND: '''and«(node as AND).id.toLowerCase.replace("_","-")»'''
			XOR:'''xor-«(node as XOR).id.toLowerCase.replace("_","-")»'''
			OR:'''or«(node as OR).id.toLowerCase.replace("_","-")»'''
			Panel : '''«(node as Panel).escape.toLowerCase.replace("_","-")»'''
		}
	}
	
	def setPreCondition(Node container) {
		if(container instanceof OR){
			var or = container as OR
			var precondition = ""
			if(!or.incomingElses.isNullOrEmpty){
				return "preCondition='ELSE'";
			}
			if(!or.fieldConstraintPredecessors.isNullOrEmpty){
				for(constraint : or.fieldConstraintPredecessors){
					var label = constraint.label
					var operator = constraint.operator
					var value = constraint.value
					precondition +='''«label»_«operator»_«value»'''
				}
				return '''preCondition="«precondition»"'''
			}
		}
		else if (container instanceof AND){
			var and = container as AND
			var precondition = ""
			if(!and.incomingElses.isNullOrEmpty){
				return "preCondition='ELSE'";
			}
			if(!and.fieldConstraintPredecessors.isNullOrEmpty){
				for(constraint : and.fieldConstraintPredecessors){
					var label = constraint.label
					var operator = constraint.operator
					var value = constraint.value
					precondition +='''«label»_«operator»_«value»'''
				}
				return '''preCondition="«precondition»"'''
			}
		}else if(container instanceof XOR){
			return '''${setPreCondition("XOR_«(container as XOR).id.replace("_", "").replace("-","")»")}'''	
		}
		else {
			return '''${setPreCondition("«container.escape.toUpperCase.replace("_","-")»")}'''			
		}
	}
	
	
	

	
	
	def generateToJson(Dependency dep)'''
	@override
	Map toJson(Map cache) {
		Map json = new Map<String, dynamic>();
		if (cache.containsKey(id)) {
			json["id"]=id;
		} else {
			cache[id] = this;
			json["id"] = id;
			json['__type'] = "«dep.escape»";
			json["name"] = name;
			json["start"] = start == null ? null : start.toJson(cache);
			json["doc"] = doc == null ? null : doc.toJson(cache);
			json["current"]= current == null ? null : current.toJson(cache);
			«generatePanelsJson(dep.allPanels.toList)»
			«generateXORs(dep.XORs)»
		}
		return json;
	}
	'''
	
	def generateXORs(EList<XOR> xors) '''
	«FOR xor : xors»
	json["xor_«xor.id.replace("_", "").replace("-","")»"] = xor_«xor.id.replace("_", "").replace("-","")» == null ? null : xor_«xor.id.replace("_", "").replace("-","")».toJson(cache);
	«ENDFOR»
	'''
	
	def generateFromJson(Dependency dep) '''
	«dep.escape».fromJson(dynamic json, Map cache) {
		id = json['id'];
		cache[id] = this;
		if(json.containsKey('start') && json['start'] != null){
			if(cache.containsKey(json['start']['id'])){
				start = cache[json['start']['id']];
			}else{
				«IF findFirstPanel(dep) !== null»
				start = «findFirstPanel(dep).getExactElement».fromJson(json['start'], cache);
				«ENDIF»
			}
		}
		if(json.containsKey('doc') && json['doc'] != null){
			if(cache.containsKey(json['doc']['id'])){
				doc = cache[json['doc']['id']];
			}else{
				doc = Document_«dep.escape».fromJson(json['doc'], cache);
			}
		}
		if(json.containsKey('current') && json['current'] != null){
			if(cache.containsKey(json['current']['id'])){
				current = cache[json['current']['id']];
			}else{
				switch(json['current']['__type']){
					«FOR panel : dep.allPanels»
					case "«panel.escape»" : current = «panel.escape».fromJson(json['current'], cache); break;
					«ENDFOR»
					«FOR xor : dep.XORs»
					case "XOR_«xor.id.replace("_", "").replace("-","")»" : current = XOR_«xor.id.replace("_", "").replace("-","")».fromJson(json['current'], cache); break;
					«ENDFOR»
				}
			}
		}
		«generateFromJsonForPanels(dep.allPanels.toList)»
		«generateFromJsonForXOR(dep.XORs)»
	}
	'''
	
	def generateFromJsonForXOR(EList<XOR> xors)'''
	«FOR xor : xors»
	if(json.containsKey('xor_«xor.id.replace("_", "").replace("-","")»') && json['xor_«xor.id.replace("_", "").replace("-","")»'] != null){
				if(cache.containsKey(json['xor_«xor.id.replace("_", "").replace("-","")»']['id'])){
					xor_«xor.id.replace("_", "").replace("-","")» = cache[json['xor_«xor.id.replace("_", "").replace("-","")»']['id']];
				}else{
					xor_«xor.id.replace("_", "").replace("-","")» = XOR_«xor.id.replace("_", "").replace("-","")».fromJson(json['xor_«xor.id.replace("_", "").replace("-","")»'], cache);
				}
	}
	«ENDFOR»
	'''
	
	
	def  getExactElement(Node container){
		if(container instanceof Panel){
			return '''«(container as Panel).escape»'''
		}else if (container instanceof AND){
			return '''«(container as AND).panels.get(0).escape»'''
		}
		else if (container instanceof OR){
			return '''«(container as OR).panels.get(0).escape»'''
		}
		else if (container instanceof XOR){
			return '''XOR_«(container as XOR).id.replace("_", "").replace("-","")»'''
		}
	}
	
	def generateFromJsonForPanels(List<Panel> panels) '''
	«FOR panel : panels»
	if(json.containsKey('«panel.escape.toFirstLower»') && json['«panel.escape.toFirstLower»'] != null){
		if(cache.containsKey(json['«panel.escape.toFirstLower»']['id'])){
			«panel.escape.toFirstLower» = cache[json['«panel.escape.toFirstLower»']['id']];
		}else{
			«panel.escape.toFirstLower» = «panel.escape».fromJson(json['«panel.escape.toFirstLower»'], cache);
		}
	}
	«ENDFOR»
	'''
	
	def maptoTmplPanel(List<Panel> panels){
		return panels.map[(panel as info.scce.cinco.product.documentproject.template.template.Panel)]
	}
	
	def generatePanelsJson(List<Panel> panels)'''
	«FOR panel : panels»
	json["«panel.escape.toFirstLower»"] = «panel.escape.toFirstLower» == null ? null : «panel.escape.toFirstLower».toJson(cache);
	«ENDFOR»
	'''
	
	
	
	def generateAddLogEntryPanel(Dependency dep) '''
	«FOR panel : dep.allPanels»
	void addLogEntry«panel.escape»(«panel.escape» panel, UserService _userService){
		var newLog = «panel.escape»LogEntry();
		newLog.date = DateTime.now();
		newLog.user = _userService.currentUser;
		«saveFieldContentLog(panel.tmplPanel)»
		newLog.content = {«generateContent(panel.panel as info.scce.cinco.product.documentproject.template.template.Panel)»};
		panel.logs.add(newLog);
	}
	
	«ENDFOR»
	'''
	
	def saveFieldContentLog(info.scce.cinco.product.documentproject.template.template.Panel panel)'''
	«FOR field : panel.fields»
	newLog.«field.escape» = panel.«field.escape»;
	«ENDFOR»
	'''
	
	def generateContent(info.scce.cinco.product.documentproject.template.template.Panel panel)'''«FOR field : panel.fields SEPARATOR ","»"«field.label»" : panel.«field.escape».toString()«ENDFOR»'''
	
	def generateAllPanelVariables(Dependency dep)'''
	«FOR panel : dep.allPanels»
	«panel.escape» «panel.escape.toFirstLower»;
	«ENDFOR»
	«FOR xor : dep.XORs»
	XOR_«xor.id.replace("_", "").replace("-","")» xor_«xor.id.replace("_", "").replace("-","")»;
	«ENDFOR»
	'''
	
	def generateDepConstructor(Dependency dep)'''
	«dep.escape»(Document document) : super.fromDocument(document){
		«IF findFirstPanel(dep) !== null»
	«««		if first and panel
			«IF findFirstPanel(dep) instanceof AND»
			«(findFirstPanel(dep) as AND).panels.get(0).escape.toFirstLower» = new «(findFirstPanel(dep) as AND).panels.get(0).escape»(document);
			start = «(findFirstPanel(dep) as AND).panels.get(0).escape.toFirstLower»;
			current = start;
			
			«FOR panel : (findFirstPanel(dep) as AND).panels.getOthers» 
			«panel.escape.toFirstLower» = new «panel.escape»(doc);
			current.next = «panel.escape.toFirstLower»;
			current = current.next;
			«ENDFOR»
			«ENDIF»
	«««		if first or
			«IF findFirstPanel(dep) instanceof OR»
			«(findFirstPanel(dep) as OR).panels.get(0).escape.toFirstLower» = new «(findFirstPanel(dep) as OR).panels.get(0).escape»(document);
			start = «(findFirstPanel(dep) as OR).panels.get(0).escape.toFirstLower»;
			current = start;
						
			«FOR panel : (findFirstPanel(dep) as OR).panels.getOthers» 
			«panel.escape.toFirstLower» = new «panel.escape»(doc);
			current.next = «panel.escape.toFirstLower»;
			current = current.next;
			«ENDFOR»
			«ENDIF»
	«««		if first xor
			«IF findFirstPanel(dep) instanceof XOR»
			xor_«(findFirstPanel(dep) as XOR).id.replace("_", "").replace("-","")» = new XOR_«(findFirstPanel(dep) as XOR).id.replace("_", "").replace("-","")»(doc);
			start = xor_«(findFirstPanel(dep) as XOR).id.replace("_", "").replace("-","")»;
			current = start;
			«ENDIF»
	«««		If panel
			«IF findFirstPanel(dep) instanceof Panel»
			«findFirstPanel(dep).escape.toFirstLower» = new «findFirstPanel(dep).escape»(document);
			start = «findFirstPanel(dep).escape.toFirstLower»;
			current = start;
			«ENDIF»
		«ENDIF»
	}
	'''
	
	def getOthers(EList<Panel> panels){
		var tmplPanels = new ArrayList<Panel>
		for(var i=1; i<panels.length; i++){
			tmplPanels.add(panels.get(i))
		}
		return tmplPanels
	}
	
	
	
	def generateContinuePanel(Dependency dep) '''
	«FOR panel : dep.allPanels»
	void continue«panel.escape»(ControlGroup myPanel,DocumentService _documentService,  NotificationService _notificationService, UserService _userService){
		«generateChoiceComparisonStuff(panel)»
		
		«generateChoiceContainComparisionStuff(panel)»
		
		if(!«panel.escape.toFirstLower».isSubmitted){
			«panel.escape.toFirstLower».isSubmitted = true;
			
			«saveFieldContent(panel)»
			«addUserFieldContent(panel)»
			addLogEntry«panel.escape»(«panel.escape.toFirstLower», _userService);
			Notification notification = Notification("Success!", "'"+«panel.escape.toFirstLower».name + "' submitted.");
			_notificationService.notify(notification);
			_documentService.persist();
			
			«generateFactory(panel)»
		}else{
			«saveFieldContent(panel)»
			«addUserFieldContent(panel)»
			addLogEntry«panel.escape»(«panel.escape.toFirstLower», _userService);
			«saveLog(panel)»
			
			«generateFactoryAfterEdit(panel)»
			Notification notification = Notification("Success!", "'"+«panel.escape.toFirstLower».name + "': changes saved.");
			_notificationService.notify(notification);
			_documentService.persist();
		}
		_documentService.persist();
	}
	
	«ENDFOR»
	'''
	
	def saveLog(Panel panel) {
		for (edge : panel.outgoingPanelToConstraints) {
			var target = edge.targetElement
			if (target instanceof ChoiceFieldConstraint) {
				var field = (target as ChoiceFieldConstraint).field as ChoiceField
				return '''List<String>  «field.escape»_logs = new List();
				«field.escape»_logs.add(«panel.escape.toFirstLower».logs[«panel.escape.toFirstLower».logs.length-2].«field.escape»);'''
			}
		}
	}

	def generateChoiceContainComparisionStuff(Panel panel)'''
	«IF hasChoiceContainConstraint(panel)»
		bool containsElement(List<String> contents , List<String> compare){
							var contains = true;
							compare.forEach((element){
								if(!contents.contains(element)){
									contains = false;
								}
							});
					return contains;
				}
		 «ENDIF»
	'''
	
	def addUserFieldContent(Panel panel) {
		for (edge : panel.outgoingPanelToConstraints) {
			var target = edge.targetElement
			if (target instanceof ChoiceFieldConstraint) {
				var field = (target as ChoiceFieldConstraint).field as ChoiceField
				return '''«field.escape».add(«panel.escape.toFirstLower».«field.escape»);'''
			}

		}
	}
	
	def generateChoiceComparisonStuff(Panel panel)'''
	«IF hasChoiceEqualConstraint(panel)»
	Function eq = const ListEquality().equals;
	 «ENDIF»
	«FOR fieldConstraintName : generateUserFieldContent(panel)»
	List<String> «fieldConstraintName» = <String>[]; 
	«ENDFOR»
	«FOR edge : panel.outgoingPanelToConstraints»
	«IF edge.targetElement instanceof ChoiceFieldConstraint»
	«var choice = edge.targetElement as ChoiceFieldConstraint»
	List<String> «escapeCompareName(choice)» = <String>[];
	«fillCompareList(choice)»
	«ENDIF»
	«ENDFOR»
	'''
	
	def hasChoiceEqualConstraint(Panel panel) {
		for(edge : panel.outgoingPanelToConstraints){
			if(edge.targetElement instanceof ChoiceFieldConstraint){
				var choice = edge.targetElement as ChoiceFieldConstraint
				if(choice.operator.getName == "equal"){
					return true;
				}
			}
		}
		return false;
	}
	
	def hasChoiceContainConstraint(Panel panel) {
		for(edge : panel.outgoingPanelToConstraints){
			if(edge.targetElement instanceof ChoiceFieldConstraint){
				var choice = edge.targetElement as ChoiceFieldConstraint
				if(choice.operator.getName == "in" || choice.operator.getName == "notIn"){
					return true;
				}
			}
		}
		return false;
	}
	
	def generateUserFieldContent(Panel panel) {
		var ArrayList<String> fields = new ArrayList()
		for(edge : panel.outgoingPanelToConstraints){
			var target = edge.targetElement
			if(target instanceof ChoiceFieldConstraint){
				var field = (target as ChoiceFieldConstraint).field as ChoiceField
				fields.add(field.escape)
			}
		}
		var unqiueFields = fields.stream().distinct().collect(Collectors.toList());
		return unqiueFields
	}
	
	def generateContinueXORPanel(Dependency dep) '''
	«FOR xor : dep.XORs»
	void continueXOR_«xor.id.replace("_", "").replace("-","")»(DocumentService _documentService, NotificationService _notificationService, String panelName ){
			if(!xor_«xor.id.replace("_", "").replace("-","")».isSubmitted){
				xor_«xor.id.replace("_", "").replace("-","")».isSubmitted = true;
				
				«FOR panel : xor.panels»
				if(panelName == "«panel.escape.toFirstLower»"){
					«panel.escape.toFirstLower» = new «panel.escape.toFirstUpper»(doc);
					current.next = «panel.escape.toFirstLower»;
					current = current.next;
				}
				«ENDFOR»
				Notification notification = Notification("Success!", "'" + xor_«xor.id.replace("_", "").replace("-","")».name + "' submitted.");
				_notificationService.notify(notification);
				_documentService.persist();
			}else{
				current = xor_«xor.id.replace("_", "").replace("-","")»;
				«FOR panel : xor.panels»
				if(panelName == "«panel.escape.toFirstLower»"){
					«panel.escape.toFirstLower» = new «panel.escape.toFirstUpper»(doc);
					current.next = «panel.escape.toFirstLower»;
					current = current.next;
				}
				«ENDFOR»
				Notification notification = Notification("Success!", "'" + xor_«xor.id.replace("_", "").replace("-","")».name + "': changes saved.");
				_notificationService.notify(notification);
				_documentService.persist();
			}
	
		}
	«ENDFOR»
	'''
		
	def generateFactoryAfterEdit(Panel panel)'''
	«IF !panel.outgoingPanelToConstraints.isNullOrEmpty»
		«FOR edge : panel.outgoingPanelToConstraints»
		//condition
		«generateAdjustedCondition(panel, edge.targetElement)»
		«ENDFOR»
	«ENDIF»
	'''
	
	def generateAdjustedCondition(Panel panel, FieldConstraint constraint)'''
	«IF ! (constraint instanceof DateFieldConstraint) && ! (constraint instanceof ChoiceFieldConstraint)»
		if(«generateFirst(panel,constraint)» && «generateSecond(panel, constraint)»){
			//step after condition
			current = «panel.escape.toFirstLower»;
			«««			TODO:
			//anderen auf null, rest anlegen (steps quasi tauschen)
			«generateStepAfterCondition(constraint.outgoing)»
		}
		«ENDIF»
		«IF constraint instanceof DateFieldConstraint»
		if(«generateFirstDate(panel, constraint)» && «generateSecondDate(panel,constraint)»){
			//step after condition
			current = «panel.escape.toFirstLower»;
			«««			TODO:
			//anderen auf null, rest anlegen (steps quasi tauschen)
			«generateStepAfterCondition(constraint.outgoing)»
		}
		«ENDIF»
		«IF constraint instanceof ChoiceFieldConstraint»
		«IF constraint.operator.getName == "equal"»
		if(«generateFirstChoiceEqual(panel, constraint)» && «generateSecondChoiceEqual(panel,constraint)»){
			//step after condition
			current = «panel.escape.toFirstLower»;
			«««			TODO:
			//anderen auf null, rest anlegen (steps quasi tauschen)
			«generateStepAfterCondition(constraint.outgoing)»
		}
		«ELSE»
		if(«generateFirstChoiceOther(panel, constraint)» && «generateSecondChoiceOther(panel, constraint)»){
			//step after condition
			current = «panel.escape.toFirstLower»;
«««			TODO:
			//anderen auf null, rest anlegen (steps quasi tauschen)
			«generateStepAfterCondition(constraint.outgoing)»
		}
		«ENDIF»
		«ENDIF»
	'''
	
	def generateSecondChoiceOther(Panel panel, ChoiceFieldConstraint constraint)'''!(«generateNot(constraint)»containsElement(«getFieldConstraintLabel(constraint)»_logs, «escapeCompareName(constraint)»))'''
	
	def generateFirstChoiceOther(Panel panel, ChoiceFieldConstraint constraint)'''«generateNot(constraint)»containsElement(«getFieldConstraintLabel(constraint)»,«escapeCompareName(constraint)»)'''
	
	def generateSecondChoiceEqual(Panel panel, ChoiceFieldConstraint constraint)'''!(«generateNot(constraint)»eq(«panel.escape.toFirstLower».logs[«panel.escape.toFirstLower».logs.length-2].«getFieldConstraintLabel(constraint)»,«escapeCompareName(constraint)»))'''
	
	def generateFirstChoiceEqual(Panel panel, ChoiceFieldConstraint constraint)'''«generateNot(constraint)»eq(«getFieldConstraintLabel(constraint)»,«escapeCompareName(constraint)»)'''
	
	def generateSecondDate(Panel panel, DateFieldConstraint constraint)'''!((«panel.escape.toFirstLower».logs[«panel.escape.toFirstLower».logs.length-2].«getFieldConstraintLabel(constraint)»«constraint.generateOperatorValue»))'''
	
	def generateFirstDate(Panel panel, DateFieldConstraint constraint)'''«panel.escape.toFirstLower».«getFieldConstraintLabel(constraint)»«constraint.generateOperatorValue»'''
	
	def generateSecond(Panel panel, FieldConstraint constraint)'''
	!(«panel.escape.toFirstLower».logs[«panel.escape.toFirstLower».logs.length-2].«getFieldConstraintLabel(constraint)»«generateComparision(constraint)»)
	'''
	
	def generateFirst(Panel panel, FieldConstraint constraint)'''«IF constraint instanceof ChoiceFieldConstraint»«getFieldConstraintLabel(constraint)»«generateComparision(constraint)»«ELSE»«panel.escape.toFirstLower».«getFieldConstraintLabel(constraint)»«generateComparision(constraint)»«ENDIF»'''
	
	
	def saveFieldContent(Panel panel) '''
	«FOR field : panel.tmplPanel.fields»
	«IF !(field instanceof DateField)»
	«panel.escape.toFirstLower».«field.escape» = myPanel.controls['«field.escape»'].value;
	«ELSE»
	«panel.escape.toFirstLower».«field.escape» = DateTime.parse(myPanel.controls['«field.escape»'].value);
	«ENDIF»
	«ENDFOR»'''
	
	
	def generateFactory(Panel panel) '''
	«IF !panel.outgoingPanelToConstraints.isNullOrEmpty»
	//condition
	«generateCondition(panel)»
	«ELSE»
	«IF panel.panelIsInAnd»
	//if
	«generateIF(panel)»
	«ENDIF»
	«IF panel.panelIsInOr»
	«generateIFOr(panel)»
	«ENDIF»
	«IF panel.panelIsInXOR»
	«generateIFXOR(panel)»
	«ENDIF»
	«IF !panel.panelIsInAnd && ! panel.panelIsInOr && ! panel.panelIsInXOR»
	//simple step
	«generateStep(panel)»
	«ENDIF»
	«ENDIF»
	
	'''
	
	
	/**
	 * Generates the if, else-if, else statements for the defined constraints
	 */
	def generateCondition(Panel panel)'''
	«FOR edge : panel.outgoingPanelToConstraints BEFORE "if" SEPARATOR "else if" »
		«var constraint = edge.targetElement»
		«IF ! (constraint instanceof DateFieldConstraint) && ! (constraint instanceof ChoiceFieldConstraint)»
		(«panel.escape.toFirstLower».«getFieldConstraintLabel(constraint)»«generateComparision(constraint)»){
			//step after condition
			«generateStepAfterCondition(constraint.outgoing)»
		}
		«ENDIF»
		«IF constraint instanceof DateFieldConstraint»
		(«panel.escape.toFirstLower».«getFieldConstraintLabel(constraint)»«constraint.generateOperatorValue»){
			//step after condition
			«generateStepAfterCondition(constraint.outgoing)»
		}
		«ENDIF»
		«IF constraint instanceof ChoiceFieldConstraint»
		«IF constraint.operator.getName == "equal"»
		(eq(«generateNot(constraint)»«getFieldConstraintLabel(constraint)»,«escapeCompareName(constraint)»)){
			//step after condition
			«generateStepAfterCondition(constraint.outgoing)»
		}
		«ELSE»
		(«generateNot(constraint)»containsElement(«getFieldConstraintLabel(constraint)»,«escapeCompareName(constraint)»)){
			//step after condition
			«generateStepAfterCondition(constraint.outgoing)»
		}
		«ENDIF»
		«ENDIF»«ENDFOR»
		«generateElse(panel)»
		'''
	
	
	def dispatch generateElse(Panel panel)'''
		«IF !panel.outgoingElses.isNullOrEmpty»
		else{
			//step after else
			«generateStepAfterConditionElse(panel.outgoingElses)»
		}
		«ENDIF»
	'''
	
	def dispatch generateElse(AND and)'''
		«IF !and.outgoingElses.isNullOrEmpty»
		else{
			//step after else
			«generateStepAfterConditionElse(and.outgoingElses)»
		}
		«ENDIF»
	'''
	
	def dispatch generateElse(OR or)'''
		«IF !or.outgoingElses.isNullOrEmpty»
		else{
			//step after else
			«generateStepAfterConditionElse(or.outgoingElses)»
		}
		«ENDIF»
	'''
	
	def dispatch generateElse(XOR xor)'''
		«IF !xor.outgoingElses.isNullOrEmpty»
		else{
			//step after else
			«generateStepAfterConditionElse(xor.outgoingElses)»
		}
		«ENDIF»
	'''
	
	
	
	
	def fillCompareList(ChoiceFieldConstraint constraint) '''
	«FOR element : constraint.value»
	«escapeCompareName(constraint)».add("«element»");
	«ENDFOR»'''
	
	def escapeCompareName(ChoiceFieldConstraint constraint) {
		return '''compare«constraint.operator.getName»«constraint.value.toName.toFirstUpper»'''
	}
	
	def toName(EList<String> list){
		var name = ""
		for(element : list) {
			name += element
		}
		return name
	}
	
	def generateNot(ChoiceFieldConstraint constraint) {
		if(constraint.operator.getName=="notIn"){
			return '''!'''
		}
	}
	
	def  generateStepAfterCondition(EList<Must> edges) {
		for( edge : edges){
			switch(edge.targetElement){
				AND : return '''«generateStepOfAND(edge.targetElement as AND)»'''
				OR: return '''«generateStepOfOr(edge.targetElement as OR)»'''
				XOR: return '''«generateStepOfXOR(edge.targetElement as XOR)»'''
				Panel : return '''«generateStepOfPanel(edge.targetElement as Panel)»'''
			}
		}
	}
	
	def  generateStepAfterConditionElse(EList<Else> edges) {
		for( edge : edges){
			switch(edge.targetElement){
				AND : return '''«generateStepOfAND(edge.targetElement as AND)»'''
				OR: return '''«generateStepOfOr(edge.targetElement as OR)»'''
				XOR: return '''«generateStepOfXOR(edge.targetElement as XOR)»'''
				Panel : return '''«generateStepOfPanel(edge.targetElement as Panel)»'''
			}
		}
	}

	
	def generateStepOfPanel(Panel panel) '''
	«IF panel.incomingMusts.length <= 1»
	«panel.escape.toFirstLower» = new «panel.escape»(doc);
	current.next = «panel.escape.toFirstLower»;
	current = current.next;
	
	«ELSE»
	if(«isNotNullSimple(panel)» «isSubmittedSimple(panel)»){
		«panel.escape.toFirstLower» = new «panel.escape»(doc);
		current.next = «panel.escape.toFirstLower»;
		current = current.next;
	}
	«ENDIF»
	
	'''
	def generateStepOfXOR(XOR xor) '''
	xor_«xor.id.replace("_", "").replace("-","")» = new XOR_«xor.id.replace("_", "").replace("-","")»(doc);
	current.next = xor_«xor.id.replace("_", "").replace("-","")»;
	current = current.next;
	'''
	
	def generateStepOfOr(OR or) '''
	«FOR panel : or.panels»
	«generateStepOfPanel(panel)»
	«ENDFOR»'''
	
	def generateStepOfAND(AND and) '''
	«FOR panel : and.panels»
	«generateStepOfPanel(panel)»
	«ENDFOR»'''
	
	def generateIF(Panel currentPanel) '''
	if(«FOR panel : (currentPanel.container as AND).panels SEPARATOR " && "»«panel.escape.toFirstLower».isSubmitted«ENDFOR»){ «««and abfrage
		«IF !(currentPanel.container as AND).outgoingPanelToConstraints.isNullOrEmpty»
		«FOR edge : (currentPanel.container as AND).outgoingPanelToConstraints BEFORE "if" SEPARATOR "else if"»  «««wenn nach nem and noch fieldconstraints kommen
			//condition after and-container
			«generateConditionAfterIF(getPanel(edge, (currentPanel.container as AND).panels), edge.targetElement)»
		«ENDFOR»
		«generateElse((currentPanel.container as AND))»
		«ELSE»
		//simple step after if AND-panel 
		«IF !(currentPanel.container as AND).XORSuccessors.isNullOrEmpty»  «««normalre step mit xor
					«FOR xor : (currentPanel.container as AND).XORSuccessors»
					«generateStepOrAndPanel(xor)»
					«ENDFOR»
				«ELSE»
		«generateStepOrAndPanel(getANDSuccessors(currentPanel.container as AND), currentPanel)»  «««normaler step
		«ENDIF»
		«ENDIF»
	}
	'''
	
	def generateIFXOR(Panel currentPanel) '''
		«IF !(currentPanel.container as XOR).outgoingPanelToConstraints.isNullOrEmpty»
			«FOR edge : (currentPanel.container as XOR).outgoingPanelToConstraints BEFORE "if" SEPARATOR "else if"»  «««wenn nach nem xor noch fieldconstraints kommen
			//condition after xor-container
			«generateConditionAfterIF(getPanel(edge, (currentPanel.container as XOR).panels), edge.targetElement)»
		«ENDFOR»
		«generateElse((currentPanel.container as XOR))»
		«ELSE»
		//simple step after if XOR-panel
		«IF !(currentPanel.container as XOR).XORSuccessors.isNullOrEmpty»
			«FOR xor : (currentPanel.container as XOR).XORSuccessors»
			«generateStepOrAndPanel(xor)»
			«ENDFOR»
		«ELSE»
		«generateStepOrAndPanel(getXORSuccessors(currentPanel.container as XOR), currentPanel)»
		«ENDIF»
		«ENDIF»
	'''
	
	def generateIFOr(Panel currentPanel) '''
	if(!(«FOR panel : filterOtherPanels((currentPanel.container as OR).panels, currentPanel) SEPARATOR "|| "»«panel.escape.toFirstLower».isSubmitted«ENDFOR»)){
			
			«IF !(currentPanel.container as OR).outgoingPanelToConstraints.isNullOrEmpty»
			«FOR edge : (currentPanel.container as OR).outgoingPanelToConstraints BEFORE "if" SEPARATOR "else if"»  «««wenn nach nem or noch fieldconstraints kommen
				//condition after or-container
				«generateConditionAfterIF(getPanel(edge, (currentPanel.container as OR).panels), edge.targetElement)»
			«ENDFOR»
			«generateElse((currentPanel.container as OR))»
					«ELSE»
			//simple step after if OR-panel
			«IF !(currentPanel.container as OR).XORSuccessors.isNullOrEmpty»
					«FOR xor : (currentPanel.container as OR).XORSuccessors»
					«generateStepOrAndPanel(xor)»
					«ENDFOR»
			«ELSE»
			«generateStepOrAndPanel(getORSuccessors(currentPanel.container as OR), currentPanel)»
			«ENDIF»«ENDIF»
		}
	'''
	
	def generateConditionAfterIF(Panel panel, FieldConstraint constraint) '''
	«IF ! (constraint instanceof DateFieldConstraint) && ! (constraint instanceof ChoiceFieldConstraint)»
				(«panel.escape.toFirstLower».«getFieldConstraintLabel(constraint)»«generateComparision(constraint)»){
					//step after condition
					«generateStepAfterCondition(constraint.outgoing)»
				}
				«ENDIF»
				«IF constraint instanceof DateFieldConstraint»
				(«panel.escape.toFirstLower».«getFieldConstraintLabel(constraint)»«constraint.generateOperatorValue»){
					//step after condition
					«generateStepAfterCondition(constraint.outgoing)»
				}
				«ENDIF»
				«IF constraint instanceof ChoiceFieldConstraint»
				«IF constraint.operator.getName == "equal"»
				(eq(«generateNot(constraint)»«getFieldConstraintLabel(constraint)»,«escapeCompareName(constraint)»)){
					//step after condition
					«generateStepAfterCondition(constraint.outgoing)»
				}
				«ELSE»
				(«generateNot(constraint)»containsElement(«panel.escape.toFirstLower».«getFieldConstraintLabel(constraint)»,«escapeCompareName(constraint)»)){
					//step after condition
					«generateStepAfterCondition(constraint.outgoing)»
				}
				«ENDIF»
	«ENDIF»	
	'''
	
	
	
	
	
	def filterOtherPanels(EList<Panel> list, Panel currentPanel) {
		var filteredList = new ArrayList();
		for(panel : list){
			if(!panel.equals(currentPanel)){
				filteredList.add(panel)
			}
		}
		
		return filteredList
	}
	
	def getPanel(PanelToConstraint constraint, EList<Panel> panels) {
		var target = constraint.targetElement
		for (panel : panels){
			for(field : panel.tmplPanel.fields){
				if(field.label.equals(target.label)){
					return panel
				}
			}
		}
	}
	
	def generateStepOrAndPanel(XOR xor)'''
		«IF xor.incomingMusts.length <= 1»
				xor_«xor.id.replace("_", "").replace("-","")» = new XOR_«xor.id.replace("_", "").replace("-","")»(doc);
				current.next = xor_«xor.id.replace("_", "").replace("-","")»;
				current = current.next;
				
				«ELSE»	
				if(«isNotNullSimple(xor)» «isSubmittedSimple(xor)»){
					xor_«xor.id.replace("_", "").replace("-","")» = new XOR_«xor.id.replace("_", "").replace("-","")»(doc);
					current.next = xor_«xor.id.replace("_", "").replace("-","")»;
					current = current.next;
					
				}
				«ENDIF»	
	'''
	
def generateStepOrAndPanel(ArrayList<Panel> panels, Panel xor)'''
	«FOR succesor : panels»
		«IF succesor instanceof XOR»
			«var xor2 = succesor as XOR»
			«generateStepOfXOR(xor2)»
		«ELSE»
			«var succ = succesor as Panel»
			«IF succ.incomingMusts.length <= 1»
			«succ.escape.toFirstLower» = new «succ.escape»(doc);
			current.next = «succ.escape.toFirstLower»;
			current = current.next;
			«ELSE»	
			«IF !succ.XORPredecessors.isNullOrEmpty»
			«FOR xor1 : succ.XORPredecessors»
			«FOR panelInXOR : xor1.panels BEFORE "if(" SEPARATOR "else if("»
			«isNotNullpanelInXor(succ, panelInXOR)» «isSubmittedpanelInXor(succ, panelInXOR)»){
				«succ.escape.toFirstLower» = new «succ.escape»(doc);
				current.next = «succ.escape.toFirstLower»;
				current = current.next;
			}
			«ENDFOR»
			«ENDFOR»
			«ELSE»
			if(«isNotNullpanelInXor(succ, xor)» «isSubmittedpanelInXor(succ, xor)»){
				«succ.escape.toFirstLower» = new «succ.escape»(doc);
				current.next = «succ.escape.toFirstLower»;
				current = current.next;
			}
			«ENDIF»
			«ENDIF»	
		«ENDIF»
		«ENDFOR»
	'''
	
	def generateStep(Panel panel) '''
	«FOR succesor : panel.getPanelSuccesor»
	«IF succesor instanceof XOR»
		«var xor = succesor as XOR»
		«generateStepOfXOR(xor)»
	«ELSE»
		«var succ = succesor as Panel»
		«IF succ.incomingMusts.length <= 1»
		«succ.escape.toFirstLower» = new «succ.escape»(doc);
		current.next = «succ.escape.toFirstLower»;
		current = current.next;
		«ELSE»	
		«IF !succ.XORPredecessors.isNullOrEmpty»
		«FOR xor : succ.XORPredecessors»
		«FOR panelInXOR : xor.panels BEFORE "if(" SEPARATOR "else if("»
		«isNotNullpanelInXor(succ, panelInXOR)» «isSubmittedpanelInXor(succ, panelInXOR)»){
			«succ.escape.toFirstLower» = new «succ.escape»(doc);
			current.next = «succ.escape.toFirstLower»;
			current = current.next;
		}
		«ENDFOR»
		«ENDFOR»
		«ELSE»
		if(«isNotNullpanelInXor(succ, panel)» «isSubmittedpanelInXor(succ, panel)»){
			«succ.escape.toFirstLower» = new «succ.escape»(doc);
			current.next = «succ.escape.toFirstLower»;
			current = current.next;
		}
		«ENDIF»
		«ENDIF»	
	«ENDIF»
	«ENDFOR»
	'''
	
	def isSubmittedpanelInXor(Panel succ, Panel current) '''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " &&" »«previousPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR "||" AFTER ")"»«previousORPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousXORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousXORPanel : succ.previousXORPanels.filter[it.equals(current)]»«previousXORPanel.escape.toFirstLower».isSubmitted«ENDFOR»'''

	
	def isNotNullpanelInXor(Panel succ, Panel current)'''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " && " AFTER "&&"»«previousPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR " || "AFTER ") &&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousXORPanels.filter[it.equals(current)] AFTER "&&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»'''
	
	def isSubmittedpanelInXor(Panel succ, XOR current) '''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " &&" »«previousPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR "||" AFTER ")"»«previousORPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousXORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousXORPanel : succ.previousXORPanels.filter[it.equals(current)]»«previousXORPanel.escape.toFirstLower».isSubmitted«ENDFOR»'''

	
	def isNotNullpanelInXor(Panel succ, XOR current)'''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " && " AFTER "&&"»«previousPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR " || "AFTER ") &&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousXORPanels.filter[it.equals(current)] AFTER "&&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»'''
	
	def isSubmittedpanelInXor(Panel succ, OR current) '''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " &&" »«previousPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR "||" AFTER ")"»«previousORPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousXORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousXORPanel : succ.previousXORPanels.filter[it.equals(current)]»«previousXORPanel.escape.toFirstLower».isSubmitted«ENDFOR»'''

	
	def isNotNullpanelInXor(Panel succ, OR current)'''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " && " AFTER "&&"»«previousPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR " || "AFTER ") &&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousXORPanels.filter[it.equals(current)] AFTER "&&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»'''
	
	def isSubmittedpanelInXor(Panel succ, AND current) '''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " &&" »«previousPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR "||" AFTER ")"»«previousORPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousXORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousXORPanel : succ.previousXORPanels.filter[it.equals(current)]»«previousXORPanel.escape.toFirstLower».isSubmitted«ENDFOR»'''

	
	def isNotNullpanelInXor(Panel succ, AND current)'''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " && " AFTER "&&"»«previousPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR " || "AFTER ") &&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousXORPanels.filter[it.equals(current)] AFTER "&&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»'''
	
	def isNotNullSimple(Panel succ)'''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " && " AFTER "&&"»«previousPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousORPanels + succ.previousXORPanels  BEFORE "(" SEPARATOR " || "AFTER ") &&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»'''
		
	def isNotNullSimple(XOR succ)'''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " && "AFTER "&&"»«previousPanel.escape.toFirstLower» != null«ENDFOR»«FOR previousORPanel : succ.previousORPanels + succ.previousXORPanels BEFORE "(" SEPARATOR " || "AFTER ") &&"»«previousORPanel.escape.toFirstLower» != null«ENDFOR»'''
	
	def isSubmittedSimple(Panel succ)'''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " &&" »«previousPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR "||" AFTER ")"»«previousORPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousXORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousXORPanel : succ.previousXORPanels BEFORE "(" SEPARATOR "^"  AFTER ")"»«previousXORPanel.escape.toFirstLower».isSubmitted«ENDFOR»'''

	def isSubmittedSimple(XOR succ)'''«FOR previousPanel :  succ.previousPanelsWithoutORXOR SEPARATOR " && " AFTER "&&"»«previousPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousORPanel : succ.previousORPanels BEFORE "(" SEPARATOR "||"  AFTER ") &&"»«previousORPanel.escape.toFirstLower».isSubmitted«ENDFOR»«IF !succ.previousXORPanels.isNullOrEmpty»&&«ENDIF»«FOR previousXORPanel : succ.previousXORPanels BEFORE "(" SEPARATOR "^"  AFTER ")"»«previousXORPanel.escape.toFirstLower».isSubmitted«ENDFOR»'''

	
	def ArrayList<Panel>  getPreviousPanelsWithoutORXOR(Panel panel){
		var ArrayList<Panel> previousPanels = new ArrayList()
		for( edge : panel.incomingMusts){
			previousPanels = getPanelNodeWithoutXOROR(edge.sourceElement, previousPanels)
		}
		
		return previousPanels
	}
	
	
	
	def ArrayList<Panel>  getPreviousPanelsWithoutORXOR(XOR panel){
		var ArrayList<Panel> previousPanels = new ArrayList()
		for( edge : panel.incomingMusts){
			previousPanels = getPanelNodeWithoutXOROR(edge.sourceElement, previousPanels)
		}
		
		return previousPanels
	}
	
	
	def ArrayList<Panel> previousPanels(Panel panel){
		var ArrayList<Panel> previousPanels = new ArrayList()
		for( edge : panel.incomingMusts){
			previousPanels = getPanelNode(edge.sourceElement, previousPanels)
		}
		
		return previousPanels
	}
	
	def ArrayList<Panel> previousPanels(XOR xor){
		var ArrayList<Panel> previousPanels = new ArrayList()
		for( edge : xor.incomingMusts){
			previousPanels = getPanelNode(edge.sourceElement, previousPanels)
		}
		
		return previousPanels
	}
	
	def List<Panel> previousORPanels(Panel panel) {
		var List<Panel> previousPanels = new ArrayList()
		for (edge : panel.incomingMusts) {
			if (edge.sourceElement instanceof OR) {
				previousPanels = (edge.sourceElement as OR).panels
			}
		}
		return previousPanels
	}
	
	def List<Panel> previousXORPanels(Panel panel) {
		var List<Panel> previousPanels = new ArrayList()
		for (edge : panel.incomingMusts) {
			if (edge.sourceElement instanceof XOR) {
				previousPanels = (edge.sourceElement as XOR).panels
			}
		}
		return previousPanels
	}
	
	def List<Panel> previousORPanels(XOR panel){
		var List<Panel> previousPanels = new ArrayList()
		for( edge : panel.incomingMusts){
			previousPanels = (edge.sourceElement as OR).panels
		}
		return previousPanels
	}
	
	def List<Panel> previousXORPanels(XOR panel){
		var List<Panel> previousPanels = new ArrayList()
		for( edge : panel.incomingMusts){
			previousPanels = (edge.sourceElement as XOR).panels
		}
		return previousPanels
	}
	
	
	def getPanelNodeWithoutXOROR(Node node, ArrayList<Panel> panels) {
		if(node instanceof Panel){
			var panelNode = node as Panel
			panels.add(panelNode)
			return panels
		}else if (node instanceof FieldConstraint){
			panels.addAll((node as FieldConstraint).panelPredecessors)
			return panels
		}else if(node instanceof AND){
			var panelNode = node as AND
			panels.addAll(panelNode.panels)
			return panels
		}else{
			return panels
		}
	}
	

	def ArrayList<Panel> getPanelNode(Node node, ArrayList<Panel> panels){
		if(node instanceof Panel){
			var panelNode = node as Panel
			panels.add(panelNode)
			return panels
		}else if (node instanceof FieldConstraint){
			panels.addAll((node as FieldConstraint).panelPredecessors)
			return panels
		}else if(node instanceof AND){
			var panelNode = node as AND
			panels.addAll(panelNode.panels)
			return panels
		}else if(node instanceof OR){
			var panelNode = node as OR
			panels.addAll(panelNode.panels)
			return panels
		}else if(node instanceof XOR){
			var panelNode = node as XOR
			panels.addAll(panelNode.panels)
			return panels
		}
	}
	
	def ArrayList<Panel> getORSuccessors(OR or){
		var ArrayList<Panel> successors = new ArrayList()
		for(edge : or.outgoing){
			switch(edge.targetElement){
				Panel: successors.add(edge.targetElement as Panel)
				FieldConstraint: successors.addAll((edge.targetElement as FieldConstraint).panelSuccessors)
				AND: successors.addAll((edge.targetElement as AND).panels)
				OR:successors.addAll((edge.targetElement as OR).panels)
			}
		}
		return successors
	}
	
	def ArrayList<Panel> getANDSuccessors(AND and){
		var ArrayList<Panel> successors = new ArrayList()
		for(edge : and.outgoing){
			switch(edge.targetElement){
				Panel: successors.add(edge.targetElement as Panel)
				FieldConstraint: successors.addAll((edge.targetElement as FieldConstraint).panelSuccessors)
				AND: successors.addAll((edge.targetElement as AND).panels)
				OR:successors.addAll((edge.targetElement as OR).panels)
			}
		}
		return successors
	}
	
	def ArrayList<Panel> getXORSuccessors(XOR xor){
		var ArrayList<Panel> successors = new ArrayList()
		for(edge : xor.outgoing){
			switch(edge.targetElement){
				Panel: successors.add(edge.targetElement as Panel)
				FieldConstraint: successors.addAll((edge.targetElement as FieldConstraint).panelSuccessors)
				AND: successors.addAll((edge.targetElement as AND).panels)
				OR:successors.addAll((edge.targetElement as OR).panels)
			}
		}
		return successors
	}
	
	/***
	 * erturns panel successor and also succesor of panels which are in an and/or container
	 ***/
	def  getPanelSuccesor(Panel panel){
		var all = new ArrayList<Node>()
		if(panelIsInAnd(panel)){
			all.addAll(getANDSuccessors((panel.container as AND)))
		}
		if(panelIsInOr(panel)){
			all.addAll(getORSuccessors((panel.container as OR)))
		}
		if(panelIsInXOR(panel)){
			all.addAll(getXORSuccessors((panel.container as XOR)))
		}
		if(panel.panelHasANDSuccesor){
			all.addAll(getAllPanelsInAnd(panel))
		}
		if(panel.panelHasORSuccesor){
			all.addAll(getAllPanelsInOr(panel))
		}
		if(panel.panelHasXORSuccesor){
			all.addAll(panel.XORSuccessors)
		}
		if(!panel.outgoingPanelToConstraints.isNullOrEmpty){
			var edges = panel.outgoingPanelToConstraints
			for(edge : edges){
				var field = edge.targetElement
				all.addAll(field.panelSuccessors)
			}
		}
		all.addAll(panel.panelSuccessors)
		return all
	}
	
	
	def getAllPanelsInXOR(Panel panel) {
		var allPanels = new ArrayList<Panel>()
		var xors =panel.XORSuccessors
		var edges = panel.outgoingPanelToConstraints
		for(edge : edges){
			var field = edge.targetElement
			var xors2 = field.XORSuccessors
			for(xor : xors2){
				allPanels.addAll(xor.panels)
			}
		}
		for(xor : xors){
			allPanels.addAll(xor.panels)
		}
		return allPanels
	}
	
	def getAllPanelsInOr(Panel panel) {
		var allPanels = new ArrayList<Panel>()
		var ors =panel.ORSuccessors
		var edges = panel.outgoingPanelToConstraints
		for(edge : edges){
			var field = edge.targetElement
			var ors2 = field.ORSuccessors
			for(or : ors2){
				allPanels.addAll(or.panels)
			}
		}
		for(or : ors){
			allPanels.addAll(or.panels)
		}
		return allPanels
	}
	def boolean panelHasXORSuccesor(Panel panel){
		if(!panel.XORSuccessors.isNullOrEmpty){
			return true
		}else if(!panel.outgoingPanelToConstraints.isNullOrEmpty){
			var constraintEdges = panel.outgoingPanelToConstraints
			for(edge : constraintEdges){
				var fieldConstraint = edge.targetElement 
				if(fieldConstraint.XORSuccessors.isNullOrEmpty){
					return false
				}else{
					return true
				}
			}
		}
		else{
			return false;
		}
	}
	
	def boolean panelHasORSuccesor(Panel panel){
		if(!panel.ORSuccessors.isNullOrEmpty){
			return true
		}else if(!panel.outgoingPanelToConstraints.isNullOrEmpty){
			var constraintEdges = panel.outgoingPanelToConstraints
			for(edge : constraintEdges){
				var fieldConstraint = edge.targetElement 
				if(fieldConstraint.ORSuccessors.isNullOrEmpty){
					return false
				}else{
					return true
				}
			}
		}
		else{
			return false;
		}
	}
	
	def getAllPanelsInAnd(Panel panel) {
		var allPanels = new ArrayList<Panel>()
		var ands =panel.ANDSuccessors
		var edges = panel.outgoingPanelToConstraints
		for( edge : edges){
			var field = edge.targetElement
			var ands2 = field.ANDSuccessors
			for(and : ands2){
			allPanels.addAll(and.panels)
		}
		}
		for(and : ands){
			allPanels.addAll(and.panels)
		}
		return allPanels
	}
	
	def boolean panelHasANDSuccesor(Panel panel){
		if(!panel.ANDSuccessors.isNullOrEmpty){
			return true
		}else if(!panel.outgoingPanelToConstraints.isNullOrEmpty){
			var constraintEdges = panel.outgoingPanelToConstraints
			for(edge : constraintEdges){
				var fieldConstraint = edge.targetElement 
				if(fieldConstraint.ANDSuccessors.isNullOrEmpty){
					return false
				}else{
					return true
				}
			}
		}
		else{
			return false;
		}
	}
	
	def generateComparision(FieldConstraint target) {
			switch target {
				TextFieldConstraint : return '''«target.generateOperatorValue»'''
				NumberFieldConstraint : return '''«target.generateOperatorValue»'''
				CheckBoxFieldConstraint :return '''== «target.value»'''
			}
	}
	
	def dispatch generateOperatorValue(TextFieldConstraint constraint){
		switch (constraint.operator.getName) {
			case "equal": return '''== "«constraint.value»"'''
			case "contains": return '''.contains("«constraint.value»")'''
			case "notEqual": return '''!= "«constraint.value»"'''
		}
	}
	
	def dispatch generateOperatorValue(NumberFieldConstraint constraint){
		switch (constraint.operator.getName) {
			case "lessEqual": return '''<= «constraint.value»'''
			case "less": return '''< «constraint.value»'''
			case "greater": return '''> «constraint.value»'''
			case "greaterEqual": return '''>= «constraint.value»'''
			case "equal" : return '''== «constraint.value»'''
			case "notEqual" : return '''!= «constraint.value»'''
		}
	}
	
	def dispatch generateOperatorValue(DateFieldConstraint constraint){
		switch (constraint.operator.getName) {
			case "same": return '''.isAtSameMomentAs(DateTime.parse("«constraint.createDateFormat»"))'''
			case "before": return '''.isBefore(DateTime.parse("«constraint.createDateFormat»"))'''
			case "after": return '''.isAfter(DateTime.parse("«constraint.createDateFormat»"))'''
		}
	}
	
	def createDateFormat(DateFieldConstraint constraint){
		if(!(constraint.date_day.isNullOrEmpty || constraint.date_year.isNullOrEmpty || constraint.date_month.isNullOrEmpty)){
			return '''«constraint.date_year»-«constraint.date_month.toDigit»-«constraint.date_day.escapeZero»'''
		}
	}
	
	
	def dispatch generateOperatorValue(ChoiceFieldConstraint constraint){
	switch (constraint.operator.getName) {
			case "equal": return ''' == compare'''
			case "in": return '''.containsAll(compare)'''
			case "notIn": return '''.containsAll(compare)'''
		}
	}
	
	
	def getFieldConstraintLabel(FieldConstraint target) {
			switch target {
				TextFieldConstraint : return '''«(target.field as TextField).escape»'''
				NumberFieldConstraint : return '''«(target.field as NumberField).escape»'''
				CheckBoxFieldConstraint : return '''«(target.field as CheckBoxField).escape»'''
				ChoiceFieldConstraint : return '''«(target.field as ChoiceField).escape»'''
				DateFieldConstraint : return '''«(target.field as DateField).escape»'''
			}
	}
	
	//------------help methods----------
	
	def  findFirstPanel(Dependency dep) {
		for(and : dep.ANDs){
			if(and.incoming.isEmpty){
				return and
			}
		}
		for(or : dep.ORs){
			if(or.incoming.isEmpty){
				return or
			}
		}
		for(xor : dep.XORs){
			if(xor.incoming.isEmpty){
				return xor
			}
		}
		for(panel : dep.panels){
			if(panel.incoming.isEmpty){
				return panel
			}
		}
	}
	
	def ArrayList<Panel> findLastPanel(Dependency dep){
		var lastElements = new ArrayList
		for(and : dep.ANDs){
			if(and.outgoing.isEmpty){
				lastElements.addAll(and.panels)
			}
		}
		for(or : dep.ORs){
			if(or.outgoing.isEmpty){
				lastElements.addAll(or.panels)
			}
		}
		for(xor : dep.XORs){
			if(xor.outgoing.isEmpty){
				lastElements.addAll(xor.panels)
			}
		}
		for(panel : dep.panels){
			if(panel.outgoing.isEmpty){
				lastElements.add(panel)
			}
		}
		return lastElements
	}
	
	
	def panelIsInAnd(Panel panel) {
		if(panel.container instanceof AND){
			return true
		}
		else{
			return false
		}
	}
	
	
	def panelIsInOr(Panel panel) {
		if(panel.container instanceof OR){
			return true
		}
		else{
			return false
		}
	}
	
	def panelIsInXOR(Panel panel) {
		if(panel.container instanceof XOR){
			return true
		}
		else{
			return false
		}
	}
	
}
