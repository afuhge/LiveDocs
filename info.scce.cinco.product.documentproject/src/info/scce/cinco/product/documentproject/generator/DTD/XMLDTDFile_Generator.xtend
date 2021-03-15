package info.scce.cinco.product.documentproject.generator.DTD

import graphmodel.Node
import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.documents.documents.Document
import info.scce.cinco.product.documentproject.generator.DTD_Helper
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.ArrayList

class XMLDTDFile_Generator {
	
	protected static extension DTD_Helper = new DTD_Helper
	protected static extension Helper = new Helper
	
	def generate(Document doc)'''
	<?xml version="1.0" encoding="UTF-8"?>
	«generateDocumentTypDeclaration(doc)»
	«generateDTD(doc)»
	]>
	«generateTransformedXML(doc)»
	'''
	
	def generateTransformedXML(Document document) '''
	<!--transformed dom code below-->
	'''
	
	//	TODO: dependency verschachtelung
	def generateDTD(Document doc)'''
	«generateRootElement(doc)»
	«FOR node : doc.getAllElements»
	«generateDTDElement(node)»
	«ENDFOR»
	«IF elementHasField(doc.panels)»
	«generateFieldElement()»
	«ENDIF»
	«IF !(doc.dependency as Dependency).fieldConstraints.isNullOrEmpty»
	«generateATTLISTCondition(doc)»
	«ENDIF»
	'''
	
	def generateRootElement(Document doc) '''<!ELEMENT «(doc.dependency as Dependency).escape.toLowerCase.replace("_","-")» («findFirstPanel(doc.dependency as Dependency).elementName»)>'''
	
	def generateATTLISTCondition(Document doc) '''
	«FOR node : doc.nodesWithPreCondition»
	<!ATTLIST «node.elementName»
		preCondition CDATA #REQUIRED>
	«ENDFOR»
	'''
	
	def generateFieldElement() '''
	<!ELEMENT field (input, label)>
	<!ELEMENT input EMPTY >
	<!ATTLIST input
		id CDATA #REQUIRED
		type CDATA #REQUIRED 
		value CDATA #REQUIRED>
	<!ELEMENT label (#PCDATA) >
	'''
	
	def generateDTDElement(Node node)'''<!ELEMENT «node.elementName» «generateChildrens(node)»>'''
	
	def generateChildrens(Node node)'''«IF generateChilds(node).length != 0»«generateChilds(node)»«ELSE»EMPTY«ENDIF»'''
		
	def  generateChilds(Node container) {
		switch(container){
			XOR: computeChilds(container as XOR)
			OR: computeChilds(container as OR)
			AND : computeChilds(container as AND)
			Panel: computeChilds(container as Panel)	
		}
	}
	
	def dispatch computeChilds(Panel panel){
		return '''«IF generateField(panel).length != 0»(«generateField(panel)»«IF !(panel.generateElse.isNullOrEmpty)»,«generateElses(panel)»«IF generateSimpleChilds(panel).length != 0»,«generateSimpleChilds(panel)»)«ELSE»«generateSimpleChilds(panel)»)«ENDIF»«ELSE»«IF generateSimpleChilds(panel).length != 0»,«generateSimpleChilds(panel)»)«ELSE»)«ENDIF»«ENDIF»«ELSE»«IF !(panel.generateElse.isNullOrEmpty)»(«generateElses(panel)»«IF generateSimpleChilds(panel).length != 0»,«generateSimpleChilds(panel)»)«ELSE»)«ENDIF»«ELSE»«IF generateSimpleChilds(panel).length != 0»(«generateSimpleChilds(panel)»)«ENDIF»«ENDIF»«ENDIF»'''
	}
	
	def dispatch computeChilds(AND and){
		return '''«generateSimpleChilds(and)»'''
			
	}
	
	def dispatch computeChilds(OR or){
		return '''«generateSimpleChilds(or)»'''
	}
	
	def dispatch computeChilds(XOR xor){
		return '''«generateSimpleChilds(xor)»'''
	}
	
	
	
	
}