package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.constraint.constraint.TextFieldConstraint

class TextFieldConstraint_OpenModel extends CincoCustomAction<TextFieldConstraint>{
	
	override execute(TextFieldConstraint field) {
		field.fieldConstraint.openEditor
	}
	
}