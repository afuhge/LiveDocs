package info.scce.cinco.product.documentproject.template.actions

import de.jabc.cinco.meta.runtime.action.CincoCustomAction
import info.scce.cinco.product.documentproject.template.template.Role

class ContextMenu_OpenRoleModel extends CincoCustomAction<Role>{
	
	
	override execute(Role role) {
		role.role.openEditor
	}
	
	override getName() {
		"Open corresponding Roles model"
	}
}