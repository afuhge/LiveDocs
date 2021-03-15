package info.scce.cinco.product.documentproject.dependency.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.dependency.dependency.TextFieldConstraint

class TextFieldConstraint_OpenModel extends CincoCustomAction<TextFieldConstraint>{
	
	override execute(TextFieldConstraint field) {
		field.field.openEditor
	}
	
}