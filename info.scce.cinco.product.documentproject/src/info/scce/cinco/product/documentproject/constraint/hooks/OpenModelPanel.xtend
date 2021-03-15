package info.scce.cinco.product.documentproject.constraint.hooks

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.constraint.constraint.Panel

class OpenModelPanel extends CincoCustomAction<Panel>{
	
	override execute(Panel panel) {
		panel.panel.openEditor
	}
	
}