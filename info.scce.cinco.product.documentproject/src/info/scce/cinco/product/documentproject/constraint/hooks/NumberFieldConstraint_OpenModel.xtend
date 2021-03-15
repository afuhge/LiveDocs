package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.constraint.constraint.NumberFieldConstraint

class NumberFieldConstraint_OpenModel  extends CincoCustomAction<NumberFieldConstraint>{
	
	override execute(NumberFieldConstraint field) {
		field.fieldConstraint.openEditor
	}
	
}