package info.scce.cinco.product.documentproject.dependency.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.dependency.dependency.Panel

class DoubleClick_OpenModel extends CincoCustomAction<Panel>{
	
	override execute(Panel pan) {
		pan.panel.openEditor
	}
	
}