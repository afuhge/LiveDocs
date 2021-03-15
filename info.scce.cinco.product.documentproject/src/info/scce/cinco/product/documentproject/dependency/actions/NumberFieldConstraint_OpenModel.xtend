package info.scce.cinco.product.documentproject.dependency.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.dependency.dependency.NumberFieldConstraint

class NumberFieldConstraint_OpenModel  extends CincoCustomAction<NumberFieldConstraint>{
	
	override execute(NumberFieldConstraint field) {
		field.field.openEditor
	}
	
}