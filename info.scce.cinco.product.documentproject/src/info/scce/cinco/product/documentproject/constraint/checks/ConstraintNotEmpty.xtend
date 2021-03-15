package info.scce.cinco.product.documentproject.constraint.checks

import info.scce.cinco.product.documentproject.constraint.mcam.modules.checks.ConstraintCheck
import info.scce.cinco.product.documentproject.constraint.constraint.Constraint

class ConstraintNotEmpty extends ConstraintCheck{
	
	override check(Constraint model) {
		var patterns =  model.premises
		patterns.forEach[pattern | {
			if(pattern.panels.isNullOrEmpty && pattern.fieldConstraints.isNullOrEmpty){
				addError(pattern, '''Premise should not be empty. Please add a panel or a fieldConstraint.''')
			}
		}]
		var conlusions =  model.conclusions
		conlusions.forEach[pattern | {
			if(pattern.panels.isNullOrEmpty && pattern.fieldConstraints.isNullOrEmpty){
				addError(pattern, '''Conclusion should not be empty. Please add a panel or a fieldConstraint.''')
			}
		}]
	}
	
}