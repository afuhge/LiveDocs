package info.scce.cinco.product.documentproject.dependency.checks

import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.FieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint
import info.scce.cinco.product.documentproject.dependency.mcam.modules.checks.DependencyCheck
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.ArrayList

class ELSECheck extends DependencyCheck{
	protected extension Helper = new Helper
	
	override check(Dependency dep) {
		for (currentPanel : dep.allPanels) {
		checkIfandElseDefined(currentPanel)
		checkDuplicatedConstraintFields(currentPanel)
		checkFullIfStatements(currentPanel)
		}
	}
	
	def checkFullIfStatements(Panel panel) {
		//TODO: volle ifs checken: if(amount <10) if(ammount >100)  lücke zwischen 10 und 100 checken
	}
	
	def checkDuplicatedConstraintFields(Panel panel) {
		for (var i = 0; i < panel.allFieldConstraints.length - 1; i++) {
			for (var j = i + 1; j < panel.allFieldConstraints.length; j++) {
				var first = panel.allFieldConstraints.get(i);
				var second = panel.allFieldConstraints.get(j);
				if (first.label.equals(second.label) && first.value.equals(second.value) &&
					first.operator.equals(second.operator)) {
					addError(panel, '''Panel '«panel.name»' has duplicated constraints.''')
				}
			}
		}
	}
	
	def value(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint : return (constraint as TextFieldConstraint).value
			NumberFieldConstraint : return (constraint as NumberFieldConstraint).value
			CheckBoxFieldConstraint : return (constraint as CheckBoxFieldConstraint).value
			ChoiceFieldConstraint : return (constraint as ChoiceFieldConstraint).value
			DateFieldConstraint : return (constraint as DateFieldConstraint).dateValue
		}
	}
	
	def operator(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint : return (constraint as TextFieldConstraint).operator
			NumberFieldConstraint : return (constraint as NumberFieldConstraint).operator
			CheckBoxFieldConstraint : return (constraint as CheckBoxFieldConstraint).operator
			ChoiceFieldConstraint : return (constraint as ChoiceFieldConstraint).operator
			DateFieldConstraint : return (constraint as DateFieldConstraint).operator
		}
	}
	
	def dateValue(DateFieldConstraint constraint){
		return '''«constraint.date_day».«constraint.date_month».«constraint.date_year»'''
	}
	
	def checkIfandElseDefined(Panel panel) {
		if(!panel.outgoingElses.isNullOrEmpty && panel.outgoingPanelToConstraints.isNullOrEmpty){
			addError(panel, '''For the panel '«panel.name»' an else path is defined, but a constraint is missing.''')
		}
	}
	
	
	def getAllFieldConstraints(Panel currentPanel) {
		var allFieldConstraint = new ArrayList();
		for (edge : currentPanel.outgoingPanelToConstraints) {
			if (edge.targetElement instanceof FieldConstraint) {
				allFieldConstraint.add(edge.targetElement as FieldConstraint)
			}
		}
		return allFieldConstraint
	}
	
}