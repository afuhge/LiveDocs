package info.scce.cinco.product.documentproject.dependency.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.dependency.dependency.CheckBoxFieldConstraint

class CheckBoxFieldConstraint_OpenModel extends CincoCustomAction<CheckBoxFieldConstraint>{
	
	override execute(CheckBoxFieldConstraint field) {
		field.field.openEditor
	}
	
}