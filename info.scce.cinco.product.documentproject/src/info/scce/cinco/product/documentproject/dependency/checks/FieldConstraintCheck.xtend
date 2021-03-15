package info.scce.cinco.product.documentproject.dependency.checks

import info.scce.cinco.product.documentproject.dependency.mcam.modules.checks.DependencyCheck
import info.scce.cinco.product.documentproject.dependency.dependency.Dependency
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint
import info.scce.cinco.product.documentproject.template.template.ChoiceField

class FieldConstraintCheck extends DependencyCheck {
	
	override check(Dependency model) {
		for(fieldConstraint : model.fieldConstraints){
			if(fieldConstraint instanceof ChoiceFieldConstraint){
				var choice = fieldConstraint as ChoiceFieldConstraint
				if(choice.value.isNullOrEmpty){
					addError(choice, '''The value of ChoiceFieldConstraint '«(fieldConstraint.field as ChoiceField).label»' should not be empty. ''')
				}
			}
		}
	}
	
}