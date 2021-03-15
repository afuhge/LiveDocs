package info.scce.cinco.product.documentproject.dependency.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.dependency.dependency.Constraints

class OpenModel extends CincoCustomAction<Constraints>{
	
	override execute(Constraints con) {
		con.constraint.openEditor
	}
	
}