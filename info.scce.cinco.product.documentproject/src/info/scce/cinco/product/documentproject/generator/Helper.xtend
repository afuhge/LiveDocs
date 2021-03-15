package info.scce.cinco.product.documentproject.generator

import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.XOR
import info.scce.cinco.product.documentproject.documents.documents.Document
import info.scce.cinco.product.documentproject.documents.documents.Documents
import info.scce.cinco.product.documentproject.documents.documents.Role
import info.scce.cinco.product.documentproject.template.template.CheckBoxField
import info.scce.cinco.product.documentproject.template.template.ChoiceField
import info.scce.cinco.product.documentproject.template.template.DateField
import info.scce.cinco.product.documentproject.template.template.Field
import info.scce.cinco.product.documentproject.template.template.NumberField
import info.scce.cinco.product.documentproject.template.template.Panel
import info.scce.cinco.product.documentproject.template.template.Template
import info.scce.cinco.product.documentproject.template.template.TextField
import java.util.ArrayList
import java.util.List
import java.util.stream.Collectors
import org.eclipse.emf.common.util.EList
import graphmodel.Node
import info.scce.cinco.product.documentproject.dependency.dependency.OR
import info.scce.cinco.product.documentproject.dependency.dependency.AND
import info.scce.cinco.product.documentproject.constraint.constraint.Constraint

class Helper {
	static extension GraphModelExtension = new GraphModelExtension
	
	
	def generateInvertedCommas() {
		return "'''"
	}
	
	def concreteElement(Node node){
		switch(node){
			XOR: return node as XOR
			OR: return node as OR
			AND : return node as AND
			info.scce.cinco.product.documentproject.dependency.dependency.Panel: return (node as info.scce.cinco.product.documentproject.dependency.dependency.Panel)
		}
	}
	
	def getTagName(Node node){
		switch(node){
			AND: '''and«(node as AND).id.toLowerCase.replace("_","-")»'''
			XOR:'''xor-«(node as XOR).id.toLowerCase.replace("_","-")»'''
			OR:'''or«(node as OR).id.toLowerCase.replace("_","-")»'''
			Panel : '''«(node as Panel).escape.toLowerCase.replace("_","-")»'''
		}
	}

	def generateSetPreCondition(info.scce.cinco.product.documentproject.dependency.dependency.Panel panel) {
		var preCondition = ""
		if(panel.container instanceof Dependency){
			for(edge : panel.incomingMusts){
				if(edge.sourceElement instanceof FieldConstraint){
					var constraint = edge.sourceElement as FieldConstraint
					var label = constraint.label
					var operator = constraint.operator
					var value = constraint.value
					preCondition +='''«label»_«operator»_«value»'''
				}
			}
			if(!panel.incomingElses.isNullOrEmpty){
				preCondition += "ELSE"
			}
		}
		else if(panel.container instanceof AND){
			var and = panel.container as AND
			for(edge : and.incomingMusts){
				if(edge.sourceElement instanceof FieldConstraint){
					var constraint = edge.sourceElement as FieldConstraint
					var label = constraint.label
					var operator = constraint.operator
					var value = constraint.value
					preCondition +='''«label»_«operator»_«value»'''
				}
			}
			if(!and.incomingElses.isNullOrEmpty){
				preCondition += "ELSE"
			}
		}else if(panel.container instanceof OR){
			var or = panel.container as OR
			for(edge : or.incomingMusts){
				if(edge.sourceElement instanceof FieldConstraint){
					var constraint = edge.sourceElement as FieldConstraint
					var label = constraint.label
					var operator = constraint.operator
					var value = constraint.value
					preCondition +='''«label»_«operator»_«value»'''
				}
			}
			if(!or.incomingElses.isNullOrEmpty){
				preCondition += "ELSE"
			}
		}
		
		return '''panel.preCondition = "«preCondition»";'''
	}
	
	def generateSetPreCondition(XOR panel) {
		var preCondition = ""
		for(edge : panel.incomingMusts){
			if(edge.sourceElement instanceof FieldConstraint){
				var constraint = edge.sourceElement as FieldConstraint
				var label = constraint.label
				var operator = constraint.operator
				var value = constraint.value
				preCondition +='''«label»_«operator»_«value»'''
			}
		}
		if(!panel.incomingElses.isNullOrEmpty){
			preCondition += "ELSE"
		}
		return '''panel.preCondition = "«preCondition»";'''
	}
	
	def value(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint:  return '''«(constraint as TextFieldConstraint).value»'''
			NumberFieldConstraint:  return '''«(constraint as NumberFieldConstraint).value»'''
			DateFieldConstraint:  return '''«(constraint as DateFieldConstraint).createDateFormat»'''
			CheckBoxFieldConstraint: return '''«(constraint as CheckBoxFieldConstraint).value»'''
			ChoiceFieldConstraint: return '''«(constraint as ChoiceFieldConstraint).value»'''
		}
	}
	
	def createDateFormat(DateFieldConstraint constraint){
		if(!(constraint.date_day.isNullOrEmpty || constraint.date_year.isNullOrEmpty || constraint.date_month.isNullOrEmpty)){
			return '''«constraint.date_year»-«constraint.date_month.toDigit»-«constraint.date_day.escapeZero»'''
		}
	}
	
	def operator(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint:  return '''«(constraint as TextFieldConstraint).operator.getName»'''
			NumberFieldConstraint:  return '''«(constraint as NumberFieldConstraint).operator.getName»'''
			DateFieldConstraint:  return '''«(constraint as DateFieldConstraint).operator.getName»'''
			CheckBoxFieldConstraint: return '''=='''
			ChoiceFieldConstraint: return '''«(constraint as ChoiceFieldConstraint).operator.getName»'''
		}
	}
	
	def Panel tmplPanel(info.scce.cinco.product.documentproject.dependency.dependency.Panel panel){
		return (panel.panel as Panel)
	}

	def dispatch escape(Dependency dep) {
		return '''«dep.name.escapeLabel.toFirstUpper»_«dep.id.replace("_", "").replace("-","")»'''
	}

	def dispatch escape(Role role) {
		return '''«role.name.escapeLabel.toFirstUpper»_«role.id.replace("_", "").replace("-","")»'''
	}

	def dispatch escape(Panel panel) {
		return '''«panel.name.escapeLabel.toFirstUpper»_«panel.id.replace("_", "").replace("-","")»'''
	}
	
	def dispatch escape(info.scce.cinco.product.documentproject.dependency.dependency.Panel panel) {
		return '''«panel.name.escapeLabel.toFirstUpper»_«panel.id.replace("_", "").replace("-","")»'''
	}
	
	
	
	def dispatch escape(XOR xor){
		return '''xor_«xor.id.replace("_", "").replace("-","")»'''
	}
	
	def dispatch escape(Field field) {
		return '''user_«field.label.escapeLabel»'''
	}
	
	def dispatch escape(FieldConstraint field) {
		return '''FIELDCONSTRAINT«field.id.toUpperCase.replace("_","-")»'''
	}
	
	def dispatch escapeLabel(String label){
		return label.replaceAll("\\s+","").replaceAll("[-+.^:,?€%&/()=_']","").toFirstLower
	}

	def dispatch escape(Document doc) {
		return '''Document_«(doc.dependency as Dependency).name.escapeLabel.toFirstUpper»_«(doc.dependency as Dependency).id.replace("_", "").replace("-","")»'''
	}

	def getAllDependencyNodes(Documents doc) {
		var depTmpl = doc.findDeeply(info.scce.cinco.product.documentproject.template.template.Dependency) [
			switch it {
				Document: dependency as Dependency
				info.scce.cinco.product.documentproject.dependency.dependency.Panel: (panel as Panel).
					rootElement as Template
			}
		]
		var deps = new ArrayList<Dependency>();
		for (dep : depTmpl) {
			deps.add(dep.dependency)
		}
		var uniques = deps.stream().distinct().collect(Collectors.toList());
		return uniques;
	}

	def getAllPanels(Dependency dep) {
		return dep.findDeeply(info.scce.cinco.product.documentproject.dependency.dependency.Panel) [
			switch it {
			}
		]
	}

	def getAllFieldConstraints(Constraint dep){
		return dep.findDeeply(info.scce.cinco.product.documentproject.constraint.constraint.FieldConstraint)[
			switch it{}
		]
	}
	
	def getAllPanels(Constraint con) {
		return con.findDeeply(info.scce.cinco.product.documentproject.constraint.constraint.Panel) [
			switch it {
			}
		]
	}
	

	def List<info.scce.cinco.product.documentproject.dependency.dependency.Panel> panels(Document doc) {
		var allPanels = new ArrayList();
		var dep = doc.dependency as Dependency
		allPanels.addAll(dep.allPanels)
		
		var panels = allPanels.stream().distinct().collect(Collectors.toList());
		return panels;
	}
	
	
	def List<info.scce.cinco.product.documentproject.dependency.dependency.Panel> panels(Documents docs) {
		var allPanels = new ArrayList();
		for (doc : docs.documents) {
			var dep = (doc.dependency as Dependency);
			allPanels.addAll(dep.allPanels)
		}
		var panels = allPanels.stream().distinct().collect(Collectors.toList());
		return panels;
	}
	
	def List<XOR> XORs(Documents docs) {
		var allXORs = new ArrayList();
		for (doc : docs.documents) {
			var dep = (doc.dependency as Dependency);
			allXORs.addAll(dep.XORs)
		}
		var xors = allXORs.stream().distinct().collect(Collectors.toList());
		return xors;
	}

	def String type(Field field) {
		switch (field) {
			TextField: return "String"
			NumberField: return "num"
			DateField: return "DateTime"
			CheckBoxField: return "bool"
			ChoiceField: return "String"
		}
	}

	def generatePanelImports(List<info.scce.cinco.product.documentproject.dependency.dependency.Panel> panels) '''
		«FOR panel : panels»
			import 'package:generated_webapp/src/«panel.escape.toFirstLower»_component/«panel.escape.toFirstLower»_component.dart';
		«ENDFOR»
	'''
	def generateXORImports(List<XOR> xors) '''
		«FOR xor : xors»
			import 'package:generated_webapp/src/XOR«xor.id»_component/XOR«xor.id»_component.dart';
		«ENDFOR»
	'''


	def generatePanelComponentDirectives(List<info.scce.cinco.product.documentproject.dependency.dependency.Panel> panels) '''
		«FOR panel : panels SEPARATOR ","»«panel.escape»Component«ENDFOR»
	'''
	
	def generateXORPanelComponentDirectives(List<XOR> xors) '''
		«FOR xor : xors SEPARATOR "," AFTER ","» XOR«xor.id.replace("_", "").replace("-","")»_panel_Component«ENDFOR»
	'''

	def getAllDependencies(Documents docs) {
		var all = docs.allDependencyNodes
		for (dep : getDocsDep(docs)) {
			if (!all.contains(dep)) {
				all.add(dep)
			}
		}
		return all
	}

	def getDocsDep(Documents docs) {
		var deps = new ArrayList<Dependency>()
		for (doc : docs.documents) {
			deps.add(doc.dependency as Dependency)
		}
		return deps
	}
	
	def generateFromJsonFields(EList<Field> fields)'''
	«FOR field : fields.toList»
	«IF field instanceof DateField»
	if(json.containsKey('«field.escape»') && json['«field.escape»'] != null) {
		«field.escape» = DateTime.parse(json['«field.escape»']);
	}
	«ELSE»
	«field.escape» = json['«field.escape»'];
	«ENDIF»
	«ENDFOR»
	'''
	
	def generateFieldVariables(info.scce.cinco.product.documentproject.dependency.dependency.Panel panel)'''
	«FOR field : panel.tmplPanel.fields»
	«IF field instanceof DateField»
	«field.type» «field.escape» = DateTime.now();
	«ENDIF»
	«IF field instanceof ChoiceField»
	«field.type» «field.escape» = "«(field as ChoiceField).firstContent»";
	«ENDIF»
	«IF field instanceof CheckBoxField»
	«field.type» «field.escape» = false;
	«ENDIF»
	«IF field instanceof TextField»
	«field.type» «field.escape» = "";
	«ENDIF»
	«IF field instanceof NumberField»
	«field.type» «field.escape» = 0;
	«ENDIF»
	«ENDFOR»
					 
	«FOR dep : panel.tmplPanel.dependencys»
	«(dep.dependency as Dependency).escape» _«(dep.dependency as Dependency).escape.toFirstLower»;
	«ENDFOR»
	'''
	
	def getFirstContent(ChoiceField field){
		if(field.content.isNullOrEmpty){
			return '''null''';
		}else {
			return '''«field.content.get(0)»'''
			
		}
	}
	
	def generateFields(EList<Field> fields) '''
	«FOR field : fields.toList»
	json["«field.escape»"] = «field.escape» == null ? null : «field.escape»«IF field instanceof DateField».toIso8601String()«ENDIF»;
	«ENDFOR»
	'''
	
	def generateDependencies(EList<info.scce.cinco.product.documentproject.template.template.Dependency> deps)'''
	«FOR dep : deps.toList »
	json["_«dep.dependency.escape.toFirstLower»"] =  _«dep.dependency.escape.toFirstLower» == null ? null : _«dep.dependency.escape.toFirstLower».toJson(cache);
	«ENDFOR»
	'''
	

	def escapeZero(String day) {
		if(!day.isNullOrEmpty){
			var digit = Integer.parseInt(day)
			if(digit < 10){
				return '''0«digit»'''
			}else{
				return '''«digit»'''
			}
		}
	}
	
	def getToDigit(String month) {
		switch(month){
			case "January": return '''01'''
			case "February": return '''02'''
			case  "March": return '''03'''
			case "April": return '''04'''
			case  "May": return '''05'''
			case "June": return '''06'''
			case "July": return '''07'''
			case "August": return '''08'''
			case "September": return '''09'''
			case "October": return '''10'''
			case "November": return '''11'''
			case "December":return '''12'''
		}
	}
}
