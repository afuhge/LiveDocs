package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.constraint.constraint.CheckBoxFieldConstraint

class CheckFieldConstraint_OpenModel extends CincoCustomAction<CheckBoxFieldConstraint>{
	
	override execute(CheckBoxFieldConstraint field) {
		field.fieldConstraint.openEditor
	}
	
}