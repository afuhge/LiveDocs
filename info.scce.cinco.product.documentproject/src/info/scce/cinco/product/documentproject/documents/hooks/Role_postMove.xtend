package info.scce.cinco.product.documentproject.documents.hooks

import de.jabc.cinco.meta.runtime.hook.CincoPostMoveHook
import info.scce.cinco.product.documentproject.documents.documents.Role
import graphmodel.ModelElementContainer

class Role_postMove extends CincoPostMoveHook<Role> {
	
	override postMove(Role role, ModelElementContainer arg1, ModelElementContainer arg2, int arg3, int arg4, int arg5, int arg6) {
		if(role.iconRef !== null) {
			var x = role.x + role.width -5
			var y = role.y
			role.iconRef.x = x
			role.iconRef.y = y
		}
	}
	
}