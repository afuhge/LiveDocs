package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.constraint.constraint.DateFieldConstraint

class DateFieldConstraint_OpenModel  extends CincoCustomAction<DateFieldConstraint>{
	
	override execute(DateFieldConstraint field) {
		field.fieldConstraint.openEditor
	}
	
}