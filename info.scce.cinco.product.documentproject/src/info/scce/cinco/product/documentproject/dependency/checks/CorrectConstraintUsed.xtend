package info.scce.cinco.product.documentproject.dependency.checks

import info.scce.cinco.product.documentproject.constraint.constraint.CheckBoxFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.DateFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.FieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.NumberFieldConstraint
import info.scce.cinco.product.documentproject.constraint.constraint.TextFieldConstraint
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.Panel
import info.scce.cinco.product.documentproject.dependency.mcam.modules.checks.DependencyCheck
import info.scce.cinco.product.documentproject.generator.Helper
import java.util.Collections

class CorrectConstraintUsed extends DependencyCheck{
	protected extension Helper = new Helper()
	override check(Dependency dep) {
		if(!dep.constraintss.isNullOrEmpty){
			var constraintModel = dep.constraintss.get(0).constraint
			var depPanels = dep.allPanels.map[id].toList
			var constraintPanels = constraintModel.allPanels.map[(panel as Panel).id].toList
			Collections.sort(depPanels);
	    	Collections.sort(constraintPanels);      
			if(!depPanels.containsAll(constraintPanels)){
				addError(dep, '''Constraints mismatch: Constraints-DSL does not include panels of this model.''')
			}
			
			var depFields = dep.fieldConstraints.map[id].toList
			var constraintFields = constraintModel.getAllFieldConstraints.map[getFieldConstraintID].toList
			if (!depFields.containsAll(constraintFields)) {
				addError(
					dep, '''Constraints mismatch: Constraints-DSL does not include fieldConstraints of this model.''')
			}

			if (constraintModel.premises.isEmpty) {
				addError(
					dep, '''Constraints-DSL does not contain any constraints. Model checking of the web application will lead to errors.''')
			}
		} else {
			addInfo(dep, '''No Constraints-Node: Model Checking of this document is deactivated.''')
		}
	}
	
	def getFieldConstraintID(FieldConstraint constraint){
		switch(constraint){
			TextFieldConstraint:  return '''«((constraint as TextFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint).id»'''
			NumberFieldConstraint:  return '''«((constraint as NumberFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint).id»'''
			DateFieldConstraint:  return '''«((constraint as DateFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint).id»'''
			CheckBoxFieldConstraint: return '''«((constraint as CheckBoxFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint).id»'''
			ChoiceFieldConstraint: return '''«((constraint as ChoiceFieldConstraint).fieldConstraint as info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint).id»'''
		}
	}
	
	
	

	
}