package info.scce.cinco.product.documentproject.dependency.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.dependency.dependency.ChoiceFieldConstraint

class ChoiceFieldConstraint_OpenModel extends CincoCustomAction<ChoiceFieldConstraint>{
	
	override execute(ChoiceFieldConstraint field) {
		field.field.openEditor
	}
	
}