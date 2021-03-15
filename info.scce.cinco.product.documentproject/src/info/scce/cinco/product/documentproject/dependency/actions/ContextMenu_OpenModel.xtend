package info.scce.cinco.product.documentproject.dependency.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.dependency.dependency.Panel

class ContextMenu_OpenModel extends CincoCustomAction<Panel> {
	/**
	 * Open corresponding template model to the template node in the dependency model
	 */
	override execute(Panel pan) {
		pan.panel.openEditor
	}
	
	override getName() {
		"Open corresponding Dependency model"
	}
	
	
}