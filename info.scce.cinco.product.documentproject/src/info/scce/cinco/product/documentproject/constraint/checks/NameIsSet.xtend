package info.scce.cinco.product.documentproject.constraint.checks

import info.scce.cinco.product.documentproject.constraint.mcam.modules.checks.ConstraintCheck
import info.scce.cinco.product.documentproject.constraint.constraint.Constraint

class NameIsSet extends ConstraintCheck{
	
	override check(Constraint model) {
		if(model.name.isNullOrEmpty){
			addError(model, "Model name should not be empty.")
		}
	}
	
}