package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.constraint.constraint.ChoiceFieldConstraint

class ChoiceFieldConstraint_OpenModel extends CincoCustomAction<ChoiceFieldConstraint>{
	
	override execute(ChoiceFieldConstraint field) {
		field.fieldConstraint.openEditor
	}
	
}