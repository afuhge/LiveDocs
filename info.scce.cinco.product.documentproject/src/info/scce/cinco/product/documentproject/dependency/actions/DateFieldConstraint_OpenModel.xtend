package info.scce.cinco.product.documentproject.dependency.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.dependency.dependency.DateFieldConstraint

class DateFieldConstraint_OpenModel extends CincoCustomAction<DateFieldConstraint>{
	
	override execute(DateFieldConstraint field) {
		field.field.openEditor
	}
	
}